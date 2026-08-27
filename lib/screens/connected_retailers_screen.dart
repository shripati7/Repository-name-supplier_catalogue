import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/shop_service.dart';
import '../services/connection_service.dart';

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

    debugPrint('==========================');
    debugPrint('SUPPLIER SHOP ID = $supplierShopId');
    debugPrint('==========================');

    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    debugPrint('QUERY SHOP ID = $supplierShopId');

    return Scaffold(
      appBar: AppBar(title: const Text('Connected Retailers')),
      body: StreamBuilder<QuerySnapshot>(
        stream: ConnectionService().retailersBySupplier(supplierShopId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('FIRESTORE ERROR = ${snapshot.error}');

            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          debugPrint('RETAILERS FOUND = ${docs.length}');

          if (docs.isEmpty) {
            return const Center(child: Text('No Connected Retailers'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              debugPrint('RETAILER DATA = $data');

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
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
