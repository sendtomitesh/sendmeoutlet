import 'package:sendme_outlet/src/common/app_functions.dart';

class Country_region {
  int? id;

  String? name;
  String? countryCode;
  String? code;

  Country_region({
    this.id,
    this.name,
    this.countryCode,
    this.code,
  });

  Country_region.fromJson(Map<String, dynamic> json) {
    id = funToInt(json['Id']);
    name = funToString(json['Name']) ?? '';
    countryCode = funToString(json['CountryCode']) ?? '';
    code = funToString(json['Code']) ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['Id'] = id;
    data['Name'] = name;
    data['CountryCode'] = countryCode;
    data['Code'] = code;
    return data;
  }
}
