import 'dart:io';
import 'dart:typed_data';

import 'package:app/operation_history.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AddUser extends StatefulWidget {
  final String documentId;

  const AddUser({Key? key, required this.documentId}) : super(key: key);

  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _secondNameController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _bloodGroupController;
  String? _gender;
  Uint8List? _image;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _secondNameController = TextEditingController();
    _emailController = TextEditingController();
    _dobController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _bloodGroupController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _secondNameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bloodGroupController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (_formKey.currentState!.validate()) {
      String? imageUrl;
      if (_image != null) {
        try {
          imageUrl = await _uploadImageToStorage();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image')),
          );
          return;
        }
      }
      DocumentReference pcountRef = FirebaseFirestore.instance
          .collection('medisync')
          .doc(widget.documentId);

      DocumentSnapshot pcountSnapshot = await pcountRef.get();

      int pcount = pcountSnapshot.exists ? pcountSnapshot['pcount'] : 0;
      int newPcount = pcount + 1;

      String formattedDocumentId = 'subprofile$newPcount${widget.documentId}';
      await pcountRef.update({'pcount': newPcount});

      // Create a new Firestore document with the formatted document ID
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('medisync')
          .doc(formattedDocumentId);

      await docRef.set({
        'firstName': _firstNameController.text,
        'secondName': _secondNameController.text,
        'email': _emailController.text,
        'gender': _gender!,
        'dob': _dobController.text.isEmpty ? "" : _dobController.text,
        'height': _heightController.text.isEmpty ? "" : _heightController.text,
        'weight': _weightController.text.isEmpty ? "" : _weightController.text,
        'bloodGroup': _bloodGroupController.text.isEmpty
            ? ""
            : _bloodGroupController.text,
        'mainDocument': widget.documentId,
        'vaccines': [],
        'history': [], // Initialize history as an empty list
        'beforeMealSugar': [],
        'afterMealSugar': [],
        'menstrualDays': [],
        'cycleDays': [],
        'pcount': 0,
        'lastMenstrualStartDate': DateTime.now(),
        'notifications': [],
        'uploadedFiles': {}, // Initialize uploadedFiles as an empty map
        'uploadedImages': {}, // Initialize uploadedImages as an empty map
        if (imageUrl != null) 'imageUrl': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User added successfully!')),
      );

      // Navigate to the OperationHistory page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OperationHistory(documentId: widget.documentId),
        ),
      );
    }
  }

  Future<Uint8List?> pickImage(ImageSource source) async {
    try {
      XFile? pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        File pickedImage = File(pickedFile.path);
        Uint8List bytes = await pickedImage.readAsBytes();
        return bytes;
      }
      return null;
    } catch (e) {
      print('Image picking error: $e');
      return null;
    }
  }

  Future<String> _uploadImageToStorage() async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('profileImages')
        .child(DateTime.now().millisecondsSinceEpoch.toString());

    UploadTask uploadTask = ref.putData(_image!);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  void selectImage() async {
    Uint8List? img = await pickImage(ImageSource.gallery);
    if (img != null) {
      setState(() {
        _image = img;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13171E),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 45.0, left: 20, right: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        "Add New User",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Stack(
                    children: [
                      _image != null
                          ? CircleAvatar(
                              radius: 40,
                              backgroundImage: MemoryImage(_image!),
                            )
                          : Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color.fromARGB(
                                      255, 137, 137, 137), // Border color
                                  width: 3.0, // Border width
                                ),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: CircleAvatar(
                                  radius: 36,
                                  backgroundImage:
                                      AssetImage('assets/profile-icon.png'),
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                            ),
                      Positioned(
                        right: 0,
                        bottom: 10,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Center(
                            child: IconButton(
                              onPressed: selectImage,
                              icon: const Icon(Icons.camera_alt_outlined),
                              iconSize: 20,
                              color: const Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "First Name",
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _firstNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 10.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter first name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "Second Name",
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _secondNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 10.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter second name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "Email",
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 10.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    } else if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "Gender",
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _gender,
                  onChanged: (value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                  items: ['Male', 'Female', 'Other']
                      .map<DropdownMenuItem<String>>((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value,
                          style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 10.0),
                  ),
                  dropdownColor: Color.fromARGB(235, 63, 63, 63),
                  style: TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select gender';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "Date of Birth",
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _dobController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 10.0),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Height",
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _heightController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 10.0),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Weight",
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _weightController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 10.0),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Blood Group",
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _bloodGroupController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 10.0),
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveUser,
                    child: const Text('Save User'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
