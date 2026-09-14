import 'package:flutter/material.dart';

import 'public_checkout_screen.dart';

class PublicCartScreen extends StatefulWidget {
  final String supplierShopId;
  final List<Map<String, dynamic>> cartItems;

  const PublicCartScreen({
    super.key,
    required this.supplierShopId,
    required this.cartItems,
  });

  @override
  State<PublicCartScreen> createState() => _PublicCartScreenState();
}

class _PublicCartScreenState extends State<PublicCartScreen> {
  String formatPrice(dynamic price) {
    final value = (price ?? 0).toDouble();

    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  double getTotalAmount() {
    double total = 0;

    for (final item in widget.cartItems) {
      total +=
          ((item['price'] ?? 0).toDouble()) * ((item['quantity'] ?? 1) as int);
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cartItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cart')),
        body: const Center(child: Text('Cart Is Empty')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final item = widget.cartItems[index];

                final quantity = item['quantity'] ?? 1;
                final moq = item['moq'] ?? 1;

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        ListTile(
                          leading:
                              (item['imageUrl'] ?? '').toString().isNotEmpty
                              ? Image.network(
                                  item['imageUrl'],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image),
                          title: Text(item['productName'] ?? ''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['brand'] ?? ''),
                              Text('₹ ${formatPrice(item['price'])}'),
                              Text('MOQ: $moq'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                widget.cartItems.removeAt(index);
                              });
                            },
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle),
                              onPressed: () {
                                if (quantity > moq) {
                                  setState(() {
                                    item['quantity'] = quantity - 1;
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Minimum order quantity is $moq',
                                      ),
                                    ),
                                  );
                                }
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
                              onPressed: () {
                                setState(() {
                                  item['quantity'] = quantity + 1;
                                });
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
                  'Total ₹ ${formatPrice(getTotalAmount())}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      for (final item in widget.cartItems) {
                        final quantity = item['quantity'] ?? 1;

                        final moq = item['moq'] ?? 1;

                        if (quantity < moq) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${item['productName']} requires minimum quantity $moq',
                              ),
                            ),
                          );
                          return;
                        }
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PublicCheckoutScreen(
                            supplierShopId: widget.supplierShopId,
                            cartItems: widget.cartItems,
                          ),
                        ),
                      );
                    },
                    child: const Text('Proceed To Checkout'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
