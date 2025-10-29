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
  SaleType _saleType = SaleType.cash;
  Client? _selectedClient;
  bool _isLoading = false;

  // --- دالة حفظ الفاتورة النهائية ---
  Future<void> _confirmSale() async {
    // التحقق من اختيار العميل في حالة البيع الآجل
    if (_saleType == SaleType.credit && _selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار عميل لإتمام البيع الآجل'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. إنشاء كائن الفاتورة
      final newSale = Sale(
        items: widget.cart,
        totalAmount: widget.totalAmount,
        saleType: _saleType,
        clientId: _selectedClient?.id,
        clientName: _selectedClient?.name,
        createdAt: DateTime.now(),
      );

      // 2. استخدام WriteBatch لضمان تنفيذ جميع العمليات معاً
      final batch = FirebaseFirestore.instance.batch();
      final firestore = FirebaseFirestore.instance;

      // 3. إضافة الفاتورة الجديدة إلى مجموعة 'sales'
      final saleRef = firestore.collection('sales').doc();
      batch.set(saleRef, newSale.toMap());

      // 4. تحديث كميات المنتجات في المخزون
      for (final item in widget.cart) {
        final productRef = firestore.collection('products').doc(item.productId);
        // إنقاص الكمية المباعة من الكمية الحالية في المخزون
        batch.update(productRef, {'quantity': FieldValue.increment(-item.quantity)});
      }

      // 5. تحديث إجمالي دين العميل (فقط في حالة البيع الآجل)
      if (_saleType == SaleType.credit && _selectedClient != null) {
        final clientRef = firestore.collection('clients').doc(_selectedClient!.id);
        // زيادة إجمالي الدين على العميل بقيمة الفاتورة
        batch.update(clientRef, {'totalDebt': FieldValue.increment(widget.totalAmount)});
      }

      // 6. تنفيذ جميع العمليات دفعة واحدة
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت عملية البيع بنجاح!'), backgroundColor: Colors.green),
        );
        // العودة إلى الشاشة الرئيسية للتطبيق
        Navigator.of(context).popUntil((route) => route.isFirst);
      }

    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ فادح: $error'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (بقية الواجهة تبقى كما هي بدون تغيير)
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
            if (_saleType == SaleType.credit)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text('اختر العميل:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _confirmSale, // استدعاء الدالة النهائية هنا
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
