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

    final shopData = shopDoc.data()!;

    final supplierShopId = (shopData['shopId'] ?? '').toString();

    if (supplierShopId.isEmpty) {
      throw Exception('SHOP NOT FOUND');
    }

    // Subscription Check
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

    // Retailer Lookup
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

    // Same Supplier + Same Retailer Duplicate Check
    final existing = await _firestore
        .collection('supplier_connections')
        .where('supplierShopId', isEqualTo: supplierShopId)
        .where('retailerId', isEqualTo: retailerId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('Retailer already connected');
    }

    final batch = _firestore.batch();

    batch.set(_firestore.collection('supplier_connections').doc(), {
      // Supplier
      'supplierShopId': supplierShopId,
      'supplierName': shopData['shopName'] ?? '',
      'supplierMobile1': shopData['mobile1'] ?? '',

      // Retailer
      'retailerId': retailerId,
      'retailerShopId': retailerData['retailerShopId'] ?? '',

      'retailerName': retailerData['retailerName'] ?? '',

      'ownerName': retailerData['ownerName'] ?? '',

      'retailerMobile1': retailerData['mobile1'] ?? '',

      'connectedAt': FieldValue.serverTimestamp(),
    });

    batch.update(_firestore.collection('subscriptions').doc(user.uid), {
      'connectedRetailers': FieldValue.increment(1),
    });

    await batch.commit();
  }

  Stream<QuerySnapshot> retailersBySupplier(String supplierShopId) {
    return _firestore
        .collection('supplier_connections')
        .where('supplierShopId', isEqualTo: supplierShopId)
        .snapshots();
  }

  Stream<QuerySnapshot> suppliersByRetailer(String retailerId) {
    return _firestore
        .collection('supplier_connections')
        .where('retailerId', isEqualTo: retailerId)
        .snapshots();
  }
}
