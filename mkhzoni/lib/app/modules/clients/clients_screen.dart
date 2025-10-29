import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/client_model.dart';
import 'add_client_screen.dart';

// 1. تحويل الشاشة إلى StatefulWidget
class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  // 2. متغير لتخزين نص البحث
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("العملاء"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // 3. إضافة حقل البحث
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: const InputDecoration(
                labelText: 'ابحث عن عميل...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
          ),
          // 4. استخدام StreamBuilder لعرض البيانات المفلترة
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('clients').orderBy('name').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('لا يوجد عملاء مضافون'));
                }

                // --- منطق الفلترة ---
                final allClients = snapshot.data!.docs;
                final filteredClients = _searchQuery.isEmpty
                    ? allClients // إذا كان البحث فارغاً، اعرض كل العملاء
                    : allClients.where((doc) {
                        final clientName = (doc.data() as Map<String, dynamic>)['name']?.toString().toLowerCase() ?? '';
                        return clientName.contains(_searchQuery); // اعرض فقط ما يطابق البحث
                      }).toList();
                
                if (filteredClients.isEmpty) {
                  return const Center(child: Text('لا توجد نتائج مطابقة للبحث'));
                }

                return ListView.builder(
                  itemCount: filteredClients.length,
                  itemBuilder: (ctx, index) {
                    final doc = filteredClients[index];
                    final client = Client.fromMap(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    );
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(client.name),
                        subtitle: Text(client.phone),
                        trailing: Text(
                          'الدين: ${client.totalDebt.toStringAsFixed(0)} ر.ي',
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          // لاحقاً: يمكن فتح شاشة تفاصيل العميل هنا
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const AddClientScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
