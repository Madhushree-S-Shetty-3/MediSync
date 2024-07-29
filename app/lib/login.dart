import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/login2.dart';
import 'package:app/home.dart';
import 'package:app/home_female.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isPhoneValid = true;
  bool _isProceedClicked = false;
  String? _storedPhoneNumber;

  void _validatePhoneNumber() {
    setState(() {
      _isPhoneValid = _phoneController.text.length == 10;
    });
  }

  void _storePhoneNumber() {
    setState(() {
      _storedPhoneNumber = '+91${_phoneController.text}';
    });
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> checkPhoneNumberAndNavigate() async {
    final phone = _storedPhoneNumber!; // Use +91 prefix

    try {
      // Query Firestore to check if phone number exists
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('medisync')
              .where('phoneNumber', isEqualTo: phone)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Phone number exists in Firestore
        final gender = querySnapshot.docs.first.get('gender');
        if (gender == 'Female') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  HomeFemale(documentId: querySnapshot.docs.first.id),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  Home(documentId: querySnapshot.docs.first.id),
            ),
          );
        }
      } else {
        // Phone number doesn't exist, proceed with OTP verification
        await FirebaseAuth.instance.verifyPhoneNumber(
          verificationCompleted: (PhoneAuthCredential credential) {
            // Automatically sign in the user if verification is successful
          },
          verificationFailed: (FirebaseAuthException e) {
            // Handle verification failure
            print('Verification failed: ${e.message}');
          },
          codeSent: (String verificationId, int? resendToken) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Login2(
                  verificationId: verificationId,
                  phoneNumber: _storedPhoneNumber.toString(),
                ),
              ),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
          phoneNumber: _storedPhoneNumber!,
        );
      }
    } catch (e) {
      print('Error checking phone number: $e');
      // Handle error checking phone number
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13171D),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 130, left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/Sign up-amico.png',
                  width: 200,
                  height: 200,
                ),
              ),
              const SizedBox(height: 40),
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  "Enter Phone Number",
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  "Please enter 10-digit valid phone number to receive OTP",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w100,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Column(
                  children: [
                    Container(
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
                        border: Border.all(
                          color: _isPhoneValid
                              ? _focusNode.hasFocus
                                  ? const Color(0xFF8766EB)
                                  : Colors.transparent
                              : Colors.red,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '+91',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 0, left: 15),
                              child: TextField(
                                controller: _phoneController,
                                focusNode: _focusNode,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'XXXX - XXXX - XX',
                                  hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 138, 138, 138),
                                    fontSize: 20,
                                  ),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  contentPadding: EdgeInsets.only(top: 0),
                                  counterText: '',
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (value) => _validatePhoneNumber(),
                                buildCounter: (BuildContext context,
                                    {int? currentLength,
                                    int? maxLength,
                                    bool? isFocused}) {
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Icon(
                              Icons.phone,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!_isPhoneValid && _isProceedClicked)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Please enter a valid 10-digit phone number.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 130),
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
                      setState(() {
                        _isProceedClicked = true;
                        _validatePhoneNumber();
                      });
                      if (_phoneController.text.isEmpty) {
                        setState(() {
                          _isPhoneValid = false;
                        });
                      } else if (_isPhoneValid) {
                        _storePhoneNumber();
                        checkPhoneNumberAndNavigate();
                      }
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
                      'Proceed',
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
    );
  }
}
