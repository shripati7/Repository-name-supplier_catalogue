class ProductModel {
  final String id;
  final String supplierId;
  final String shopId;
  final String productName;
  final String category;
  final String brand;
  final String description;
  final double price;
  final int moq;
  final String imageUrl;

  ProductModel({
    required this.id,
    required this.supplierId,
    required this.shopId,
    required this.productName,
    required this.category,
    required this.brand,
    required this.description,
    required this.price,
    required this.moq,
    required this.imageUrl,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ProductModel(
      id: documentId,
      supplierId: map['supplierId'] ?? '',
      shopId: map['shopId'] ?? '',
      productName: map['productName'] ?? '',
      category: map['category'] ?? '',
      brand: map['brand'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      moq: (map['moq'] ?? 1) as int,
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'supplierId': supplierId,
      'shopId': shopId,
      'productName': productName,
      'category': category,
      'brand': brand,
      'description': description,
      'price': price,
      'moq': moq,
      'imageUrl': imageUrl,
    };
  }
}
