import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/home.dart'; // Import the Home page
import 'package:app/home_female.dart'; // Import the HomeFemale page

class Login3 extends StatefulWidget {
  final String phoneNumber;

  const Login3({super.key, required this.phoneNumber});

  @override
  _Login3State createState() => _Login3State();
}

class _Login3State extends State<Login3> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController secondNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  String gender = 'Male'; // Default gender

  @override
  void dispose() {
    firstNameController.dispose();
    secondNameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  final _key = GlobalKey<FormState>();

  void saveDetails(String firstName, String secondName, String email) async {
    if (_key.currentState!.validate()) {
      try {
        // Save user details to Firestore

        DocumentReference docRef =
            await FirebaseFirestore.instance.collection('medisync').add({
          'firstName': firstName,
          'secondName': secondName,
          'email': email,
          'phoneNumber': widget.phoneNumber,
          'gender': gender,
          'dob': "",
          'height': "",
          'weight': "",
          'bloodGroup': "",
          'vaccines': [],
          'history': [], // Initialize history as an empty list
          'beforeMealSugar': [],
          'afterMealSugar': [],
          'menstrualDays': [],
          'cycleDays': [],
          'lastMenstrualStartDate': DateTime.now(),
          'notifications': [],
          'uploadedFiles': {}, // Initialize uploadedFiles as an empty map
          'uploadedImages': {},
          'imageUrl': '',
          'pcount': 0
        });

        String documentId = docRef.id;

        // Navigate to appropriate home page based on gender
        if (gender == 'Female') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeFemale(documentId: documentId),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Home(documentId: documentId),
            ),
          );
        }
      } catch (e) {
        print('Error saving details: $e');
        // Handle error saving data
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13171D),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 50, left: 10, right: 10),
          child: Form(
            key: _key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    'assets/Profile pic-cuate.png',
                    width: 120,
                    height: 140,
                  ),
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    "Add Personal Details",
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                buildTextField("First Name", firstNameController),
                const SizedBox(height: 20),
                buildTextField("Second Name", secondNameController),
                const SizedBox(height: 20),
                buildTextField("E-Mail ID", emailController),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  '       Select Gender:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w200,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio(
                      value: 'Male',
                      groupValue: gender,
                      onChanged: (value) {
                        setState(() {
                          gender = value.toString();
                        });
                      },
                      activeColor: Colors.white,
                    ),
                    const Text(
                      'Male',
                      style: TextStyle(color: Colors.white, fontSize: 17),
                    ),
                    const SizedBox(
                      width: 60,
                    ),
                    Radio(
                      value: 'Female',
                      groupValue: gender,
                      onChanged: (value) {
                        setState(() {
                          gender = value.toString();
                        });
                      },
                      activeColor: Colors.white,
                    ),
                    const Text(
                      'Female',
                      style: TextStyle(color: Colors.white, fontSize: 17),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 300,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        saveDetails(
                          firstNameController.text.trim(),
                          secondNameController.text.trim(),
                          emailController.text.trim(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8766EB),
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          color: Color.fromARGB(255, 8, 8, 8),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String labelText, TextEditingController controller,
      {VoidCallback? onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30, bottom: 5),
          child: Text(
            labelText,
            style: const TextStyle(
              fontSize: 17,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w100,
              color: Colors.white,
            ),
          ),
        ),
        Center(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: 330,
              height: 62,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF282828),
                    Color.fromARGB(140, 66, 67, 73),
                    Color(0xFF282828),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
