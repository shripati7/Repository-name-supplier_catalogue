class ConnectionModel {
  final String id;

  final String supplierShopId;
  final String supplierName;
  final String supplierMobile1;

  final String retailerId;
  final String retailerShopId;
  final String retailerName;
  final String retailerMobile1;

  final String ownerName;

  ConnectionModel({
    required this.id,
    required this.supplierShopId,
    required this.supplierName,
    required this.supplierMobile1,
    required this.retailerId,
    required this.retailerShopId,
    required this.retailerName,
    required this.retailerMobile1,
    required this.ownerName,
  });

  factory ConnectionModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ConnectionModel(
      id: documentId,

      supplierShopId: map['supplierShopId'] ?? '',
      supplierName: map['supplierName'] ?? '',
      supplierMobile1: map['supplierMobile1'] ?? '',

      retailerId: map['retailerId'] ?? '',
      retailerShopId: map['retailerShopId'] ?? '',
      retailerName: map['retailerName'] ?? '',
      retailerMobile1: map['retailerMobile1'] ?? '',

      ownerName: map['ownerName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'supplierShopId': supplierShopId,
      'supplierName': supplierName,
      'supplierMobile1': supplierMobile1,

      'retailerId': retailerId,
      'retailerShopId': retailerShopId,
      'retailerName': retailerName,
      'retailerMobile1': retailerMobile1,

      'ownerName': ownerName,
    };
  }
}
