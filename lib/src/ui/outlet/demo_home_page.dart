import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'package:sendme_outlet/AppConfig.dart';
import 'package:sendme_outlet/flutter_project_imports.dart';

/// Demo home page shown after successful login.
class DemoHomePage extends StatelessWidget {
  const DemoHomePage({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    await PreferencesHelper.saveStringPref(PreferencesHelper.prefUserData, '');
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: const LoginPage(call: 'Main'),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          activeApp.name ?? 'Outlet',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.mainAppColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: () => _logout(context),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 80,
              color: AppColors.mainAppColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to ${activeApp.name ?? 'Outlet'}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.mainAppColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Demo Home - Login successful',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
