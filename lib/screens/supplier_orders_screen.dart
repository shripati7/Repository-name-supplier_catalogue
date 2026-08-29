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
    'Partial Accepted',
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

  Future<void> showPartialAcceptDialog(String orderId, int orderedQty) async {
    final controller = TextEditingController(text: orderedQty.toString());

    final acceptedQty = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Partial Acceptance'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Accepted Quantity',
              hintText: 'Max $orderedQty',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final qty = int.tryParse(controller.text);

                if (qty == null || qty <= 0 || qty >= orderedQty) {
                  return;
                }

                Navigator.pop(dialogContext, qty);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (acceptedQty == null) return;

    await OrderService().updateAcceptedQuantity(orderId, acceptedQty);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order partially accepted ($acceptedQty/$orderedQty)'),
      ),
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

              final price = (data['price'] ?? 0).toDouble();

              final quantity = ((data['quantity'] ?? 1) as num).toInt();

              final acceptedQuantity =
                  ((data['acceptedQuantity'] ?? quantity) as num).toInt();

              final total = price * acceptedQuantity;

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['productName'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(status),
                      ),

                      const SizedBox(height: 10),

                      Text('Retailer: ${data['retailerName'] ?? ''}'),

                      Text('Shop ID: ${data['retailerShopId'] ?? ''}'),

                      Text('Email: ${data['retailerEmail'] ?? ''}'),

                      const SizedBox(height: 8),

                      Text('Date: ${data['orderDate'] ?? ''}'),

                      Text('Day: ${data['orderDay'] ?? ''}'),

                      const SizedBox(height: 8),

                      Text('Brand: ${data['brand'] ?? ''}'),

                      Text('Price: ₹ ${formatPrice(price)}'),

                      Text('Ordered Qty: $quantity'),

                      Text('Accepted Qty: $acceptedQuantity'),

                      Text(
                        'Total: ₹ ${formatPrice(total)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 12),

                      if (status == 'Pending' || status == 'Accepted')
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              showPartialAcceptDialog(docs[index].id, quantity);
                            },
                            child: const Text('Partially Accept'),
                          ),
                        ),

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
