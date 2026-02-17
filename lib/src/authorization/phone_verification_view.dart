import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:sendme_outlet/flutter_project_imports.dart';

class PhoneVerificationView extends StatefulWidget {
  final String? call;
  final int partNumber;

  PhoneVerificationView({Key? key, this.call, this.partNumber = 0})
    : super(key: key);

  @override
  State<PhoneVerificationView> createState() => _PhoneVerificationViewState();
}

class _PhoneVerificationViewState extends State<PhoneVerificationView> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  UserModel? _user;
  String? _phoneNoWithCountryCode;
  String? _phoneNoWithoutCountryCode;
  String? _verificationId;
  String? _errorMessage;
  String? _countryCode;

  bool _sendOTPPressed = false;
  bool _progress = false;
  bool _agreeChecked = false;
  bool _phoneError = false;
  bool _useBackendOTP = false; // true when backend sent OTP (skip Firebase)

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _getPermission() async {
    final permission = await Permission.locationWhenInUse.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      await [Permission.locationWhenInUse].request();
    }
  }

  void _onPhoneChanged(PhoneNumber phone) {
    setState(() {
      _countryCode = phone.countryCode;
      _phoneNoWithoutCountryCode = phone.number;
      _phoneNoWithCountryCode = phone.completeNumber;
      _phoneError = false;
    });
  }

  Future<void> _continueButtonClick() async {
    FocusScope.of(context).requestFocus(FocusNode());
    await Future.delayed(const Duration(milliseconds: 600));

    if (_phoneNoWithoutCountryCode == null ||
        _phoneNoWithoutCountryCode!.isEmpty) {
      setState(() => _phoneError = true);
      return;
    }

    if (!_agreeChecked) {
      showToast('Please accept terms and conditions');
      return;
    }

    setState(() => _progress = true);

    try {
      final url =
          ApiPath.sendOTP +
          'mobileNumber=$_phoneNoWithoutCountryCode' +
          '&version=${GlobalConstants.App_Version}' +
          '&isOld=1' +
          '&platformId=${GlobalConstants.Device_Type}' +
          '&hashKey=kX9E8TUfIrN' +
          '&countryCode=$_countryCode' +
          '&packageName=${ThemeUI.appPackageName}' +
          '&password=${ThemeUI.appPassword}';

      logPrint('SendOTP url: $url');
      final response = await http.Client()
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      logPrint('SendOTP response: ${response.statusCode} ${response.body}');
      final data = json.decode(utf8.decode(response.bodyBytes));

      final status = data['Status'];
      final isSuccess =
          status == 0 || status == '0' || status == 1 || status == '1';
      if (isSuccess) {
        _errorMessage = data['Data']?.toString();
        _useBackendOTP = true;
        _sendOTPPressed = true;
        _progress = false;
        if (mounted) setState(() {});
      } else {
        setState(() => _progress = false);
        showToast(data['Message']?.toString() ?? 'Failed to send OTP');
      }
    } catch (e, stack) {
      logPrint('SendOTP error: $e\n$stack');
      setState(() => _progress = false);
      showToast('Network error. Please try again.');
    }
  }

  void _submitOTP() {
    if (_otpController.text.isEmpty || _otpController.text.length != 6) return;
    setState(() => _progress = true);
    _saveUserAndNavigate();
  }

  Future<void> _saveUserAndNavigate() async {
    setState(() => _progress = true);

    try {
      final url = Uri.encodeFull(
        ApiPath.verifyOTP +
            'mobileNumber=$_phoneNoWithoutCountryCode'
                '&accessToken=${_otpController.text}'
                '&deviceToken=${GlobalConstants.FIREBASE_TOKEN}'
                '&deviceId=${GlobalConstants.Device_Id}'
                '&deviceType=${GlobalConstants.Device_Type}'
                '&version=${GlobalConstants.App_Version}'
                '&packageName=${ThemeUI.appPackageName}'
                '&password=${ThemeUI.appPassword}',
      );

      logPrint('verifyOTP url: $url');
      final response = await http.Client()
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      final data = json.decode(utf8.decode(response.bodyBytes));

      if (data['Data'] != null && data['Status'] == 1) {
        _user = UserModel.fromJson(data['Data'] as Map<String, dynamic>);
        await PreferencesHelper.saveStringPref(
          PreferencesHelper.prefUserData,
          response.body,
        );

        if (!mounted) return;
        await Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: const OutletMainScreen(),
          ),
        );
      } else {
        setState(() {
          _progress = false;
          _otpController.clear();
        });
        showToast(data['Message'] ?? 'Verification failed');
      }
    } catch (e) {
      logPrint('verifyOTP error: $e');
      setState(() {
        _progress = false;
        _otpController.clear();
      });
      showToast('Network error. Please try again.');
    }
  }

  void _changeNumber() {
    setState(() {
      _sendOTPPressed = false;
      _useBackendOTP = false;
      _otpController.clear();
    });
  }

  void _resendOTP() {
    if (_progress) return;
    _continueButtonClick();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: !_sendOTPPressed ? _buildPhoneInput() : _buildOtpInput(),
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello,',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.mainAppColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Enter your phone number',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 10),
            IntlPhoneField(
              controller: _phoneController,
              initialCountryCode: GlobalConstants.intPhoneCountryCode ?? 'IN',
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 22,
                  horizontal: 12,
                ),
                hintText: 'Phone Number',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                    color: _phoneError ? Colors.red : AppColors.mainAppColor,
                  ),
                ),
              ),
              style: TextStyle(
                color: AppColors.mainAppColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              onChanged: _onPhoneChanged,
            ),
            if (_phoneError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Please enter a valid phone number',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              height: 30,
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 10, left: 4),
                    width: 16,
                    height: 16,
                    color: Colors.white,
                    child: Checkbox(
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: BorderSide(
                        width: 1.0,
                        color: AppColors.mainAppColor,
                      ),
                      value: _agreeChecked,
                      checkColor: AppColors.mainAppColor,
                      activeColor: Colors.white,
                      onChanged: (v) =>
                          setState(() => _agreeChecked = v ?? false),
                    ),
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {},
                              child: Text(
                                'Terms and Conditions',
                                style: TextStyle(
                                  color: AppColors.mainAppColor,
                                  fontSize: 12,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {},
                              child: Text(
                                'Privacy Policy',
                                style: TextStyle(
                                  color: AppColors.mainAppColor,
                                  fontSize: 12,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: MediaQuery.of(context).size.height / 15,
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (_agreeChecked &&
                        _phoneNoWithoutCountryCode != null &&
                        _phoneNoWithoutCountryCode!.length >= 10 &&
                        !_progress)
                    ? _continueButtonClick
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainAppColor,
                  disabledBackgroundColor: AppColors.mainAppColor.withOpacity(
                    0.5,
                  ),
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _progress
                    ? const SpinKitThreeBounce(color: Colors.white, size: 20)
                    : const Text(
                        'Next',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Almost done,',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.mainAppColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'OTP sent to $_phoneNoWithoutCountryCode',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                GestureDetector(
                  onTap: _changeNumber,
                  child: Text(
                    ' Change',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.mainAppColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            PinCodeTextField(
              controller: _otpController,
              length: 6,
              keyboardType: TextInputType.phone,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(10),
                borderWidth: 1,
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.white,
                inactiveFillColor: Colors.white,
                selectedFillColor: Colors.white,
                inactiveColor: Colors.grey.shade400,
                activeColor: Colors.grey.shade400,
                selectedColor: AppColors.mainAppColor,
              ),
              animationDuration: const Duration(milliseconds: 300),
              enableActiveFill: true,
              onCompleted: (value) => _submitOTP(),
              onChanged: (value) => setState(() {}),
              appContext: context,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Did not received OTP? ',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                ),
                GestureDetector(
                  onTap: _progress ? null : _resendOTP,
                  child: _progress
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: SpinKitThreeBounce(
                            color: Color(0xff29458E),
                            size: 16,
                          ),
                        )
                      : Text(
                          'Resend',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: MediaQuery.of(context).size.height / 15,
          child: ElevatedButton(
            onPressed: (_otpController.text.length == 6 && !_progress)
                ? _submitOTP
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainAppColor,
              disabledBackgroundColor: AppColors.mainAppColor.withOpacity(0.5),
              disabledForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _progress
                ? const SpinKitThreeBounce(color: Colors.white, size: 20)
                : const Text(
                    'Verify',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }
}
