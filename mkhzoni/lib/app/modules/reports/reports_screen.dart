import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

    @override
      Widget build(BuildContext context) {
          return Scaffold(
                appBar: AppBar(
                        title: const Text("التقارير"),
                                backgroundColor: Colors.green,
                                      ),
                                            body: const Center(
                                                    child: Text('تقارير يومية/شهرية\nقيد التنفيذ', textAlign: TextAlign.center),
                                                          ),
                                                              );
                                                                }
                                                                }