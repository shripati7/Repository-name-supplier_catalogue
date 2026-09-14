import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'public_cart_screen.dart';

class PublicCatalogueScreen extends StatefulWidget {
  final String shopId;

  const PublicCatalogueScreen({super.key, required this.shopId});

  @override
  State<PublicCatalogueScreen> createState() => _PublicCatalogueScreenState();
}

class _PublicCatalogueScreenState extends State<PublicCatalogueScreen> {
  String searchText = '';

  final List<Map<String, dynamic>> cartItems = [];

  String formatPrice(dynamic price) {
    final value = (price ?? 0).toDouble();

    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  void addToCart(String productId, Map<String, dynamic> product) {
    final existingIndex = cartItems.indexWhere(
      (item) => item['productId'] == productId,
    );

    if (existingIndex >= 0) {
      setState(() {
        cartItems[existingIndex]['quantity'] =
            (cartItems[existingIndex]['quantity'] ?? 1) + 1;
      });
    } else {
      setState(() {
        cartItems.add({
          'productId': productId,
          'supplierShopId': widget.shopId,
          'productName': product['productName'] ?? '',
          'category': product['category'] ?? '',
          'brand': product['brand'] ?? '',
          'price': (product['price'] ?? 0).toDouble(),
          'moq': product['moq'] ?? 1,
          'quantity': product['moq'] ?? 1,
          'imageUrl': product['imageUrl'] ?? '',
        });
      });
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Added To Cart')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catalogue - ${widget.shopId}'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PublicCartScreen(
                        supplierShopId: widget.shopId,
                        cartItems: cartItems,
                      ),
                    ),
                  );
                },
              ),

              if (cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 9,
                    child: Text(
                      cartItems.length.toString(),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
            ],
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
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where('shopId', isEqualTo: widget.shopId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final productName = (data['productName'] ?? '')
                      .toString()
                      .toLowerCase();

                  final brand = (data['brand'] ?? '').toString().toLowerCase();

                  if (searchText.isEmpty) {
                    return true;
                  }

                  return productName.contains(searchText) ||
                      brand.contains(searchText);
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text('No Products Found'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: (data['imageUrl'] ?? '').toString().isNotEmpty
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
                          onPressed: () {
                            addToCart(docs[index].id, data);
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
    );
  }
}
