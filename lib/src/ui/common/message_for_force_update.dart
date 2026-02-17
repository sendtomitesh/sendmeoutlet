import 'package:flutter/material.dart';
import 'package:sendme_outlet/AppConfig.dart';
import 'package:sendme_outlet/flutter_project_imports.dart';
import 'package:url_launcher/url_launcher.dart';

/// Force update screen – shown when backend requires app update.
class MessageForForceUpdate extends StatelessWidget {
  final String? message;

  const MessageForForceUpdate({Key? key, this.message}) : super(key: key);

  Future<void> _openStore() async {
    final url = GlobalConstants.Device_Type == 1
        ? (activeApp.androidAppLink ?? 'https://play.google.com/store')
        : (activeApp.iosAppLink ?? 'https://apps.apple.com');
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.system_update,
                  size: 80,
                  color: AppColors.mainAppColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'Update required',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message ??
                      'A new version of the app is available. Please update to continue.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _openStore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainAppColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                  ),
                  child: const Text('Update now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
