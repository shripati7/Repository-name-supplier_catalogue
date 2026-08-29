import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/cart_service.dart';
import '../services/order_service.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  String formatPrice(dynamic price) {
    final value = (price ?? 0).toDouble();

    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: StreamBuilder<QuerySnapshot>(
        stream: OrderService().myOrders(),
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
                      Text('Brand: ${data['brand'] ?? ''}'),
                      Text('Price: ₹ ${formatPrice(data['price'])}'),
                      Text('Qty: ${data['quantity'] ?? 1}'),
                      Text('Status: $status'),
                      const SizedBox(height: 10),

                      if (status == 'Cancelled' || status == 'Dispatched')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              await CartService().addToCart(
                                productId: data['productId'] ?? '',
                                supplierShopId: data['supplierShopId'] ?? '',
                                productName: data['productName'] ?? '',
                                category: data['category'] ?? '',
                                brand: data['brand'] ?? '',
                                price: (data['price'] ?? 0).toDouble(),
                                moq: (data['moq'] ?? 1) as int,
                                imageUrl: '',
                                quantity: data['quantity'] ?? 1,
                              );

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      status == 'Cancelled'
                                          ? 'Added To Cart For Reorder'
                                          : 'Added To Cart For Repeat Order',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              status == 'Cancelled'
                                  ? 'Reorder'
                                  : 'Repeat Order',
                            ),
                          ),
                        ),

                      if (status == 'Pending')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Cancel Order'),
                                    content: const Text(
                                      'Are you sure you want to cancel this order?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context, false);
                                        },
                                        child: const Text('No'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context, true);
                                        },
                                        child: const Text('Yes'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirm == true) {
                                await OrderService().cancelOrder(
                                  docs[index].id,
                                );
                              }
                            },
                            child: const Text('Cancel Order'),
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
