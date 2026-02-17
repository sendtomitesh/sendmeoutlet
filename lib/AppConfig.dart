import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// App configuration for white-label outlet app.
/// activeApp is resolved at runtime from the app's package/bundle ID,
/// so you only need: flutter run --flavor sendme

/// Active app config - set in main() after reading package name.
/// Defaults to sendme until resolved.
AppConfig activeApp = sendme;

/// Resolves the correct AppConfig from the app's package name.
/// Call this in main() before runApp().
Future<AppConfig> resolveActiveApp() async {
  final packageInfo = await PackageInfo.fromPlatform();
  activeApp = _getAppConfigFromPackageName(packageInfo.packageName);
  return activeApp;
}

AppConfig _getAppConfigFromPackageName(String packageName) {
  // Maps both Android package names and iOS bundle IDs
  switch (packageName) {
    case 'today.sendme.outlet':
    case 'com.vs2.sendme.outlet':
      return sendme;
    case 'today.sendme6app.outlet':
      return sendme6;
    case 'com.eatozfood_outlet':
      return eatoz;
    case 'today.sendmelebanondev.outlet':
      return sendmeLebanon;
    case 'today.talabetak.outlet':
      return sendmeTalabetak;
    case 'today.sendmeshrirampur.outlet':
      return sendmeshrirampur;
    case 'today.tyeb.outlet':
      return tyeb;
    case 'today.hopshop.outlet':
      return hopshop;
    case 'today.sendmetest.outlet':
      return sendmetest;
    default:
      return sendme;
  }
}

// =============================================================================
// OUTLET APP CONFIGS - Must match sendme app configs for same platforms
// =============================================================================

/// SendMe Outlet
AppConfig sendme = AppConfig(
  id: 'send_me',
  name: 'SendMe Outlet',
  color: const Color(0xff29458E),
  packageName: 'today.sendme',
  packagePassword: 'SMWL2022',
  domainName: 'cp-sendme.today',
  termsAndConditionsLink:
      'https://s3.ap-south-1.amazonaws.com/web.sendme.today.in/terms.html',
  privacyPolicyLink:
      'https://s3.ap-south-1.amazonaws.com/web.sendme.today.in/privacypolicy.html',
  whatsappLink: 'https://wa.me/message/TGZLSZYVYVSVC1',
  appType: 1, // Outlet app type
  androidAppLink: 'https://play.google.com/store/apps/details?id=today.sendme',
  iosAppLink: 'https://apps.apple.com/us/app/id1279244554',
  deepLink: 'https://deeplink.sendme.today',
  email: 'admin@sendme.today',
  androidBundle: 'today.sendme.outlet',
  iosBundle: 'com.vs2.sendme.outlet',
  iosAppStoreId: '1279244554',
  urlLink: 'https://sendme.today?',
);

/// SendMe6 Outlet
AppConfig sendme6 = AppConfig(
  id: 'send_me6',
  name: 'SendMe6 Outlet',
  color: const Color(0xff1982C4),
  packageName: 'today.sendme6app.outlet',
  packagePassword: 'SMWL2023@SendMe6',
  domainName: 'cp-sendme6.sendme.today',
  termsAndConditionsLink:
      'https://s3.ap-south-1.amazonaws.com/web.sendme.today.in/terms.html',
  privacyPolicyLink:
      'https://s3.ap-south-1.amazonaws.com/web.sendme.today.in/privacypolicy.html',
  whatsappLink: '',
  appType: 1,
  androidAppLink: '',
  iosAppLink: '',
  deepLink: '',
  email: '',
  androidBundle: 'today.sendme6app.outlet',
  iosBundle: 'today.sendme6app.outlet',
  iosAppStoreId: '',
  urlLink: '',
);

/// Eatoz Outlet
AppConfig eatoz = AppConfig(
  id: 'eatoz',
  name: 'Eatoz Outlet',
  color: const Color(0xff1982C4),
  packageName: 'com.eatozfood_outlet',
  packagePassword: 'SMWL2023@eatoz',
  domainName: 'cp-eatoz.sendme.today',
  termsAndConditionsLink:
      'https://s3.ap-south-1.amazonaws.com/web.sendme.today.in/terms.html',
  privacyPolicyLink:
      'https://s3.ap-south-1.amazonaws.com/web.sendme.today.in/privacypolicy.html',
  whatsappLink: '',
  appType: 1,
  androidAppLink: '',
  iosAppLink: '',
  deepLink: 'https://eatozfood.page.link',
  email: '',
  androidBundle: 'com.eatozfood_outlet',
  iosBundle: 'com.eatozfood_outlet',
  iosAppStoreId: '',
  urlLink: 'https://eatoz.in?',
);

/// SendMe Lebanon Outlet
AppConfig sendmeLebanon = AppConfig(
  id: 'send_me_lebanon',
  name: 'SendMe Horeca Outlet',
  color: const Color(0xff1982C4),
  packageName: 'today.sendmelebanondev.outlet',
  packagePassword: 'SMWL2023@SendMeLebanonDev',
  domainName: 'cp-lebanondev.sendme.today',
  termsAndConditionsLink:
      'https://s3.ap-south-1.amazonaws.com/web.sendme.today.in/terms.html',
  privacyPolicyLink:
      'https://s3.ap-south-1.amazonaws.com/web.sendme.today.in/privacypolicy.html',
  whatsappLink: '',
  appType: 1,
  androidAppLink: '',
  iosAppLink: 'https://apps.apple.com/us/app/id6670752907',
  deepLink: '',
  email: '',
  androidBundle: 'today.sendmelebanondev.outlet',
  iosBundle: 'today.sendmelebanondev.outlet',
  iosAppStoreId: '6670752907',
  urlLink: '',
);

/// SendMe Talabetak Outlet
AppConfig sendmeTalabetak = AppConfig(
  id: 'send_me_talabetak',
  name: 'SendMeTalabetak Outlet',
  color: const Color(0xfff74747),
  packageName: 'today.talabetak.outlet',
  packagePassword: 'SMWL2023@Talabetak',
  domainName: 'talabetak.sendme.today',
  termsAndConditionsLink:
      'https://s3.ap-south-1.amazonaws.com/web.sendme.today.in/terms.html',
  privacyPolicyLink:
      'https://s3.ap-south-1.amazonaws.com/web.sendme.today.in/privacypolicy.html',
  whatsappLink: '',
  appType: 1,
  androidAppLink: '',
  iosAppLink: '',
  deepLink: '',
  email: '',
  androidBundle: 'today.talabetak.outlet',
  iosBundle: 'today.talabetak.outlet',
  iosAppStoreId: '',
  urlLink: '',
);

/// SendMe Shrirampur Outlet
AppConfig sendmeshrirampur = AppConfig(
  id: 'send_me_shrirampur',
  name: 'SendMe Shrirampur Outlet',
  color: const Color(0xff29458E),
  packageName: 'today.sendmeshrirampur.outlet',
  packagePassword: 'SMWL2023@SendMeShrirampur',
  domainName: 'cp-sendmeshrirampur.sendme.today',
  termsAndConditionsLink:
      'https://sendme-images.s3.ap-south-1.amazonaws.com/WhiteLabel/shrirampur/terms.html',
  privacyPolicyLink:
      'https://sendme-images.s3.ap-south-1.amazonaws.com/WhiteLabel/shrirampur/privacy.html',
  whatsappLink: 'https://wa.me/919011794508',
  appType: 1,
  androidAppLink:
      'https://play.google.com/store/apps/details?id=today.sendmeshrirampur',
  iosAppLink: 'https://apps.apple.com/us/app/id6447060680',
  deepLink: 'https://sendmeshrirampur.page.link',
  email: 'sendme.shrirampur@gmail.com',
  androidBundle: 'today.sendmeshrirampur.outlet',
  iosBundle: 'today.sendmeshrirampur.outlet',
  iosAppStoreId: '6447060680',
  urlLink: 'https://sendme.today?',
);

/// Tyeb Outlet
AppConfig tyeb = AppConfig(
  id: 'tyeb',
  name: 'Tyeb Outlet',
  color: const Color(0xff000000),
  packageName: 'today.tyeb.outlet',
  packagePassword: 'SMWL2023@Tyeb',
  domainName: 'cp-tyeb.sendme.today',
  termsAndConditionsLink:
      'https://sendme-images.s3.ap-south-1.amazonaws.com/WhiteLabel/tyeb/index.html?myParam=tc',
  privacyPolicyLink:
      'https://sendme-images.s3.ap-south-1.amazonaws.com/WhiteLabel/tyeb/index.html?myParam=privacy',
  whatsappLink: 'link',
  appType: 1,
  androidAppLink: 'https://play.google.com/store/apps/details?id=today.tyeb',
  iosAppLink: 'https://apps.apple.com/us/app/',
  deepLink: '',
  email: 'sendmeapplicationlb@gmail.com',
  androidBundle: 'today.tyeb.outlet',
  iosBundle: 'today.tyeb.outlet',
  iosAppStoreId: '',
  urlLink: '',
);

/// Hopshop Outlet
AppConfig hopshop = AppConfig(
  id: 'hopshop',
  name: 'Hopshop Outlet',
  color: const Color(0xffF97C38),
  packageName: 'today.hopshop.outlet',
  packagePassword: 'SMWL2023@Hopshop',
  domainName: 'cp.hopshop.app',
  termsAndConditionsLink:
      'https://sendme-images.s3.ap-south-1.amazonaws.com/WhiteLabel/hopshop87383/terms.html',
  privacyPolicyLink:
      'https://sendme-images.s3.ap-south-1.amazonaws.com/WhiteLabel/hopshop87383/privacy.html',
  whatsappLink: 'https://wa.me/96171487383',
  appType: 1,
  androidAppLink: 'https://play.google.com/store/apps/details?id=today.hopshop',
  iosAppLink: 'https://apps.apple.com/us/app/id6448111466',
  deepLink: 'https://hopshop.page.link',
  email: 'info@mediavision.mobi',
  androidBundle: 'today.hopshop.outlet',
  iosBundle: 'today.hopshop.outlet',
  iosAppStoreId: '6448111466',
  urlLink: 'https://hopshop.app?',
);

/// SendMe Test Outlet
AppConfig sendmetest = AppConfig(
  id: 'send_me_test',
  name: 'SendMe Test Outlet',
  color: const Color(0xff29458E),
  packageName: 'today.sendmetest.outlet',
  packagePassword: 'SMWL2023@Myntra',
  domainName: 'cp-sendmetest.sendme.today',
  termsAndConditionsLink: 'link',
  privacyPolicyLink: 'link',
  whatsappLink: 'link',
  appType: 1,
  androidAppLink: '',
  iosAppLink: '',
  deepLink: '',
  email: '',
  androidBundle: 'today.sendmetest.outlet',
  iosBundle: 'today.sendmetest.outlet',
  iosAppStoreId: '',
  urlLink: '',
);

// =============================================================================

class AppConfig {
  final String? id;
  final String? name;
  final Color? color;
  final String? packageName;
  final String? packagePassword;
  final String? domainName;
  final String? termsAndConditionsLink;
  final String? privacyPolicyLink;
  final String? whatsappLink;
  final int? appType;
  final String? androidAppLink;
  final String? iosAppLink;
  final String? deepLink;
  final String? email;
  final String? androidBundle;
  final String? iosBundle;
  final String? iosAppStoreId;
  final String? urlLink;

  const AppConfig({
    this.id,
    this.name,
    this.color,
    this.packageName,
    this.packagePassword,
    this.domainName,
    this.termsAndConditionsLink,
    this.privacyPolicyLink,
    this.whatsappLink,
    this.appType,
    this.androidAppLink,
    this.iosAppLink,
    this.deepLink,
    this.email,
    this.androidBundle,
    this.iosBundle,
    this.iosAppStoreId,
    this.urlLink,
  });
}
