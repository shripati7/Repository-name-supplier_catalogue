import 'package:flutter/material.dart';
import 'supplier_login_screen.dart';
import 'retailer_login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Role')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SupplierLoginScreen(),
                  ),
                );
              },
              child: const Text('Supplier'),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RetailerLoginScreen(),
                  ),
                );
              },
              child: const Text('Retailer'),
            ),
          ],
        ),
      ),
    );
  }
}
