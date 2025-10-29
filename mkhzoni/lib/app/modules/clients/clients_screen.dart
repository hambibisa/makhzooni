import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/client_model.dart'; // استيراد نموذج العميل
import 'add_client_screen.dart'; // استيراد شاشة الإضافة

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
      // استخدام StreamBuilder لعرض البيانات الحية من Firebase
      body: StreamBuilder<QuerySnapshot>(
        // الاستماع إلى مجموعة 'clients' وترتيبهم حسب الاسم
        stream: FirebaseFirestore.instance.collection('clients').orderBy('name').snapshots(),
        builder: (context, snapshot) {
          // 1. في حالة التحميل
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. في حالة حدوث خطأ
          if (snapshot.hasError) {
            return const Center(child: Text('حدث خطأ في تحميل البيانات'));
          }

          // 3. في حالة عدم وجود بيانات
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'لا يوجد عملاء حالياً.\nاضغط على زر + لإضافة عميل جديد.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // 4. في حالة وجود بيانات، قم بعرضها
          final clientsDocs = snapshot.data!.docs;
          
          return ListView.builder(
            itemCount: clientsDocs.length,
            itemBuilder: (ctx, index) {
              // تحويل بيانات المستند إلى كائن Client
              final client = Client.fromMap(
                clientsDocs[index].data() as Map<String, dynamic>,
                clientsDocs[index].id,
              );

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[100],
                    child: Text(
                      client.name.isNotEmpty ? client.name[0].toUpperCase() : 'C',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                  title: Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(client.phone ?? 'لا يوجد رقم هاتف'),
                  // لاحقاً، يمكننا عرض إجمالي الدين هنا
                  trailing: Text(
                    '${client.totalDebt.toStringAsFixed(2)} ر.ي',
                    style: TextStyle(
                      color: client.totalDebt > 0 ? Colors.red : Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    // لاحقاً: يمكننا فتح صفحة تفاصيل العميل هنا
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddClient(context),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
