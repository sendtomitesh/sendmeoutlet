import 'package:sendme_outlet/src/common/app_functions.dart';

class City {
  int? id;

  double? latitude;
  double? longitude;

  String? name;
  String? countryName;
  String? currency;
  String? countryCode;
  String? deliveryPolicy;

  City({
    this.id,
    this.name,
    this.latitude,
    this.longitude,
    this.countryName,
    this.currency,
    this.countryCode,
    this.deliveryPolicy,
  });

  City.fromJson(Map<String, dynamic> json) {
    id = funToInt(json['Id']);
    latitude = funToDouble(json['latitude']);
    longitude = funToDouble(json['longitude']);

    name = funToString(json['Name']);
    countryName = funToString(json['CountryName']);
    currency = funToString(json['Currency']);
    countryCode = funToString(json['Code']) ?? '';
    deliveryPolicy = funToString(json['DeliveryPolicy']) ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['Id'] = id;
    data['Name'] = name;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['CountryName'] = countryName;
    data['Currency'] = currency;
    data['Code'] = countryCode;
    data['DeliveryPolicy'] = deliveryPolicy;
    return data;
  }
}
