import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StaffNotificationsScreen extends StatelessWidget {
  final Map<String, dynamic> staff;

  const StaffNotificationsScreen({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    // Sample notifications list
    final List<Map<String, String>> notifications = [
      {
        'title': 'New Shift Assigned',
        'message': 'You have a shift on Friday from 10 AM to 6 PM.',
        'time': '2 hours ago'
      },
      {
        'title': 'Menu Updated',
        'message': 'New dishes have been added to the menu.',
        'time': '1 day ago'
      },
      {
        'title': 'Meeting Reminder',
        'message': 'Manager meeting at 5 PM today.',
        'time': '3 days ago'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: GoogleFonts.poppins()),
        backgroundColor: Colors.deepPurple,
      ),
      body: notifications.isEmpty
          ? Center(
              child: Text(
                'No notifications yet!',
                style: GoogleFonts.poppins(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Icon(Icons.notifications, color: Colors.deepPurple),
                    title: Text(
                      notif['title']!,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notif['message']!, style: GoogleFonts.poppins()),
                        const SizedBox(height: 4),
                        Text(
                          notif['time']!,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
