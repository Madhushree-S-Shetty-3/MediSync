import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Cyclecontd extends StatefulWidget {
  final String documentId;

  const Cyclecontd({super.key, required this.documentId});

  @override
  _CyclecontdState createState() => _CyclecontdState();
}

class _CyclecontdState extends State<Cyclecontd> {
  String _selectedDate = "Select Date";
  String menstrualDays = "";
  String cycleDays = "";
  DateTime lastMenstrualStartDate = DateTime.now();
  DateTime nextPredictedMenstrualCycleDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchDataFromFirestore();
  }

  void _fetchDataFromFirestore() async {
    try {
      DocumentSnapshot document = await FirebaseFirestore.instance
          .collection('medisync')
          .doc(widget.documentId)
          .get();

      if (document.exists) {
        setState(() {
          menstrualDays = document['menstrualDays']?.toString() ?? "";
          cycleDays = document['cycleDays']?.toString() ?? "";
          lastMenstrualStartDate =
              (document['lastMenstrualStartDate'] as Timestamp?)?.toDate() ??
                  DateTime.now();
          _selectedDate =
              "${lastMenstrualStartDate.month}/${lastMenstrualStartDate.day}/${lastMenstrualStartDate.year}";
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data: $e')),
      );
    }
  }

  void _showPicker(
      BuildContext context, List<String> options, Function(String) onSelected) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          color: const Color(0xFF414141),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color.fromARGB(255, 160, 160, 160),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Color.fromARGB(255, 160, 160, 160),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  child: CupertinoPicker(
                    backgroundColor: const Color(0xFF414141),
                    itemExtent: 32,
                    onSelectedItemChanged: (int value) {
                      onSelected(options[value]);
                    },
                    children: options.map((String value) {
                      return Text(value,
                          style: const TextStyle(color: Colors.white));
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          color: const Color(0xFF414141),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color.fromARGB(255, 160, 160, 160),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Color.fromARGB(255, 160, 160, 160),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    backgroundColor: const Color(0xFF414141),
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: DateTime.now(),
                    onDateTimeChanged: (DateTime newDateTime) {
                      setState(() {
                        lastMenstrualStartDate = newDateTime;
                        _selectedDate =
                            "${newDateTime.month}/${newDateTime.day}/${newDateTime.year}";
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveToFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('medisync')
          .doc(widget.documentId)
          .set({
        'menstrualDays': menstrualDays,
        'cycleDays': cycleDays,
        'lastMenstrualStartDate': lastMenstrualStartDate,
        'nextPredictedMenstrualCycleDay': _calculateNextMenstrualCycleDay(),
      }, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data saved successfully!')),
      );
      _fetchDataFromFirestore(); // Refresh data to show updated predicted date
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save data: $e')),
      );
    }
  }

  DateTime _calculateNextMenstrualCycleDay() {
    int cycleDuration = int.tryParse(cycleDays) ?? 28;
    return lastMenstrualStartDate.add(Duration(days: cycleDuration));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13171E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF9F9F9F)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          "Cycle Settings",
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
            fontFamily: "Inter",
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
        child: Column(
          children: [
            _buildOptionItem(
              title: "Menstrual days",
              subtitle: menstrualDays.isEmpty
                  ? "How many days does your period usually last?"
                  : menstrualDays,
              onTap: () => _showPicker(
                context,
                List.generate(8, (index) => (4 + index).toString()),
                (value) {
                  setState(() {
                    menstrualDays = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildOptionItem(
              title: "Cycle days",
              subtitle: cycleDays.isEmpty
                  ? "How many days is the interval between your periods?"
                  : cycleDays,
              onTap: () => _showPicker(
                context,
                List.generate(16, (index) => (15 + index).toString()),
                (value) {
                  setState(() {
                    cycleDays = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildOptionItem(
              title: "Last menstrual start date",
              subtitle: _selectedDate,
              onTap: () => _showDatePicker(context),
            ),
            const SizedBox(height: 16),
            _buildOptionItem(
              title: "Next Predicted Menstrual Cycle Day",
              subtitle:
                  "${nextPredictedMenstrualCycleDay.month}/${nextPredictedMenstrualCycleDay.day}/${nextPredictedMenstrualCycleDay.year}",
              onTap: () {},
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveToFirestore,
              child: const Text('Save Data'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF414141),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.normal,
            fontFamily: "Inter",
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white, // Changed to white
            fontSize: 12,
            fontWeight: FontWeight.w100,
            fontFamily: "Inter",
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
