import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static final String prefUserData = 'UserData';
  static final String prefUserOutletData = 'UserOutletData';
  static final String prefOutletData = 'OutletData';
  static final String prefRiderData = 'RiderData';
  static final String prefAdminData = 'AdminData';
  static final String prefCityData = 'CityData';
  static final String prefAreaData = 'AreaData';
  static final String prefAddressData = 'AddressData';
  static final String prefOnBoardingData = 'OnBoardingData';
  static final String prefUserDetails = 'UserDetails';
  static final String prefAutoRefresh = 'AutoRefresh';
  static final String prefManageByOutlet = 'ManageByOutlet';

  static Future<String?> readStringPref(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<bool> saveStringPref(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }
}
