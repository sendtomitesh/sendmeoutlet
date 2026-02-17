import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:sendme_outlet/AppConfig.dart';
import 'package:sendme_outlet/flutter_project_imports.dart';
import 'package:sendme_outlet/src/api/api_call.dart';
import 'package:sendme_outlet/src/ui/common/no_internet_page.dart';
import 'package:sendme_outlet/src/ui/outlet/outletManage/outlet_manage_placeholder.dart';

class OutletManageView extends StatefulWidget {
  final Outlet? outlet;
  final int? userId;

  const OutletManageView({
    Key? key,
    this.outlet,
    this.userId,
  }) : super(key: key);

  @override
  State<OutletManageView> createState() => _OutletManageViewState();
}

class _OutletManageViewState extends State<OutletManageView> {
  bool _isLoading = true;
  List<ManageOutletStore> _manageStoreList = [];

  @override
  void initState() {
    super.initState();
    _fetchManageStoreData();
  }

  Future<void> _fetchManageStoreData() async {
    if (!await GlobalConstants.checkInternetConnection()) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NoInternetPage()),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    try {
      final url =
          '${ApiPath.getStoreMenuTab}outletId=${widget.outlet!.hotelId}'
          '&userType=${GlobalConstants.Outlet}'
          '&deviceType=${GlobalConstants.Device_Type}'
          '&version=${GlobalConstants.App_Version}'
          '&deviceId=${GlobalConstants.Device_Id}';

      final response = await apiCall(url, '', 'get', 0, context);
      if (!mounted) return;

      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['Data'] != null && data['Status'] == 1) {
        final rest = data['Data'] as List;
        setState(() {
          _manageStoreList = rest
              .map<ManageOutletStore>(
                  (j) => ManageOutletStore.fromJson(j as Map<String, dynamic>))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          showToast(data['Message']?.toString() ?? 'Something went wrong');
        }
      }
    } catch (e) {
      logPrint('Manage store error: $e');
      setState(() => _isLoading = false);
      if (mounted) showToast('Something went wrong');
    }
  }

  bool _shouldHide(ManageOutletStore item) {
    if ((item.isBlocked ?? 0) == 1) return true;
    final id = item.id ?? 0;
    if (activeApp.id == 'send_me_lebanon' &&
        (id == 7 || id == 8 || id == 5 || id == 2)) {
      return true;
    }
    if (activeApp.id == 'send_me_talabetak' && (id == 8 || id == 2)) {
      return true;
    }
    return false;
  }

  IconData _getManageListIconById(int id) {
    switch (id) {
      case 1:
        return Icons.local_offer_outlined;
      case 2:
        return Icons.confirmation_number_outlined;
      case 3:
        return Icons.rate_review_outlined;
      case 4:
        return Icons.assessment_outlined;
      case 5:
        return Icons.two_wheeler_outlined;
      case 6:
        return Icons.store_outlined;
      case 7:
        return Icons.delivery_dining_outlined;
      case 8:
        return Icons.chat_outlined;
      default:
        return Icons.settings_outlined;
    }
  }

  String _getManageListTitleById(int id) {
    switch (id) {
      case 1:
        return 'Offers';
      case 2:
        return 'Coupons';
      case 3:
        return 'Reviews';
      case 4:
        return 'Bill Reports';
      case 5:
        return 'Riders';
      case 6:
        return 'Outlet Profile';
      case 7:
        return 'Delivery Area & Charges';
      case 8:
        return 'WhatsApp Stories';
      default:
        return 'Manage';
    }
  }

  void _navigateToScreen(int id) {
    final title = _manageStoreList
            .where((e) => e.id == id)
            .map((e) => e.name)
            .firstOrNull ??
        _getManageListTitleById(id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OutletManagePlaceholder(
          title: title,
          outlet: widget.outlet,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: false,
        title: Text(
          'Manage Store',
          style: TextStyle(
            fontFamily: AssetsFont.textBold,
            color: AppColors.mainAppColor,
            fontSize: 20,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: SpinKitThreeBounce(color: AppColors.mainAppColor),
              )
            : _manageStoreList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.settings_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No manage options',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: _manageStoreList.length,
                    itemBuilder: (context, index) {
                      final item = _manageStoreList[index];
                      if (_shouldHide(item)) {
                        return const SizedBox.shrink();
                      }
                      return _buildManageItem(item);
                    },
                  ),
      ),
    );
  }

  Widget _buildManageItem(ManageOutletStore item) {
    final id = item.id ?? 0;
    return InkWell(
      onTap: () => _navigateToScreen(id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.mainAppColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(
                    _getManageListIconById(id),
                    color: AppColors.mainAppColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'View',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontFamily: AssetsFont.textMedium,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.name ?? _getManageListTitleById(id),
                      style: TextStyle(
                        color: AppColors.mainAppColor,
                        fontFamily: AssetsFont.textBold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: AppColors.mainAppColor,
            ),
          ],
        ),
      ),
    );
  }
}
