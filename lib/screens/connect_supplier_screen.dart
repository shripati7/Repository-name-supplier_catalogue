import 'package:flutter/material.dart';

import '../services/connection_service.dart';
import 'my_orders_screen.dart';
import 'retailer_catalogue_screen.dart';

class ConnectSupplierScreen extends StatefulWidget {
  const ConnectSupplierScreen({super.key});

  @override
  State<ConnectSupplierScreen> createState() => _ConnectSupplierScreenState();
}

class _ConnectSupplierScreenState extends State<ConnectSupplierScreen> {
  final supplierShopIdController = TextEditingController();

  bool loading = false;

  Future<void> connectSupplier() async {
    final shopId = supplierShopIdController.text.trim();

    if (shopId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter Supplier Shop ID')));
      return;
    }

    try {
      setState(() => loading = true);

      await ConnectionService().connectSupplier(shopId);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RetailerCatalogueScreen(shopId: shopId),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    supplierShopIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect Supplier')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: supplierShopIdController,
              decoration: const InputDecoration(
                labelText: 'Supplier Shop ID',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : connectSupplier,
                child: Text(loading ? 'Connecting...' : 'View Catalogue'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                  );
                },
                child: const Text('My Orders'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
