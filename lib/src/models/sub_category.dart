import 'package:sendme_outlet/src/common/app_functions.dart';

class SubCategory {
  int? subCategoryId;
  int? priority;
  int? isDeleted;
  int? categoryId;
  int? isActive;

  String? subCategoryName;
  String? imageURL;

  SubCategory({
    this.subCategoryId,
    this.priority,
    this.isDeleted,
    this.categoryId,
    this.isActive,
    this.subCategoryName,
    this.imageURL,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      subCategoryId: funToInt(json['subCategoryId']),
      priority: funToInt(json['priority']),
      isDeleted: funToInt(json['isDeleted']),
      categoryId: funToInt(json['categoryId']),
      isActive: funToInt(json['isActive']),
      subCategoryName: funToString(json['subCategoryName']),
      imageURL: funToString(json['imageURL']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subCategoryId': subCategoryId,
      'priority': priority,
      'isDeleted': isDeleted,
      'categoryId': categoryId,
      'isActive': isActive,
      'subCategoryName': subCategoryName,
      'imageURL': imageURL,
    };
  }
}
