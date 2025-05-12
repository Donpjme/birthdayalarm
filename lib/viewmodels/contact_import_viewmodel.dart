import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/birthday.dart';
import '../services/database_helper.dart';

class ContactImportViewModel {
  final DatabaseHelper databaseHelper;
  final VoidCallback onImportComplete;

  ContactImportViewModel({
    required this.databaseHelper,
    required this.onImportComplete,
  });

  Future<String> importContacts() async {
    final permissionStatus = await Permission.contacts.request();
  
    if (!permissionStatus.isGranted) {
      return 'Contacts permission is required';
    }

    try {
      final contacts = await ContactsService.getContacts();
      int importCount = 0;

      for (Contact contact in contacts) {
        if (contact.birthday != null) {
          final birthday = Birthday(
            firstName: contact.givenName ?? '',
            lastName: contact.familyName ?? '',
            birthDate: contact.birthday ?? DateTime.now(),
            phoneNumber: contact.phones?.firstOrNull?.value,
            notes: 'Imported from contacts',
          );

          await databaseHelper.insertBirthday(birthday);
          importCount++;
        }
      }

      onImportComplete();
      return 'Imported $importCount birthdays from contacts';
    } catch (e) {
      return 'Failed to import contacts: $e';
    }
  }
}