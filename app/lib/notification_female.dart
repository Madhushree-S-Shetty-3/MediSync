import 'package:app/home_female.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:app/cyclecontd.dart';

class NotificationFemale extends StatefulWidget {
  final String documentId;

  const NotificationFemale({Key? key, required this.documentId})
      : super(key: key);

  @override
  _NotificationFemaleState createState() => _NotificationFemaleState();
}

class _NotificationFemaleState extends State<NotificationFemale> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final List<Map<String, String>> _notifications = [];
  bool _showCycleSettings =
      false; // Variable to conditionally show Cycle Settings

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('medisync')
          .doc(widget.documentId)
          .get();

      if (docSnapshot.exists) {
        List<dynamic> notifications = docSnapshot.get('notifications') ?? [];
        String gender =
            docSnapshot.get('gender') ?? ''; // Assuming 'gender' field exists

        setState(() {
          _notifications.addAll(
            notifications.map((n) {
              Map<String, dynamic> notification = n as Map<String, dynamic>;
              return {
                'description': notification['description'] as String,
                'date': notification['date'] as String,
                'time': notification['time'] as String,
              };
            }).toList(),
          );

          // Check gender and set whether to show cycle settings
          if (gender.toLowerCase() == 'female' ||
              gender.toLowerCase() == 'female') {
            _showCycleSettings = true;
          } else {
            _showCycleSettings = false;
          }
        });
      }
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  void _saveNotifications() async {
    await FirebaseFirestore.instance
        .collection('medisync')
        .doc(widget.documentId)
        .update({'notifications': _notifications});
  }

  void _addReminder(DateTime selectedDate) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      _timeController.text = pickedTime.format(context);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF13171D),
            title: const Text(
              'Add Reminder',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Date: ${selectedDate.toLocal()}'.split(' ')[0]),
                TextField(
                  controller: _descriptionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    labelStyle:
                        TextStyle(color: Color.fromARGB(255, 158, 157, 157)),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _notifications.add({
                      'description': _descriptionController.text,
                      'date': selectedDate.toLocal().toString().split(' ')[0],
                      'time': _timeController.text,
                    });
                    _descriptionController.clear();
                    _timeController.clear();
                  });
                  _saveNotifications();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2D30),
                  foregroundColor: const Color(0xFFC1C1C1),
                ),
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    }
  }

  void _editReminder(int index) async {
    _descriptionController.text = _notifications[index]['description'] ?? '';
    _timeController.text = _notifications[index]['time'] ?? '';

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      _timeController.text = pickedTime.format(context);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF13171D),
            title: const Text(
              'Edit Reminder',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _descriptionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    labelStyle:
                        TextStyle(color: Color.fromARGB(255, 158, 157, 157)),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _notifications[index] = {
                      'description': _descriptionController.text,
                      'date': _notifications[index]['date'] ?? '',
                      'time': _timeController.text,
                    };
                    _descriptionController.clear();
                    _timeController.clear();
                  });
                  _saveNotifications();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2D30),
                  foregroundColor: const Color(0xFFC1C1C1),
                ),
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    }
  }

  void _deleteReminder(int index) {
    setState(() {
      _notifications.removeAt(index);
    });
    _saveNotifications();
  }

  void _openCycleSettings() {
    if (_showCycleSettings) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Cyclecontd(documentId: widget.documentId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var container3 = Container(
      margin: const EdgeInsets.only(left: 15, right: 15, top: 0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Theme(
        data: ThemeData(
          primaryColor: Colors.grey,
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _addReminder(selectedDay);
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },
            headerStyle: const HeaderStyle(
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: Color(0xFF8766EB),
              ),
              weekendStyle: TextStyle(
                color: Color.fromARGB(255, 158, 130, 242),
              ),
            ),
            calendarStyle: CalendarStyle(
              defaultTextStyle: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            daysOfWeekHeight: 30.0,
          ),
        ),
      ),
    );

    var center = Center(
      child: container3,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF13171D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 218, 218, 218)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeFemale(documentId: widget.documentId),
              ),
            );
          },
        ),
        title: const Text(''),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            center,
            Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  if (_showCycleSettings) // Conditionally show based on gender
                    Container(
                      width: 320,
                      height: 68,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2D30),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C2D30),
                          foregroundColor: const Color(0xFFC1C1C1),
                        ),
                        onPressed: _openCycleSettings,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Cycle Settings',
                              textAlign: TextAlign.left,
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              height: 6,
            ),
            Text(
              "Notifications",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              height: MediaQuery.of(context).size.height * 0.45,
              child: ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: const Color(0xFF1B1D1E),
                    child: ListTile(
                      title: Text(
                        _notifications[index]['description'] ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${_notifications[index]['date']} at ${_notifications[index]['time']}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            color: Colors.grey,
                            onPressed: () => _editReminder(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () => _deleteReminder(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
