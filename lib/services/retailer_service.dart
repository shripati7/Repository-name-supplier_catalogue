import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/retailer_model.dart';

class RetailerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveRetailerProfile({
    required String retailerName,
    required String ownerName,
    required String mobile1,
    required String mobile2,
    required String address,
    required String city,
    required String pincode,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final retailerShopId = 'RT${DateTime.now().millisecondsSinceEpoch}';

    await _firestore.collection('retailers').doc(user.uid).set({
      'retailerShopId': retailerShopId,
      'retailerName': retailerName,
      'ownerName': ownerName,
      'mobile1': mobile1,
      'mobile2': mobile2,
      'address': address,
      'city': city,
      'pincode': pincode,
      'email': user.email ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<RetailerModel?> getRetailer() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    final doc = await _firestore.collection('retailers').doc(user.uid).get();

    if (!doc.exists) return null;

    return RetailerModel.fromMap(doc.data()!, doc.id);
  }
}
