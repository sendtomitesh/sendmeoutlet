import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:sendme_outlet/flutter_project_imports.dart';

/// LocationView for outlet: get permission + location, then go to LoginPage.
/// No Home/Account tabs - direct to login.
class LocationView extends StatefulWidget {
  final String? call;

  const LocationView({Key? key, this.call}) : super(key: key);

  @override
  State<LocationView> createState() => _LocationViewState();
}

class _LocationViewState extends State<LocationView> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _getPermissionAndLocation();
  }

  Future<void> _getPermissionAndLocation() async {
    try {
      final permission = await Permission.locationWhenInUse.status;
      if (permission != PermissionStatus.granted &&
          permission != PermissionStatus.denied) {
        final status = await [Permission.locationWhenInUse].request();
        if (status[Permission.locationWhenInUse] != PermissionStatus.granted) {
          setState(() {
            _loading = false;
            _error = 'Location permission denied';
          });
          return;
        }
      } else if (permission == PermissionStatus.denied) {
        setState(() {
          _loading = false;
          _error = 'Location permission denied';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      GlobalConstants.longitude = position.longitude;
      GlobalConstants.latitude = position.latitude;

      List<Placemark> placemarks = [];
      try {
        placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 5));
      } catch (_) {}
      if (placemarks.isNotEmpty) {
        final data = <String, dynamic>{
          'countryCode': placemarks[0].isoCountryCode,
          'city': placemarks[0].locality,
          'Longitude': position.longitude,
          'Latitude': position.latitude,
          'Address': placemarks[0].subLocality,
          'LandMark': placemarks[0].subLocality,
        };
        await PreferencesHelper.saveStringPref(
          PreferencesHelper.prefAddressData,
          json.encode(data),
        );
      }

      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: LoginPage(call: widget.call ?? 'Main'),
        ),
      );
    } catch (e) {
      logPrint('Location error: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _skipLocation() {
    GlobalConstants.latitude = 0.0;
    GlobalConstants.longitude = 0.0;
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: LoginPage(call: widget.call ?? 'Main'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xff29458E)),
              const SizedBox(height: 16),
              Text(
                'Getting location...',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: _skipLocation,
                child: Text(
                  'Skip (emulator)',
                  style: TextStyle(color: AppColors.mainAppColor),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Could not get location',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loading = true;
                        _error = null;
                      });
                      _getPermissionAndLocation();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainAppColor,
                    ),
                    child: const Text('Try Again'),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: _skipLocation,
                    child: Text(
                      'Skip (use for emulator)',
                      style: TextStyle(color: AppColors.mainAppColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
