import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/product_model.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _barcodeController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // تعبئة الحقول بالبيانات الحالية للمنتج
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _quantityController = TextEditingController(text: widget.product.quantity.toString());
    _barcodeController = TextEditingController(text: widget.product.barcode);
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final updatedProduct = Product(
        id: widget.product.id,
        name: _nameController.text,
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        barcode: _barcodeController.text,
      );

      try {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.product.id)
            .update(updatedProduct.toMap());
            
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحديث المنتج بنجاح!')),
          );
          Navigator.of(context).pop(); // العودة للشاشة السابقة
        }
      } catch (error) {
        // معالجة الخطأ
      } finally {
        if (mounted) setState(() => _isLoading = false);
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
        title: const Text('تعديل المنتج'),
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
                     const SizedBox(height: 16),
                    TextFormField(
                      controller: _barcodeController,
                      decoration: const InputDecoration(labelText: 'رقم الباركود (اختياري)'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateProduct,
                        child: const Text('حفظ التعديلات'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
