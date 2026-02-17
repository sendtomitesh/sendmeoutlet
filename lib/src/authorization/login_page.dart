import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:sendme_outlet/flutter_project_imports.dart';

class LoginPage extends StatefulWidget {
  final String? call;

  const LoginPage({Key? key, this.call}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    _clearCache();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkLocationPermission());
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.locationWhenInUse.status;
    if (!mounted) return;
    if (status.isDenied || status.isPermanentlyDenied || status.isRestricted) {
      _showLocationDialog();
    }
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Location permission'),
        content: const Text(
          'Please enable location permission to use this app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final status = await Permission.locationWhenInUse.request();
              if (status.isPermanentlyDenied && mounted) {
                openAppSettings();
              }
            },
            child: const Text('Enable'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCache() async {
    await PreferencesHelper.saveStringPref(PreferencesHelper.prefUserData, '');
    await PreferencesHelper.saveStringPref(
      PreferencesHelper.prefUserOutletData,
      '',
    );
    await PreferencesHelper.saveStringPref(
      PreferencesHelper.prefOutletData,
      '',
    );
    await PreferencesHelper.saveStringPref(PreferencesHelper.prefRiderData, '');
    await PreferencesHelper.saveStringPref(PreferencesHelper.prefAdminData, '');
    await PreferencesHelper.saveStringPref(PreferencesHelper.prefCityData, '');
    await PreferencesHelper.saveStringPref(PreferencesHelper.prefAreaData, '');
    await PreferencesHelper.saveStringPref(
      PreferencesHelper.prefOnBoardingData,
      '',
    );
    await PreferencesHelper.saveStringPref(
      PreferencesHelper.prefUserDetails,
      '',
    );
    await PreferencesHelper.saveStringPref(
      PreferencesHelper.prefManageByOutlet,
      '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: PhoneVerificationView(
          call: widget.call ?? 'Main',
          partNumber: 0,
        ),
      ),
    );
  }
}
