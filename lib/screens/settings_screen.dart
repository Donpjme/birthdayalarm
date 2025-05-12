import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/backup_service.dart';
import '../services/database_helper.dart';

class SettingsScreen extends StatefulWidget {
  final DatabaseHelper databaseHelper;

  const SettingsScreen({
    super.key,
    required this.databaseHelper,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);
  int _notificationDays = 1;
  bool _isDarkMode = false;
  late final BackupService _backupService;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _backupService = BackupService(widget.databaseHelper);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _notificationDays = prefs.getInt('notification_days') ?? 1;
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
      final timeString = prefs.getString('notification_time') ?? '09:00';
      final timeParts = timeString.split(':');
      _notificationTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setInt('notification_days', _notificationDays);
    await prefs.setBool('dark_mode', _isDarkMode);
    await prefs.setString(
      'notification_time',
      '${_notificationTime.hour}:${_notificationTime.minute}',
    );
  }

  Future<void> _handleExport() async {
    try {
      await _backupService.exportData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create backup')),
        );
      }
    }
  }

  Future<void> _handleImport() async {
    try {
      final success = await _backupService.importData();
      if (!mounted) return;
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data imported successfully')),
        );
        // Refresh the app
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to import data')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Get birthday reminders'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
                _saveSettings();
              });
            },
          ),
          ListTile(
            title: const Text('Notification Time'),
            subtitle: Text(_notificationTime.format(context)),
            leading: const Icon(Icons.access_time),
            onTap: _selectNotificationTime,
          ),
          ListTile(
            title: const Text('Notify Days Before'),
            subtitle: Text('$_notificationDays days'),
            leading: const Icon(Icons.timer),
            onTap: _selectNotificationDays,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle dark theme'),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
                _saveSettings();
              });
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Export Data'),
            leading: const Icon(Icons.upload),
            onTap: _handleExport,
          ),
          ListTile(
            title: const Text('Import Data'),
            leading: const Icon(Icons.download),
            onTap: _handleImport,
          ),
          const Divider(),
          ListTile(
            title: const Text('About'),
            leading: const Icon(Icons.info),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Birthday Alarm',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(
                  Icons.cake,
                  size: 48,
                  color: Colors.blue,
                ),
                children: [
                  const Text(
                    'A simple birthday reminder app\nDeveloped with ❤️ by Donpj',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _selectNotificationTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
    );
    if (picked != null) {
      setState(() {
        _notificationTime = picked;
        _saveSettings();
      });
    }
  }

  Future<void> _selectNotificationDays() async {
    final int? picked = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Days before birthday'),
        children: [1, 2, 3, 7].map((days) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, days),
            child: Text('$days ${days == 1 ? 'day' : 'days'}'),
          );
        }).toList(),
      ),
    );
    if (picked != null) {
      setState(() {
        _notificationDays = picked;
        _saveSettings();
      });
    }
  }
}