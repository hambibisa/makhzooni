import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
    final Function(int) onTap;

      const CustomBottomNav({
          super.key,
              required this.currentIndex,
                  required this.onTap,
                    });

                      @override
                        Widget build(BuildContext context) {
                            return BottomNavigationBar(
                                  currentIndex: currentIndex,
                                        selectedItemColor: Colors.green,
                                              unselectedItemColor: Colors.grey,
                                                    type: BottomNavigationBarType.fixed,
                                                          onTap: onTap,
                                                                items: const [
                                                                        BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
                                                                                BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: "المنتجات"),
                                                                                        BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: "المبيعات"),
                                                                                                BottomNavigationBarItem(icon: Icon(Icons.people), label: "العملاء"),
                                                                                                        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "التقارير"),
                                                                                                                BottomNavigationBarItem(icon: Icon(Icons.settings), label: "الإعدادات"),
                                                                                                                      ],
                                                                                                                          );
                                                                                                                            }
                                                                                                                            }