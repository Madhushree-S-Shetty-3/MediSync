import 'package:app/notification_female.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'linechart.dart'; // Import the Linechart widget

import 'profile_page.dart';
import 'prescription_page.dart';

class Home extends StatefulWidget {
  final String documentId;

  const Home({
    super.key,
    required this.documentId,
  });

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String firstName = '';
  String gender = ''; // Initially empty until fetched from Firestore
  String? age; // Nullable age
  String? weight; // Nullable weight
  String? height; // Nullable height
  List<double> beforeMealSugar = [];
  List<double> afterMealSugar = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('medisync')
          .doc(widget.documentId)
          .get();

      if (documentSnapshot.exists) {
        setState(() {
          firstName = documentSnapshot.get('firstName');
          gender =
              documentSnapshot.get('gender'); // Fetch and set the age field
          weight = documentSnapshot.get('weight');
          height = documentSnapshot.get('height');
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      // Handle error fetching data
    }
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  double? _calculateBMI() {
    if (weight != null && height != null) {
      double? weightDouble = double.tryParse(weight!);
      double? heightDouble = double.tryParse(height!);

      if (weightDouble != null && heightDouble != null) {
        double heightInMeters = heightDouble / 100; // Convert cm to meters
        return weightDouble / (heightInMeters * heightInMeters);
      }
    }
    return null;
  }

  Future<void> _showInputDialog(BuildContext context, String type) async {
    double? value;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(
              255, 39, 39, 39), // Set background color to black
          title: Text(
            "Enter $type Sugar Level",
            style: const TextStyle(
                color: Colors.white), // Set title text color to white
          ),
          content: TextField(
            keyboardType: TextInputType.number,
            style: const TextStyle(
                color: Colors.white), // Set input text color to white
            onChanged: (input) {
              value = double.tryParse(input);
            },
            decoration: const InputDecoration(
              hintText: "Enter value in mg/dL",
              hintStyle: TextStyle(color: Colors.grey), // Set hint text color
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(
                    255, 113, 113, 113), // Set button background color to grey
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(
                    color: Colors.white), // Set button text color to white
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                    0xFF8766EB), // Set button background color to purple
              ),
              child: const Text(
                "Save",
                style: TextStyle(
                    color: Colors.white), // Set button text color to white
              ),
              onPressed: () async {
                if (value != null) {
                  setState(() {
                    if (type == "Before Meal") {
                      beforeMealSugar.add(value!);
                    } else if (type == "After Meal") {
                      afterMealSugar.add(value!);
                    }
                  });
                  try {
                    await FirebaseFirestore.instance
                        .collection('medisync')
                        .doc(widget.documentId)
                        .update({
                      type == "Before Meal"
                          ? 'beforeMealSugar'
                          : 'afterMealSugar': FieldValue.arrayUnion([value])
                    });
                  } catch (e) {
                    print('Error updating user data: $e');
                    // Handle error updating data
                  }
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double? bmi = _calculateBMI();
    return Scaffold(
      backgroundColor: const Color(0xFF13171D),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 45, left: 10, right: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hi, $firstName", // Display fetched firstName
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        age != null
                            ? "$age years, $gender"
                            : gender, // Display fetched gender and age
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w100),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _navigateToPage(context,
                          NotificationFemale(documentId: widget.documentId));
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(15),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    child: const Icon(
                      Icons.notifications,
                      size: 30,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 320,
                  height: 139,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: const Color.fromARGB(255, 51, 52, 53),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.3),
                        spreadRadius: 4,
                        blurRadius: 9,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, left: 25),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Bio-Mass Index",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                )),
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Container(
                                width: 75,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(210, 70, 71, 72),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    weight != null ? "$weight kg" : "-",
                                    style: const TextStyle(
                                        color: Color(0xFF62AA69),
                                        fontSize: 15,
                                        fontFamily: 'Inter'),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.only(left: 60),
                              child: Container(
                                width: 75,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(210, 70, 71, 72),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    height != null ? "$height cm" : "-",
                                    style: const TextStyle(
                                        color:
                                            Color.fromARGB(255, 159, 158, 158),
                                        fontSize: 15,
                                        fontFamily: 'Inter'),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Stack(
                          children: [
                            Image.asset(
                              'assets/bmi.png',
                              width: 120,
                              height: 140,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 70, left: 35),
                              child: Text(
                                bmi != null ? bmi.toStringAsFixed(1) : "-",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 65,
                width: 320,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color.fromARGB(255, 51, 52, 53),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.3),
                      spreadRadius: 4,
                      blurRadius: 9,
                      offset: const Offset(4, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 70, 71, 72),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        onPressed: () {
                          _showInputDialog(context, "Before Meal");
                        },
                        child: const Text(
                          "Before Meal",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 70, 71, 72),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        onPressed: () {
                          _showInputDialog(context, "After Meal");
                        },
                        child: const Text(
                          "After Meal",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 320,
                  height: 275,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: const Color.fromARGB(255, 51, 52, 53),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.3),
                        spreadRadius: 4,
                        blurRadius: 9,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 25, top: 10),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Text(
                              "Blood Sugar",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300),
                            ),
                            SizedBox(width: 50),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            ClipOval(
                              child: Container(
                                color: const Color.fromARGB(255, 155, 57, 241),
                                height: 6,
                                width: 6,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              "Before Meal",
                              style: TextStyle(
                                color: Color.fromARGB(255, 201, 200, 200),
                              ),
                            ),
                            const SizedBox(width: 20),
                            ClipOval(
                              child: Container(
                                color: const Color.fromARGB(255, 74, 143, 239),
                                height: 6,
                                width: 6,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              "After Meal",
                              style: TextStyle(
                                color: Color.fromARGB(255, 201, 200, 200),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Center(
                          child: Linechart(
                            documentId: widget.documentId,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Center(
                child: Container(
                    width: 250,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: const Color.fromARGB(255, 51, 52, 53),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.3),
                          spreadRadius: 4,
                          blurRadius: 9,
                          offset: const Offset(4, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _navigateToPage(
                                  context,
                                  ProfilePage(
                                    documentId: widget.documentId,
                                  ));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(0),
                            ),
                            child: const Icon(
                              Icons.account_circle_rounded,
                              size: 38,
                              color: Colors.white,
                            ),
                          ),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                _navigateToPage(
                                    context,
                                    PrescriptionPage(
                                      documentId: widget.documentId,
                                    ));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 152, 123, 239),
                                elevation: 0,
                                shadowColor:
                                    const Color.fromARGB(226, 27, 27, 27),
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(0),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 38,
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _navigateToPage(
                                  context,
                                  NotificationFemale(
                                      documentId: widget.documentId));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(0),
                            ),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              size: 38,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
