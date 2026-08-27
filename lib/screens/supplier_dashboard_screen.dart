import 'package:flutter/material.dart';

import 'connected_retailers_screen.dart';
import 'my_catalogue_screen.dart';
import 'requirements_screen.dart';
import 'subscription_screen.dart';
import 'supplier_orders_screen.dart';

class SupplierDashboardScreen extends StatelessWidget {
  const SupplierDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Supplier Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
    );
  }
}
