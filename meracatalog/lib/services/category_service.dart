import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> addCategory(
    String userId,
    CategoryModel category,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .doc(category.id)
        .set(category.toMap());
  }

  Future<List<CategoryModel>> getCategories(
    String userId,
  ) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .get();

    return snapshot.docs
        .map(
          (doc) => CategoryModel.fromMap(
            doc.data(),
          ),
        )
        .toList();
  }
}
