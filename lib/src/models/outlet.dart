import 'package:sendme_outlet/src/common/app_functions.dart';
import 'package:sendme_outlet/src/models/city.dart';

class Outlet {
  int? hotelId;
  int? isMedicine;
  int? themeId;
  int? outletTypeId;
  int? deliveryManagedBy;
  int? deliveryPartnerId;
  int? cityId;
  int? userId;

  String? hotel;
  String? imageUrl;
  String? currency;
  String? address;
  String? outletCountryCode;
  String? contact;

  List<City>? roleAssignCity;

  Outlet({
    this.hotelId,
    this.hotel,
    this.outletTypeId,
    this.isMedicine,
    this.themeId,
    this.currency,
    this.imageUrl,
    this.deliveryManagedBy,
    this.address,
    this.outletCountryCode,
    this.deliveryPartnerId,
    this.contact,
    this.roleAssignCity,
    this.cityId,
    this.userId,
  });

  Outlet.fromJson(Map<String, dynamic> json) {
    hotelId = funToInt(json['HotelId']);
    isMedicine = funToInt(json['isMedicine']);
    themeId = funToInt(json['ThemeId']);
    outletTypeId = funToInt(json['outletTypeId']);
    deliveryManagedBy = funToInt(json['DeliveryManagedBy']);
    deliveryPartnerId = funToInt(json['deliveryPartnerId']);
    cityId = funToInt(json['CityId']);
    userId = funToInt(json['UserId']);

    hotel = funToString(json['Hotel']) ?? '';
    imageUrl = funToString(json['ImageUrl']) ?? '';
    currency = funToString(json['currency']);
    address = funToString(json['Address']) ?? '';
    outletCountryCode = funToString(json['OutletCountryCode']);
    contact = funToString(json['Mobile']);

    if (json['roleAssignCity'] != null) {
      roleAssignCity = <City>[];
      json['roleAssignCity'].forEach((v) {
        roleAssignCity!.add(City.fromJson(v));
      });
    }
  }
}
