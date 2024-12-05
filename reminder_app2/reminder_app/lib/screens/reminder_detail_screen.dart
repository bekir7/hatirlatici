import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reminder_app/database/db_helper.dart';
import 'package:reminder_app/screens/add_edit_reminder.dart';

class ReminderDetailScreen extends StatefulWidget {
  final int reminderId;
  const ReminderDetailScreen({super.key, required this.reminderId});

  @override
  State<ReminderDetailScreen> createState() => _ReminderDetailScreenState();
}

class _ReminderDetailScreenState extends State<ReminderDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: DbHelper.getRemindersById(widget.reminderId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.lightGreen,
              ),
            ),
          );
        }
        final reminder = snapshot.data!;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.lightGreen),
            title: const Text("Hatırlatıcı Detayları",
                style: TextStyle(color: Colors.lightGreen)),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildDetailCard(
                    label: "Başlık",
                    icon: Icons.title,
                    content: reminder['title']),
                SizedBox(height: 20),
                buildDetailCard(
                    label: "Açıklama",
                    icon: Icons.description,
                    content: reminder['description']),
                SizedBox(height: 20),
                buildDetailCard(
                    label: "Kategori",
                    icon: Icons.category,
                    content: reminder['category']),
                SizedBox(height: 20),
                buildDetailCard(
                    label: "Zaman",
                    icon: Icons.access_time,
                    content: DateFormat('yyyy-MM-dd hh:mm a')
                        .format(DateTime.parse(reminder['time']))),
                SizedBox(height: 20),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.lightGreen,
            foregroundColor: Colors.white,
            child: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddEditReminder(
                            reminderId: widget.reminderId,
                          )));
            },
          ),
        );
      },
    );
  }

  Widget buildDetailCard({
    required String label,
    required IconData icon,
    required String content,
  }) {
    return Card(
      elevation: 6,
      color: Colors.lightGreen.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: Colors.lightGreen),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              )
            ]),
            SizedBox(height: 10),
            Text(
              content,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
