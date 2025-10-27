import 'package:flutter/material.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

    @override
      Widget build(BuildContext context) {
          return Scaffold(
                appBar: AppBar(
                        title: const Text("المبيعات"),
                                backgroundColor: Colors.green,
                                      ),
                                            body: const Center(
                                                    child: Text('نقطة البيع (POS) - بيع نقدي/آجل\nسيتم تصميمها لاحقًا', textAlign: TextAlign.center),
                                                          ),
                                                              );
                                                                }
                                                                }