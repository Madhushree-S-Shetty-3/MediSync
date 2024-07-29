import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile.dart'; // Import EditProfile page
import 'operation_history.dart'; // Import OperationHistory page
import 'health_history.dart'; // Import HealthHistory page
import 'home.dart';

class ProfilePage extends StatefulWidget {
  final String documentId;

  const ProfilePage({
    super.key,
    required this.documentId,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String firstName = '';
  String email = '';
  String bloodGroup = '';
  String height = '';
  String weight = '';
  List<String> vaccines = [];
  String imageUrl = ''; // Store the image URL

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('medisync')
          .doc(widget.documentId) // Use documentId directly
          .get();

      if (docSnapshot.exists) {
        setState(() {
          firstName = docSnapshot['firstName'] ?? '';
          email = docSnapshot['email'] ?? '';
          bloodGroup = docSnapshot['bloodGroup'] ?? '';
          height = docSnapshot['height'] ?? '';
          weight = docSnapshot['weight'] ?? '';
          vaccines = List<String>.from(docSnapshot['vaccines'] ?? []);
          imageUrl = docSnapshot['imageUrl'] ?? ''; // Fetch the image URL
        });
      } else {
        setState(() {
          firstName = '';
          email = '';
          bloodGroup = '';
          height = '';
          weight = '';
          vaccines = [];
          imageUrl = ''; // Reset if document does not exist
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        firstName = '';
        email = '';
        bloodGroup = '';
        height = '';
        weight = '';
        vaccines = [];
        imageUrl = ''; // Reset on error
      });
    }
  }

  Future<void> _addVaccine(String vaccine) async {
    setState(() {
      vaccines.add(vaccine);
    });

    await FirebaseFirestore.instance
        .collection('medisync')
        .doc(widget.documentId)
        .update({'vaccines': vaccines});
  }

  void _showAddVaccineDialog() {
    final TextEditingController vaccineController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF13171E),
          title: const Text(
            'Add Vaccine',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: vaccineController,
            decoration: const InputDecoration(
              hintText: 'Enter vaccine name',
              hintStyle: TextStyle(color: Colors.grey),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                _addVaccine(vaccineController.text);
                Navigator.of(context).pop();
              },
              child:
                  const Text('Add', style: TextStyle(color: Color(0xFFB59CFF))),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13171E),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 60,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Profile",
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditProfile(
                                      documentId: widget.documentId)),
                            );
                            _fetchData();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E3032),
                            padding: const EdgeInsets.all(8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                "Edit Profile",
                                style: TextStyle(
                                    color: Color(0xFFECFE72),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w300),
                              ),
                              SizedBox(width: 7),
                              Icon(
                                Icons.edit,
                                color: Color(0xFFECFE72),
                                size: 13,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF333435),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                firstName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700),
                              ),
                              Text(
                                email,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w200),
                              ),
                            ],
                          ),
                          imageUrl.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    imageUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.account_circle,
                                  size: 50,
                                  color: Colors.white,
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoCard("Blood Group", bloodGroup, ""),
                        _buildInfoCard("Height", height, "cm"),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildVaccinesCard("Vaccines Taken", vaccines,
                            height: 120),
                        _buildInfoCard("Weight", weight, "kg"),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Additional",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w200),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (widget.documentId.contains('subprofile')) {
                          // Fetch main document ID
                          FirebaseFirestore.instance
                              .collection('medisync')
                              .doc(widget.documentId)
                              .get()
                              .then((doc) {
                            if (doc.exists && doc['mainDocument'] != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfilePage(
                                    documentId: doc['mainDocument'],
                                  ),
                                ),
                              );
                            }
                          });
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OperationHistory(
                                documentId: widget.documentId,
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF333435),
                        padding: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _buildListCard(
                          widget.documentId.contains('subprofile')
                              ? "Return to Main Profile"
                              : "Add Profile"),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HealthHistory(
                                    documentId: widget.documentId,
                                  )),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF333435),
                        padding: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _buildListCard("Medical and Family History"),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Home(
                                    documentId: widget
                                        .documentId)), // Pass the documentId to Home page
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF333435),
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(0),
                        ),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF333435),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(
                            Icons.home_rounded,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, String unit) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.42,
      height: 90,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF333435),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$value $unit',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinesCard(String title, List<String> vaccines,
      {double height = 140}) {
    return Container(
      width: 150,
      height: height,
      padding: const EdgeInsets.only(left: 15, bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF333435),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w300),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add,
                  color: Color(0xFFB59CFF),
                  size: 20,
                ),
                onPressed: _showAddVaccineDialog,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: vaccines.length,
              itemBuilder: (context, index) {
                return Text(
                  vaccines[index],
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard(String title) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF333435),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
            size: 15,
          ),
        ],
      ),
    );
  }
}
