import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/client_model.dart';

class ClientDetailsScreen extends StatelessWidget {
  final Client client;

  const ClientDetailsScreen({super.key, required this.client});

  // --- هنا سنضيف دالة تسجيل الدفعة لاحقاً ---
  void _showAddPaymentDialog(BuildContext context) {
    final TextEditingController amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('تسجيل دفعة جديدة'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'المبلغ المدفوع',
                prefixText: 'ر.ي ',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال المبلغ';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'الرجاء إدخال مبلغ صحيح';
                }
                if (amount > client.totalDebt) {
                  return 'المبلغ أكبر من الدين الحالي!';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final amountPaid = double.parse(amountController.text);
                  
                  // --- منطق تحديث الدين ---
                  try {
                    final clientRef = FirebaseFirestore.instance.collection('clients').doc(client.id);
                    await clientRef.update({
                      'totalDebt': FieldValue.increment(-amountPaid)
                    });

                    Navigator.of(ctx).pop(); // إغلاق الحوار
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تسجيل الدفعة بنجاح!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                     ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('حدث خطأ: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    // استخدام StreamBuilder للاستماع للتحديثات الفورية على دين العميل
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('clients').doc(client.id).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // تحديث بيانات العميل بالبيانات الحية من الـ stream
        final liveClient = Client.fromMap(snapshot.data!.data() as Map<String, dynamic>, snapshot.data!.id);

        return Scaffold(
          appBar: AppBar(
            title: Text(liveClient.name),
            backgroundColor: Colors.green,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- بطاقة معلومات العميل ---
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.person, 'الاسم:', liveClient.name),
                        const Divider(),
                        _buildInfoRow(Icons.phone, 'الهاتف:', liveClient.phone),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- بطاقة الدين ---
                Card(
                  elevation: 4,
                  color: Colors.red[50],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'إجمالي الدين الحالي',
                          style: TextStyle(fontSize: 18, color: Colors.red),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${liveClient.totalDebt.toStringAsFixed(0)} ر.ي',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(), // لدفع الزر إلى الأسفل

                // --- زر تسجيل دفعة ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.payment),
                    label: const Text('تسجيل دفعة جديدة'),
                    onPressed: () => _showAddPaymentDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(fontSize: 18, fontFamily: 'Cairo'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 15),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
