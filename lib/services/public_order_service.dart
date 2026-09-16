import 'package:cloud_firestore/cloud_firestore.dart';

class PublicOrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> placeOrder({
    required String supplierShopId,
    required String retailerName,
    required String retailerShopName,
    required String retailerMobile,
    required Map<String, dynamic> item,
  }) async {
    final now = DateTime.now();

    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final orderDate = '${now.day} ${months[now.month - 1]} ${now.year}';
    final orderDay = days[now.weekday - 1];

    final quantity = item['quantity'] ?? 1;

    await _firestore.collection('orders').add({
      'supplierShopId': supplierShopId,

      // Public Order Fields
      'retailerId': 'WEB',
      'retailerShopId': retailerShopName,
      'retailerName': retailerName,

      // Keep email empty for public orders
      'retailerEmail': '',

      // Product Fields
      'productId': item['productId'] ?? '',
      'productName': item['productName'] ?? '',
      'category': item['category'] ?? '',
      'brand': item['brand'] ?? '',
      'price': (item['price'] ?? 0).toDouble(),
      'moq': item['moq'] ?? 1,

      // Quantity
      'quantity': quantity,
      'acceptedQuantity': quantity,

      // Dates
      'orderDate': orderDate,
      'orderDay': orderDay,

      // Status
      'status': 'Pending',

      // Public Order Metadata
      'orderSource': 'WEB',
      'retailerMobile': retailerMobile,
      'mobileVerified': false,

      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
