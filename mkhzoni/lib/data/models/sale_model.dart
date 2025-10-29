import 'package:cloud_firestore/cloud_firestore.dart';
import 'sale_item_model.dart';

// نوع البيع: نقدي أم آجل (دين)
enum SaleType { cash, credit }

class Sale {
  final String? id;
  final List<SaleItem> items;
  final double totalAmount;
  final SaleType saleType;
  final String? clientId; // معرّف العميل في حالة البيع الآجل
  final String? clientName; // اسم العميل في حالة البيع الآجل
  final DateTime createdAt;

  Sale({
    this.id,
    required this.items,
    required this.totalAmount,
    required this.saleType,
    this.clientId,
    this.clientName,
    required this.createdAt,
  });

  // تحويل من وإلى Map للتحدث مع Firebase
  factory Sale.fromMap(Map<String, dynamic> map, String documentId) {
    return Sale(
      id: documentId,
      items: (map['items'] as List)
          .map((itemMap) => SaleItem.fromMap(itemMap))
          .toList(),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      saleType: (map['saleType'] == 'credit') ? SaleType.credit : SaleType.cash,
      clientId: map['clientId'],
      clientName: map['clientName'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'saleType': (saleType == SaleType.credit) ? 'credit' : 'cash',
      'clientId': clientId,
      'clientName': clientName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
