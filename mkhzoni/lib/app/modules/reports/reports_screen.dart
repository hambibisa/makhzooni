import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../sales/sales_history_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // هذه المتغيرات ستحمل قيم التقارير التي سنحسبها
  double _todaySales = 0.0;
  double _monthlySales = 0.0;
  bool _isLoading = true; // لعرض مؤشر التحميل في البداية

  @override
  void initState() {
    super.initState();
    // عند فتح الشاشة، قم بحساب التقارير
    _calculateReports();
  }

  // --- دالة حساب التقارير ---
  Future<void> _calculateReports() async {
    setState(() => _isLoading = true);

    final now = DateTime.now();
    // تحديد بداية اليوم (الساعة 12 صباحاً)
    final startOfToday = DateTime(now.year, now.month, now.day);
    // تحديد بداية الشهر
    final startOfMonth = DateTime(now.year, now.month, 1);

    // 1. جلب فواتير اليوم
    final todaySnapshot = await FirebaseFirestore.instance
        .collection('sales')
        .where('createdAt', isGreaterThanOrEqualTo: startOfToday)
        .get();

    // 2. جلب فواتير الشهر
    final monthSnapshot = await FirebaseFirestore.instance
        .collection('sales')
        .where('createdAt', isGreaterThanOrEqualTo: startOfMonth)
        .get();

    // 3. حساب الإجماليات
    double todayTotal = 0.0;
    for (var doc in todaySnapshot.docs) {
      todayTotal += (doc.data()['totalAmount'] as num).toDouble();
    }

    double monthTotal = 0.0;
    for (var doc in monthSnapshot.docs) {
      monthTotal += (doc.data()['totalAmount'] as num).toDouble();
    }

    // 4. تحديث الواجهة بالنتائج
    if (mounted) {
      setState(() {
        _todaySales = todayTotal;
        _monthlySales = monthTotal;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("التقارير والسجلات"),
        backgroundColor: Colors.green,
        actions: [
          // زر لتحديث التقارير يدوياً
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _calculateReports,
            tooltip: 'تحديث البيانات',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- قسم الملخص المالي ---
          const Text('ملخص مالي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildReportCard(
                      title: 'مبيعات اليوم',
                      value: '${_todaySales.toStringAsFixed(0)} ر.ي',
                      icon: Icons.today,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 10),
                    _buildReportCard(
                      title: 'مبيعات هذا الشهر',
                      value: '${_monthlySales.toStringAsFixed(0)} ر.ي',
                      icon: Icons.calendar_month,
                      color: Colors.orange,
                    ),
                  ],
                ),
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // --- قسم السجلات (كما كان) ---
          const Text('السجلات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.receipt_long, color: Colors.white),
              ),
              title: const Text(
                'سجل المبيعات',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('عرض جميع الفواتير السابقة وتفاصيلها'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const SalesHistoryScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // دالة مساعدة لبناء بطاقات التقارير
  Widget _buildReportCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 5),
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
