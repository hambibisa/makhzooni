import 'package:flutter/material.dart';
import 'add_client_screen.dart'; // استيراد الشاشة الجديدة

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  void _navigateToAddClient(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => const AddClientScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("العملاء"),
        backgroundColor: Colors.green,
      ),
      // --- هنا سنعرض قائمة العملاء من Firebase لاحقاً ---
      body: const Center(
        child: Text(
          'قائمة العملاء والديون\nسيتم عرضها هنا قريباً',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
      // إضافة الزر العائم
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddClient(context),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
