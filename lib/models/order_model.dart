class OrderModel {
  final String id;
  final String supplierShopId;
  final String retailerId;
  final String retailerShopId;
  final String retailerName;

  final String productId;
  final String productName;
  final String brand;
  final double price;
  final int quantity;

  final String status;

  OrderModel({
    required this.id,
    required this.supplierShopId,
    required this.retailerId,
    required this.retailerShopId,
    required this.retailerName,
    required this.productId,
    required this.productName,
    required this.brand,
    required this.price,
    required this.quantity,
    required this.status,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String documentId) {
    return OrderModel(
      id: documentId,
      supplierShopId: map['supplierShopId'] ?? '',
      retailerId: map['retailerId'] ?? '',
      retailerShopId: map['retailerShopId'] ?? '',
      retailerName: map['retailerName'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      brand: map['brand'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      status: map['status'] ?? 'Pending',
    );
  }
}
