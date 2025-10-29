class SaleItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price; // سعر الوحدة عند البيع

  SaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  // دالة لحساب الإجمالي لهذا السطر (الكمية * السعر)
  double get totalPrice => quantity * price;

  // تحويل من وإلى Map للتحدث مع Firebase
  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      productId: map['productId'],
      productName: map['productName'],
      quantity: map['quantity'],
      price: (map['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }
}
