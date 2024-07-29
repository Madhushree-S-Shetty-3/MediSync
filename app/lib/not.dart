import 'package:app/notificationApi.dart';
import 'package:flutter/material.dart';

class Not extends StatelessWidget {
  const Not({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF8766EB),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await NotificationApi.showNotification();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8766EB),
              ),
              child: const Text('Instant Notification'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => {
                NotificationApi.showNotification(
                    title: 'Medisync',
                    body: "Hey there! nice to have you on board")
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8766EB),
              ),
              child: const Text('Scheduled Notification'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                //await NotificationApi.removeNotification();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8766EB),
              ),
              child: const Text('Remove Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
