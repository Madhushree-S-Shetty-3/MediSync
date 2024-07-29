import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  final String documentId;

  const EditProfile({super.key, required this.documentId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _secondNameController;
  late TextEditingController _dobController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _bloodGroupController;
  String? _gender;
  String? _imageUrl;
  Uint8List? _image;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _secondNameController = TextEditingController();
    _dobController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _bloodGroupController = TextEditingController();
    _fetchData();
  }

  Future<void> _fetchData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('medisync')
        .doc(widget.documentId)
        .get();

    if (userDoc.exists) {
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      setState(() {
        _firstNameController.text = data['firstName'];
        _secondNameController.text = data['secondName'];
        _gender = data['gender'];
        _dobController.text = data['dob'];
        _heightController.text = data['height'];
        _weightController.text = data['weight'];
        _bloodGroupController.text = data['bloodGroup'];
        if (data.containsKey('imageUrl')) {
          _imageUrl = data['imageUrl'];
        }
      });
    }
  }

  Future<void> _saveChanges() async {
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

      await FirebaseFirestore.instance
          .collection('medisync')
          .doc(widget.documentId)
          .update({
        'firstName': _firstNameController.text,
        'secondName': _secondNameController.text,
        'gender': _gender!,
        'dob': _dobController.text,
        'height': _heightController.text,
        'weight': _weightController.text,
        'bloodGroup': _bloodGroupController.text,
        if (imageUrl != null) 'imageUrl': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );

      Navigator.pop(context);
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
    print('Starting image upload...');
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('profileImages')
        .child(widget.documentId);

    UploadTask uploadTask = ref.putData(_image!);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    print('Image uploaded successfully: $downloadUrl');
    return downloadUrl;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _secondNameController.dispose();
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bloodGroupController.dispose();
    super.dispose();
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
                        "Edit Health Profile",
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
                          : _imageUrl != null
                              ? CircleAvatar(
                                  radius: 40,
                                  backgroundImage: NetworkImage(_imageUrl!),
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
                  "Gender",
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _gender,
                  onChanged: (newValue) {
                    setState(() {
                      _gender = newValue;
                    });
                  },
                  items: <String>['Male', 'Female', 'Other']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(value),
                      ),
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
                      return 'Please select a gender';
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
                      return 'Please enter date of birth';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "Height (cm)",
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _heightController,
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
                      return 'Please enter height';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "Weight (kg)",
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _weightController,
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
                      return 'Please enter weight';
                    }
                    return null;
                  },
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter blood group';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color.fromARGB(255, 117, 27, 243),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 24.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    child: const Text('Save Changes'),
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
