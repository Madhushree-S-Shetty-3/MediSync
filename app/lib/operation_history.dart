import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_page.dart'; // Ensure you have this import for navigation
import 'addUser.dart'; // Ensure you have this import for navigation

class OperationHistory extends StatefulWidget {
  final String documentId;

  const OperationHistory({Key? key, required this.documentId})
      : super(key: key);

  @override
  _OperationHistoryState createState() => _OperationHistoryState();
}

class _OperationHistoryState extends State<OperationHistory> {
  Map<String, dynamic> mainProfile = {};
  List<Map<String, dynamic>> subprofiles = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      DocumentSnapshot mainProfileSnapshot = await FirebaseFirestore.instance
          .collection('medisync')
          .doc(widget.documentId)
          .get();

      DocumentReference pcountRef = FirebaseFirestore.instance
          .collection('medisync')
          .doc(widget.documentId);

      DocumentSnapshot pcountSnapshot = await pcountRef.get();

      int pcount = pcountSnapshot.exists ? pcountSnapshot['pcount'] : 0;

      QuerySnapshot subprofilesSnapshot = await FirebaseFirestore.instance
          .collection('medisync')
          .where(FieldPath.documentId,
              isGreaterThanOrEqualTo: 'subprofile1${widget.documentId}')
          .where(FieldPath.documentId,
              isLessThanOrEqualTo: 'subprofile$pcount${widget.documentId}')
          .get();

      setState(() {
        if (mainProfileSnapshot.exists) {
          mainProfile = mainProfileSnapshot.data() as Map<String, dynamic>;
        }
        subprofiles = subprofilesSnapshot.docs.map((doc) {
          return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
        }).toList();
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _navigateToProfilePage(String profileId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          documentId: profileId,
        ),
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> profile, bool isMainProfile) {
    return GestureDetector(
      onTap: () {
        _navigateToProfilePage(profile['id']);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF333435),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          title: Text(
            profile['firstName'] ?? 'Unnamed Profile',
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            isMainProfile ? 'Main Profile' : 'Subprofile',
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: isMainProfile
              ? null
              : PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _confirmDeleteSubprofile(profile['id']);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete Subprofile'),
                      ),
                    ];
                  },
                ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteSubprofile(String profileId) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF13171E),
          title: const Text(
            'Delete Subprofile',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to delete this subprofile?',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _deleteSubprofile(profileId);
    }
  }

  Future<void> _deleteSubprofile(String profileId) async {
    await FirebaseFirestore.instance
        .collection('medisync')
        .doc(profileId)
        .delete();

    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13171E),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: const Text(
          "Existing Profiles",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (mainProfile.isNotEmpty) _buildProfileCard(mainProfile, true),
              const SizedBox(height: 20),
              const Text(
                'Subprofiles',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 10),
              if (subprofiles.isEmpty)
                const Center(
                  child: Text(
                    'No subprofiles yet.',
                    style: TextStyle(
                        color: Color.fromARGB(255, 170, 140, 255),
                        fontSize: 20,
                        fontWeight: FontWeight.w200),
                  ),
                ),
              if (subprofiles.isNotEmpty)
                Column(
                  children: subprofiles.map((profile) {
                    return _buildProfileCard(profile, false);
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          onPressed: () async {
            final newSubprofileId = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddUser(documentId: widget.documentId),
              ),
            );
            if (newSubprofileId != null) {
              _fetchData();
            }
          },
          backgroundColor: Colors.grey,
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
