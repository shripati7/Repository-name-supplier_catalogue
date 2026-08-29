import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addToCart({
    required String productId,
    required String supplierShopId,
    required String productName,
    required String category,
    required String brand,
    required double price,
    required int moq,
    required String imageUrl,
    int? quantity,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final docRef = _firestore
        .collection('retailers')
        .doc(user.uid)
        .collection('cart')
        .doc(productId);

    final doc = await docRef.get();

    if (doc.exists) {
      final existingQty = (doc.data()?['quantity'] ?? moq) as int;

      await docRef.update({'quantity': existingQty + (quantity ?? moq)});
    } else {
      await docRef.set({
        'productId': productId,
        'supplierShopId': supplierShopId,
        'productName': productName,
        'category': category,
        'brand': brand,
        'price': price,
        'moq': moq,
        'quantity': quantity ?? moq,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<QuerySnapshot> myCart() {
    final user = FirebaseAuth.instance.currentUser;

    return _firestore
        .collection('retailers')
        .doc(user!.uid)
        .collection('cart')
        .snapshots();
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final user = FirebaseAuth.instance.currentUser;

    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }

    await _firestore
        .collection('retailers')
        .doc(user!.uid)
        .collection('cart')
        .doc(productId)
        .update({'quantity': quantity});
  }

  Future<void> removeFromCart(String cartId) async {
    final user = FirebaseAuth.instance.currentUser;

    await _firestore
        .collection('retailers')
        .doc(user!.uid)
        .collection('cart')
        .doc(cartId)
        .delete();
  }
}
