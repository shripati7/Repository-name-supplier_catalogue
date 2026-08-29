import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/order_service.dart';
import '../services/shop_service.dart';

class ProductAggregationScreen extends StatefulWidget {
  const ProductAggregationScreen({super.key});

  @override
  State<ProductAggregationScreen> createState() =>
      _ProductAggregationScreenState();
}

class _ProductAggregationScreenState extends State<ProductAggregationScreen> {
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
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Product Aggregation')),
      body: StreamBuilder<QuerySnapshot>(
        stream: OrderService().supplierOrders(supplierShopId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No Orders Found'));
          }

          final Map<String, int> productTotals = {};

          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;

            final status = data['status'] ?? '';

            if (status == 'Rejected' || status == 'Dispatched') {
              continue;
            }

            final productName = (data['productName'] ?? '').toString();

            final quantity = ((data['quantity'] ?? 0) as num).toInt();

            productTotals[productName] =
                (productTotals[productName] ?? 0) + quantity;
          }

          final entries = productTotals.entries.toList();

          entries.sort((a, b) => b.value.compareTo(a.value));

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final item = entries[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(item.key),
                  subtitle: const Text('Total Required Quantity'),
                  trailing: Text(
                    item.value.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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
