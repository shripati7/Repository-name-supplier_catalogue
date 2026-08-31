import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/order_service.dart';
import '../services/shop_service.dart';

class OrderAnalyticsScreen extends StatefulWidget {
  const OrderAnalyticsScreen({super.key});

  @override
  State<OrderAnalyticsScreen> createState() => _OrderAnalyticsScreenState();
}

class _OrderAnalyticsScreenState extends State<OrderAnalyticsScreen> {
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

  String formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }

    return amount.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Order Analytics')),
      body: StreamBuilder<QuerySnapshot>(
        stream: OrderService().supplierOrders(supplierShopId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          int totalOrders = docs.length;

          int pendingOrders = 0;
          int acceptedOrders = 0;
          int partialAcceptedOrders = 0;
          int rejectedOrders = 0;
          int dispatchedOrders = 0;
          int cancelledOrders = 0;

          double totalOrderedValue = 0;
          double totalAcceptedValue = 0;

          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;

            final status = (data['status'] ?? '').toString();

            final price = ((data['price'] ?? 0) as num).toDouble();

            final quantity = ((data['quantity'] ?? 0) as num).toInt();

            final acceptedQuantity =
                ((data['acceptedQuantity'] ?? quantity) as num).toInt();

            totalOrderedValue += price * quantity;

            if (status != 'Rejected' && status != 'Cancelled') {
              totalAcceptedValue += price * acceptedQuantity;
            }

            switch (status) {
              case 'Pending':
                pendingOrders++;
                break;

              case 'Accepted':
                acceptedOrders++;
                break;

              case 'Partial Accepted':
                partialAcceptedOrders++;
                break;

              case 'Rejected':
                rejectedOrders++;
                break;

              case 'Dispatched':
                dispatchedOrders++;
                break;

              case 'Cancelled':
                cancelledOrders++;
                break;
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  title: const Text('Total Orders'),
                  trailing: Text(
                    totalOrders.toString(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              Card(
                child: ListTile(
                  title: const Text('Pending Orders'),
                  trailing: Text(
                    pendingOrders.toString(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              Card(
                child: ListTile(
                  title: const Text('Accepted Orders'),
                  trailing: Text(
                    acceptedOrders.toString(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              Card(
                child: ListTile(
                  title: const Text('Partial Accepted'),
                  trailing: Text(
                    partialAcceptedOrders.toString(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              Card(
                child: ListTile(
                  title: const Text('Rejected Orders'),
                  trailing: Text(
                    rejectedOrders.toString(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              Card(
                child: ListTile(
                  title: const Text('Cancelled Orders'),
                  trailing: Text(
                    cancelledOrders.toString(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              Card(
                child: ListTile(
                  title: const Text('Dispatched Orders'),
                  trailing: Text(
                    dispatchedOrders.toString(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Card(
                child: ListTile(
                  title: const Text('Total Ordered Value'),
                  subtitle: const Text('All retailer orders value'),
                  trailing: Text(
                    '₹ ${formatAmount(totalOrderedValue)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              Card(
                child: ListTile(
                  title: const Text('Total Accepted Value'),
                  subtitle: const Text('Accepted + Partial Accepted value'),
                  trailing: Text(
                    '₹ ${formatAmount(totalAcceptedValue)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
