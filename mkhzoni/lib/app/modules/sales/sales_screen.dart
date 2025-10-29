import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // استيراد Firestore
import '../../data/models/product_model.dart';
import '../../data/models/sale_item_model.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  // سلة المشتريات (تبقى كما هي)
  final List<SaleItem> _cart = [];
  
  // --- تم حذف قائمة المنتجات المؤقتة ---

  void _addToCart(Product product) {
    // التأكد من أن الكمية المتاحة أكبر من صفر
    if (product.quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الكمية نفدت للمنتج: ${product.name}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      final index = _cart.indexWhere((item) => item.productId == product.id);
      if (index != -1) {
        _cart[index] = SaleItem(
          productId: _cart[index].productId,
          productName: _cart[index].productName,
          quantity: _cart[index].quantity + 1,
          price: _cart[index].price,
        );
      } else {
        _cart.add(SaleItem(
          productId: product.id!,
          productName: product.name,
          quantity: 1,
          price: product.price,
        ));
      }
    });
  }

  double get _cartTotal {
    return _cart.fold(0.0, (sum, item) => sum + item.totalPrice);
  }
  
  // دالة لمسح السلة
  void _clearCart() {
    setState(() {
      _cart.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("نقطة البيع"),
        backgroundColor: Colors.green,
        actions: [
          // زر لمسح السلة
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _cart.isEmpty ? null : _clearCart,
            tooltip: 'مسح السلة',
          ),
        ],
      ),
      body: Row(
        children: [
          // --- الجزء الأيسر: قائمة المنتجات من Firebase ---
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[100],
              child: StreamBuilder<QuerySnapshot>(
                // الاستماع إلى مجموعة 'products'
                stream: FirebaseFirestore.instance.collection('products').orderBy('name').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('لا توجد منتجات في المخزون'));
                  }

                  final productsDocs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: productsDocs.length,
                    itemBuilder: (ctx, index) {
                      final product = Product.fromMap(
                        productsDocs[index].data() as Map<String, dynamic>,
                        productsDocs[index].id,
                      );
                      
                      // جعل العنصر غير قابل للاستخدام إذا كانت الكمية صفر
                      final bool isOutOfStock = product.quantity <= 0;

                      return Card(
                        margin: const EdgeInsets.all(4),
                        color: isOutOfStock ? Colors.grey[300] : null,
                        child: ListTile(
                          title: Text(product.name),
                          subtitle: Text('المتاح: ${product.quantity} | السعر: ${product.price.toStringAsFixed(0)} ر.ي'),
                          trailing: isOutOfStock 
                            ? const Text('نفد', style: TextStyle(color: Colors.red))
                            : const Icon(Icons.add_shopping_cart, color: Colors.green),
                          onTap: isOutOfStock ? null : () => _addToCart(product),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // --- الجزء الأيمن: سلة المشتريات (تبقى كما هي) ---
          Expanded(
            flex: 3,
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.shopping_cart),
                  title: Text('سلة المشتريات', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const Divider(),
                Expanded(
                  child: _cart.isEmpty
                      ? const Center(child: Text('السلة فارغة'))
                      : ListView.builder(
                          itemCount: _cart.length,
                          itemBuilder: (ctx, index) {
                            final item = _cart[index];
                            return ListTile(
                              title: Text(item.productName),
                              subtitle: Text('الكمية: ${item.quantity}'),
                              trailing: Text(
                                '${item.totalPrice.toStringAsFixed(0)} ر.ي',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                        ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('الإجمالي:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(
                            '${_cartTotal.toStringAsFixed(0)} ر.ي',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _cart.isEmpty ? null : () {
                            // لاحقاً: فتح شاشة إتمام البيع
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text('إتمام البيع', style: TextStyle(fontSize: 18, fontFamily: 'Cairo')),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
