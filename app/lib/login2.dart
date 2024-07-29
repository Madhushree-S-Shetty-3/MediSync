import 'dart:async';
import 'package:app/home_female.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/home.dart';
import 'package:app/login3.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/login.dart';

class Login2 extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const Login2(
      {super.key, required this.verificationId, required this.phoneNumber});

  @override
  _Login2State createState() => _Login2State();
}

class _Login2State extends State<Login2> {
  final TextEditingController otpController1 = TextEditingController();
  final TextEditingController otpController2 = TextEditingController();
  final TextEditingController otpController3 = TextEditingController();
  final TextEditingController otpController4 = TextEditingController();
  final TextEditingController otpController5 = TextEditingController();
  final TextEditingController otpController6 = TextEditingController();

  final FocusNode focusNode1 = FocusNode();
  final FocusNode focusNode2 = FocusNode();
  final FocusNode focusNode3 = FocusNode();
  final FocusNode focusNode4 = FocusNode();
  final FocusNode focusNode5 = FocusNode();
  final FocusNode focusNode6 = FocusNode();

  late Timer _timer;
  int _start = 30;
  bool isResendVisible = false;
  late String verificationId;

  @override
  void initState() {
    super.initState();
    verificationId = widget.verificationId;
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      if (_start == 0) {
        setState(() {
          isResendVisible = true;
          _timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void resendOTP() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
        }
      },
      codeSent: (String newVerificationId, int? resendToken) {
        setState(() {
          verificationId = newVerificationId;
          isResendVisible = false;
          _start = 30; // Reset timer
          startTimer(); // Restart timer
        });
      },
      codeAutoRetrievalTimeout: (String newVerificationId) {
        verificationId = newVerificationId;
      },
    );
  }

  Future<void> _submitOTP(BuildContext context) async {
    String otp = otpController1.text +
        otpController2.text +
        otpController3.text +
        otpController4.text +
        otpController5.text +
        otpController6.text;
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: otp);
      await auth.signInWithCredential(credential);

      print('Verifying phone number: ${widget.phoneNumber}');

      final phoneNumberDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.phoneNumber)
          .get();

      if (phoneNumberDoc.exists) {
        print('Document found for phone number: ${widget.phoneNumber}');

        if (phoneNumberDoc.data()!.containsKey('gender')) {
          String gender = phoneNumberDoc['gender'];

          // Navigate to HomeFemale if gender is 'Female', otherwise navigate to Home
          if (gender.toLowerCase() == 'female') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      HomeFemale(documentId: phoneNumberDoc.id)),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => Home(documentId: phoneNumberDoc.id)),
            );
          }
        } else {
          // If 'gender' field is not found, navigate to default Home page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => Home(documentId: phoneNumberDoc.id)),
          );
        }
      } else {
        print('No document found for phone number: ${widget.phoneNumber}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Login3(
                    phoneNumber: widget.phoneNumber,
                  )),
        );
      }
    } catch (e) {
      print('Error during OTP verification: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content:
                const Text("The OTP entered is incorrect. Please try again."),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
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

  @override
  Widget build(BuildContext context) {
    String hiddenPhoneNumber =
        '+91 XXXXXX${widget.phoneNumber.substring(widget.phoneNumber.length - 4)}';
    String otpText = 'Enter the OTP sent on $hiddenPhoneNumber';

    return Scaffold(
      backgroundColor: const Color(0xFF13171D),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 110, left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/Enter OTP-amico.png',
                  width: 200,
                  height: 200,
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  "Enter OTP",
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    Text(
                      otpText,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w100,
                      ),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Login()),
                        );
                      },
                      child: const Text(
                        "Change number?",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB59CFF),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildOtpTextField(otpController1, focusNode1, focusNode2),
                    const SizedBox(width: 7),
                    buildOtpTextField(otpController2, focusNode2, focusNode3),
                    const SizedBox(width: 7),
                    buildOtpTextField(otpController3, focusNode3, focusNode4),
                    const SizedBox(width: 7),
                    buildOtpTextField(otpController4, focusNode4, focusNode5),
                    const SizedBox(width: 7),
                    buildOtpTextField(otpController5, focusNode5, focusNode6),
                    const SizedBox(width: 7),
                    buildOtpTextField(otpController6, focusNode6, null),
                  ],
                ),
              ),
              const SizedBox(height: 90),
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
                    onPressed: () => _submitOTP(context),
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
                      'Verify',
                      style: TextStyle(
                        color: Color.fromARGB(255, 8, 8, 8),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: isResendVisible
                    ? GestureDetector(
                        onTap: resendOTP,
                        child: const Text(
                          "Resend OTP",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFB59CFF),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )
                    : Text(
                        "You can resend OTP in $_start seconds",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFB59CFF),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOtpTextField(TextEditingController controller,
      FocusNode currentFocus, FocusNode? nextFocus) {
    return SizedBox(
      width: 47,
      child: Center(
        child: TextField(
          controller: controller,
          focusNode: currentFocus,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            counterText: '',
          ),
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.phone,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          onChanged: (value) {
            if (value.length == 1 && nextFocus != null) {
              nextFocus.requestFocus();
            }
          },
        ),
      ),
    );
  }
}
