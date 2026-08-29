import 'package:flutter/material.dart';

import '../services/dashboard_service.dart';
import '../services/shop_service.dart';

import 'connected_retailers_screen.dart';
import 'my_catalogue_screen.dart';
import 'product_aggregation_screen.dart';
import 'requirements_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: loadDashboard,
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
                  title: const Text('Product Aggregation'),
                  subtitle: const Text('Total quantity required product wise'),
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
    );
  }
}
