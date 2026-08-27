class ConnectionModel {
  final String id;
  final String supplierShopId;
  final String retailerId;
  final String retailerShopId;
  final String retailerName;
  final String ownerName;
  final String mobile1;

  ConnectionModel({
    required this.id,
    required this.supplierShopId,
    required this.retailerId,
    required this.retailerShopId,
    required this.retailerName,
    required this.ownerName,
    required this.mobile1,
  });

  factory ConnectionModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ConnectionModel(
      id: documentId,
      supplierShopId: map['supplierShopId'] ?? '',
      retailerId: map['retailerId'] ?? '',
      retailerShopId: map['retailerShopId'] ?? '',
      retailerName: map['retailerName'] ?? '',
      ownerName: map['ownerName'] ?? '',
      mobile1: map['mobile1'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'supplierShopId': supplierShopId,
      'retailerId': retailerId,
      'retailerShopId': retailerShopId,
      'retailerName': retailerName,
      'ownerName': ownerName,
      'mobile1': mobile1,
    };
  }
}
