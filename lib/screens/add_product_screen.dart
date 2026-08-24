import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();

  bool loading = false;

  Future<void> saveProduct() async {
    setState(() => loading = true);

    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection('products').add({
      'supplierId': user?.uid,
      'name': nameController.text.trim(),
      'price': priceController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Product Added')));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : saveProduct,
              child: const Text('Save Product'),
            ),
          ],
        ),
      ),
    );
  }
}
