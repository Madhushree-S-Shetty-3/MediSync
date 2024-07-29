import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:app/home.dart';

class NotificationPage extends StatefulWidget {
  final String documentId;

  const NotificationPage({super.key, required this.documentId});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final List<Map<String, String>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('medisync')
        .doc(widget.documentId)
        .get();

    if (docSnapshot.exists) {
      List<dynamic> notifications = docSnapshot.get('notifications') ?? [];
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
      });
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
                builder: (context) => Home(documentId: widget.documentId),
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
              width: 320,
              height: 300, // Set a fixed height to make it scrollable
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(0, 44, 45, 48),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF13171D),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ListTile(
                                  title: Text(
                                    _notifications[index]['description'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${_notifications[index]['date']}, ${_notifications[index]['time']}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Color(0xFF8766EB)),
                                        onPressed: () {
                                          _editReminder(index);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () {
                                          _deleteReminder(index);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
