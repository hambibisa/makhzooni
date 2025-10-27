import 'package:flutter/material.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

    @override
      Widget build(BuildContext context) {
          return Scaffold(
                appBar: AppBar(
                        title: const Text("المنتجات"),
                                backgroundColor: Colors.green,
                                      ),
                                            body: const Center(
                                                    child: Text('قائمة المنتجات\n(سيتم إضافة المميزات قريبًا)', textAlign: TextAlign.center),
                                                          ),
                                                                floatingActionButton: FloatingActionButton(
                                                                        onPressed: () {
                                                                                  // لاحقًا: فتح إضافة منتج
                                                                                          },
                                                                                                  child: const Icon(Icons.add),
                                                                                                        ),
                                                                                                            );
                                                                                                              }
                                                                                                              }