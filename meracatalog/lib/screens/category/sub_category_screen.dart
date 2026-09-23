import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/category_model.dart';
import '../../services/category_service.dart';

class SubCategoryScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const SubCategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<SubCategoryScreen> createState() =>
      _SubCategoryScreenState();
}

class _SubCategoryScreenState
    extends State<SubCategoryScreen> {
  final CategoryService categoryService =
      CategoryService();

  List<CategoryModel> subCategories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSubCategories();
  }

  Future<void> loadSubCategories() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final allCategories =
          await categoryService.getCategories(
        user.uid,
      );

      subCategories = allCategories.where((item) {
        return !item.isMainCategory &&
            item.parentCategoryId ==
                widget.categoryId;
      }).toList();
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addSubCategory() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Sub Category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Sub Category Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final user =
                  FirebaseAuth.instance.currentUser;

              if (user == null) {
                return;
              }

              if (controller.text
                  .trim()
                  .isEmpty) {
                return;
              }

              final subCategory =
                  CategoryModel(
                id: DateTime.now()
                    .millisecondsSinceEpoch
                    .toString(),
                name: controller.text.trim(),
                parentCategoryId:
                    widget.categoryId,
                isMainCategory: false,
              );

              await categoryService
                  .addCategory(
                user.uid,
                subCategory,
              );

              if (!mounted) return;

              Navigator.pop(context);

              await loadSubCategories();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: subCategories.isEmpty
          ? const Center(
              child: Text(
                'No Sub Categories Added',
              ),
            )
          : ListView.builder(
              itemCount:
                  subCategories.length,
              itemBuilder:
                  (context, index) {
                final item =
                    subCategories[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.category,
                    ),
                    title: Text(item.name),
                  ),
                );
              },
            ),
      floatingActionButton:
          FloatingActionButton(
        onPressed: addSubCategory,
        child: const Icon(Icons.add),
      ),
    );
  }
}


