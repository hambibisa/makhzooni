import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mkhzoni/app/data/models/product_model.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // <-- الحزمة الجديدة
import 'package:permission_handler/permission_handler.dart'; // <-- حزمة الأذونات

class AddProductScreen extends StatefulWidget {
  final Product? product;
  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _barcodeController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _barcodeController = TextEditingController(text: widget.product?.barcode ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _quantityController = TextEditingController(text: widget.product?.quantity.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    // طلب إذن الكاميرا
    var status = await Permission.camera.request();
    if (status.isGranted) {
      // إظهار شاشة الماسح الضوئي في نافذة منبثقة
      final String? barcode = await showModalBottomSheet<String>(
        context: context,
        builder: (context) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: MobileScanner(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final String? code = barcodes.first.rawValue;
                  if (code != null && Navigator.canPop(context)) {
                    Navigator.of(context).pop(code);
                  }
                }
              },
            ),
          );
        },
      );

      if (barcode != null) {
        setState(() {
          _barcodeController.text = barcode;
        });
      }
    } else {
       if(mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يجب السماح بالوصول إلى الكاميرا لمسح الباركود')),
        );
       }
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final product = Product(
        id: widget.product?.id, // Keep old id if editing
        name: _nameController.text,
        barcode: _barcodeController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        quantity: int.tryParse(_quantityController.text) ?? 0,
      );

      try {
        final collection = FirebaseFirestore.instance.collection('products');
        if (product.id == null) {
          await collection.add(product.toJson());
        } else {
          await collection.doc(product.id).update(product.toJson());
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حفظ المنتج بنجاح!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('حدث خطأ: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'إضافة منتج جديد' : 'تعديل المنتج'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'اسم المنتج'),
                    validator: (value) => value!.isEmpty ? 'الرجاء إدخال اسم المنتج' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _barcodeController,
                    decoration: InputDecoration(
                      labelText: 'الباركود (رمز المنتج)',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: _scanBarcode,
                      ),
                    ),
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
                    decoration: const InputDecoration(labelText: 'الكمية المتوفرة'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'الرجاء إدخال الكمية' : null,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveProduct,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('حفظ'),
                  ),
                ],
              ),
            ),
    );
  }
}
