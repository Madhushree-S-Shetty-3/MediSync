import 'package:flutter/material.dart';

class FilesUpload extends StatelessWidget {
  const FilesUpload({super.key});

  @override
  Widget build(BuildContext context) {
    return const FilesUploads();
  }
}

class FilesUploads extends StatelessWidget {
  const FilesUploads({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Two Buttons Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Add your logic for the first button here
                print('First Button Pressed');
              },
              child: const Text('Select File'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add your logic for the second button here
                print('Second Button Pressed');
              },
              child: const Text('Upload File'),
            ),
          ],
        ),
      ),
    );
  }
}
