import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const ProductDetailScreen({super.key, required this.data});

  String formatPrice(dynamic price) {
    final value = (price ?? 0).toDouble();

    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = (data['imageUrl'] ?? '').toString();

    return Scaffold(
      appBar: AppBar(title: Text(data['productName'] ?? 'Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              Center(
                child: Image.network(
                  imageUrl,
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),

            const SizedBox(height: 20),

            Text(
              data['productName'] ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              'Brand: ${data['brand'] ?? ''}',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 10),

            Text(
              '₹ ${formatPrice(data['price'])}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              'MOQ: ${data['moq'] ?? 1}',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              (data['description'] ?? 'No Description Available').toString(),
            ),
          ],
        ),
      ),
    );
  }
}
