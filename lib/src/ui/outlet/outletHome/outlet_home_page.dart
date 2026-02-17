import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sendme_outlet/flutter_project_imports.dart';
import 'package:sendme_outlet/src/api/api_call.dart';
import 'package:sendme_outlet/src/ui/outlet/outletOrder/add_order.dart';
import 'package:sendme_outlet/src/ui/outlet/outletOrder/manual_add_order_for_medicine_and_grocery.dart';
import 'package:sendme_outlet/src/api/api_path.dart';
import 'package:sendme_outlet/src/ui/common/no_internet_page.dart';

class OutletHomePage extends StatefulWidget {
  final Outlet? outlet;
  final int? index;

  const OutletHomePage({
    Key? key,
    this.outlet,
    this.index,
  }) : super(key: key);

  @override
  State<OutletHomePage> createState() => _OutletHomePageState();
}

class _OutletHomePageState extends State<OutletHomePage>
    with TickerProviderStateMixin {
  final DateFormat _dateFormat = DateFormat('MM/dd/yyyy', 'en');

  int? delayTimeValue;
  String overViewFilterValue = 'Today';
  dynamic fromDate;
  dynamic toDate;
  dynamic currency;

  bool loadingData = true;
  bool processOverview = false;
  bool? _outletStatus;
  bool whatsappProcess = false;

  int totalTodaysOrder = 0;
  int totalDelivered = 0;
  double totalTodaysNetBill = 0.0;
  double averageRating = 0;

  String selectedDelayTime = '';

  AnimationController? animationController;
  Animation<double>? animation;

  @override
  void initState() {
    super.initState();
    fromDate = _dateFormat.format(DateTime.now());
    toDate = _dateFormat.format(DateTime.now());
    _outletStatus = GlobalConstants.outletStatus == 1;

    animationController = AnimationController(
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
      duration: const Duration(milliseconds: 700),
    );
    animation = CurvedAnimation(
      parent: animationController!,
      curve: Curves.easeInOut,
    );
    if (_outletStatus == true) {
      animationController!.forward();
    } else {
      animationController!.reverse();
    }

    fetchOutletDetail();
    fetchUserWPOptIn();
    fetchOutletDashboardData();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  Future<void> fetchOutletDetail() async {
    if (!await GlobalConstants.checkInternetConnection()) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NoInternetPage()),
        );
      }
      return;
    }
    try {
      final url =
          '${ApiPath.getHotelDetail}outletId=${widget.outlet!.hotelId}&userType=${GlobalConstants.Outlet}&version=${GlobalConstants.App_Version}&deviceId=${GlobalConstants.Device_Id}';
      final response = await apiCall(url, '', 'get', 0, context);
      if (!mounted) return;
      final data = json.decode(response.body);
      if (data['Data'] != null && data['Status'] == 1) {
        setState(() {});
      }
    } catch (e) {
      logPrint('fetchOutletDetail error: $e');
    }
  }

  Future<void> fetchUserWPOptIn() async {
    if (!await GlobalConstants.checkInternetConnection()) return;
    try {
      final url =
          '${ApiPath.getUserWPOpTin}userId=${widget.outlet!.userId}&userType=${GlobalConstants.Outlet}'
          '&deviceType=${GlobalConstants.Device_Type}&version=${GlobalConstants.App_Version}&deviceId=${GlobalConstants.Device_Id}';
      final response = await apiCall(url, '', 'get', 0, context);
      if (!mounted) return;
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['Data'] != null && data['Status'] == 1 && data['Data'] == 0) {
        setState(() => whatsappProcess = true);
      }
    } catch (e) {
      logPrint('fetchUserWPOptIn error: $e');
    }
  }

  Future<void> fetchOutletDashboardData() async {
    if (!await GlobalConstants.checkInternetConnection()) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NoInternetPage()),
        );
      }
      setState(() => loadingData = false);
      return;
    }
    try {
      final url =
          '${ApiPath.getOutletDashBoardData}outletId=${widget.outlet!.hotelId}'
          '&fromDate=$fromDate&toDate=$toDate&userType=${GlobalConstants.Outlet}'
          '&version=${GlobalConstants.App_Version}&deviceId=${GlobalConstants.Device_Id}';
      final response = await apiCall(url, '', 'get', 0, context);
      if (!mounted) return;
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['Data'] != null && data['Status'] == 1) {
        setState(() {
          averageRating =
              (data['Data']['OutletRating'] ?? 0).toDouble();
          totalTodaysOrder = data['Data']['TotalTodaysOrder'] ?? 0;
          currency = data['Data']['Currency'] ?? '';
          totalTodaysNetBill =
              (data['Data']['TotalTodaysAmount'] ?? 0).toDouble();
          totalDelivered = (data['Data']['TotalDeliveredOrder'] ?? 0).toInt();
          processOverview = false;
        });
      }
      setState(() => loadingData = false);
    } catch (e) {
      logPrint('fetchOutletDashboardData error: $e');
      setState(() => loadingData = false);
    }
  }

  void _showOfflineBottomSheet() {
    var call = false;
    var openingTime;
    final now = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Go online after',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                ...['1 hour', '2 hours', '4 hours', 'Tomorrow, at same time', 'I will go online myself']
                    .map((label) => RadioListTile<String>(
                          title: Text(label),
                          value: label,
                          groupValue: selectedDelayTime,
                          onChanged: (v) {
                            setModalState(() {
                              selectedDelayTime = v ?? '';
                              if (label == '1 hour') {
                                delayTimeValue = 1;
                                openingTime = DateFormat('hh:mm a')
                                    .format(now.add(const Duration(hours: 1)));
                              } else if (label == '2 hours') {
                                delayTimeValue = 2;
                                openingTime = DateFormat('hh:mm a')
                                    .format(now.add(const Duration(hours: 2)));
                              } else if (label == '4 hours') {
                                delayTimeValue = 4;
                                openingTime = DateFormat('hh:mm a')
                                    .format(now.add(const Duration(hours: 4)));
                              } else if (label == 'Tomorrow, at same time') {
                                delayTimeValue = 24;
                                openingTime = DateFormat('hh:mm a')
                                    .format(now.add(const Duration(hours: 24)));
                              } else {
                                delayTimeValue = 0;
                                openingTime = null;
                              }
                            });
                          },
                        )),
                if (openingTime != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      delayTimeValue == 24
                          ? 'Reopen $openingTime tomorrow'
                          : 'Reopen $openingTime',
                      style: TextStyle(
                          color: Colors.grey.shade700, fontSize: 14),
                    ),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedDelayTime.isEmpty
                        ? null
                        : () {
                            call = true;
                            Navigator.pop(context);
                            changeOutletStatus();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainAppColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      if (!call && mounted) {
        setState(() {
          _outletStatus = !_outletStatus!;
          if (_outletStatus!) {
            animationController?.forward();
          } else {
            animationController?.reverse();
          }
        });
      }
    });
  }

  Future<void> changeOutletStatus() async {
    final status = _outletStatus == true ? 1 : 0;
    if (!await GlobalConstants.checkInternetConnection()) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NoInternetPage()),
        );
      }
      return;
    }
    try {
      final url =
          '${ApiPath.updateOutletStatus}hotelId=${widget.outlet!.hotelId}'
          '&status=$status&delayTime=${delayTimeValue ?? 0}'
          '&userType=${GlobalConstants.Outlet}&deviceType=${GlobalConstants.Device_Type}'
          '&version=${GlobalConstants.App_Version}&deviceId=${GlobalConstants.Device_Id}';
      final response = await apiCall(url, '', 'get', 0, context);
      if (!mounted) return;
      final data = json.decode(response.body);
      if (data['Data'] != null && data['Status'] == 1) {
        setState(() {
          GlobalConstants.outletStatus = data['Data']['HotelStatus'];
          _outletStatus = data['Data']['HotelStatus'] == 1;
          if (_outletStatus!) {
            animationController?.forward();
          } else {
            animationController?.reverse();
          }
          selectedDelayTime = '';
          delayTimeValue = null;
        });
        showToast(data['Message']?.toString() ?? 'Status updated');
      } else {
        setState(() {
          _outletStatus = !_outletStatus!;
          selectedDelayTime = '';
          delayTimeValue = null;
          if (_outletStatus!) {
            animationController?.forward();
          } else {
            animationController?.reverse();
          }
        });
        showToast(data['Message']?.toString() ?? 'Failed');
      }
    } catch (e) {
      logPrint('changeOutletStatus error: $e');
      if (mounted) {
        setState(() {
          _outletStatus = !_outletStatus!;
          selectedDelayTime = '';
          delayTimeValue = null;
          if (_outletStatus!) {
            animationController?.forward();
          } else {
            animationController?.reverse();
          }
        });
        showToast('Something went wrong');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: loadingData
            ? _buildShimmerLoading()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        if (whatsappProcess && ThemeUI.whatsappLink != null && ThemeUI.whatsappLink!.isNotEmpty)
                          _buildWhatsAppBanner(),
                        _buildOverviewSection(),
                        _buildStatsCards(),
                      ],
                    ),
                  ),
                  _buildAddOrderButton(),
                ],
              ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Container(
      color: Colors.grey.shade100,
      child: ListView(
        children: [
          const Padding(padding: EdgeInsets.all(16)),
          ListTileShimmer(),
          const Divider(),
          const Padding(padding: EdgeInsets.all(16)),
          ListTileShimmer(),
          const Divider(),
          const Padding(padding: EdgeInsets.all(16)),
          ListTileShimmer(),
          const Divider(),
          const Padding(padding: EdgeInsets.all(16)),
          ListTileShimmer(),
          const Divider(),
          const Padding(padding: EdgeInsets.all(16)),
          ListTileShimmer(),
          const Divider(),
          const Padding(padding: EdgeInsets.all(16)),
          ListTileShimmer(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    _outletStatus == true
                        ? AppColors.doneStatusColor
                        : AppColors.mainAppColor,
                radius: 45,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 42,
                  backgroundImage:
                      widget.outlet!.imageUrl != null &&
                              widget.outlet!.imageUrl!.isNotEmpty
                          ? NetworkImage(widget.outlet!.imageUrl!)
                          : null,
                  child:
                      widget.outlet!.imageUrl == null ||
                              widget.outlet!.imageUrl!.isEmpty
                          ? Icon(Icons.store, color: AppColors.mainAppColor)
                          : null,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      widget.outlet!.hotel ?? 'Outlet',
                      maxLines: 2,
                      minFontSize: 18,
                      maxFontSize: 20,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _outletStatus == true ? 'Available' : 'Unavailable',
                      style: TextStyle(
                        color:
                            _outletStatus == true
                                ? AppColors.doneStatusColor
                                : AppColors.mainAppColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () {
              setState(() {
                if (_outletStatus == true) {
                  _outletStatus = false;
                  animationController?.reverse();
                  _showOfflineBottomSheet();
                } else {
                  _outletStatus = true;
                  animationController?.forward();
                  changeOutletStatus();
                }
              });
            },
            child: CircleAvatar(
              backgroundColor:
                  _outletStatus == true
                      ? AppColors.doneStatusColor
                      : AppColors.mainAppColor,
              child: const Icon(Icons.power_settings_new, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppBanner() {
    final link = ThemeUI.whatsappLink ?? '';
    return InkWell(
      onTap: () async {
        final uri = Uri.tryParse(link);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
        height: MediaQuery.of(context).size.height / 15,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 15,
              width: MediaQuery.of(context).size.width / 8.5,
              alignment: Alignment.center,
              child: FaIcon(FontAwesomeIcons.whatsapp, color: const Color(0xFF25D366), size: 32),
            ),
            Flexible(
              child: Text(
                'Subscribe to receive notification on WhatsApp',
                style: TextStyle(
                  color: const Color(0xFF25D366),
                  decoration: TextDecoration.underline,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Overview',
            style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.bold),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: overViewFilterValue,
              icon: const Icon(Icons.keyboard_arrow_down_outlined),
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  processOverview = true;
                  overViewFilterValue = v;
                  final now = DateTime.now();
                  if (v == 'Today') {
                    fromDate = _dateFormat.format(now);
                    toDate = _dateFormat.format(now);
                  } else if (v == 'Yesterday') {
                    final yesterday =
                        DateTime(now.year, now.month, now.day - 1);
                    fromDate = _dateFormat.format(yesterday);
                    toDate = _dateFormat.format(yesterday);
                  } else if (v == 'This Week') {
                    fromDate =
                        _dateFormat.format(now.subtract(const Duration(days: 6)));
                    toDate = _dateFormat.format(now);
                  } else {
                    fromDate = _dateFormat.format(DateTime(now.year, now.month, 1));
                    toDate = _dateFormat.format(now);
                  }
                  fetchOutletDashboardData();
                });
              },
              items: ['Today', 'Yesterday', 'This Week', 'This Month']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final cur = currency ?? '';
    final cardWidth = MediaQuery.of(context).size.width / 2;
    final cardHeight = MediaQuery.of(context).size.height / 8;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _statCard(cardWidth, cardHeight, 'Total Amount', processOverview ? null : '$cur ${GlobalConstants.formatCurrency(cur, totalTodaysNetBill)}'),
                _statCard(cardWidth, cardHeight, 'Overall Rating', processOverview ? null : '$averageRating'),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                _statCard(cardWidth, cardHeight, 'Total Orders', processOverview ? null : '$totalTodaysOrder'),
                _statCard(cardWidth, cardHeight, 'Delivered', processOverview ? null : '$totalDelivered'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(double width, double height, String label, String? value) {
    return SizedBox(
      width: width,
      height: height,
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                  fontFamily: AssetsFont.textMedium,
                  color: Colors.grey,
                  fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            value != null
                ? Text(
                    value,
                    style: TextStyle(
                        fontFamily: AssetsFont.textBold,
                        color: AppColors.mainAppColor,
                        fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : Container(
                    height: 10,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOrderButton() {
    final isRestaurant = GlobalConstants.themeId != GlobalConstants.Grocery_Store_UI &&
        (GlobalConstants.isMedicine ?? 0) != 1;

    if (isRestaurant) {
      return _buildAddOrderRestaurantButton();
    } else {
      return _buildAddOrderGroceryMedicineButton();
    }
  }

  Widget _buildAddOrderRestaurantButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Center(
        child: InkWell(
          onTap: _outletStatus == false
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddOrder(
                        outlet: widget.outlet,
                        outletId: widget.outlet!.hotelId,
                        outletName: widget.outlet!.hotel,
                        quantity: 0,
                        cityId: GlobalConstants.outletCityId,
                      ),
                    ),
                  );
                },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: _outletStatus == false
                    ? [Colors.grey, Colors.grey.shade300]
                    : [
                        AppColors.mainAppColor,
                        AppColors.mainAppColor,
                        AppColors.mainAppColor.withValues(alpha: 0.92),
                      ],
                stops: const [0.0, 0.88, 1.0],
              ),
            ),
            width: MediaQuery.of(context).size.width / 2,
            alignment: Alignment.center,
            height: 45,
            child: Text(
              'Add Order',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _outletStatus == false ? Colors.grey : Colors.white,
                fontFamily: AssetsFont.textRegular,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddOrderGroceryMedicineButton() {
    final isMedicine = (GlobalConstants.isMedicine ?? 0) == 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: _outletStatus == false
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ManualAddOrderForMedicineAndGrocery(
                          outlet: widget.outlet,
                        ),
                      ),
                    );
                  },
            icon: const Icon(Icons.upload_file),
            label: Text(
              isMedicine ? 'Upload Prescription' : 'Upload Items List',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainAppColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: _outletStatus == false
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ManualAddOrderForMedicineAndGrocery(
                          outlet: widget.outlet,
                        ),
                      ),
                    );
                  },
            icon: const Icon(Icons.edit_note),
            label: const Text('Enter Items List'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
