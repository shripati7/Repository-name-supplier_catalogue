import 'package:flutter/material.dart';

import '../services/public_order_service.dart';

class PublicCheckoutScreen extends StatefulWidget {
  final String supplierShopId;
  final List<Map<String, dynamic>> cartItems;

  const PublicCheckoutScreen({
    super.key,
    required this.supplierShopId,
    required this.cartItems,
  });

  @override
  State<PublicCheckoutScreen> createState() => _PublicCheckoutScreenState();
}

class _PublicCheckoutScreenState extends State<PublicCheckoutScreen> {
  final retailerNameController = TextEditingController();
  final shopNameController = TextEditingController();
  final mobileController = TextEditingController();

  bool loading = false;

  String formatPrice(dynamic price) {
    final value = (price ?? 0).toDouble();

    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  double getTotal() {
    double total = 0;

    for (final item in widget.cartItems) {
      total +=
          ((item['price'] ?? 0).toDouble()) * ((item['quantity'] ?? 1) as int);
    }

    return total;
  }

  Future<void> placeOrder() async {
    final retailerName = retailerNameController.text.trim();

    final shopName = shopNameController.text.trim();

    final mobile = mobileController.text.trim();

    if (retailerName.isEmpty || shopName.isEmpty || mobile.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => loading = true);

    try {
      final service = PublicOrderService();

      for (final item in widget.cartItems) {
        await service.placeOrder(
          supplierShopId: widget.supplierShopId,
          retailerName: retailerName,
          retailerShopName: shopName,
          retailerMobile: mobile,
          item: item,
        );
      }

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            title: const Text('Order Sent'),
            content: const Text('Your order has been sent successfully.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();

                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    retailerNameController.dispose();
    shopNameController.dispose();
    mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = getTotal();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: retailerNameController,
              decoration: const InputDecoration(
                labelText: 'Retailer Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: shopNameController,
              decoration: const InputDecoration(
                labelText: 'Shop Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: mobileController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Items: ${widget.cartItems.length}'),
                    const SizedBox(height: 8),
                    Text(
                      'Total ₹ ${formatPrice(total)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : placeOrder,
                child: Text(loading ? 'Submitting...' : 'Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
