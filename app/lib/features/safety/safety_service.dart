import 'package:url_launcher/url_launcher.dart';

class SafetyService {
  static Future<void> sendSos(List<EmergencyContact> contacts, double lat, double lng) async {
    final locationUrl = 'https://maps.google.com/?q=$lat,$lng';
    for (final contact in contacts) {
      final smsBody = 'Mwendo SOS: I need help. Location: $locationUrl';
      final uri = Uri.parse('sms:${contact.phone}?body=${Uri.encodeComponent(smsBody)}');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }
}

class EmergencyContact {
  final String name;
  final String phone;
  final String relationship;

  EmergencyContact({required this.name, required this.phone, required this.relationship});

  factory EmergencyContact.fromJson(Map<String, dynamic> j) => EmergencyContact(
        name: j['name'] ?? '',
        phone: j['phone'] ?? '',
        relationship: j['relationship'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'relationship': relationship,
      };
}