import 'package:sendme_outlet/src/common/app_functions.dart';

class ManageOutletStore {
  int? id;
  int? outletId;
  int? isBlocked;
  String? name;
  String? message;
  String? icon;

  ManageOutletStore({
    this.id,
    this.name,
    this.outletId,
    this.message,
    this.icon,
    this.isBlocked,
  });

  factory ManageOutletStore.fromJson(Map<String, dynamic> json) {
    return ManageOutletStore(
      id: funToInt(json['id']),
      outletId: funToInt(json['outletId']),
      isBlocked: funToInt(json['isBlocked']),
      name: funToString(json['name']),
      message: funToString(json['message']) ?? '',
      icon: funToString(json['icon']) ?? '',
    );
  }
}
