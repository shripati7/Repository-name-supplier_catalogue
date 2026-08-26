import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateShopScreen extends StatefulWidget {
  const CreateShopScreen({super.key});

  @override
  State<CreateShopScreen> createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends State<CreateShopScreen> {
  bool loading = false;

  Future<void> createShop() async {
    setState(() => loading = true);

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() => loading = false);
      return;
    }

    final shopDoc = await FirebaseFirestore.instance
        .collection('shops')
        .doc(user.uid)
        .get();

    // Shop already exists
    if (shopDoc.exists) {
      final existingShopId = shopDoc.data()?['shopId'] ?? '';

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Shop ID Already Exists: $existingShopId')),
      );

      setState(() => loading = false);
      return;
    }

    // Create new shop only once
    final shopId = 'SJ${DateTime.now().millisecondsSinceEpoch}';

    await FirebaseFirestore.instance.collection('shops').doc(user.uid).set({
      'shopId': shopId,
      'supplierEmail': user.email,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Shop Created: $shopId')));

    Navigator.pop(context);

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Shop')),
      body: Center(
        child: ElevatedButton(
          onPressed: loading ? null : createShop,
          child: Text(loading ? 'Creating...' : 'Create Shop ID'),
        ),
      ),
    );
  }
}
