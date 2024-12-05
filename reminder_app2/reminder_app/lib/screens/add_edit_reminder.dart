import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reminder_app/database/db_helper.dart';
import 'package:reminder_app/screens/home_screen.dart';
import 'package:reminder_app/services/notifications_helper.dart';

class AddEditReminder extends StatefulWidget {
  final int? reminderId;
  const AddEditReminder({super.key, this.reminderId});

  @override
  State<AddEditReminder> createState() => _AddEditReminderState();
}

class _AddEditReminderState extends State<AddEditReminder> {
  final formKey = GlobalKey<FormState>();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  String category = 'İş';
  DateTime reminderDate = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.reminderId != null) {
      fetchReminder();
    }
  }

  Future<void> fetchReminder() async {
    try {
      final data = await DbHelper.getRemindersById(widget.reminderId!);
      if (data != null) {
        titleController.text = data['title'];
        descriptionController.text = data['description'];
        category = data['category'];
        reminderDate = DateTime.parse(data['time']);
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.reminderId == null
              ? "Yeni Hatırlatıcı"
              : "Hatırlatıcı Düzenle",
          style: TextStyle(color: Colors.lightGreen),
        ),
        iconTheme: IconThemeData(color: Colors.lightGreen),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildInputCard(
                  label: "Başlık",
                  icon: Icons.title,
                  child: TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: "Başlık Girin"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen Başlık Girin';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                buildInputCard(
                  label: "Açıklama",
                  icon: Icons.description,
                  child: TextFormField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: "Açıklama Girin"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen Açıklama Girin';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                buildInputCard(
                    label: "Kategori",
                    icon: Icons.category,
                    child: DropdownButtonFormField(
                        value: category,
                        dropdownColor: Colors.lightGreen.shade50,
                        decoration: InputDecoration.collapsed(hintText: ""),
                        items: [
                          "İş",
                          "Ders Çalışma",
                          "Ödev",
                          "Sağlık",
                          "Kişisel",
                          "Diğer"
                        ].map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            category = value!;
                          });
                        })),
                SizedBox(height: 20),
                buildDatePicker(
                  label: "Tarih",
                  icon: Icons.access_time,
                  displayValue: DateFormat('yyyy-MM-dd').format(reminderDate),
                  onPressed: selectDate,
                ),
                SizedBox(height: 10),
                buildDatePicker(
                  label: "Saat",
                  icon: Icons.calendar_today,
                  displayValue: DateFormat('hh:mm a').format(reminderDate),
                  onPressed: selectTime,
                ),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: saveReminder,
                    child: Text(
                      "Kaydet",
                      style: TextStyle(color: Colors.lightGreen.shade50),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputCard({
    required String label,
    required IconData icon,
    required Widget child,
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
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            ]),
            SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  Widget buildDatePicker(
      {required String label,
      required IconData icon,
      required String displayValue,
      required Function() onPressed}) {
    return Card(
      elevation: 6,
      color: Colors.lightGreen.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.lightGreen),
        title: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: TextButton(
          onPressed: onPressed,
          child: Text(
            displayValue,
            style: TextStyle(color: Colors.lightGreen),
          ),
        ),
      ),
    );
  }

  Future<void> selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: reminderDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        reminderDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          reminderDate.hour,
          reminderDate.minute,
        );
      });
    }
  }

  Future<void> selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: reminderDate.hour, minute: reminderDate.minute),
    );
    if (picked != null) {
      setState(() {
        reminderDate = DateTime(
          reminderDate.year,
          reminderDate.month,
          reminderDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> saveReminder() async {
    if (formKey.currentState!.validate()) {
      final newReminder = {
        "title": titleController.text,
        "description": descriptionController.text,
        "isActive": 1,
        "category": category,
        "time": reminderDate.toIso8601String(),
      };
      if (widget.reminderId == null) {
        final reminderId = await DbHelper.addReminders(newReminder);
        NotificationsHelper.scheduleNotification(
            reminderId, titleController.text, category, reminderDate);
      } else {
        await DbHelper.updateReminders(widget.reminderId!, newReminder);
        NotificationsHelper.scheduleNotification(
            widget.reminderId!, titleController.text, category, reminderDate);
      }
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ));
    }
  }
}
