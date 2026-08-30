import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/shop_service.dart';
import '../services/connection_service.dart';
import 'add_retailer_screen.dart';

class ConnectedRetailersScreen extends StatefulWidget {
  const ConnectedRetailersScreen({super.key});

  @override
  State<ConnectedRetailersScreen> createState() =>
      _ConnectedRetailersScreenState();
}

class _ConnectedRetailersScreenState extends State<ConnectedRetailersScreen> {
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
      setState(() => loading = false);
    }
  }

  Future<void> openAddRetailer() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddRetailerScreen()),
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connected Retailers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Add Retailer',
            onPressed: openAddRetailer,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ConnectionService().retailersBySupplier(supplierShopId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.people_outline, size: 72),
                    const SizedBox(height: 16),
                    const Text(
                      'No Connected Retailers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: openAddRetailer,
                      icon: const Icon(Icons.person_add),
                      label: const Text('Add Retailer'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.store)),
                  title: Text((data['retailerName'] ?? '').toString()),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Owner: ${(data['ownerName'] ?? '').toString()}'),
                      Text('Mobile: ${(data['mobile1'] ?? '').toString()}'),
                      Text(
                        'Shop ID: ${(data['retailerShopId'] ?? '').toString()}',
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
