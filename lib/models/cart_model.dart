class CartModel {
  final String id;
  final String productId;
  final String supplierShopId;
  final String productName;
  final String brand;
  final double price;
  final int quantity;
  final String imageUrl;

  CartModel({
    required this.id,
    required this.productId,
    required this.supplierShopId,
    required this.productName,
    required this.brand,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  factory CartModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CartModel(
      id: documentId,
      productId: map['productId'] ?? '',
      supplierShopId: map['supplierShopId'] ?? '',
      productName: map['productName'] ?? '',
      brand: map['brand'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'supplierShopId': supplierShopId,
      'productName': productName,
      'brand': brand,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }
}
