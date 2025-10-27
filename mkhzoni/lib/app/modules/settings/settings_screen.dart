import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

    @override
      Widget build(BuildContext context) {
          return Scaffold(
                appBar: AppBar(
                        title: const Text("الإعدادات"),
                                backgroundColor: Colors.green,
                                      ),
                                            body: Padding(
                                                    padding: const EdgeInsets.all(16),
                                                            child: ListView(
                                                                      children: [
                                                                                  const ListTile(
                                                                                                title: Text("⚙️ إعدادات عامة"),
                                                                                                              subtitle: Text("تخصيص التطبيق حسب رغبتك"),
                                                                                                                          ),
                                                                                                                                      const Divider(),
                                                                                                                                                  const SizedBox(height: 20),
                                                                                                                                                              const Center(
                                                                                                                                                                            child: Text("عن التطبيق", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                                                                                                                                                                        ),
                                                                                                                                                                                                    const SizedBox(height: 10),
                                                                                                                                                                                                                const Center(child: Text("مخزوني - لإدارة محلك التجاري بسهولة")),
                                                                                                                                                                                                                            const SizedBox(height: 16),
                                                                                                                                                                                                                                        const Center(
                                                                                                                                                                                                                                                      child: Text("🔹 برمجة وتطوير: النبراس البعداني (Alnbras Albadani)"),
                                                                                                                                                                                                                                                                  ),
                                                                                                                                                                                                                                                                              const SizedBox(height: 6),
                                                                                                                                                                                                                                                                                          const Center(
                                                                                                                                                                                                                                                                                                        child: Text("📞 الهاتف: +967-XXXXXXXXX\n📧 البريد: alnbras.dev@gmail.com",
                                                                                                                                                                                                                                                                                                                          textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                                                                                                                                                                                                                                                                                                                                      ),
                                                                                                                                                                                                                                                                                                                                                ],
                                                                                                                                                                                                                                                                                                                                                        ),
                                                                                                                                                                                                                                                                                                                                                              ),
                                                                                                                                                                                                                                                                                                                                                                  );
                                                                                                                                                                                                                                                                                                                                                                    }
                                                                                                                                                                                                                                                                                                                                                                    }