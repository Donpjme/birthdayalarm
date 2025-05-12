import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/birthday.dart';

class ContactActions extends StatelessWidget {
  final Birthday birthday;

  const ContactActions({super.key, required this.birthday});

  Future<void> _sendWhatsApp(String name, String? phoneNumber) async {
    if (phoneNumber == null) return;
    
    final message = Uri.encodeFull('Happy Birthday $name! 🎉🎂');
    final whatsappUrl = 'whatsapp://send?phone=$phoneNumber&text=$message';
    
    if (await canLaunchUrlString(whatsappUrl)) {
      await launchUrlString(whatsappUrl);
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

  Future<void> _sendSMS(String name, String? phoneNumber) async {
    if (phoneNumber == null) return;
    
    final message = Uri.encodeFull('Happy Birthday $name! 🎉🎂');
    final smsUrl = 'sms:$phoneNumber?body=$message';
    
    if (await canLaunchUrlString(smsUrl)) {
      await launchUrlString(smsUrl);
    } else {
      throw 'Could not launch SMS';
    }
  }

  Future<void> _sendMessage(String contactMethod, String name, String? phoneNumber) async {
    try {
      switch (contactMethod) {
        case 'whatsapp':
          await _sendWhatsApp(name, phoneNumber);
          break;
        case 'sms':
          await _sendSMS(name, phoneNumber);
          break;
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (birthday.phoneNumber == null) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.whatsapp),
          onPressed: () => _sendMessage('whatsapp', birthday.fullName, birthday.phoneNumber),
          tooltip: 'Send WhatsApp message',
        ),
        IconButton(
          icon: const Icon(Icons.sms),
          onPressed: () => _sendMessage('sms', birthday.fullName, birthday.phoneNumber),
          tooltip: 'Send SMS',
        ),
      ],
    );
  }
}