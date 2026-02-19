import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';

import 'package:sendme_outlet/src/common/app_functions.dart';

import 'dart:async';

class GlobalConstants {
  static String? FIREBASE_TOKEN = '';
  static StreamController<String> streamController = StreamController<String>.broadcast();

  static String App_Version = '';
  static String Device_Id = '';
  static int? Device_Type;

  static String? intPhoneCountryCode = 'IN';

  static double latitude = 0.0;
  static double longitude = 0.0;

  /// User address coordinates (used in Add Order)
  static double userAddressLatitude = 0.0;
  static double userAddressLongitude = 0.0;

  /// Outlet constants
  static int Outlet = 1;
  static int? outletCityId;
  static String? outletCountryCode;
  static String? outletCurrency;
  static int? outletStatus;
  static int? themeId;
  static int? isMedicine;
  static int isOutlet = 0;
  static int? AdmincityId;
  static int? userType;

  /// Order status constants (for outlet home orders)
  static final int ORDER_PENDING = 1;
  static final int USER_CANCELLED = 2;
  static final int HOTEL_CANCELLED = 3;
  static final int ADMIN_CANCELLED = 3;
  static final int SENDME_CANCELLED = 4;
  static final int HOTEL_ACCEPTED = 5;
  static final int ADMIN_ACCEPTED = 5;
  static final int SENDME_ACCEPTED = 6;
  static final int ORDER_PICKED = 7;
  static final int ORDER_DELIVERED = 8;
  static final int ORDER_PREPARED = 11;

  /// User type
  static final int Customer = 2;

  /// Payment mode
  static final int CASH = 1;

  /// Delivery type
  static final int HOME_DELIVERY = 1;
  static final int TAKE_AWAY = 2;
  static final int Grocery_Store_UI = 3;
  static final int Grocery_Menu_UI = 4;

  /// Catalogue tab state
  static int tabControllerCategoryId = 0;
  static int tabControllerSubCategoryId = 0;
  static int forceUpdate = 1;
  static int? isForceUpdate;
  static String? Live_App_Version;
  static String? Package_Name;

  /// Format currency amount for display (handles num or String price)
  static String formatCurrency(dynamic currency, dynamic price) {
    final p = funToDouble(price) ?? 0.0;
    final point = p.truncateToDouble() == p ? 0 : 2;
    final formatter = '$currency' == 'Rs'
        ? NumberFormat.currency(decimalDigits: point, locale: 'HI', symbol: '')
        : NumberFormat.currency(decimalDigits: point, locale: 'en', symbol: '');
    return formatter.format(p);
  }

  static Future<bool> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi);
  }
}
