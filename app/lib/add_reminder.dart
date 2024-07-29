import 'package:app/reminder_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

addReminder(BuildContext context, String uid) {
  add(String uid, TimeOfDay time) {
    try {
      DateTime d = DateTime.now();
      DateTime dateTime =
          DateTime(d.year, d.month, d.day, time.hour, time.minute);
      Timestamp timestamp = Timestamp.fromDate(dateTime);
      ReminderModel reminderModel = ReminderModel();
      reminderModel.timestamp = timestamp;
      reminderModel.onOff = false;
      FirebaseFirestore.instance
          .collection('medisync')
          .doc(uid)
          .collection('notifications')
          .doc()
          .set(reminderModel.toMap());

      Fluttertoast.showToast(msg: "Reminder Added");
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}
