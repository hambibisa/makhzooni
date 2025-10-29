import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String? id;
    final String name;
      final double price;
        final int quantity;
          final String category;
            final String? barcode;
              final String? imageUrl;

                Product({
                    this.id,
                        required this.name,
                            required this.price,
                                required this.quantity,
                                    this.category = 'غير مصنف', // قيمة افتراضية
                                        this.barcode,
                                            this.imageUrl,
                                              });

                                                // دالة لتحويل بيانات المنتج إلى صيغة Map لإرسالها إلى Firestore
                                                  Map<String, dynamic> toMap() {
                                                      return {
                                                            'name': name,
                                                                  'price': price,
                                                                        'quantity': quantity,
                                                                              'category': category,
                                                                                    'barcode': barcode,
                                                                                          'imageUrl': imageUrl,
                                                                                              };
                                                                                                }

                                                                                                  // دالة لبناء كائن المنتج من بيانات قادمة من Firestore
                                                                                                    factory Product.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
                                                                                                        final data = doc.data()!;
                                                                                                            return Product(
                                                                                                                  id: doc.id,
                                                                                                                        name: data['name'] ?? '',
                                                                                                                              price: (data['price'] ?? 0.0).toDouble(),
                                                                                                                                    quantity: data['quantity'] ?? 0,
                                                                                                                                          category: data['category'] ?? 'غير مصنف',
                                                                                                                                                barcode: data['barcode'],
                                                                                                                                                      imageUrl: data['imageUrl'],
                                                                                                                                                          );
                                                                                                                                                            }
                                                                                                                                                            }
                                                                                                                                                            