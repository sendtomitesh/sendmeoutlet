import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:sendme_outlet/flutter_project_imports.dart';
import 'package:sendme_outlet/src/ui/common/no_internet_page.dart';

/// Simplified API call for outlet app. Uses Basic auth with user credentials.
Future<http.Response> apiCall(
  String apiUrl,
  dynamic param,
  String method,
  int type,
  BuildContext context, {
  bool withoutParams = false,
}) async {
  if (!(await GlobalConstants.checkInternetConnection())) {
    if (context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NoInternetPage()),
      );
    }
    throw Exception('No internet connection');
  }

  var basicAuth = 'Basic ${base64Encode(utf8.encode('SendMe'))}';
  var userId = '';
  var phone = '';
  var userName = '';
  var cityIdLog = '';
  var now = DateTime.now();

  final userData =
      await PreferencesHelper.readStringPref(PreferencesHelper.prefUserData);
  if (userData != null && userData.isNotEmpty) {
    try {
      final jsonData = json.decode(userData);
      final rest = jsonData['Data'];
      if (rest != null) {
        final u = UserModel.fromJson(rest as Map<String, dynamic>);
        userId = '${u.userId}';
        phone = u.mobile ?? '';
        userName = u.name ?? '';
        cityIdLog = '${u.cityId ?? ''}';
        final password = '${u.userId}*${u.userType}*${now.minute}';
        basicAuth = 'Basic ${base64Encode(utf8.encode('$phone:$password'))}';
      }
    } catch (e) {
      logPrint('apiCall: parse userData error: $e');
    }
  }

  var url = apiUrl;
  if (method == 'get') {
    url = '$apiUrl'
        '&adminId=$userId'
        '&phoneNumberLogs=$phone'
        '&userNameLogs=$userName'
        '&cityIdLogs=$cityIdLog'
        '&requestfrom=app'
        '&packageName=${ThemeUI.appPackageName}'
        '&password=${ThemeUI.appPassword}';
    logPrint('apiCall GET: $url');
  }

  http.Response result;
  if (method == 'get') {
    result = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'authorization': basicAuth,
        'referer': 'https://sendme.today/',
      },
    );
  } else {
    var body = param;
    if (type == 2 && param is Map) {
      final paramData = Map<String, dynamic>.from(param);
      paramData['adminId'] = userId;
      paramData['phoneNumberLogs'] = phone;
      paramData['userNameLogs'] = userName;
      paramData['cityIdLogs'] = cityIdLog;
      paramData['requestfrom'] = 'app';
      paramData['packageName'] = ThemeUI.appPackageName ?? '';
      paramData['password'] = ThemeUI.appPassword ?? '';
      body = json.encode(paramData);
    }
    logPrint('apiCall POST: $apiUrl');
    result = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'authorization': basicAuth,
        'Content-Type': 'application/json',
        'referer': 'https://sendme.today/',
      },
      body: body,
    );
  }

  try {
    final data = json.decode(result.body);
    if (data['Data'] != null && data['Status'] == -1) {
      if (context.mounted) {
        await _logoutAndNavigateToLogin(context, 'Profile');
      }
    }
  } catch (_) {}

  return result;
}

Future<void> _logoutAndNavigateToLogin(BuildContext context, String call) async {
  await PreferencesHelper.saveStringPref(PreferencesHelper.prefUserData, '');
  await PreferencesHelper.saveStringPref(PreferencesHelper.prefOutletData, '');
  await PreferencesHelper.saveStringPref(PreferencesHelper.prefCityData, '');
  await PreferencesHelper.saveStringPref(PreferencesHelper.prefAreaData, '');
  if (context.mounted) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage(call: call)),
      (_) => false,
    );
  }
}
