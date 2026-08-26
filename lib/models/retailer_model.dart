class RetailerModel {
  final String id;
  final String retailerShopId;
  final String retailerName;
  final String ownerName;
  final String mobile1;
  final String mobile2;
  final String address;
  final String city;
  final String pincode;
  final String email;

  RetailerModel({
    required this.id,
    required this.retailerShopId,
    required this.retailerName,
    required this.ownerName,
    required this.mobile1,
    required this.mobile2,
    required this.address,
    required this.city,
    required this.pincode,
    required this.email,
  });

  factory RetailerModel.fromMap(Map<String, dynamic> map, String documentId) {
    return RetailerModel(
      id: documentId,
      retailerShopId: map['retailerShopId'] ?? '',
      retailerName: map['retailerName'] ?? '',
      ownerName: map['ownerName'] ?? '',
      mobile1: map['mobile1'] ?? '',
      mobile2: map['mobile2'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      pincode: map['pincode'] ?? '',
      email: map['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'retailerShopId': retailerShopId,
      'retailerName': retailerName,
      'ownerName': ownerName,
      'mobile1': mobile1,
      'mobile2': mobile2,
      'address': address,
      'city': city,
      'pincode': pincode,
      'email': email,
    };
  }
}
