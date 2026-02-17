import 'package:sendme_outlet/src/common/app_functions.dart';
import 'package:sendme_outlet/src/models/address.dart';
import 'package:sendme_outlet/src/models/city.dart';
import 'package:sendme_outlet/src/models/country.dart';

class UserModel {
  int? cityId;
  int? userId;
  int? userType;
  int? addressId;
  int? adminId;
  int? areaId;
  int? adminCityId;

  double? latitude;
  double? longitude;

  String? name;
  String? mobile;
  String? email;
  String? defaultAddress;
  String? registerDate;
  String? adminCountryCode;
  String? countryManagerContact;
  String? cityManagerContact;

  List<AddressModel>? address;
  List<int>? userTypeList;
  List<Country_region>? franchiserAssignCountry;
  List<City>? roleAssignCity;

  UserModel({
    this.userId,
    this.cityId,
    this.name,
    this.email,
    this.userType,
    this.latitude,
    this.longitude,
    this.defaultAddress,
    this.addressId,
    this.address,
    this.adminId,
    this.areaId,
    this.adminCityId,
    this.mobile,
    this.registerDate,
    this.userTypeList,
    this.adminCountryCode,
    this.franchiserAssignCountry,
    this.roleAssignCity,
    this.countryManagerContact,
    this.cityManagerContact,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    cityId = funToInt(json['cityId']);
    userId = funToInt(json['UserId']);
    userType = funToInt(json['userType']);
    addressId = funToInt(json['addressId']);
    adminId = funToInt(json['adminId']);
    areaId = funToInt(json['areaId']);
    adminCityId = funToInt(json['adminCityId']);

    latitude = (funToDouble(json['Latitude']) != '' &&
            funToDouble(json['Latitude']) != null)
        ? funToDouble(json['Latitude'])
        : 0.0;
    longitude = (funToDouble(json['Longitude']) != '' &&
            funToDouble(json['Longitude']) != null)
        ? funToDouble(json['Longitude'])
        : 0.0;

    name = funToString(json['Name']);
    mobile = funToString(json['userMobile']) ?? (funToString(json['Mobile']) ?? '');
    email = funToString(json['email']) != null &&
            funToString(json['email']) != 'null' &&
            funToString(json['email']) != ''
        ? funToString(json['email'])
        : '';
    defaultAddress = funToString(json['DefaultAddress']);
    registerDate = funToString(json['datetime']);
    adminCountryCode = funToString(json['Code']) != null &&
            funToString(json['Code']) != ''
        ? funToString(json['Code'])
        : null;
    countryManagerContact = funToString(json['countryManagerContact']);
    cityManagerContact = funToString(json['cityManagerContact']);

    userTypeList = json['userTypeList'] != null
        ? json['userTypeList'].cast<int>()
        : json['userTypeList'];

    if (json['Address'] != null) {
      address = <AddressModel>[];
      json['Address'].forEach((v) {
        address!.add(AddressModel.fromJson(v));
      });
    }
    if (json['franchiserAssignCountry'] != null) {
      franchiserAssignCountry = <Country_region>[];
      json['franchiserAssignCountry'].forEach((v) {
        franchiserAssignCountry!.add(Country_region.fromJson(v));
      });
    }
    if (json['roleAssignCity'] != null) {
      roleAssignCity = <City>[];
      json['roleAssignCity'].forEach((v) {
        roleAssignCity!.add(City.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['cityId'] = cityId;
    data['adminId'] = adminId;
    data['UserId'] = userId;
    data['Name'] = name;
    data['userMobile'] = mobile;
    data['email'] = email;
    data['userType'] = userType;
    data['Latitude'] = latitude;
    data['Longitude'] = longitude;
    data['DefaultAddress'] = defaultAddress;
    data['AddressId'] = addressId;
    if (address != null) {
      data['Address'] = address!.map((v) => v.toJson()).toList();
    }
    data['adminCityId'] = adminCityId;
    data['datetime'] = registerDate;
    data['userTypeList'] = userTypeList;
    data['Code'] = adminCountryCode;
    if (franchiserAssignCountry != null) {
      data['franchiserAssignCountry'] =
          franchiserAssignCountry!.map((v) => v.toJson()).toList();
    }
    if (roleAssignCity != null) {
      data['roleAssignCity'] =
          roleAssignCity!.map((v) => v.toJson()).toList();
    }
    data['countryManagerContact'] = countryManagerContact;
    data['cityManagerContact'] = cityManagerContact;
    return data;
  }
}
