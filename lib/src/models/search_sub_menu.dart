import 'package:sendme_outlet/src/common/app_functions.dart';

class SearchSubMenu {
  int? subItemId;
  String? subItemName;

  SearchSubMenu({this.subItemId, this.subItemName});

  SearchSubMenu.fromJson(Map<String, dynamic> json) {
    subItemId = funToInt(json['subItemId']);
    subItemName = funToString(json['subItemName']);
  }
}
