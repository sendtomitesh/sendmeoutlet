import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sendme_outlet/flutter_project_imports.dart';
import 'package:sendme_outlet/src/api/api_call.dart';
import 'package:sendme_outlet/src/ui/common/no_internet_page.dart';
import 'package:sendme_outlet/src/ui/outlet/outlet_account_tab.dart';
import 'package:sendme_outlet/src/ui/outlet/outletHome/outlet_home_page.dart';
import 'package:sendme_outlet/src/ui/outlet/outletOrder/outlet_order_tab.dart';
import 'package:sendme_outlet/src/ui/outlet/outletManage/outlet_manage_view.dart';
import 'package:sendme_outlet/src/ui/outlet/outletProducts/catalogue_view.dart';

class OutletMainScreen extends StatefulWidget {
  final int? tabIndex;
  final int? index;

  const OutletMainScreen({
    Key? key,
    this.tabIndex,
    this.index,
  }) : super(key: key);

  @override
  State<OutletMainScreen> createState() => _OutletMainScreenState();
}

class _OutletMainScreenState extends State<OutletMainScreen> {
  int _currentIndex = 0;
  UserModel? u;
  Outlet? _outlet;
  Future<String?>? outletData;
  DateTime? _backButtonPressedTime;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.tabIndex ?? 0;
    outletData = _fetchOutletData();
    requestNotificationPermissionIfNeeded();
  }

  Future<String?> _fetchOutletData() async {
    if (!await GlobalConstants.checkInternetConnection()) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NoInternetPage()),
        );
      }
      return null;
    }

    final userData =
        await PreferencesHelper.readStringPref(PreferencesHelper.prefUserData);
    if (userData == null || userData.isEmpty) {
      _logoutAndGoToLogin('Main');
      return null;
    }

    try {
      final jsonData = json.decode(userData);
      final rest = jsonData['Data'];
      if (rest == null) {
        _logoutAndGoToLogin('Main');
        return null;
      }
      u = UserModel.fromJson(rest as Map<String, dynamic>);
    } catch (e) {
      logPrint('fetchOutletData: parse userData error: $e');
      _logoutAndGoToLogin('Main');
      return null;
    }

    final hasOutletAccess = u!.userType == GlobalConstants.Outlet ||
        (u!.userTypeList?.contains(GlobalConstants.Outlet) ?? false);
    if (!hasOutletAccess) {
      logPrint('fetchOutletData: userType=${u!.userType}, no outlet access');
      showToast('This app is for outlet users only');
      _logoutAndGoToLogin('Main');
      return null;
    }

    final apiUrl =
        '${ApiPath.switchUser}userType=${GlobalConstants.Outlet}&mobileNumber=${u!.mobile}'
        '&deviceType=${GlobalConstants.Device_Type}&version=${GlobalConstants.App_Version}'
        '&deviceId=${GlobalConstants.Device_Id}';

    try {
      final response = await apiCall(apiUrl, '', 'get', 0, context);
      if (!mounted) return null;

      dynamic data;
      try {
        data = json.decode(response.body);
      } catch (e) {
        logPrint('fetchOutletData: JSON decode error: $e');
        logPrint('fetchOutletData: response body: ${response.body}');
        showToast('Invalid server response');
        _logoutAndGoToLogin('Main');
        return null;
      }

      if (data == null || data is! Map) {
        logPrint('fetchOutletData: unexpected data: $data');
        showToast('Invalid server response');
        _logoutAndGoToLogin('Main');
        return null;
      }

      if (data['Data'] != null && data['Status'] == 1) {
        final isBlocked = data['Data']['isBlocked'];
        if (isBlocked != null && (isBlocked == 1 || isBlocked == true)) {
          await _clearPrefs();
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (_) => const LoginPage(call: 'Block')),
              (_) => false,
            );
          }
          return null;
        }

        setState(() {
          GlobalConstants.outletCityId = funToInt(data['Data']['CityId']);
          GlobalConstants.userType = GlobalConstants.Outlet;
          GlobalConstants.outletCountryCode =
              data['Data']['OutletCountryCode']?.toString();
          GlobalConstants.outletCurrency =
              data['Data']['currency']?.toString();
          GlobalConstants.outletStatus = funToInt(data['Data']['HotelStatus']);
          GlobalConstants.isMedicine = funToInt(data['Data']['isMedicine']);
          GlobalConstants.themeId = funToInt(data['Data']['ThemeId']);
          GlobalConstants.AdmincityId = funToInt(data['Data']['CityId']);
          GlobalConstants.isOutlet = 1;
        });

        await PreferencesHelper.saveStringPref(
            PreferencesHelper.prefOutletData, response.body);
        await PreferencesHelper.saveStringPref('userType', '${GlobalConstants.Outlet}');

        refreshFcmTokenAfterLogin();

        final forceUpdateVal = GlobalConstants.Device_Type == 1
            ? data['Android']
            : data['IOS'];
        GlobalConstants.isForceUpdate =
            forceUpdateVal == true ? 1 : (forceUpdateVal == false ? 0 : funToInt(forceUpdateVal));
        GlobalConstants.Live_App_Version =
            GlobalConstants.Device_Type == 1
                ? data['AndroidVersion']
                : data['IOSVersion'];

        if (GlobalConstants.forceUpdate == 1 &&
            GlobalConstants.Live_App_Version != null &&
            GlobalConstants.Live_App_Version!
                .compareTo(GlobalConstants.App_Version) >
                0) {
          if (mounted) {
            // TODO Phase 6: MessageForForceUpdate
            logPrint('Force update required');
          }
        }

        return response.body;
      } else {
        final msg = data['Message']?.toString() ?? 'Unable to load outlet';
        logPrint('fetchOutletData: API returned Status!=1: $msg');
        logPrint('fetchOutletData: full response: $data');
        showToast(msg);
        _logoutAndGoToLogin('Main');
        return null;
      }
    } catch (e, stack) {
      logPrint('fetchOutletData error: $e');
      logPrint('fetchOutletData stack: $stack');
      showToast('Something went wrong. Please try again.');
      _logoutAndGoToLogin('Main');
      return null;
    }
  }

  Future<void> _clearPrefs() async {
    await PreferencesHelper.saveStringPref(
        PreferencesHelper.prefCityData, '');
    await PreferencesHelper.saveStringPref(
        PreferencesHelper.prefAreaData, '');
    await PreferencesHelper.saveStringPref(
        PreferencesHelper.prefUserData, '');
    await PreferencesHelper.saveStringPref(
        PreferencesHelper.prefOutletData, '');
  }

  Future<void> _logoutAndGoToLogin(String call) async {
    await _clearPrefs();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginPage(call: call)),
        (_) => false,
      );
    }
  }

  Future<bool> _onBackPressed() async {
    final now = DateTime.now();
    final shouldExit = _backButtonPressedTime == null ||
        now.difference(_backButtonPressedTime!) > const Duration(seconds: 3);

    if (shouldExit) {
      _backButtonPressedTime = now;
      showToast('Press again to exit');
      return false;
    }
    return SystemNavigator.pop() as Future<bool>;
  }

  List<Widget> _buildChildren(Outlet o) {
    final isRestaurant = GlobalConstants.themeId != GlobalConstants.Grocery_Store_UI &&
        (GlobalConstants.isMedicine ?? 0) != 1;

    if (isRestaurant) {
      return [
        OutletHomePage(outlet: o, index: widget.index),
        OutletOrderTab(outlet: o, userId: u!.userId, index: widget.index),
        CatalogueView(outlet: o),
        OutletManageView(outlet: o, userId: u!.userId),
        OutletAccountTab(outlet: o, user: u),
      ];
    } else {
      return [
        OutletHomePage(outlet: o, index: widget.index),
        OutletOrderTab(outlet: o, userId: u!.userId, index: widget.index),
        OutletManageView(outlet: o, userId: u!.userId),
        OutletAccountTab(outlet: o, user: u),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _onBackPressed();
      },
      child: Scaffold(
        body: FutureBuilder<String?>(
          future: outletData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.connectionState == ConnectionState.none) {
              return Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                          color: AppColors.mainAppColor),
                      const SizedBox(height: 16),
                      Text(
                        'Loading outlet...',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
              return Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Could not load outlet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            try {
              final data = json.decode(snapshot.data!);
              final result = data['Data'] as Map<String, dynamic>;
              final newOutlet = Outlet.fromJson(result);
              if (_outlet == null) {
                _outlet = newOutlet;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() {});
                });
              }
              final o = _outlet!;
              final children = _buildChildren(o);
              return children[_currentIndex.clamp(0, children.length - 1)];
            } catch (e) {
              logPrint('OutletMainScreen build error: $e');
              return Center(
                child: Text('Error: $e'),
              );
            }
          },
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget? _buildBottomNav() {
    if (_outlet == null) return null;

    final isRestaurant = GlobalConstants.themeId != GlobalConstants.Grocery_Store_UI &&
        (GlobalConstants.isMedicine ?? 0) != 1;

    final items = isRestaurant
        ? [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Orders',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Products',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Manage',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Account',
            ),
          ]
        : [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Orders',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Manage',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Account',
            ),
          ];

    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.mainAppColor,
      unselectedItemColor: Colors.grey.shade400,
      currentIndex: _currentIndex.clamp(0, items.length - 1),
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      items: items,
    );
  }
}
