import 'package:cloud_firestore/cloud_firestore.dart';

class Client {
  final String? id;
  final String name;
  final String? phone;
  final String? address;
  final double totalDebt; // إجمالي الدين على العميل

  Client({
    this.id,
    required this.name,
    this.phone,
    this.address,
    this.totalDebt = 0.0, // القيمة الافتراضية للدين هي صفر
  });

  // تحويل البيانات من خريطة (Map) إلى كائن (Object) لاستقبالها من Firestore
  factory Client.fromMap(Map<String, dynamic> map, String documentId) {
    return Client(
      id: documentId,
      name: map['name'] ?? 'اسم غير معروف',
      phone: map['phone'],
      address: map['address'],
      totalDebt: (map['totalDebt'] ?? 0.0).toDouble(),
    );
  }

  // تحويل الكائن (Object) إلى خريطة (Map) لإرساله إلى Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'totalDebt': totalDebt,
    };
  }
}
