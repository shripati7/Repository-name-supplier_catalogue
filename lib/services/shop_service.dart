import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShopService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getShopId() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return '';

    final doc = await _firestore.collection('shops').doc(user.uid).get();

    if (!doc.exists) return '';

    return doc.data()?['shopId'] ?? '';
  }
}
