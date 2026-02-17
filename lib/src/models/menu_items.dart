import 'package:sendme_outlet/src/common/app_functions.dart';

class MenuItems {
  int? categoryItemId;
  int? categoryId;
  int? subCategoryId;
  int? priceId;
  int? status;
  int? outletId;

  double? price;
  double? priority;

  String? name;
  String? description;
  String? imageUrl;
  String? ImageUrl;
  String? imagePath;
  String? currency;

  List<String>? imagePathList;

  MenuItems({
    this.categoryItemId,
    this.categoryId,
    this.subCategoryId,
    this.priceId,
    this.status,
    this.outletId,
    this.price,
    this.priority,
    this.name,
    this.description,
    this.imageUrl,
    this.ImageUrl,
    this.imagePath,
    this.currency,
    this.imagePathList,
  });

  factory MenuItems.fromJson(Map<String, dynamic> json) {
    List<String>? imgList;
    if (json['imagePathList'] != null) {
      imgList = (json['imagePathList'] as List).cast<String>();
    }
    return MenuItems(
      categoryItemId: funToInt(json['CategoryItemId']),
      categoryId: funToInt(json['CategoryId']),
      subCategoryId: funToInt(json['subCategoryId']),
      priceId: funToInt(json['priceId']),
      status: funToInt(json['Status']),
      outletId: funToInt(json['OutletId']),
      price: funToDouble(json['Price']),
      priority: funToDouble(json['Priority']),
      name: funToString(json['Name']),
      description: funToString(json['Description']),
      imageUrl: funToString(json['imageUrl']),
      ImageUrl: funToString(json['ImageUrl']),
      imagePath: funToString(json['imagePath']),
      currency: funToString(json['currency']),
      imagePathList: imgList,
    );
  }
}
