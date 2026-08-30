import 'package:flutter/material.dart';

import '../services/retailer_service.dart';
import 'my_orders_screen.dart';

class RetailerProfileScreen extends StatefulWidget {
  const RetailerProfileScreen({super.key});

  @override
  State<RetailerProfileScreen> createState() => _RetailerProfileScreenState();
}

class _RetailerProfileScreenState extends State<RetailerProfileScreen> {
  final retailerNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final mobile1Controller = TextEditingController();
  final mobile2Controller = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final pincodeController = TextEditingController();

  bool loading = false;

  Future<void> saveProfile() async {
    if (retailerNameController.text.trim().isEmpty ||
        ownerNameController.text.trim().isEmpty ||
        mobile1Controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Retailer Name, Owner Name and Mobile Number are required',
          ),
        ),
      );
      return;
    }

    try {
      setState(() => loading = true);

      await RetailerService().saveRetailerProfile(
        retailerName: retailerNameController.text.trim(),
        ownerName: ownerNameController.text.trim(),
        mobile1: mobile1Controller.text.trim(),
        mobile2: mobile2Controller.text.trim(),
        address: addressController.text.trim(),
        city: cityController.text.trim(),
        pincode: pincodeController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile Saved. Wait for supplier connection approval.',
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
      );
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
    retailerNameController.dispose();
    ownerNameController.dispose();
    mobile1Controller.dispose();
    mobile2Controller.dispose();
    addressController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Retailer Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: retailerNameController,
              decoration: const InputDecoration(labelText: 'Retailer Name'),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: ownerNameController,
              decoration: const InputDecoration(labelText: 'Owner Name'),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: mobile1Controller,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Mobile Number 1'),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: mobile2Controller,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Mobile Number 2'),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: addressController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Address'),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: cityController,
              decoration: const InputDecoration(labelText: 'City'),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: pincodeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Pincode'),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : saveProfile,
                child: Text(loading ? 'Saving...' : 'Save Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
