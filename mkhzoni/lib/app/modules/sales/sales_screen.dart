import 'package:flutter/material.dart';
import '../../data/models/product_model.dart'; // استيراد نموذج المنتج
import '../../data/models/sale_item_model.dart'; // استيراد نموذج بند البيع

// شاشة نقطة البيع الرئيسية
class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  // قائمة المنتجات (مؤقتة - لاحقاً سنقرأها من Firebase)
  final List<Product> _availableProducts = [
    Product(id: 'p1', name: 'تونة الخير', price: 500, quantity: 20),
    Product(id: 'p2', name: 'زيت طبخ', price: 1200, quantity: 15),
    Product(id: 'p3', name: 'سكر 1 كيلو', price: 800, quantity: 30),
  ];

  // سلة المشتريات
  final List<SaleItem> _cart = [];

  // دالة لإضافة منتج إلى السلة
  void _addToCart(Product product) {
    setState(() {
      // التحقق مما إذا كان المنتج موجوداً بالفعل في السلة
      final index = _cart.indexWhere((item) => item.productId == product.id);
      if (index != -1) {
        // إذا كان موجوداً، قم بزيادة الكمية
        final existingItem = _cart[index];
        _cart[index] = SaleItem(
          productId: existingItem.productId,
          productName: existingItem.productName,
          quantity: existingItem.quantity + 1,
          price: existingItem.price,
        );
      } else {
        // إذا لم يكن موجوداً، قم بإضافته
        _cart.add(SaleItem(
          productId: product.id!,
          productName: product.name,
          quantity: 1,
          price: product.price,
        ));
      }
    });
  }

  // حساب إجمالي مبلغ السلة
  double get _cartTotal {
    return _cart.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("نقطة البيع"),
        backgroundColor: Colors.green,
      ),
      body: Row(
        children: [
          // --- الجزء الأيسر: قائمة المنتجات ---
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[100],
              child: ListView.builder(
                itemCount: _availableProducts.length,
                itemBuilder: (ctx, index) {
                  final product = _availableProducts[index];
                  return Card(
                    margin: const EdgeInsets.all(4),
                    child: ListTile(
                      title: Text(product.name),
                      subtitle: Text('${product.price.toStringAsFixed(0)} ر.ي'),
                      trailing: const Icon(Icons.add_shopping_cart, color: Colors.green),
                      onTap: () => _addToCart(product),
                    ),
                  );
                },
              ),
            ),
          ),

          // --- الجزء الأيمن: سلة المشتريات ---
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // رأس القائمة
                const ListTile(
                  leading: Icon(Icons.shopping_cart),
                  title: Text('سلة المشتريات', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const Divider(),
                // قائمة المنتجات في السلة
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
                              // لاحقاً: يمكن إضافة أزرار لزيادة/إنقاص الكمية أو الحذف
                            );
                          },
                        ),
                ),
                const Divider(),
                // الإجمالي وزر إتمام البيع
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
                            // لاحقاً: فتح شاشة إتمام البيع (نقدي أم آجل)
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
