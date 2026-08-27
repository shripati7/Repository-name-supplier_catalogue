import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/retailer_model.dart';
import 'retailer_service.dart';

class ConnectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> connectSupplier(String supplierShopId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('USER NULL');
    }

    final RetailerModel? retailer = await RetailerService().getRetailer();

    if (retailer == null) {
      throw Exception('RETAILER NULL');
    }

    await _firestore.collection('connections').doc(user.uid).set({
      'supplierShopId': supplierShopId,
      'retailerId': user.uid,
      'retailerShopId': retailer.retailerShopId,
      'retailerName': retailer.retailerName,
      'ownerName': retailer.ownerName,
      'mobile1': retailer.mobile1,
      'connectedAt': FieldValue.serverTimestamp(),
    });
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
