import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/sale_model.dart';

class SaleDetailsScreen extends StatelessWidget {
  final Sale sale;

  const SaleDetailsScreen({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('yyyy/MM/dd – hh:mm a').format(sale.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الفاتورة #${sale.id!.substring(0, 6)}'),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- معلومات الفاتورة الأساسية ---
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('رقم الفاتورة:', '#${sale.id!}'),
                  _buildDetailRow('التاريخ:', formattedDate),
                  _buildDetailRow('نوع البيع:', sale.saleType == SaleType.cash ? 'نقدي' : 'آجل (دين)'),
                  if (sale.saleType == SaleType.credit)
                    _buildDetailRow('العميل:', sale.clientName ?? 'غير محدد'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),

          // --- قائمة المنتجات المباعة ---
          const Text('المنتجات المباعة:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),
          // استخدام ListView.builder لعرض قائمة المنتجات
          ListView.builder(
            shrinkWrap: true, // مهم جداً عند وضع ListView داخل ListView آخر
            physics: const NeverScrollableScrollPhysics(), // لمنع التمرير المتعارض
            itemCount: sale.items.length,
            itemBuilder: (ctx, index) {
              final item = sale.items[index];
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(item.productName),
                subtitle: Text('الكمية: ${item.quantity} × السعر: ${item.price.toStringAsFixed(0)}'),
                trailing: Text(
                  '${item.totalPrice.toStringAsFixed(0)} ر.ي',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
          const Divider(),

          // --- الإجمالي ---
          Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'الإجمالي النهائي:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${sale.totalAmount.toStringAsFixed(0)} ر.ي',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // دالة مساعدة لتنسيق عرض التفاصيل
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
