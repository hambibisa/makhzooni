import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/client_model.dart';
import '../../data/models/sale_item_model.dart';
import '../../data/models/sale_model.dart';

class CheckoutScreen extends StatefulWidget {
  final List<SaleItem> cart;
  final double totalAmount;

  const CheckoutScreen({
    super.key,
    required this.cart,
    required this.totalAmount,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  SaleType _saleType = SaleType.cash; // النوع الافتراضي هو نقدي
  Client? _selectedClient; // العميل المختار في حالة البيع الآجل
  bool _isLoading = false;

  // --- هنا سنضيف دالة حفظ الفاتورة لاحقاً ---
  Future<void> _confirmSale() async {
    // منطق الحفظ سيأتي في الخطوة التالية
    print('نوع البيع: $_saleType');
    if (_saleType == SaleType.credit && _selectedClient != null) {
      print('العميل: ${_selectedClient!.name}');
    }
    print('المبلغ الإجمالي: ${widget.totalAmount}');
    
    // محاكاة للشبكة
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الفاتورة بنجاح (مؤقتاً)')),
      );
      // العودة مرتين: إغلاق شاشة الدفع ثم شاشة نقطة البيع
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إتمام البيع'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عرض المبلغ الإجمالي
            Card(
              color: Colors.green[50],
              child: ListTile(
                title: const Text('المبلغ الإجمالي', style: TextStyle(fontSize: 18)),
                trailing: Text(
                  '${widget.totalAmount.toStringAsFixed(0)} ر.ي',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // اختيار نوع البيع (نقدي أو آجل)
            const Text('اختر نوع البيع:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            RadioListTile<SaleType>(
              title: const Text('بيع نقدي (كاش)'),
              value: SaleType.cash,
              groupValue: _saleType,
              onChanged: (value) => setState(() => _saleType = value!),
            ),
            RadioListTile<SaleType>(
              title: const Text('بيع آجل (دين)'),
              value: SaleType.credit,
              groupValue: _saleType,
              onChanged: (value) => setState(() => _saleType = value!),
            ),
            const Divider(),

            // عرض قائمة العملاء في حالة البيع الآجل
            if (_saleType == SaleType.credit)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text('اختر العميل:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  // قائمة منسدلة لعرض العملاء من Firebase
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('clients').orderBy('name').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      
                      final clientsDocs = snapshot.data!.docs;
                      final clients = clientsDocs.map((doc) => Client.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();

                      return DropdownButtonFormField<Client>(
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        hint: const Text('اختر من قائمة العملاء'),
                        value: _selectedClient,
                        onChanged: (client) => setState(() => _selectedClient = client),
                        items: clients.map((client) {
                          return DropdownMenuItem<Client>(
                            value: client,
                            child: Text(client.name),
                          );
                        }).toList(),
                        validator: (value) {
                          if (_saleType == SaleType.credit && value == null) {
                            return 'الرجاء اختيار عميل للبيع الآجل';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                ],
              ),
            
            const SizedBox(height: 40),

            // زر تأكيد البيع
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_saleType == SaleType.credit && _selectedClient == null) {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('الرجاء اختيار عميل لإتمام البيع الآجل'), backgroundColor: Colors.red),
                    );
                    return;
                  }
                  _confirmSale();
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('تأكيد وحفظ الفاتورة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontFamily: 'Cairo'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
