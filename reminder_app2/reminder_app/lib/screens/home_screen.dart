import 'package:flutter/material.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:reminder_app/database/db_helper.dart';
import 'package:reminder_app/screens/add_edit_reminder.dart';
import 'package:reminder_app/screens/reminder_detail_screen.dart';
import 'package:reminder_app/services/notifications_helper.dart';
import 'package:reminder_app/services/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> reminders = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestNotificationPermission();
    loadReminders();
  }

  Future<void> loadReminders() async {
    final reminders = await DbHelper.getReminders();
    setState(() {
      this.reminders = reminders;
    });
  }

  Future<void> toggleReminder(int id, bool isActive) async {
    await DbHelper.toggleReminder(id, isActive);
    if (isActive) {
      final reminder = reminders.firstWhere((rem) => rem['id'] == id);
      NotificationsHelper.scheduleNotification(id, reminder['title'],
          reminder['category'], DateTime.parse(reminder['time']));
    } else {
      NotificationsHelper.cancelNotification(id);
    }
    loadReminders();
  }

  Future<void> deleteReminder(int id) async {
    await DbHelper.deleteReminders(id);
    NotificationsHelper.cancelNotification(id);
    loadReminders();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Hatırlatıcı",
            style: TextStyle(color: Colors.lightGreen),
          ),
          iconTheme: IconThemeData(color: Colors.lightGreen),
        ),
        body: reminders.isEmpty
            ? Center(
                child: Text(
                "Hiç Hatırlatıcı Yok",
                style: TextStyle(color: Colors.lightGreen, fontSize: 18),
              ))
            : ListView.builder(
                itemCount: reminders.length,
                itemBuilder: (context, index) {
                  final reminder = reminders[index];
                  return Dismissible(
                    key: Key(reminder['id'].toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.redAccent,
                      padding: EdgeInsets.only(right: 20),
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDeleteConfirmationDialog(context);
                    },
                    onDismissed: (direction) {
                      deleteReminder(reminder['id']);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.redAccent,
                          content: Text("Hatırlatıcı Silindi"),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.white,
                      elevation: 6,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReminderDetailScreen(
                                    reminderId: reminder['id'],
                                  ),
                                ));
                          },
                          leading: Icon(
                            Icons.notifications,
                            color: Colors.lightGreen,
                          ),
                          title: Text(
                            reminder['title'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black),
                          ),
                          subtitle: Text(
                            "Kategori: ${reminder['category']}",
                            style: TextStyle(),
                          ),
                          // trailing: LiteRollingSwitch(
                          trailing: Transform.scale(
                              scale: 0.6,
                              child: LiteRollingSwitch(
                                value: reminder['isActive'] == 1,
                                textOn: '',
                                textOff: '',
                                colorOn: Colors.lightGreen,
                                colorOff: Colors.black54,
                                iconOn: Icons.check_circle,
                                iconOff: Icons.remove_circle_outline,
                                onChanged: (value) {
                                  toggleReminder(reminder['id'], value);
                                },
                                onTap: () {
                                  // Tek tıklama ile yapılacak işlemler
                                  print("Switch tapped!");
                                },
                                onDoubleTap: () {
                                  // Çift tıklama ile yapılacak işlemler
                                  print("Switch double-tapped!");
                                },
                                onSwipe: () {
                                  // Swipe (kaydırma) hareketi ile yapılacak işlemler
                                  print("Switch swiped!");
                                },
                              ))

                          // trailing: Switch(
                          //   value: reminder['isActive'] == 1,
                          //   activeColor: Colors.lightGreen,
                          //   inactiveTrackColor: Colors.white,
                          //   inactiveThumbColor: Colors.black54,
                          //   onChanged: (value) {
                          //     toggleReminder(reminder['id'], value);
                          //   },
                          // ),
                          ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.lightGreen,
          foregroundColor: Colors.white,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return AddEditReminder();
            }));
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Future<bool?> showDeleteConfirmationDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext content) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Hatırlatıcı Sil"),
          content: Text("Bu hatırlatıcıyı silmek istediğinize emin misiniz?"),
          actions: [
            TextButton(
              child: Text(
                "Hayır",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(
                "Evet",
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}
