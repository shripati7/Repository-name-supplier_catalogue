import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/product_model.dart';
import 'shop_service.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addProduct({
    required String productName,
    required String category,
    required String brand,
    required String description,
    required double price,
    String imageUrl = '',
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final shopId = await ShopService().getShopId();

    await _firestore.collection('products').add({
      'supplierId': user.uid,
      'shopId': shopId,
      'productName': productName,
      'category': category,
      'brand': brand,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> myProducts() {
    final user = FirebaseAuth.instance.currentUser;

    return _firestore
        .collection('products')
        .where('supplierId', isEqualTo: user?.uid)
        .snapshots();
  }

  Stream<QuerySnapshot> productsByShopId(String shopId) {
    debugPrint('QUERY SHOP ID = $shopId');

    return _firestore
        .collection('products')
        .where('shopId', isEqualTo: shopId)
        .snapshots();
  }

  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  Future<void> updateProduct(String productId, ProductModel product) async {
    await _firestore
        .collection('products')
        .doc(productId)
        .update(product.toMap());
  }
}
