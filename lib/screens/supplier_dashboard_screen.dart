import 'package:flutter/material.dart';

import 'my_catalogue_screen.dart';
import 'subscription_screen.dart';

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
            const Card(
              child: ListTile(
                title: Text('Connected Retailers'),
                subtitle: Text('Coming Soon'),
              ),
            ),
            const Card(
              child: ListTile(
                title: Text('Orders'),
                subtitle: Text('Coming Soon'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
