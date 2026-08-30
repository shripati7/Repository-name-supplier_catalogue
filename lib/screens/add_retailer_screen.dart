import 'package:flutter/material.dart';

import '../services/connection_service.dart';

class AddRetailerScreen extends StatefulWidget {
  const AddRetailerScreen({super.key});

  @override
  State<AddRetailerScreen> createState() => _AddRetailerScreenState();
}

class _AddRetailerScreenState extends State<AddRetailerScreen> {
  final retailerShopIdController = TextEditingController();
  final mobile1Controller = TextEditingController();

  bool loading = false;

  Future<void> connectRetailer() async {
    final retailerShopId = retailerShopIdController.text.trim();
    final mobile1 = mobile1Controller.text.trim();

    if (retailerShopId.isEmpty || mobile1.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter Retailer Shop ID and Mobile Number'),
        ),
      );
      return;
    }

    try {
      setState(() => loading = true);

      await ConnectionService().connectRetailer(
        retailerShopId: retailerShopId,
        mobile1: mobile1,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Retailer Connected Successfully')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    retailerShopIdController.dispose();
    mobile1Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Retailer')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: retailerShopIdController,
              decoration: const InputDecoration(
                labelText: 'Retailer Shop ID',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: mobile1Controller,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : connectRetailer,
                child: Text(loading ? 'Please Wait...' : 'Connect Retailer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
