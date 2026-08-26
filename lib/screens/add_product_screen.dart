import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../services/product_service.dart';
import '../services/storage_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final productNameController = TextEditingController();
  final categoryController = TextEditingController();
  final brandController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  bool loading = false;
  File? selectedImage;

  Future<File?> compressImage(File file) async {
    final dir = await getTemporaryDirectory();

    final targetPath = path.join(
      dir.path,
      'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 40,
    );

    if (result == null) return null;

    return File(result.path);
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();

    final image = await picker.pickImage(source: source);

    if (image == null) return;

    setState(() {
      selectedImage = File(image.path);
    });
  }

  Future<void> showImagePicker() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> saveProduct() async {
    if (productNameController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product name and price required')),
      );
      return;
    }

    setState(() => loading = true);

    String imageUrl = '';

    if (selectedImage != null) {
      final compressedImage = await compressImage(selectedImage!);

      if (compressedImage != null) {
        imageUrl = await StorageService().uploadProductImage(
          compressedImage,
          DateTime.now().millisecondsSinceEpoch.toString(),
        );
      }
    }

    await ProductService().addProduct(
      productName: productNameController.text.trim(),
      category: categoryController.text.trim(),
      brand: brandController.text.trim(),
      description: descriptionController.text.trim(),
      price: double.tryParse(priceController.text.trim()) ?? 0,
      imageUrl: imageUrl,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Product Added')));

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
      appBar: AppBar(title: const Text('Add Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: showImagePicker,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(selectedImage!, fit: BoxFit.cover),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 50),
                          SizedBox(height: 10),
                          Text('Tap to Select Product Image'),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),

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
                onPressed: loading ? null : saveProduct,
                child: Text(loading ? 'Saving...' : 'Save Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
