import 'package:flutter/material.dart';
import 'app/widgets/custom_bottom_nav.dart';
import 'app/modules/home/home_screen.dart';
import 'app/modules/products/products_screen.dart';
import 'app/modules/sales/sales_screen.dart';
import 'app/modules/clients/clients_screen.dart';
import 'app/modules/reports/reports_screen.dart';
import 'app/modules/settings/settings_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mkhzoni/firebase_options.dart';


// هذا هو الكود الجديد
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
            );

              runApp(const MakhzoniApp());
              }
              

  class MakhzoniApp extends StatelessWidget {
    const MakhzoniApp({super.key});

      @override
        Widget build(BuildContext context) {
            return MaterialApp(
                  title: 'مخزوني',
                        debugShowCheckedModeBanner: false,
                              theme: ThemeData(
                                      primarySwatch: Colors.green,
                                               fontFamily: 'Cairo', // يمكنك تفعيل لو أضفت الخط في assets لاحقًا
                                                      scaffoldBackgroundColor: Colors.white,
                                                            ),
                                                                  home: const MainScreen(),
                                                                        // يمكنك إضافة routes هنا لاحقًا
                                                                            );
                                                                              }
                                                                              }

                                                                              class MainScreen extends StatefulWidget {
                                                                                const MainScreen({super.key});

                                                                                  @override
                                                                                    State<MainScreen> createState() => _MainScreenState();
                                                                                    }

                                                                                    class _MainScreenState extends State<MainScreen> {
                                                                                      int _currentIndex = 0;

                                                                                        final List<Widget> _pages = const [
                                                                                            HomeScreen(),
                                                                                                ProductsScreen(),
                                                                                                    SalesScreen(),
                                                                                                        ClientsScreen(),
                                                                                                            ReportsScreen(),
                                                                                                                SettingsScreen(),
                                                                                                                  ];

                                                                                                                    @override
                                                                                                                      Widget build(BuildContext context) {
                                                                                                                          return Scaffold(
                                                                                                                                body: _pages[_currentIndex],
                                                                                                                                      bottomNavigationBar: CustomBottomNav(
                                                                                                                                              currentIndex: _currentIndex,
                                                                                                                                                      onTap: (index) => setState(() => _currentIndex = index),
                                                                                                                                                            ),
                                                                                                                                                                );
                                                                                                                                                                  }
                                                                                                                                                                  }
