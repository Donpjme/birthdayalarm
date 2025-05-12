import 'package:flutter/material.dart';
import '../models/birthday.dart';
import 'package:intl/intl.dart';
import 'contact_actions.dart';

class BirthdayCard extends StatelessWidget {
  final Birthday birthday;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BirthdayCard({
    super.key,
    required this.birthday,
    required this.onEdit,
    required this.onDelete,
  });

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  int _daysUntilNextBirthday(DateTime birthDate) {
    final today = DateTime.now();
    final nextBirthday = DateTime(today.year, birthDate.month, birthDate.day);
    if (nextBirthday.isBefore(today)) {
      return DateTime(today.year + 1, birthDate.month, birthDate.day)
          .difference(today)
          .inDays;
    } else {
      return nextBirthday.difference(today).inDays;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final age = _calculateAge(birthday.birthDate);
    final nextBirthday = _daysUntilNextBirthday(birthday.birthDate);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                birthday.fullName[0].toUpperCase(),
                style: TextStyle(color: theme.colorScheme.onPrimary),
              ),
            ),
            title: Text(
              birthday.fullName,
              style: theme.textTheme.titleLarge,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('MMMM d, yyyy').format(birthday.birthDate)),
                Text('Age: $age years'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ContactActions(birthday: birthday),
                PopupMenuButton<String>(
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (nextBirthday <= 30) ...[
            Container(
              color: theme.colorScheme.primaryContainer,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.cake,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    nextBirthday == 0
                        ? 'Birthday today! 🎉'
                        : nextBirthday == 1
                            ? 'Birthday tomorrow!'
                            : '$nextBirthday days until birthday',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}