import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/dashboard_service.dart';
import '../services/shop_service.dart';

import 'connected_retailers_screen.dart';
import 'my_catalogue_screen.dart';
import 'order_analytics_screen.dart';
import 'product_aggregation_screen.dart';
import 'requirements_screen.dart';
import 'role_selection_screen.dart';
import 'subscription_screen.dart';
import 'supplier_orders_screen.dart';

class SupplierDashboardScreen extends StatefulWidget {
  const SupplierDashboardScreen({super.key});

  @override
  State<SupplierDashboardScreen> createState() =>
      _SupplierDashboardScreenState();
}

class _SupplierDashboardScreenState extends State<SupplierDashboardScreen> {
  bool loading = true;

  String supplierShopId = '';

  int products = 0;
  int retailers = 0;
  int pendingOrders = 0;
  int totalOrders = 0;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    setState(() {
      loading = true;
    });

    final shopId = await ShopService().getShopId();

    supplierShopId = shopId;

    final dashboardService = DashboardService();

    products = await dashboardService.totalProducts(shopId);

    retailers = await dashboardService.connectedRetailers(shopId);

    pendingOrders = await dashboardService.pendingOrders(shopId);

    totalOrders = await dashboardService.totalOrders(shopId);

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      (route) => false,
    );
  }

  Future<void> exitApp() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Exit App'),
          content: const Text('Are you sure you want to exit?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      SystemNavigator.pop();
    }
  }

  Widget metricCard(String title, int value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            children: [
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> copySupplierId() async {
    if (supplierShopId.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: supplierShopId));

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Supplier ID Copied')));
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await exitApp();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Supplier Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: loadDashboard,
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: logout,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: loadDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  child: ListTile(
                    title: const Text('My Shop'),
                    subtitle: Text(
                      supplierShopId.isEmpty
                          ? 'Shop ID Not Found'
                          : supplierShopId,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      tooltip: 'Copy Supplier ID',
                      onPressed: copySupplierId,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    metricCard('Products', products),
                    metricCard('Retailers', retailers),
                  ],
                ),

                Row(
                  children: [
                    metricCard('Pending Orders', pendingOrders),
                    metricCard('Total Orders', totalOrders),
                  ],
                ),

                const SizedBox(height: 16),

                Card(
                  child: ListTile(
                    title: const Text('My Catalogue'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyCatalogueScreen(),
                        ),
                      );
                    },
                  ),
                ),

                Card(
                  child: ListTile(
                    title: const Text('Order Analytics'),
                    subtitle: const Text('Order value and order statistics'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OrderAnalyticsScreen(),
                        ),
                      );
                    },
                  ),
                ),

                Card(
                  child: ListTile(
                    title: const Text('Product Aggregation'),
                    subtitle: const Text(
                      'Total quantity required product wise',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProductAggregationScreen(),
                        ),
                      );
                    },
                  ),
                ),

                Card(
                  child: ListTile(
                    title: const Text('Subscription Status'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SubscriptionScreen(),
                        ),
                      );
                    },
                  ),
                ),

                Card(
                  child: ListTile(
                    title: const Text('Connected Retailers'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ConnectedRetailersScreen(),
                        ),
                      );
                    },
                  ),
                ),

                Card(
                  child: ListTile(
                    title: const Text('Orders'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SupplierOrdersScreen(),
                        ),
                      );
                    },
                  ),
                ),

                Card(
                  child: ListTile(
                    title: const Text('Requirements'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RequirementsScreen(),
                        ),
                      );
                    },
                  ),
                ),

                const Card(
                  child: ListTile(
                    title: Text('Chat'),
                    subtitle: Text('Locked - Coming Soon'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
