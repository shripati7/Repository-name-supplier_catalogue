import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/order_service.dart';

class RetailerOrderAnalyticsScreen extends StatelessWidget {
  const RetailerOrderAnalyticsScreen({super.key});

  String formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }

    return amount.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Purchase Analytics')),
      body: StreamBuilder<QuerySnapshot>(
        stream: OrderService().myOrders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          debugPrint('RETAILER ANALYTICS DOCS = ${docs.length}');

          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;

            debugPrint(
              'ORDER => '
              '${data['productName']} | '
              '${data['retailerId']} | '
              '${data['status']}',
            );
          }

          int totalOrders = docs.length;

          double totalPurchaseValue = 0;
          double acceptedPurchaseValue = 0;
          double todayPurchaseValue = 0;
          double monthPurchaseValue = 0;

          final now = DateTime.now();

          final Map<String, double> dateWiseTotals = {};

          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;

            final price = ((data['price'] ?? 0) as num).toDouble();

            final quantity = ((data['quantity'] ?? 1) as num).toInt();

            final acceptedQuantity =
                ((data['acceptedQuantity'] ?? quantity) as num).toInt();

            final status = (data['status'] ?? '').toString();

            final orderDate = (data['orderDate'] ?? '').toString();

            final value = price * quantity;
            final acceptedValue = price * acceptedQuantity;

            totalPurchaseValue += value;

            if (status != 'Rejected' && status != 'Cancelled') {
              acceptedPurchaseValue += acceptedValue;
            }

            if (orderDate.isNotEmpty) {
              dateWiseTotals.update(
                orderDate,
                (existing) => existing + acceptedValue,
                ifAbsent: () => acceptedValue,
              );
            }

            final createdAt = data['createdAt'];

            if (createdAt is Timestamp) {
              final date = createdAt.toDate();

              if (date.year == now.year && date.month == now.month) {
                monthPurchaseValue += acceptedValue;
              }

              if (date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day) {
                todayPurchaseValue += acceptedValue;
              }
            }
          }

          final dates = dateWiseTotals.keys.toList();

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
                  title: const Text('Total Purchase Value'),
                  trailing: Text(
                    '₹ ${formatAmount(totalPurchaseValue)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Accepted Purchase Value'),
                  trailing: Text(
                    '₹ ${formatAmount(acceptedPurchaseValue)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Today Purchase Value'),
                  trailing: Text(
                    '₹ ${formatAmount(todayPurchaseValue)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('This Month Purchase Value'),
                  trailing: Text(
                    '₹ ${formatAmount(monthPurchaseValue)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Date Wise Purchase History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (dates.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No Purchase History Found'),
                  ),
                ),
              ...dates.map(
                (date) => Card(
                  child: ListTile(
                    title: Text(date),
                    trailing: Text(
                      '₹ ${formatAmount(dateWiseTotals[date] ?? 0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
