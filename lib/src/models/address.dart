import 'package:sendme_outlet/src/common/app_functions.dart';

class AddressModel {
  int? addressId;
  int? pincode;
  int? cityId;
  int? countryId;
  int? userId;
  int? areaId;
  int? isPickupDrop;

  double? longitude;
  double? latitude;

  String? address;
  String? landMark;
  String? area;
  String? countryCode;
  String? tag;
  String? contactNo;
  String? contactName;
  String? floor;
  String? countryName;
  String? cityName;
  String? userName;
  String? userContact;
  String? zipcode;
  String? currency;
  String? city;
  String? areaName;

  AddressModel({
    this.addressId,
    this.address,
    this.pincode,
    this.landMark,
    this.longitude,
    this.latitude,
    this.area,
    this.cityId,
    this.countryId,
    this.countryCode,
    this.contactNo,
    this.contactName,
    this.tag,
    this.floor,
    this.countryName,
    this.cityName,
    this.userName,
    this.userContact,
    this.zipcode,
    this.userId,
    this.areaId,
    this.currency,
    this.city,
    this.areaName,
    this.isPickupDrop,
  });

  AddressModel.fromJson(Map<String, dynamic> json) {
    addressId = funToInt(json['AddressId']);
    pincode = funToInt(json['Pincode']);
    cityId = funToInt(json['cityId']);
    countryId = funToInt(json['CountryId']) ?? 0;
    userId = funToInt(json['UserId']);
    areaId = funToInt(json['areaId']);
    isPickupDrop = funToInt(json['isPickupDrop']);

    longitude = funToDouble(json['Longitude']);
    latitude = funToDouble(json['Latitude']);

    address = funToString(json['Address']);
    zipcode = funToString(json['zipcode']) ?? '';
    landMark = funToString(json['LandMark']);
    area = funToString(json['Area']) ?? '';
    countryCode = funToString(json['countryCode']);
    contactNo = funToString(json['contactNo']) != null &&
            funToString(json['contactNo']) != '' &&
            funToString(json['contactNo']) != 'undefined'
        ? funToString(json['contactNo'])
        : null;

    contactName = funToString(json['contactName']) != null &&
            funToString(json['contactName']) != '' &&
            funToString(json['contactName']) != 'undefined'
        ? funToString(json['contactName'])
        : null;
    tag = funToString(json['tag']) != null &&
            funToString(json['tag']) != '' &&
            funToString(json['tag']) != 'undefined'
        ? funToString(json['tag'])
        : 'Other';
    floor = funToString(json['Floor']);
    countryName = funToString(json['countryName']) ?? '';
    cityName = funToString(json['cityName']) ?? '';
    userName = funToString(json['userName']) ?? '';
    userContact = funToString(json['userContact']) ?? '';
    city = funToString(json['city']);
    currency = funToString(json['currency']);
    areaName = funToString(json['area']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['countryName'] = countryName;
    data['cityName'] = cityName;
    data['AddressId'] = addressId;
    data['Address'] = address;
    data['Pincode'] = pincode;
    data['zipcode'] = zipcode;
    data['LandMark'] = landMark;
    data['Longitude'] = longitude;
    data['Latitude'] = latitude;
    data['Area'] = area;
    data['cityId'] = cityId;
    data['CountryId'] = countryId;
    data['countryCode'] = countryCode;
    data['contactNo'] = contactNo;
    data['contactName'] = contactName;
    data['tag'] = tag;
    data['Floor'] = floor;
    data['userName'] = userName;
    data['userContact'] = userContact;
    data['UserId'] = userId;
    data['areaId'] = areaId;
    data['city'] = city;
    data['currency'] = currency;
    data['area'] = areaName;
    data['isPickupDrop'] = isPickupDrop;
    return data;
  }
}
