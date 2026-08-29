import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/order_service.dart';
import '../services/shop_service.dart';

class SupplierOrdersScreen extends StatefulWidget {
  const SupplierOrdersScreen({super.key});

  @override
  State<SupplierOrdersScreen> createState() => _SupplierOrdersScreenState();
}

class _SupplierOrdersScreenState extends State<SupplierOrdersScreen> {
  String supplierShopId = '';
  bool loading = true;

  final List<String> statuses = [
    'Pending',
    'Accepted',
    'Packing',
    'Packed',
    'Dispatched',
    'Rejected',
  ];

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

  String formatPrice(dynamic price) {
    final value = (price ?? 0).toDouble();

    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
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

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final status = data['status'] ?? 'Pending';

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['productName'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 8),

                      Text('Retailer: ${data['retailerName'] ?? ''}'),

                      Text('Shop ID: ${data['retailerShopId'] ?? ''}'),

                      Text('Email: ${data['retailerEmail'] ?? ''}'),

                      const SizedBox(height: 6),

                      Text('Brand: ${data['brand'] ?? ''}'),

                      Text('Price: ₹ ${formatPrice(data['price'])}'),

                      Text('Qty: ${data['quantity'] ?? 1}'),

                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        initialValue: statuses.contains(status)
                            ? status
                            : 'Pending',
                        decoration: const InputDecoration(
                          labelText: 'Order Status',
                          border: OutlineInputBorder(),
                        ),
                        items: statuses.map((item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (value) async {
                          if (value == null) return;

                          await OrderService().updateStatus(
                            docs[index].id,
                            value,
                          );
                        },
                      ),
                    ],
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
