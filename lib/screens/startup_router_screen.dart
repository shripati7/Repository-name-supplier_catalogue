import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'my_suppliers_screen.dart';
import 'retailer_catalogue_screen.dart';
import 'retailer_login_screen.dart';
import 'role_selection_screen.dart';
import 'supplier_dashboard_screen.dart';

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
      final supplierDoc = await firestore
          .collection('shops')
          .doc(user.uid)
          .get();

      if (supplierDoc.exists) {
        navigateTo(const SupplierDashboardScreen());
        return;
      }

      final retailerDoc = await firestore
          .collection('retailers')
          .doc(user.uid)
          .get();

      if (retailerDoc.exists) {
        final suppliers = await firestore
            .collection('supplier_connections')
            .where('retailerId', isEqualTo: user.uid)
            .get();

        if (suppliers.docs.isEmpty) {
          navigateTo(const RetailerWaitingScreen());
          return;
        }

        if (suppliers.docs.length == 1) {
          final data = suppliers.docs.first.data();

          navigateTo(
            RetailerCatalogueScreen(
              shopId: (data['supplierShopId'] ?? '').toString(),
            ),
          );
          return;
        }

        navigateTo(const MySuppliersScreen());
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
