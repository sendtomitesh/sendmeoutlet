import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:sendme_outlet/AppConfig.dart';
import 'package:sendme_outlet/flutter_project_imports.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runZonedGuarded(() async {
    await resolveActiveApp();
    await _initGlobals();
    await initializeDateFormatting('en');
    // Firebase is initialized lazily in PhoneVerificationView when user logs in.
    runApp(const MyApp());
  }, (error, stack) {
    debugPrint('Unhandled error: $error\n$stack');
  });
}

Future<void> _initGlobals() async {
  final packageInfo = await PackageInfo.fromPlatform();
  GlobalConstants.App_Version = packageInfo.version;
  GlobalConstants.Package_Name = packageInfo.packageName;

  final deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    final android = await deviceInfo.androidInfo;
    GlobalConstants.Device_Id = android.id;
    GlobalConstants.Device_Type = 1;
  } else if (Platform.isIOS) {
    final ios = await deviceInfo.iosInfo;
    GlobalConstants.Device_Id = ios.identifierForVendor ?? 'unknown';
    GlobalConstants.Device_Type = 2;
  } else {
    GlobalConstants.Device_Id = 'unknown';
    GlobalConstants.Device_Type = 0;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: activeApp.name ?? 'SendMe Outlet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: activeApp.color ?? const Color(0xff29458E),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

/// Shows Demo Home if logged in, otherwise Login page directly.
class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: PreferencesHelper.readStringPref(PreferencesHelper.prefUserData),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.mainAppColor),
                  const SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }
        final userData = snapshot.data;
        if (userData != null && userData.isNotEmpty && userData != '') {
          return const OutletMainScreen();
        }
        return const LoginPage(call: 'Main');
      },
    );
  }
}
