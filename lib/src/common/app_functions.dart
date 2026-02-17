import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:sendme_outlet/src/common/colors.dart';
import 'package:url_launcher/url_launcher.dart';

var logger = Logger(
  printer: PrettyPrinter(
    lineLength: 100,
    methodCount: 0,
    errorMethodCount: 8,
    colors: true,
    printEmojis: true,
    printTime: false,
  ),
);

void logPrint(String message) {
  if (kDebugMode) {
    logger.d(message);
  }
}

dynamic funToString(dynamic value) {
  if (value != null) {
    if (value.toString().contains('null') || value.toString().contains('undefined')) {
      return null;
    }
    if (value.runtimeType == double) {
      return (value as double).toString();
    } else if (value.runtimeType == int) {
      return (value as int).toString();
    } else if (value.runtimeType == String) {
      return value;
    } else {
      return value;
    }
  } else {
    return value;
  }
}

dynamic funToInt(dynamic value) {
  if (value != null) {
    if (value.runtimeType == double) {
      return (value as double).toInt();
    } else if (value.runtimeType == String) {
      if (value != '') {
        return int.parse(value as String);
      } else {
        return 0;
      }
    } else if (value.runtimeType == int) {
      return value as int;
    } else if (value.runtimeType == bool) {
      return (value as bool) ? 1 : 0;
    } else {
      return value;
    }
  } else {
    return value;
  }
}

dynamic funToDouble(dynamic value) {
  if (value != null) {
    if (value.runtimeType == double) {
      return value as double;
    } else if (value.runtimeType == String) {
      if (value != '') {
        return double.parse(value as String);
      } else {
        return 0.0;
      }
    } else if (value.runtimeType == int) {
      return (value as int).toDouble();
    } else {
      return value;
    }
  } else {
    return value;
  }
}

Future<void> appLaunchUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }
}

void showToast(String message) {
  logPrint("Show Toast message is == > $message");
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: AppColors.mainAppColor,
    textColor: Colors.white,
    timeInSecForIosWeb: 1,
  );
}
