import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/product_model.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart'; // <-- استيراد شاشة التعديل

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("المنتجات"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: const InputDecoration(
                labelText: 'ابحث عن منتج...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').orderBy('name').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('لا توجد منتجات مضافة'));
                }

                final allProducts = snapshot.data!.docs;
                final filteredProducts = _searchQuery.isEmpty
                    ? allProducts
                    : allProducts.where((doc) {
                        final productName = (doc.data() as Map<String, dynamic>)['name']?.toString().toLowerCase() ?? '';
                        return productName.contains(_searchQuery);
                      }).toList();
                
                if (filteredProducts.isEmpty) {
                  return const Center(child: Text('لا توجد نتائج مطابقة للبحث'));
                }

                return ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (ctx, index) {
                    final doc = filteredProducts[index];
                    final product = Product.fromMap(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    );
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(product.quantity.toString()),
                        ),
                        title: Text(product.name),
                        subtitle: Text('السعر: ${product.price.toStringAsFixed(0)} ر.ي'),
                        trailing: const Icon(Icons.edit, color: Colors.blue),
                        onTap: () {
                          // --- الربط مع شاشة التعديل ---
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => EditProductScreen(product: product),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const AddProductScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
