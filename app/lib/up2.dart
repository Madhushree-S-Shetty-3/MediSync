import 'package:flutter/material.dart';
import 'package:app/prescription.dart';

class Up2 extends StatelessWidget {
  final String documentId;

  const Up2({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13171D),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(51, 54, 58, 1),
        title: const TextField(
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: Colors.white),
            hintText: 'Search..',
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: IconButton(
                icon: const Icon(
                  Icons.account_circle,
                  color: Colors.white,
                  size: 30.0,
                ),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          const SizedBox(height: 0), // Remove the default bottom navigation bar
      bottomSheet: Container(
        height: 150,
        width: 400,
        decoration: const BoxDecoration(
          color: Color.fromRGBO(51, 54, 58, 1),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 40.0, top: 20, right: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                "Upload Prescription / Medical Documents :",
                style: TextStyle(
                  color: Color.fromRGBO(208, 200, 236, 1),
                  fontSize: 14,
                  fontFamily: 'inter',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildUploadButton(Icons.camera, 'Camera', context),
                  _buildUploadButton(Icons.photo_library, 'Gallery', context),
                  _buildUploadButton(
                      Icons.document_scanner, 'Document', context),
                  _buildUploadButton(
                      Icons.create_new_folder_rounded, 'New Folder', context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadButton(IconData icon, String label, BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color.fromRGBO(51, 54, 58, 1),
            border: Border.all(
              color: const Color.fromRGBO(172, 145, 190, 1),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Icon(icon, color: const Color.fromRGBO(247, 247, 248, 1)),
            iconSize: 25,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Prescription(documentId: documentId),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w100,
          ),
        ),
      ],
    );
  }
}
