import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/cart_service.dart';
import '../services/product_service.dart';
import 'cart_screen.dart';
import 'my_orders_screen.dart';
import 'retailer_order_analytics_screen.dart';
import 'role_selection_screen.dart';

class RetailerCatalogueScreen extends StatefulWidget {
  final String shopId;

  const RetailerCatalogueScreen({super.key, required this.shopId});

  @override
  State<RetailerCatalogueScreen> createState() =>
      _RetailerCatalogueScreenState();
}

class _RetailerCatalogueScreenState extends State<RetailerCatalogueScreen> {
  String searchText = '';

  Future<void> logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      (route) => false,
    );
  }

  Future<void> confirmExit() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Exit App'),
          content: const Text('Are you sure you want to exit?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (shouldExit == true) {
      SystemNavigator.pop();
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await confirmExit();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Catalogue - ${widget.shopId}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.receipt_long),
              tooltip: 'My Orders',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                );
              },
            ),

            IconButton(
              icon: const Icon(Icons.analytics),
              tooltip: 'Order Analytics',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RetailerOrderAnalyticsScreen(),
                  ),
                );
              },
            ),

            IconButton(
              icon: const Icon(Icons.shopping_cart),
              tooltip: 'Cart',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
            ),

            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: logout,
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search Product Or Brand',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value.trim().toLowerCase();
                  });
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: ProductService().productsByShopId(widget.shopId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allDocs = snapshot.data!.docs;

                  final docs = allDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    final productName = (data['productName'] ?? '')
                        .toString()
                        .toLowerCase();

                    final brand = (data['brand'] ?? '')
                        .toString()
                        .toLowerCase();

                    if (searchText.isEmpty) {
                      return true;
                    }

                    return productName.contains(searchText) ||
                        brand.contains(searchText);
                  }).toList();

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('No Matching Products Found'),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
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
                              Text('MOQ: ${data['moq'] ?? 1}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_shopping_cart),
                            onPressed: () async {
                              await CartService().addToCart(
                                productId: docs[index].id,
                                supplierShopId: widget.shopId,
                                productName: data['productName'] ?? '',
                                category: data['category'] ?? '',
                                brand: data['brand'] ?? '',
                                price: (data['price'] ?? 0).toDouble(),
                                moq: (data['moq'] ?? 1) as int,
                                imageUrl: data['imageUrl'] ?? '',
                              );

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Added To Cart'),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
