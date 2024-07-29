import 'package:app/home.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:app/cyclecontd.dart';

class Calender extends StatefulWidget {
  final String documentId;

  const Calender({super.key, required this.documentId});

  @override
  _CalenderState createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final List<String> _notifications = [];

  void _openCycleSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CycleSettingsPage()),
    );
  }

  void _addReminder(DateTime selectedDate) {
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
                controller: _timeController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Time (e.g., 10:45 AM)',
                  labelStyle:
                      TextStyle(color: Color.fromARGB(255, 158, 157, 157)),
                ),
              ),
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
                  _notifications.add(
                      '${selectedDate.toLocal().toString().split(' ')[0]} at ${_timeController.text}: ${_descriptionController.text}');
                  _descriptionController.clear();
                  _timeController.clear();
                });
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
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Center(
                        child: Container(
                          width: 320,
                          height: 50,
                          decoration: BoxDecoration(
                              color: const Color(0xFF2C2D30),
                              borderRadius: BorderRadius.circular(15)),
                          child: Center(
                            child: Row(
                              children: [
                                ElevatedButton(
                                  iconAlignment: IconAlignment.end,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2C2D30),
                                      foregroundColor: const Color(0xFFC1C1C1),
                                      alignment: Alignment.center),
                                  onPressed: () {},
                                  child: const Center(
                                    child: Text(
                                      'Menstrual Reminder',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 320,
                    height: 50,
                    decoration: BoxDecoration(
                        color: const Color(0xFF2C2D30),
                        borderRadius: BorderRadius.circular(15)),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C2D30),
                        foregroundColor: const Color(0xFFC1C1C1),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Cyclecontd(
                              documentId: widget.documentId,
                            ),
                          ),
                        );
                      },
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
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 320,
              height: 170,
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2D30),
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
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          _notifications[index],
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      );
                    },
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

class CycleSettingsPage extends StatelessWidget {
  const CycleSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cycle Settings'),
      ),
      body: const Center(
        child: Text('Cycle Settings Page'),
      ),
    );
  }
}
