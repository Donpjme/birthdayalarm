import 'package:flutter/material.dart';
import '../models/birthday.dart';
import 'package:intl/intl.dart';

class UpcomingBirthdays extends StatelessWidget {
  final List<Birthday> birthdays;

  const UpcomingBirthdays({super.key, required this.birthdays});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Birthdays',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...birthdays.take(3).map((birthday) => ListTile(
                  leading: const Icon(Icons.cake),
                  title: Text(
                    birthday.fullName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(DateFormat('MMMM d').format(birthday.birthDate)),
                )),
          ],
        ),
      ),
    );
  }
}