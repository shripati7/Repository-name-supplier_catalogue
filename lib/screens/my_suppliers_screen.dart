import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'retailer_catalogue_screen.dart';

class MySuppliersScreen extends StatelessWidget {
  const MySuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final retailerId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('My Suppliers')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('supplier_connections')
            .where('retailerId', isEqualTo: retailerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No Suppliers Connected'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final supplierName = (data['supplierName'] ?? '').toString();

              final supplierShopId = (data['supplierShopId'] ?? '').toString();

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(
                    supplierName.isEmpty ? supplierShopId : supplierName,
                  ),
                  subtitle: Text(supplierShopId),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            RetailerCatalogueScreen(shopId: supplierShopId),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
