import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/subscription_model.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createFreeSubscription() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final subscription = SubscriptionModel(
      supplierId: user.uid,
      planName: 'Free',
      status: 'Active',
      startDate: DateTime.now(),
      endDate: null,
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
}
