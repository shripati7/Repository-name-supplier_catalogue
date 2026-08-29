import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'retailer_service.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> placeOrder(Map<String, dynamic> cartItem) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final retailer = await RetailerService().getRetailer();

    if (retailer == null) return;

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

    await _firestore.collection('orders').add({
      'supplierShopId': cartItem['supplierShopId'] ?? '',

      'retailerId': user.uid,
      'retailerShopId': retailer.retailerShopId,
      'retailerName': retailer.retailerName,
      'retailerEmail': retailer.email,

      'productId': cartItem['productId'] ?? '',
      'productName': cartItem['productName'] ?? '',
      'category': cartItem['category'] ?? '',
      'brand': cartItem['brand'] ?? '',
      'price': (cartItem['price'] ?? 0).toDouble(),
      'moq': cartItem['moq'] ?? 1,
      'quantity': cartItem['quantity'] ?? 1,

      'orderDate': orderDate,
      'orderDay': orderDay,

      'status': 'Pending',

      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> myOrders() {
    final user = FirebaseAuth.instance.currentUser;

    return _firestore
        .collection('orders')
        .where('retailerId', isEqualTo: user!.uid)
        .snapshots();
  }

  Stream<QuerySnapshot> supplierOrders(String supplierShopId) {
    return _firestore
        .collection('orders')
        .where('supplierShopId', isEqualTo: supplierShopId)
        .snapshots();
  }

  Future<void> updateStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
    });
  }

  Future<void> cancelOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': 'Cancelled',
    });
  }
}
