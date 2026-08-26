import 'package:flutter/material.dart';

import 'retailer_catalogue_screen.dart';

class ConnectSupplierScreen extends StatefulWidget {
  const ConnectSupplierScreen({super.key});

  @override
  State<ConnectSupplierScreen> createState() => _ConnectSupplierScreenState();
}

class _ConnectSupplierScreenState extends State<ConnectSupplierScreen> {
  final supplierShopIdController = TextEditingController();

  @override
  void dispose() {
    supplierShopIdController.dispose();
    super.dispose();
  }

  void connectSupplier() {
    final shopId = supplierShopIdController.text.trim();

    if (shopId.isEmpty) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RetailerCatalogueScreen(shopId: shopId),
      ),
    );
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
                onPressed: connectSupplier,
                child: const Text('View Catalogue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
