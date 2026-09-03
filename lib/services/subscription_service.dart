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
      planName: SubscriptionModel.freeTrial,
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

  Future<void> activateBasicPlan() async {
    await _activatePaidPlan(
      planName: SubscriptionModel.basic,
      retailerLimit: 10,
    );
  }

  Future<void> activateSilverPlan() async {
    await _activatePaidPlan(
      planName: SubscriptionModel.silver,
      retailerLimit: 15,
    );
  }

  Future<void> activateGoldPlan() async {
    await _activatePaidPlan(
      planName: SubscriptionModel.gold,
      retailerLimit: 20,
    );
  }

  Future<void> _activatePaidPlan({
    required String planName,
    required int retailerLimit,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final now = DateTime.now();

    final existingDoc = await _firestore
        .collection('subscriptions')
        .doc(user.uid)
        .get();

    int connectedRetailers = 0;

    if (existingDoc.exists) {
      final data = existingDoc.data()!;

      connectedRetailers = (data['connectedRetailers'] ?? 0) as int;
    }

    await _firestore.collection('subscriptions').doc(user.uid).set({
      'supplierId': user.uid,
      'planName': planName,
      'status': 'Active',
      'startDate': now,
      'endDate': now.add(const Duration(days: 30)),
      'retailerLimit': retailerLimit,
      'connectedRetailers': connectedRetailers,
      'freeTrialDays': 0,
    });
  }

  Stream<DocumentSnapshot> getSubscription() {
    final user = FirebaseAuth.instance.currentUser;

    return _firestore.collection('subscriptions').doc(user!.uid).snapshots();
  }

  Future<DocumentSnapshot> getSubscriptionDoc(String supplierId) async {
    return _firestore.collection('subscriptions').doc(supplierId).get();
  }

  Future<bool> isSubscriptionActive(String supplierId) async {
    final doc = await _firestore
        .collection('subscriptions')
        .doc(supplierId)
        .get();

    if (!doc.exists) {
      return false;
    }

    final data = doc.data()!;

    final endDateRaw = data['endDate'];

    if (endDateRaw == null) {
      return false;
    }

    final endDate = (endDateRaw as Timestamp).toDate();

    return DateTime.now().isBefore(endDate);
  }

  Future<void> markExpiredIfNeeded(String supplierId) async {
    final doc = await _firestore
        .collection('subscriptions')
        .doc(supplierId)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;

    final endDateRaw = data['endDate'];

    if (endDateRaw == null) return;

    final endDate = (endDateRaw as Timestamp).toDate();

    if (DateTime.now().isAfter(endDate)) {
      await doc.reference.update({'status': 'Expired'});
    }
  }
}
