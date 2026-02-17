import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

import 'package:sendme_outlet/flutter_project_imports.dart';
import 'package:sendme_outlet/src/api/api_call.dart';
import 'package:sendme_outlet/src/api/api_path.dart';
import 'package:sendme_outlet/src/models/order_summary.dart';
import 'package:sendme_outlet/src/ui/common/no_internet_page.dart';

class OrderSummaryView extends StatefulWidget {
  final Outlet? outlet;

  const OrderSummaryView({
    Key? key,
    this.outlet,
  }) : super(key: key);

  @override
  State<OrderSummaryView> createState() => _OrderSummaryViewState();
}

class _OrderSummaryViewState extends State<OrderSummaryView> {
  String _summaryFilterValue = 'Today';
  bool _loading = true;
  List<OrderSummary>? _orderSummary;
  final DateFormat _dateFormat = DateFormat('MM/dd/yyyy', 'en');

  String _fromDate = '';
  String _toDate = '';

  @override
  void initState() {
    super.initState();
    _updateDates();
    _fetchOrderSummary();
  }

  void _updateDates() {
    final now = DateTime.now();
    switch (_summaryFilterValue) {
      case 'Today':
        _fromDate = _dateFormat.format(now);
        _toDate = _dateFormat.format(now);
        break;
      case 'Yesterday':
        final yesterday = DateTime(now.year, now.month, now.day - 1);
        _fromDate = _dateFormat.format(yesterday);
        _toDate = _dateFormat.format(yesterday);
        break;
      case 'This Week':
        _fromDate = _dateFormat.format(now.subtract(const Duration(days: 6)));
        _toDate = _dateFormat.format(now);
        break;
      case 'This Month':
        _fromDate = _dateFormat.format(DateTime(now.year, now.month, 1));
        _toDate = _dateFormat.format(now);
        break;
    }
  }

  Future<void> _fetchOrderSummary() async {
    if (widget.outlet == null) {
      setState(() {
        _orderSummary = [];
        _loading = false;
      });
      return;
    }
    if (!await GlobalConstants.checkInternetConnection()) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NoInternetPage()),
        );
      }
      setState(() => _loading = false);
      return;
    }

    setState(() {
      _orderSummary = null;
      _loading = true;
    });

    try {
      final url =
          '${ApiPath.getProductSummaryReport}countryCode=${GlobalConstants.outletCountryCode}'
          '&fromDate=$_fromDate&toDate=$_toDate'
          '&outletId=${widget.outlet?.hotelId ?? ''}&cityId=${GlobalConstants.AdmincityId ?? ''}'
          '&deviceId=${GlobalConstants.Device_Id}&deviceType=${GlobalConstants.Device_Type}'
          '&version=${GlobalConstants.App_Version}';

      final response = await apiCall(url, '', 'get', 0, context);
      if (!mounted) return;

      final data = json.decode(utf8.decode(response.bodyBytes));

      if (data['Data'] != null && data['Status'] == 1) {
        final result = data['Data'] as List;
        setState(() {
          _orderSummary = result
              .map((j) => OrderSummary.fromJson(j as Map<String, dynamic>))
              .toList();
        });
      } else {
        setState(() => _orderSummary = []);
      }
    } catch (e) {
      logPrint('fetchOrderSummary error: $e');
      setState(() => _orderSummary = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _summaryFilterValue,
                isExpanded: true,
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _summaryFilterValue = v;
                    _updateDates();
                    _fetchOrderSummary();
                  });
                },
                items: ['Today', 'Yesterday', 'This Week', 'This Month']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? Center(
                    child: SpinKitThreeBounce(color: AppColors.mainAppColor),
                  )
                : _orderSummary == null || _orderSummary!.isEmpty
                    ? Center(
                        child: Text(
                          'No records',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _orderSummary!.length,
                        itemBuilder: (context, catIndex) {
                          final cat = _orderSummary![catIndex];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    cat.outlet ?? 'Outlet',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...(cat.products ?? []).map((p) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              p.subProduct != null && p.subProduct!.isNotEmpty
                                                  ? '${p.product} (${p.subProduct})'
                                                  : p.product ?? '-',
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                          Text(
                                            'Qty: ${p.qtySales ?? 0}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
