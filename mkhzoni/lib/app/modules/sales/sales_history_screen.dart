import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../data/models/sale_model.dart';
import 'sale_details_screen.dart'; // 1. استيراد شاشة تفاصيل الفاتورة

class SalesHistoryScreen extends StatelessWidget {
  const SalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل المبيعات'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sales')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('حدث خطأ في تحميل السجل'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'لا يوجد فواتير مسجلة بعد.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final salesDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: salesDocs.length,
            itemBuilder: (ctx, index) {
              final sale = Sale.fromMap(
                salesDocs[index].data() as Map<String, dynamic>,
                salesDocs[index].id,
              );

              final IconData iconData = sale.saleType == SaleType.cash
                  ? Icons.money_rounded
                  : Icons.person_rounded;
              final Color iconColor = sale.saleType == SaleType.cash
                  ? Colors.blue
                  : Colors.orange;
              
              final String formattedDate = DateFormat('yyyy/MM/dd – hh:mm a').format(sale.createdAt);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: iconColor.withOpacity(0.1),
                    child: Icon(iconData, color: iconColor),
                  ),
                  title: Text(
                    'فاتورة #${sale.id!.substring(0, 6)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    sale.saleType == SaleType.credit
                        ? 'عميل: ${sale.clientName ?? 'غير محدد'}\n$formattedDate'
                        : 'بيع نقدي\n$formattedDate',
                  ),
                  trailing: Text(
                    '${sale.totalAmount.toStringAsFixed(0)} ر.ي',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.green,
                    ),
                  ),
                  isThreeLine: true,
                  // 2. تعديل دالة onTap لفتح شاشة التفاصيل
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => SaleDetailsScreen(sale: sale),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
