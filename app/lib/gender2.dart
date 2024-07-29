import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/home.dart';

class Gender2 extends StatefulWidget {
  final String firstName;
  final String secondName;
  final String email;
  final String phoneNumber;

  const Gender2({
    super.key,
    required this.firstName,
    required this.secondName,
    required this.email,
    required this.phoneNumber,
  });

  @override
  _Gender2State createState() => _Gender2State();
}

class _Gender2State extends State<Gender2> {
  String? documentId;
  String? selectedGender;

  Future<void> saveUserDetails() async {
    try {
      documentId = '${widget.phoneNumber}_${selectedGender!.toLowerCase()}';

      await FirebaseFirestore.instance
          .collection('medisync')
          .doc(documentId)
          .set({
        'firstName': widget.firstName,
        'secondName': widget.secondName,
        'email': widget.email,
        'phoneNumber': widget.phoneNumber,
        'gender': selectedGender, // Adding selected gender to Firestore
        'dob': "",
        'height': "",
        'weight': "",
        'bloodGroup': "",
        'vaccines': [],
        'history': [], // Initialize history as an empty list
        'beforeMealSugar': [],
        'afterMealSugar': []
      });

      // Navigate to appropriate home page based on gender
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => selectedGender == 'Female'
              ? Home(documentId: documentId!)
              : Home(documentId: documentId!),
        ),
      );
    } catch (e) {
      print('Error saving user details: $e');
    }
  }

  void selectGender(String gender) {
    setState(() {
      selectedGender = gender;
    });
  }

  Widget buildGenderButton(String gender, String imagePath) {
    bool isSelected = selectedGender == gender;

    return GestureDetector(
      onTap: () => selectGender(gender),
      child: Stack(
        children: [
          Container(
            width: 182,
            height: 192,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2C2C2C), Color(0xFF3E3E3E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.3),
                  spreadRadius: 3,
                  blurRadius: 15,
                  offset: const Offset(5, 7),
                ),
              ],
              border: Border.all(
                color:
                    isSelected ? const Color(0xFF8766EB) : Colors.transparent,
                width: 4,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, top: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  imagePath,
                  width: 120,
                  height: 140,
                ),
                const SizedBox(height: 10),
                Text(
                  gender,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13171D),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 50, left: 10, right: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Select a Gender",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 50),
              Center(
                child: buildGenderButton('Female', 'assets/g1.png'),
              ),
              const SizedBox(height: 80),
              Center(
                child: buildGenderButton('Male', 'assets/b1.png'),
              ),
              const SizedBox(height: 80),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (selectedGender != null) {
                        saveUserDetails();
                      }
                    },
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 46, 46, 46),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Color.fromARGB(255, 220, 220, 220),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
