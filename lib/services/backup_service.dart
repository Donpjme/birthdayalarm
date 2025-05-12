import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../models/birthday.dart';
import 'database_helper.dart';

class BackupService {
  final DatabaseHelper _databaseHelper;

  BackupService(this._databaseHelper);

  Future<void> exportData() async {
    try {
      // Get all birthdays
      final birthdays = await _databaseHelper.getBirthdays();
      
      // Convert to JSON
      final jsonData = json.encode({
        'birthdays': birthdays.map((b) => b.toMap()).toList(),
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      });

      // Create file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/birthday_backup.json');
      await file.writeAsString(jsonData);

      // Share file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Birthday Alarm Backup',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> importData() async {
    try {
      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return false;

      // Read file
      final file = File(result.files.first.path!);
      final jsonString = await file.readAsString();
      final jsonData = json.decode(jsonString);

      // Validate format
      if (!jsonData.containsKey('birthdays')) {
        throw FormatException('Invalid backup file format');
      }

      // Convert and save birthdays
      final birthdays = (jsonData['birthdays'] as List)
          .map((map) => Birthday.fromMap(map as Map<String, dynamic>))
          .toList();

      // Clear existing data and import new
      await _databaseHelper.deleteAllBirthdays();
      for (var birthday in birthdays) {
        await _databaseHelper.insertBirthday(birthday);
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }
}