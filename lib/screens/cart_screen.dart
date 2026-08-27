import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/cart_service.dart';
import '../services/order_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

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
      appBar: AppBar(title: const Text('My Cart')),
      body: StreamBuilder<QuerySnapshot>(
        stream: CartService().myCart(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('Cart Is Empty'));
          }

          double totalAmount = 0;

          for (final doc in docs) {
            final item = doc.data() as Map<String, dynamic>;

            totalAmount +=
                ((item['price'] ?? 0).toDouble()) *
                ((item['quantity'] ?? 1) as int);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    final quantity = data['quantity'] ?? 1;

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            ListTile(
                              leading:
                                  (data['imageUrl'] ?? '').toString().isNotEmpty
                                  ? Image.network(
                                      data['imageUrl'],
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.image),

                              title: Text(data['productName'] ?? ''),

                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data['brand'] ?? ''),
                                  Text('₹ ${formatPrice(data['price'])}'),
                                ],
                              ),

                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await CartService().removeFromCart(
                                    docs[index].id,
                                  );
                                },
                              ),
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle),
                                  onPressed: () async {
                                    await CartService().updateQuantity(
                                      docs[index].id,
                                      quantity - 1,
                                    );
                                  },
                                ),

                                Text(
                                  quantity.toString(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                IconButton(
                                  icon: const Icon(Icons.add_circle),
                                  onPressed: () async {
                                    await CartService().updateQuantity(
                                      docs[index].id,
                                      quantity + 1,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Total: ₹ ${formatPrice(totalAmount)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          for (final doc in docs) {
                            final item = doc.data() as Map<String, dynamic>;

                            await OrderService().placeOrder(item);

                            await CartService().removeFromCart(doc.id);
                          }

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Order Placed Successfully'),
                              ),
                            );
                          }
                        },
                        child: const Text('Place Order'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
