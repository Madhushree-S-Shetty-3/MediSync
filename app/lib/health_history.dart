import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HealthHistory extends StatefulWidget {
  final String documentId;

  const HealthHistory({super.key, required this.documentId});

  @override
  _HealthHistoryState createState() => _HealthHistoryState();
}

class _HealthHistoryState extends State<HealthHistory> {
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    QuerySnapshot historySnapshot = await FirebaseFirestore.instance
        .collection('medisync')
        .doc(widget.documentId)
        .collection('history')
        .get();

    setState(() {
      history = historySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    });
  }

  Future<void> _addHistoryEntry(String title, String description) async {
    CollectionReference historyRef = FirebaseFirestore.instance
        .collection('medisync')
        .doc(widget.documentId)
        .collection('history');

    Map<String, dynamic> newEntry = {
      'title': title,
      'description': description,
    };

    await historyRef.add(newEntry);

    _fetchData();
  }

  Future<void> _updateHistoryEntry(
      String id, String title, String description) async {
    DocumentReference historyRef = FirebaseFirestore.instance
        .collection('medisync')
        .doc(widget.documentId)
        .collection('history')
        .doc(id);

    Map<String, dynamic> updatedEntry = {
      'title': title,
      'description': description,
    };

    await historyRef.update(updatedEntry);

    _fetchData();
  }

  Future<void> _deleteHistoryEntry(String id) async {
    DocumentReference historyRef = FirebaseFirestore.instance
        .collection('medisync')
        .doc(widget.documentId)
        .collection('history')
        .doc(id);

    await historyRef.delete();

    _fetchData();
  }

  void _showAddHistoryDialog(
      {String? id, String? currentTitle, String? currentDescription}) {
    final TextEditingController titleController =
        TextEditingController(text: currentTitle);
    final TextEditingController descriptionController =
        TextEditingController(text: currentDescription);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF13171E),
          title: const Text(
            'Add History',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter title',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Enter description',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ],
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
                final title = titleController.text;
                final description = descriptionController.text;
                if (title.isNotEmpty && description.isNotEmpty) {
                  if (id == null) {
                    _addHistoryEntry(title, description);
                  } else {
                    _updateHistoryEntry(id, title, description);
                  }
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter both title and description'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Save',
                  style: TextStyle(color: Color(0xFFB59CFF))),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> historyEntry) {
    return Container(
      width: 320,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF333435),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  historyEntry['title'] ?? 'No Title',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  historyEntry['description'] ?? 'No Description',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'edit') {
                _showAddHistoryDialog(
                  id: historyEntry['id'],
                  currentTitle: historyEntry['title'],
                  currentDescription: historyEntry['description'],
                );
              } else if (value == 'delete') {
                _deleteHistoryEntry(historyEntry['id']);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13171E),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: const Text(
          "Medical and Family History",
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
              const SizedBox(height: 15),
              if (history.isEmpty)
                const Center(
                  child: Text(
                    'No history entries yet.',
                    style: TextStyle(
                        color: Color.fromARGB(255, 209, 209, 209),
                        fontSize: 20,
                        fontWeight: FontWeight.w300),
                  ),
                ),
              if (history.isNotEmpty)
                Column(
                  children:
                      history.map((entry) => _buildHistoryCard(entry)).toList(),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          onPressed: () {
            _showAddHistoryDialog();
          },
          backgroundColor: Colors.grey,
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
