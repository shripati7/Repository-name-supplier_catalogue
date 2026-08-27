import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/shop_service.dart';

class RequirementsScreen extends StatefulWidget {
  const RequirementsScreen({super.key});

  @override
  State<RequirementsScreen> createState() => _RequirementsScreenState();
}

class _RequirementsScreenState extends State<RequirementsScreen> {
  String supplierShopId = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadShopId();
  }

  Future<void> loadShopId() async {
    supplierShopId = await ShopService().getShopId();

    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Requirements')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('supplierShopId', isEqualTo: supplierShopId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          final Map<String, int> requirements = {};

          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;

            final status = (data['status'] ?? '').toString();

            if (status == 'Cancelled' || status == 'Rejected') {
              continue;
            }

            final productName = (data['productName'] ?? '').toString();

            final quantity = ((data['quantity'] ?? 0) as num).toInt();

            requirements[productName] =
                (requirements[productName] ?? 0) + quantity;
          }

          if (requirements.isEmpty) {
            return const Center(child: Text('No Requirements Found'));
          }

          final products = requirements.entries.toList();

          products.sort(
            (a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()),
          );

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final item = products[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(item.key),
                  trailing: Text(
                    'Qty ${item.value}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
