import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> totalProducts(String supplierShopId) async {
    final snapshot = await _firestore
        .collection('products')
        .where('shopId', isEqualTo: supplierShopId)
        .get();

    return snapshot.docs.length;
  }

  Future<int> connectedRetailers(String supplierShopId) async {
    final snapshot = await _firestore
        .collection('connections')
        .where('supplierShopId', isEqualTo: supplierShopId)
        .get();

    return snapshot.docs.length;
  }

  Future<int> pendingOrders(String supplierShopId) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('supplierShopId', isEqualTo: supplierShopId)
        .where('status', isEqualTo: 'Pending')
        .get();

    return snapshot.docs.length;
  }

  Future<int> totalOrders(String supplierShopId) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('supplierShopId', isEqualTo: supplierShopId)
        .get();

    return snapshot.docs.length;
  }
}
