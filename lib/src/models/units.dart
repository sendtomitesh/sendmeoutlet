import 'package:sendme_outlet/src/common/app_functions.dart';

class Units {
  int? id;
  String? unit;

  Units({this.id, this.unit});

  Units.fromJson(Map<String, dynamic> json) {
    id = funToInt(json['Id']);
    unit = funToString(json['Unit']) ?? '';
  }
}
