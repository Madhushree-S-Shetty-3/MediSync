import 'package:app/home.dart';
import 'package:flutter/material.dart';
import 'up2.dart'; // Ensure you have this import for navigation

class Upload extends StatelessWidget {
  final String documentId;

  const Upload({super.key, required this.documentId});

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
            child: IconButton(
              icon: const Icon(
                Icons.account_circle,
                color: Colors.white,
                size: 30.0,
              ),
              iconSize: 43,
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No Documents uploaded yet!',
              style: TextStyle(
                color: Color.fromARGB(255, 133, 79, 168),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Add medical prescriptions/ Medical documents\nby clicking + icon below.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Image.asset(
              'asset/file_search.png', // Replace with your image asset path
              width: 50,
              height: 50,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF13171D),
        shape: const CircularNotchedRectangle(),
        notchMargin: 5,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                  backgroundColor: const Color(0xFFEDEAF1),
                  foregroundColor: const Color.fromRGBO(36, 30, 30, 1),
                ),
                child: const Icon(Icons.home, color: Color.fromRGBO(36, 30, 30, 1)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Home(documentId: documentId)),
                  );
                },
              ),
            ),
            const SizedBox(width: 30), // Space for the floating action button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                  backgroundColor: const Color(0xFFEDEAF1),
                  foregroundColor: const Color.fromRGBO(36, 30, 30, 1),
                ),
                child: const Icon(Icons.add, color: Color.fromRGBO(36, 30, 30, 1)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Up2(documentId: documentId)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
