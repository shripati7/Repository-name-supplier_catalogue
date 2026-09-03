import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateShopScreen extends StatefulWidget {
  const CreateShopScreen({super.key});

  @override
  State<CreateShopScreen> createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends State<CreateShopScreen> {
  final shopNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final mobile1Controller = TextEditingController();
  final mobile2Controller = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final pincodeController = TextEditingController();

  bool loading = false;

  Future<void> createShop() async {
    final shopName = shopNameController.text.trim();
    final ownerName = ownerNameController.text.trim();
    final mobile1 = mobile1Controller.text.trim();
    final mobile2 = mobile2Controller.text.trim();
    final address = addressController.text.trim();
    final city = cityController.text.trim();
    final pincode = pincodeController.text.trim();

    if (shopName.isEmpty ||
        ownerName.isEmpty ||
        mobile1.isEmpty ||
        address.isEmpty ||
        city.isEmpty ||
        pincode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all mandatory fields')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() => loading = false);
        return;
      }

      final shopDoc = await FirebaseFirestore.instance
          .collection('shops')
          .doc(user.uid)
          .get();

      if (shopDoc.exists) {
        final existingShopId = shopDoc.data()?['shopId'] ?? '';

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Shop ID Already Exists: $existingShopId')),
        );

        setState(() => loading = false);
        return;
      }

      final shopId = 'SJ${DateTime.now().millisecondsSinceEpoch}';

      await FirebaseFirestore.instance.collection('shops').doc(user.uid).set({
        'shopId': shopId,

        'shopName': shopName,
        'ownerName': ownerName,

        'mobile1': mobile1,
        'mobile2': mobile2,

        'address': address,
        'city': city,
        'pincode': pincode,

        'supplierEmail': user.email ?? '',

        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Shop Created Successfully: $shopId')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    shopNameController.dispose();
    ownerNameController.dispose();
    mobile1Controller.dispose();
    mobile2Controller.dispose();
    addressController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    super.dispose();
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Shop Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildTextField(
              controller: shopNameController,
              label: 'Shop Name *',
            ),

            buildTextField(
              controller: ownerNameController,
              label: 'Owner Name *',
            ),

            buildTextField(
              controller: mobile1Controller,
              label: 'Mobile 1 *',
              keyboardType: TextInputType.phone,
            ),

            buildTextField(
              controller: mobile2Controller,
              label: 'Mobile 2',
              keyboardType: TextInputType.phone,
            ),

            buildTextField(controller: addressController, label: 'Address *'),

            buildTextField(controller: cityController, label: 'City *'),

            buildTextField(
              controller: pincodeController,
              label: 'Pincode *',
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : createShop,
                child: Text(loading ? 'Creating Shop...' : 'Create Shop'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
