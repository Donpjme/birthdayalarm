import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactPicker extends StatelessWidget {
  final Function(Contact) onContactSelected;

  const ContactPicker({super.key, required this.onContactSelected});

  Future<void> _pickContact(BuildContext context) async {
    final permission = await Permission.contacts.request();
    
    if (permission.isGranted) {
      try {
        final Contact? contact = await ContactsService.openDeviceContactPicker();
        if (contact != null) {
          onContactSelected(contact);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error accessing contacts: $e')),
          );
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contacts permission is required')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.contacts),
      onPressed: () => _pickContact(context),
      tooltip: 'Select from contacts',
    );
  }
}