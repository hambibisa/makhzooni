import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; // لاستقبال أخطاء الماسح
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart'; // 1. استيراد الحزمة
import '../../data/models/product_model.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _barcodeController = TextEditingController(); // 2. متحكم لحقل الباركود

  bool _isLoading = false;

  // 3. دالة مسح الباركود
  Future<void> _scanBarcode() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // لون الشريط
        'إلغاء',    // نص زر الإلغاء
        true,       // تفعيل الفلاش
        ScanMode.BARCODE, // تحديد نوع المسح (باركود)
      );
    } on PlatformException {
      barcodeScanRes = 'فشل في الحصول على إصدار المنصة.';
    }

    if (!mounted) return;

    // إذا لم يقم المستخدم بالإلغاء (الماسح يعيد '-1' عند الإلغاء)
    if (barcodeScanRes != '-1') {
      setState(() {
        _barcodeController.text = barcodeScanRes; // 4. وضع الرقم في حقل الباركود
      });
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final newProduct = Product(
        name: _nameController.text,
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        barcode: _barcodeController.text, // حفظ الباركود
      );

      try {
        await FirebaseFirestore.instance.collection('products').add(newProduct.toMap());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تمت إضافة المنتج بنجاح!')),
          );
          Navigator.of(context).pop();
        }
      } catch (error) {
        // ... (معالجة الخطأ)
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة منتج جديد'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // --- حقل الباركود وزر المسح ---
                    TextFormField(
                      controller: _barcodeController,
                      decoration: InputDecoration(
                        labelText: 'رقم الباركود (اختياري)',
                        // 5. إضافة زر المسح داخل الحقل
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: _scanBarcode,
                          tooltip: 'مسح باركود',
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'اسم المنتج'),
                      validator: (value) => value!.isEmpty ? 'الرجاء إدخال اسم المنتج' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'سعر البيع'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'الرجاء إدخال السعر' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'الكمية المتاحة'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'الرجاء إدخال الكمية' : null,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProduct,
                        child: const Text('حفظ المنتج'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
