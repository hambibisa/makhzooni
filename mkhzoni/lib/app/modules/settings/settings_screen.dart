import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isBackingUp = false;
  bool _isRestoring = false;

  // --- 1. وظيفة النسخ الاحتياطي ---
  Future<void> _createBackup() async {
    if (!mounted) return;
    setState(() => _isBackingUp = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري إنشاء النسخة الاحتياطية...')));

    try {
      final productsSnapshot = await FirebaseFirestore.instance.collection('products').get();
      final clientsSnapshot = await FirebaseFirestore.instance.collection('clients').get();
      final salesSnapshot = await FirebaseFirestore.instance.collection('sales').get();

      final List<Map<String, dynamic>> productsData = productsSnapshot.docs.map((doc) => doc.data()).toList();
      final List<Map<String, dynamic>> clientsData = clientsSnapshot.docs.map((doc) => doc.data()).toList();
      
      // تحويل Timestamps إلى نص ISO8601 String لضمان التوافق
      final List<Map<String, dynamic>> salesData = salesSnapshot.docs.map((doc) {
        var data = doc.data();
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        return data;
      }).toList();

      final Map<String, dynamic> backupData = {
        'products': productsData,
        'clients': clientsData,
        'sales': salesData,
        'backupDate': DateTime.now().toIso8601String(),
      };

      final String jsonString = jsonEncode(backupData);
      final directory = await getApplicationDocumentsDirectory();
      final date = DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now());
      final filePath = '${directory.path}/makhzoni_backup_$date.json';
      final file = File(filePath);
      await file.writeAsString(jsonString);

      await Share.shareXFiles([XFile(filePath)], text: 'ملف النسخة الاحتياطية لتطبيق مخزوني');

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل إنشاء النسخة الاحتياطية: $e')));
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  // --- 2. وظيفة الاستعادة ---
  Future<void> _restoreBackup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الاستعادة'),
        content: const Text('هل أنت متأكد؟ سيتم حذف جميع البيانات الحالية واستبدالها بالبيانات من ملف النسخة الاحتياطية. لا يمكن التراجع عن هذه العملية.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('نعم، استمر', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;
    setState(() => _isRestoring = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري استعادة البيانات...')));

    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
      if (result == null || result.files.single.path == null) {
        throw Exception('لم يتم اختيار ملف.');
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      final collections = ['products', 'clients', 'sales'];
      final batchDelete = FirebaseFirestore.instance.batch();
      for (final collectionName in collections) {
        final snapshot = await FirebaseFirestore.instance.collection(collectionName).get();
        for (final doc in snapshot.docs) {
          batchDelete.delete(doc.reference);
        }
      }
      await batchDelete.commit();

      final batchWrite = FirebaseFirestore.instance.batch();
      
      final products = (backupData['products'] as List).cast<Map<String, dynamic>>();
      for (final data in products) {
        batchWrite.set(FirebaseFirestore.instance.collection('products').doc(), data);
      }

      final clients = (backupData['clients'] as List).cast<Map<String, dynamic>>();
      for (final data in clients) {
        batchWrite.set(FirebaseFirestore.instance.collection('clients').doc(), data);
      }
      
      final sales = (backupData['sales'] as List).cast<Map<String, dynamic>>();
      for (var data in sales) {
        if (data['createdAt'] is String) {
          data['createdAt'] = Timestamp.fromDate(DateTime.parse(data['createdAt']));
        }
        batchWrite.set(FirebaseFirestore.instance.collection('sales').doc(), data);
      }

      await batchWrite.commit();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت استعادة البيانات بنجاح!'), backgroundColor: Colors.green,));

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل في استعادة البيانات: $e')));
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الإعدادات"),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- قسم إدارة البيانات الجديد ---
          const Text('إدارة البيانات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: _isBackingUp ? const CircularProgressIndicator() : const Icon(Icons.cloud_upload, color: Colors.blue),
              title: const Text('إنشاء نسخة احتياطية'),
              subtitle: const Text('حفظ جميع بياناتك في ملف آمن'),
              onTap: _isBackingUp ? null : _createBackup,
            ),
          ),
          Card(
            child: ListTile(
              leading: _isRestoring ? const CircularProgressIndicator() : const Icon(Icons.cloud_download, color: Colors.orange),
              title: const Text('استعادة البيانات من ملف'),
              subtitle: const Text('تحذير: سيتم استبدال البيانات الحالية', style: TextStyle(color: Colors.red)),
              onTap: _isRestoring ? null : _restoreBackup,
            ),
          ),
          
          const Divider(height: 40),

          // --- قسم عن التطبيق (كما كان) ---
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
    );
  }
}
