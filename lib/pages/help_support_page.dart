import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: const Color(0xFF00C853),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF00C853), Color(0xFF1B5E20)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHelpSection('FAQs', Icons.question_answer, [
              'How do I track my trips?',
              'How are emissions calculated?',
              'How can I edit my profile?',
            ]),
            const Divider(),
            _buildHelpSection('Contact Us', Icons.contact_support, [
              'Email: support@greenmile.com',
              'Phone: +91 123 456 7890',
              'Hours: Mon-Fri 9AM-5PM',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection(String title, IconData icon, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            item,
            style: const TextStyle(color: Colors.white70),
          ),
        )),
        const SizedBox(height: 16),
      ],
    );
  }
}
