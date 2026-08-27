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

  Widget buildActionButton(String text, String orderId, String nextStatus) {
    return ElevatedButton(
      onPressed: () async {
        await OrderService().updateStatus(orderId, nextStatus);
      },
      child: Text(text),
    );
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

                      const SizedBox(height: 6),

                      Text('Retailer: ${data['retailerName'] ?? ''}'),

                      Text('Shop ID: ${data['retailerShopId'] ?? ''}'),

                      Text('Brand: ${data['brand'] ?? ''}'),

                      Text('Price: ₹ ${formatPrice(data['price'])}'),

                      Text('Qty: ${data['quantity'] ?? 1}'),

                      Text('Status: $status'),

                      const SizedBox(height: 10),

                      if (status == 'Pending')
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await OrderService().updateStatus(
                                    docs[index].id,
                                    'Accepted',
                                  );
                                },
                                child: const Text('Accept'),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await OrderService().updateStatus(
                                    docs[index].id,
                                    'Rejected',
                                  );
                                },
                                child: const Text('Reject'),
                              ),
                            ),
                          ],
                        ),

                      if (status == 'Accepted')
                        SizedBox(
                          width: double.infinity,
                          child: buildActionButton(
                            'Move To Packing',
                            docs[index].id,
                            'Packing',
                          ),
                        ),

                      if (status == 'Packing')
                        SizedBox(
                          width: double.infinity,
                          child: buildActionButton(
                            'Move To Packed',
                            docs[index].id,
                            'Packed',
                          ),
                        ),

                      if (status == 'Packed')
                        SizedBox(
                          width: double.infinity,
                          child: buildActionButton(
                            'Move To Dispatched',
                            docs[index].id,
                            'Dispatched',
                          ),
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
