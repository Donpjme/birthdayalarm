import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/birthday.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';
import '../widgets/contact_picker.dart';

class AddBirthdayScreen extends StatefulWidget {
  const AddBirthdayScreen({super.key});

  @override
  State<AddBirthdayScreen> createState() => _AddBirthdayScreenState();
}

class _AddBirthdayScreenState extends State<AddBirthdayScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Birthday'),
        actions: [
          ContactPicker(
            onContactSelected: (contact) {
              setState(() {
                _firstNameController.text = contact.givenName ?? '';
                _lastNameController.text = contact.familyName ?? '';
                _phoneController.text = contact.phones?.firstOrNull?.value ?? '';
              });
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name *',
                      icon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                    ),
                  ),
                ),
                // Replace ContactPicker with a placeholder or define it properly
                                // ContactPicker(
                                //   onContactSelected: (contact) {
                                //     setState(() {
                                //       _firstNameController.text = contact.givenName ?? '';
                                //       _lastNameController.text = contact.familyName ?? '';
                                //       _phoneController.text = contact.phones?.firstOrNull?.value ?? '';
                                //     });
                                //   },
                                // ),
                                const SizedBox(), // Placeholder until ContactPicker is defined
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                icon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(_selectedDate == null 
                ? 'Select Birthday *' 
                : 'Birthday: ${_formatDate(_selectedDate!)}'),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                icon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveBirthday,
              child: const Text('Save Birthday'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveBirthday() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      try {
        final birthday = Birthday(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          birthDate: _selectedDate!,
          notes: _notesController.text,
          phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
        );

        await DatabaseHelper().insertBirthday(birthday);
        await NotificationService().scheduleNextBirthdayNotification(birthday);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Birthday saved successfully!')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving birthday: ${e.toString()}')),
          );
        }
      }
    } else if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a birthday date')),
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}