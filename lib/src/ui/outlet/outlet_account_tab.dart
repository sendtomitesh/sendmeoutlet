import 'package:flutter/material.dart';

import 'package:sendme_outlet/flutter_project_imports.dart';
import 'package:sendme_outlet/src/ui/outlet/outletHome/genrate_webstore_link_view.dart';

class OutletAccountTab extends StatelessWidget {
  final Outlet? outlet;
  final UserModel? user;

  const OutletAccountTab({
    Key? key,
    this.outlet,
    this.user,
  }) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    await PreferencesHelper.saveStringPref(PreferencesHelper.prefUserData, '');
    await PreferencesHelper.saveStringPref(
        PreferencesHelper.prefOutletData, '');
    await PreferencesHelper.saveStringPref(
        PreferencesHelper.prefCityData, '');
    await PreferencesHelper.saveStringPref(
        PreferencesHelper.prefAreaData, '');
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage(call: 'Main')),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Account'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (outlet != null) ...[
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.mainAppColor.withOpacity(0.2),
                  backgroundImage: outlet!.imageUrl != null &&
                          outlet!.imageUrl!.isNotEmpty
                      ? NetworkImage(outlet!.imageUrl!)
                      : null,
                  child: outlet!.imageUrl == null || outlet!.imageUrl!.isEmpty
                      ? Icon(
                          Icons.store,
                          size: 50,
                          color: AppColors.mainAppColor,
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  outlet!.hotel ?? 'Outlet',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (outlet!.address != null && outlet!.address!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    outlet!.address!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
              if (user != null) ...[
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Mobile'),
                  subtitle: Text(user!.mobile ?? ''),
                ),
                if (user!.name != null && user!.name!.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Name'),
                    subtitle: Text(user!.name!),
                  ),
                const SizedBox(height: 24),
              ],
              if (outlet != null) ...[
                ListTile(
                  leading: Icon(Icons.link, color: AppColors.mainAppColor),
                  title: const Text('WebStore Link'),
                  subtitle: const Text('Generate or view your store link'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GenrateWebStoreLinkView(
                          outlet: outlet,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
              const Divider(),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainAppColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
