import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'role_selection_screen.dart';
import 'supplier_dashboard_screen.dart';
import 'retailer_catalogue_screen.dart';
import 'retailer_login_screen.dart';

class StartupRouterScreen extends StatefulWidget {
  const StartupRouterScreen({super.key});

  @override
  State<StartupRouterScreen> createState() => _StartupRouterScreenState();
}

class _StartupRouterScreenState extends State<StartupRouterScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      routeUser();
    });
  }

  Future<void> routeUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      navigateTo(const RoleSelectionScreen());
      return;
    }

    final firestore = FirebaseFirestore.instance;

    try {
      // Supplier Check
      final supplierDoc = await firestore
          .collection('shops')
          .doc(user.uid)
          .get();

      if (supplierDoc.exists) {
        navigateTo(const SupplierDashboardScreen());
        return;
      }

      // Retailer Check
      final retailerDoc = await firestore
          .collection('retailers')
          .doc(user.uid)
          .get();

      if (retailerDoc.exists) {
        final connectionDoc = await firestore
            .collection('connections')
            .doc(user.uid)
            .get();

        if (connectionDoc.exists) {
          final data = connectionDoc.data() ?? {};

          final supplierShopId = (data['supplierShopId'] ?? '').toString();

          navigateTo(RetailerCatalogueScreen(shopId: supplierShopId));
          return;
        }

        navigateTo(const RetailerWaitingScreen());
        return;
      }

      navigateTo(const RoleSelectionScreen());
    } catch (e) {
      navigateTo(const RoleSelectionScreen());
    }
  }

  void navigateTo(Widget screen) {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
