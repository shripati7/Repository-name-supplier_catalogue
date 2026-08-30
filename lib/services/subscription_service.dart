import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/subscription_model.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createFreeSubscription() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final startDate = DateTime.now();

    final subscription = SubscriptionModel(
      supplierId: user.uid,
      planName: 'Free Trial',
      status: 'Active',
      startDate: startDate,
      endDate: startDate.add(const Duration(days: 60)),
      retailerLimit: 5,
      connectedRetailers: 0,
      freeTrialDays: 60,
    );

    await _firestore
        .collection('subscriptions')
        .doc(user.uid)
        .set(subscription.toMap());
  }

  Stream<DocumentSnapshot> getSubscription() {
    final user = FirebaseAuth.instance.currentUser;

    return _firestore.collection('subscriptions').doc(user!.uid).snapshots();
  }

  Future<DocumentSnapshot> getSubscriptionDoc(String supplierId) async {
    return _firestore.collection('subscriptions').doc(supplierId).get();
  }
}
