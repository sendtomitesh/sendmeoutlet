import 'package:sendme_outlet/AppConfig.dart';

class ThemeUI {
  static String? appPackageName = activeApp.packageName;
  static String? appPassword = activeApp.packagePassword;
  static String? appDomainName = activeApp.domainName;
  static String? appName = activeApp.name;
  static int? appType = activeApp.appType;
  static String? termsAndConditionsLink = activeApp.termsAndConditionsLink;
  static String? privacyPolicyLink = activeApp.privacyPolicyLink;
  static String? whatsappLink = activeApp.whatsappLink;
}
