import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConnectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> connectRetailer({
    required String retailerShopId,
    required String mobile1,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('USER NULL');
    }

    // Supplier Shop
    final shopDoc = await _firestore.collection('shops').doc(user.uid).get();

    if (!shopDoc.exists) {
      throw Exception('SHOP NOT FOUND');
    }

    final supplierShopId = shopDoc.data()?['shopId'] ?? '';

    if (supplierShopId.isEmpty) {
      throw Exception('SHOP NOT FOUND');
    }

    // Subscription
    final subscriptionDoc = await _firestore
        .collection('subscriptions')
        .doc(user.uid)
        .get();

    if (!subscriptionDoc.exists) {
      throw Exception('SUBSCRIPTION NOT FOUND');
    }

    final subscriptionData = subscriptionDoc.data()!;

    final retailerLimit = (subscriptionData['retailerLimit'] ?? 0) as int;

    final connectedRetailers =
        (subscriptionData['connectedRetailers'] ?? 0) as int;

    if (connectedRetailers >= retailerLimit) {
      throw Exception('Retailer limit reached. Upgrade plan.');
    }

    // Retailer lookup by retailerShopId
    final retailerSnapshot = await _firestore
        .collection('retailers')
        .where('retailerShopId', isEqualTo: retailerShopId)
        .limit(1)
        .get();

    if (retailerSnapshot.docs.isEmpty) {
      throw Exception('Retailer not found');
    }

    final retailerDoc = retailerSnapshot.docs.first;

    final retailerData = retailerDoc.data();

    if ((retailerData['mobile1'] ?? '').toString().trim() != mobile1.trim()) {
      throw Exception('Retailer details do not match');
    }

    final retailerId = retailerDoc.id;

    // Already connected check
    final existingConnection = await _firestore
        .collection('connections')
        .doc(retailerId)
        .get();

    if (existingConnection.exists) {
      throw Exception('Retailer already connected');
    }

    final batch = _firestore.batch();

    batch.set(_firestore.collection('connections').doc(retailerId), {
      'supplierShopId': supplierShopId,
      'retailerId': retailerId,
      'retailerShopId': retailerData['retailerShopId'] ?? '',
      'retailerName': retailerData['retailerName'] ?? '',
      'ownerName': retailerData['ownerName'] ?? '',
      'mobile1': retailerData['mobile1'] ?? '',
      'connectedAt': FieldValue.serverTimestamp(),
    });

    batch.update(_firestore.collection('subscriptions').doc(user.uid), {
      'connectedRetailers': FieldValue.increment(1),
    });

    await batch.commit();
  }

  Future<DocumentSnapshot> getMyConnection() async {
    final user = FirebaseAuth.instance.currentUser;

    return _firestore.collection('connections').doc(user!.uid).get();
  }

  Stream<QuerySnapshot> retailersBySupplier(String supplierShopId) {
    return _firestore
        .collection('connections')
        .where('supplierShopId', isEqualTo: supplierShopId)
        .snapshots();
  }
}
