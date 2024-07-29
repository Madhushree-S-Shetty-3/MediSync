import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class PrescriptionPage extends StatefulWidget {
  final String documentId;

  PrescriptionPage({Key? key, required this.documentId}) : super(key: key);

  @override
  _PrescriptionPageState createState() => _PrescriptionPageState();
}

class _PrescriptionPageState extends State<PrescriptionPage> {
  TextEditingController searchController = TextEditingController();
  List<String> uploadedFiles = [];
  List<String> uploadedImages = [];

  @override
  void initState() {
    super.initState();
    initializeFirestoreStructure(); // Initialize Firestore structure
    fetchUploadedFilesAndImages();
  }

  Future<void> initializeFirestoreStructure() async {
    try {
      // Check if the main document exists, create if it doesn't
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('medisync')
          .doc(widget.documentId)
          .get();

      if (!docSnapshot.exists) {
        await FirebaseFirestore.instance
            .collection('medisync')
            .doc(widget.documentId)
            .set({
          'fileUrls': [],
          'imageUrls': [],
        });
      }
    } catch (e) {
      print('Error initializing Firestore structure: $e');
    }
  }

  Future<void> fetchUploadedFilesAndImages() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('medisync')
          .doc(widget.documentId)
          .get();

      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

        setState(() {
          uploadedFiles = List<String>.from(data['fileUrls'] ?? []);
          uploadedImages = List<String>.from(data['imageUrls'] ?? []);
        });
      } else {
        print('Document does not exist: ${widget.documentId}');
      }
    } catch (e) {
      print('Error fetching uploaded files and images: $e');
    }
  }

  Future<void> uploadFile(File file) async {
    try {
      String fileName = file.path.split('/').last;
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('${widget.documentId}/uploaded_files/$fileName');

      UploadTask uploadTask = storageRef.putFile(file);
      await uploadTask.whenComplete(() async {
        String fileUrl = await storageRef.getDownloadURL();
        await saveFileUrl(fileUrl);
      });
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  Future<void> saveFileUrl(String fileUrl) async {
    try {
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('medisync')
          .doc(widget.documentId);

      await docRef.update({
        'fileUrls': FieldValue.arrayUnion([
          fileUrl,
        ]),
      });
      await fetchUploadedFilesAndImages(); // Refresh the list of uploaded files and images
    } catch (e) {
      print('Error saving file URL: $e');
    }
  }

  Future<void> uploadImage(File image) async {
    try {
      String imageName = image.path.split('/').last;
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('${widget.documentId}/uploaded_images/$imageName');
      UploadTask uploadTask = storageRef.putFile(image);
      await uploadTask.whenComplete(() async {
        String imageUrl = await storageRef.getDownloadURL();
        await saveImageUrl(imageUrl);
      });
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> saveImageUrl(String imageUrl) async {
    try {
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('medisync')
          .doc(widget.documentId);

      await docRef.update({
        'imageUrls': FieldValue.arrayUnion([
          imageUrl,
        ]),
      });
      await fetchUploadedFilesAndImages(); // Refresh the list of uploaded files and images
    } catch (e) {
      print('Error saving image URL: $e');
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      await uploadImage(file);
    } else {
      print('No image selected.');
    }
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      await uploadFile(file);
    } else {
      print('No file selected.');
    }
  }

  Future<void> deleteFile(String url, bool isFile) async {
    try {
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('medisync')
          .doc(widget.documentId);

      if (isFile) {
        await docRef.update({
          'fileUrls': FieldValue.arrayRemove([url]),
        });
      } else {
        await docRef.update({
          'imageUrls': FieldValue.arrayRemove([url]),
        });
      }

      await FirebaseStorage.instance.refFromURL(url).delete();
      await fetchUploadedFilesAndImages(); // Refresh the list of uploaded files and images
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13171D),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(51, 54, 58, 1),
        title: Text(
          'Medical Documents',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18, // Adjust font size as needed
            fontWeight: FontWeight.w400, // Optional: Adjust font weight
          ),
        ),
      ),
      body: ListView(
        children: [
          _buildSectionTitle('Uploaded Files'),
          SizedBox(height: 10),
          _buildFilesList(),
          SizedBox(height: 20),
          _buildSectionTitle('Uploaded Images'),
          SizedBox(height: 10),
          _buildImagesList(),
        ],
      ),
      bottomSheet: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(51, 54, 58, 1),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Upload Prescription / Medical Documents :",
                style: TextStyle(
                  color: Color.fromRGBO(208, 200, 236, 1),
                  fontSize: 14,
                  fontFamily: 'inter',
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildUploadButton(Icons.camera, 'Camera', () async {
                    await pickImage(ImageSource.camera);
                  }),
                  SizedBox(width: 16),
                  _buildUploadButton(Icons.photo_library, 'Gallery', () async {
                    await pickImage(ImageSource.gallery);
                  }),
                  SizedBox(width: 16),
                  _buildUploadButton(Icons.attach_file, 'File', () async {
                    await pickFile();
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFilesList() {
    if (uploadedFiles.isEmpty) {
      return Center(
        child: Text(
          'No files uploaded yet.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: uploadedFiles.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            _showFilePreviewDialog(uploadedFiles[index]);
          },
          child: Stack(
            children: [
              Container(
                color: Colors.grey[800],
                child: Center(
                  child: Icon(Icons.insert_drive_file, color: Colors.white),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    deleteFile(uploadedFiles[index], true);
                  },
                  child: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagesList() {
    if (uploadedImages.isEmpty) {
      return Center(
        child: Text(
          'No images uploaded yet.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: uploadedImages.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            _showImagePreviewDialog(uploadedImages[index]);
          },
          child: Stack(
            children: [
              Image.network(uploadedImages[index], fit: BoxFit.cover),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    deleteFile(uploadedImages[index], false);
                  },
                  child: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUploadButton(
      IconData icon, String text, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Future<void> _showFilePreviewDialog(String fileUrl) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('File Preview'),
          content: Text('File URL: $fileUrl'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showImagePreviewDialog(String imageUrl) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Image.network(imageUrl),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
