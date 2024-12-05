import 'package:flutter/material.dart';
import 'package:reminder_app/database/db_helper.dart';
import 'package:reminder_app/screens/home_screen.dart';
import 'package:reminder_app/services/notifications_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DbHelper.initDb();
  await NotificationsHelper.initializeNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Hatırlatıcı",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.lightGreen,
          fontFamily: "Montserrat",
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
            bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
            titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          )),
      home: HomeScreen(),
    );
  }
}
