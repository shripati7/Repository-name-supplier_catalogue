class CategoryModel {
  final String id;
  final String name;
  final String parentCategoryId;
  final bool isMainCategory;

  CategoryModel({
    required this.id,
    required this.name,
    required this.parentCategoryId,
    required this.isMainCategory,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'parentCategoryId': parentCategoryId,
      'isMainCategory': isMainCategory,
    };
  }

  factory CategoryModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return CategoryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      parentCategoryId: map['parentCategoryId'] ?? '',
      isMainCategory: map['isMainCategory'] ?? true,
    );
  }
}
