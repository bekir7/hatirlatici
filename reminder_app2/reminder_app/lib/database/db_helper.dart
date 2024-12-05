import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static late Database db;

  static Future<void> initDb() async {
    final dbPath = await getDatabasesPath();
    db = await openDatabase(join(dbPath, 'reminders.db'),
        onCreate: (db, version) async {
      await db.execute(''' 
      
      CREATE TABLE reminders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        isActive INTEGER,
        category TEXT,
        time TEXT
      )
      ''');
    }, version: 1);
  }

  static Future<List<Map<String, dynamic>>> getReminders() async {
    return await db.query('reminders');
  }

  static Future<Map<String, dynamic>?> getRemindersById(int id) async {
    final List<Map<String, dynamic>> results = await db.query(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  static Future<int> addReminders(Map<String, dynamic> reminder) async {
    return await db.insert('reminders', reminder);
  }

  static Future<void> updateReminders(
      int id, Map<String, dynamic> reminder) async {
    await db.update('reminders', reminder, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteReminders(int id) async {
    await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> toggleReminder(int id, bool isActive) async {
    await db.update('reminders', {'isActive': !isActive ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }
}
