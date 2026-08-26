import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/product_service.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late final TextEditingController productNameController;
  late final TextEditingController categoryController;
  late final TextEditingController brandController;
  late final TextEditingController descriptionController;
  late final TextEditingController priceController;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    productNameController = TextEditingController(
      text: widget.product.productName,
    );

    categoryController = TextEditingController(text: widget.product.category);

    brandController = TextEditingController(text: widget.product.brand);

    descriptionController = TextEditingController(
      text: widget.product.description,
    );

    priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
  }

  Future<void> updateProduct() async {
    if (productNameController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty) {
      return;
    }

    setState(() => loading = true);

    final updatedProduct = ProductModel(
      id: widget.product.id,
      supplierId: widget.product.supplierId,
      shopId: widget.product.shopId,
      productName: productNameController.text.trim(),
      category: categoryController.text.trim(),
      brand: brandController.text.trim(),
      description: descriptionController.text.trim(),
      price: double.tryParse(priceController.text.trim()) ?? 0,
      imageUrl: widget.product.imageUrl,
    );

    await ProductService().updateProduct(widget.product.id, updatedProduct);

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  void dispose() {
    productNameController.dispose();
    categoryController.dispose();
    brandController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: productNameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: brandController,
              decoration: const InputDecoration(labelText: 'Brand'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : updateProduct,
                child: Text(loading ? 'Updating...' : 'Update Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
