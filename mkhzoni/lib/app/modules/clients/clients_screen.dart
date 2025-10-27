import 'package:flutter/material.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

    @override
      Widget build(BuildContext context) {
          return Scaffold(
                appBar: AppBar(
                        title: const Text("العملاء"),
                                backgroundColor: Colors.green,
                                      ),
                                            body: const Center(
                                                    child: Text('سجل العملاء والديون\nسيتم الإضافة لاحقًا', textAlign: TextAlign.center),
                                                          ),
                                                              );
                                                                }
                                                                }