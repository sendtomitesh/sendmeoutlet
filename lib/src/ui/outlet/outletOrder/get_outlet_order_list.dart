import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

import 'package:sendme_outlet/flutter_project_imports.dart';
import 'package:sendme_outlet/src/api/api_call.dart';
import 'package:sendme_outlet/src/api/api_path.dart';
import 'package:sendme_outlet/src/models/outlet_order_or_user_order_detail.dart';
import 'package:sendme_outlet/src/ui/common/no_internet_page.dart';
import 'package:sendme_outlet/src/ui/outlet/outletOrder/outlet_order_tab_view.dart';

class GetOutletOrderList extends StatefulWidget {
  final Outlet? outlet;
  final int? userId;
  final int tab;

  const GetOutletOrderList({
    Key? key,
    this.outlet,
    this.userId,
    required this.tab,
  }) : super(key: key);

  @override
  State<GetOutletOrderList> createState() => _GetOutletOrderListState();
}

class _GetOutletOrderListState extends State<GetOutletOrderList> {
  Future<List<OutletOrderOrUserOrderDetail>?>? _outletOrderFuture;

  @override
  void initState() {
    super.initState();
    _outletOrderFuture = _fetchOrders();
  }

  @override
  void didUpdateWidget(covariant GetOutletOrderList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tab != widget.tab) {
      _outletOrderFuture = _fetchOrders();
    }
  }

  Future<List<OutletOrderOrUserOrderDetail>?> _fetchOrders() async {
    if (!await GlobalConstants.checkInternetConnection()) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NoInternetPage()),
        );
      }
      return null;
    }

    int dateType = 2;
    int? type;
    if (widget.tab == 3) {
      dateType = 1;
    } else if (widget.tab == 2) {
      type = GlobalConstants.ORDER_PENDING;
    }

    final apiParam = {
      'outletId': '${widget.outlet!.hotelId}',
      'pageIndex': '0',
      'pagination': '{}',
      'type': type != null ? '$type' : 'null',
      'dateType': '$dateType',
      'fromDate': dateType == 0 ? DateFormat('MM/dd/yyyy').format(DateTime.now()) : '',
      'toDate': dateType == 0 ? DateFormat('MM/dd/yyyy').format(DateTime.now()) : '',
      'userType': '${GlobalConstants.Outlet}',
      'CountryCode': '${GlobalConstants.outletCountryCode}',
      'deliveryPartnerId': '0',
      'deviceType': '${GlobalConstants.Device_Type}',
      'version': '${GlobalConstants.App_Version}',
      'deviceId': '${GlobalConstants.Device_Id}',
    };

    try {
      final response = await apiCall(ApiPath.getOrderList, apiParam, 'post', 2, context);
      if (!mounted) return null;

      final data = json.decode(utf8.decode(response.bodyBytes));

      if (data['Data'] != null && data['Status'] == 1) {
        final result = data['Data'] as List;
        return result
            .map<OutletOrderOrUserOrderDetail>(
                (j) => OutletOrderOrUserOrderDetail.fromJson(j as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      logPrint('fetchOrders error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<List<OutletOrderOrUserOrderDetail>?>(
          future: _outletOrderFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Something went wrong',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.connectionState == ConnectionState.none) {
              return Center(
                child: SpinKitThreeBounce(color: AppColors.mainAppColor),
              );
            }

            final orders = snapshot.data;
            if (orders == null || orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No orders',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              );
            }

            return OutletOrderTabView(
              outletOrder: orders,
              userId: widget.userId,
              tab: widget.tab,
            );
          },
        ),
      ),
    );
  }
}
