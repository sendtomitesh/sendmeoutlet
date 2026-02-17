import 'package:sendme_outlet/src/common/app_functions.dart';

class Categories {
  int? catId;
  int? hotelId;
  int? outletTypeId;
  int? themeId;
  int? categoryId;
  int? isMedicine;
  int? isFoodType;
  int? categoryStatus;
  int? priority;
  int? categoryOutletId;
  int? isCombo;

  String? catName;
  String? catImage;
  String? category;
  String? imageUrl;

  Categories({
    this.catId,
    this.hotelId,
    this.outletTypeId,
    this.themeId,
    this.categoryId,
    this.isMedicine,
    this.isFoodType,
    this.categoryStatus,
    this.priority,
    this.categoryOutletId,
    this.isCombo,
    this.catName,
    this.catImage,
    this.category,
    this.imageUrl,
  });

  factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(
      catId: funToInt(json['Id']),
      hotelId: funToInt(json['HotelId'] ?? json['hotelId']),
      outletTypeId: funToInt(json['outletTypeId']),
      themeId: funToInt(json['ThemeId']),
      categoryId: funToInt(json['CategoryId']),
      isMedicine: funToInt(json['isMedicine']),
      isFoodType: funToInt(json['isFoodType']),
      categoryStatus: funToInt(json['CategoryStatus']),
      priority: funToInt(json['priority']),
      categoryOutletId: funToInt(json['CategoryOutletId']),
      isCombo: funToInt(json['isCombo']),
      catName: funToString(json['Name']),
      catImage: funToString(json['Image']),
      category: funToString(json['Category']),
      imageUrl: funToString(json['ImageUrl']),
    );
  }
}
