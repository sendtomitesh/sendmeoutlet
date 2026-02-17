import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

import 'package:sendme_outlet/flutter_project_imports.dart';
import 'package:sendme_outlet/src/api/api_call.dart';
import 'package:sendme_outlet/src/api/api_path.dart';
import 'package:sendme_outlet/src/ui/common/no_internet_page.dart';
import 'package:sendme_outlet/src/ui/outlet/outletOrder/get_outlet_order_details.dart';
import 'package:sendme_outlet/src/ui/outlet/outlet_main_screen.dart';

class OutletOrderTabView extends StatefulWidget {
  final List<OutletOrderOrUserOrderDetail>? outletOrder;
  final int? userId;
  final int tab;

  const OutletOrderTabView({
    Key? key,
    this.outletOrder,
    this.userId,
    required this.tab,
  }) : super(key: key);

  @override
  State<OutletOrderTabView> createState() => _OutletOrderTabViewState();
}

class _OutletOrderTabViewState extends State<OutletOrderTabView> {
  int? _orderPreparedIndex;
  bool _orderPreparedLoading = false;

  String _orderStatusText(int status) {
    if (status == GlobalConstants.ORDER_PENDING) return 'PENDING';
    if (status == GlobalConstants.USER_CANCELLED) return 'USER CANCELLED';
    if (status == GlobalConstants.HOTEL_CANCELLED ||
        status == GlobalConstants.ADMIN_CANCELLED) return 'CANCELLED';
    if (status == GlobalConstants.SENDME_CANCELLED) return 'CANCELLED';
    if (status == GlobalConstants.HOTEL_ACCEPTED ||
        status == GlobalConstants.ADMIN_ACCEPTED ||
        status == GlobalConstants.SENDME_ACCEPTED) return 'ACCEPTED';
    if (status == GlobalConstants.ORDER_PREPARED) return 'PREPARED';
    if (status == GlobalConstants.ORDER_DELIVERED) return 'DELIVERED';
    return 'ORDER #$status';
  }

  Color _orderStatusColor(int status) {
    if (status == GlobalConstants.ORDER_PENDING) return Colors.red;
    if (status == GlobalConstants.USER_CANCELLED ||
        status == GlobalConstants.HOTEL_CANCELLED ||
        status == GlobalConstants.ADMIN_CANCELLED ||
        status == GlobalConstants.SENDME_CANCELLED) return Colors.red;
    if (status == GlobalConstants.HOTEL_ACCEPTED ||
        status == GlobalConstants.ADMIN_ACCEPTED ||
        status == GlobalConstants.SENDME_ACCEPTED ||
        status == GlobalConstants.ORDER_PREPARED) return Colors.green;
    if (status == GlobalConstants.ORDER_DELIVERED) return AppColors.mainAppColor;
    return AppColors.mainAppColor;
  }

  bool _isPending(int status) => status == GlobalConstants.ORDER_PENDING;
  bool _isCancelled(int status) =>
      status == GlobalConstants.USER_CANCELLED ||
      status == GlobalConstants.HOTEL_CANCELLED ||
      status == GlobalConstants.ADMIN_CANCELLED ||
      status == GlobalConstants.SENDME_CANCELLED;

  bool _canOrderPrepared(int status) =>
      status == GlobalConstants.HOTEL_ACCEPTED ||
      status == GlobalConstants.ADMIN_ACCEPTED ||
      status == GlobalConstants.SENDME_ACCEPTED;

  Future<void> _markOrderPrepared(int index) async {
    if (!await GlobalConstants.checkInternetConnection()) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NoInternetPage()),
        );
      }
      return;
    }

    setState(() {
      _orderPreparedIndex = index;
      _orderPreparedLoading = true;
    });

    try {
      final o = widget.outletOrder![index];
      final url =
          '${ApiPath.orderStatusUpdates}orderId=${o.orderId}'
          '&reason=&userId=${o.userId}'
          '&orderStatus=${GlobalConstants.ORDER_PREPARED}&actionType=2'
          '&userType=${GlobalConstants.Outlet}&deviceType=${GlobalConstants.Device_Type}'
          '&version=${GlobalConstants.App_Version}&deviceId=${GlobalConstants.Device_Id}';

      final response = await apiCall(url, '', 'get', 0, context);
      if (!mounted) return;

      final data = json.decode(response.body);
      if (data['Data'] != null && data['Status'] == 1) {
        showToast(data['Message']?.toString() ?? 'Order marked as prepared');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => OutletMainScreen(tabIndex: 1),
          ),
        );
      } else {
        showToast(data['Message']?.toString() ?? 'Failed');
      }
    } catch (e) {
      logPrint('Order prepared error: $e');
      if (mounted) showToast('Something went wrong');
    } finally {
      if (mounted) {
        setState(() {
          _orderPreparedIndex = null;
          _orderPreparedLoading = false;
        });
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == 'null') return '-';
    try {
      final parsed = DateFormat('MM/dd/yyyy h:mm:s a', 'en').parse(dateStr);
      return DateFormat('dd-MM-yyyy h:mm a').format(parsed);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = widget.outletOrder ?? [];
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final o = orders[index];
        final status = o.orderStatus ?? 0;
        final statusColor = _orderStatusColor(status);
        final statusText = _orderStatusText(status);

        return Card(
          elevation: 5,
          margin: const EdgeInsets.all(5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              width: 3,
              color: _isPending(status)
                  ? Colors.red.shade100
                  : (_isCancelled(status) ? Colors.grey.shade300 : Colors.transparent),
            ),
          ),
          color: _isPending(status)
              ? Colors.red.shade50
              : (_isCancelled(status) ? Colors.grey.shade200 : Colors.white),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GetOutletOrderDetails(order: o),
                ),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              '#${o.orderId} ',
                              style: TextStyle(
                                color: AppColors.mainAppColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '(${o.paymentType ?? '-'})',
                                style: TextStyle(
                                  color: AppColors.mainAppColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          statusText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          o.userName ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(o.mobile ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('Order at: ', style: TextStyle(color: Colors.grey.shade700)),
                      Expanded(
                        child: Text(
                          _formatDate(o.orderOn),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (o.slot != null && o.slot!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('Slot: ', style: TextStyle(color: Colors.green.shade700)),
                        Text(o.slot!, style: TextStyle(color: Colors.green.shade700)),
                      ],
                    ),
                  ],
                  if (o.riderName != null && o.riderName!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Assigned to: ${o.riderName}',
                      style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                    ),
                  ],
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_canOrderPrepared(status))
                        ElevatedButton.icon(
                          onPressed: _orderPreparedLoading && _orderPreparedIndex == index
                              ? null
                              : () => _markOrderPrepared(index),
                          icon: _orderPreparedLoading && _orderPreparedIndex == index
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
                          label: Text(
                            _orderPreparedLoading && _orderPreparedIndex == index ? '...' : 'Order Prepared',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mainAppColor,
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      Flexible(
                        child: Text(
                          '${o.currency ?? ''} ${GlobalConstants.formatCurrency(o.currency ?? '', o.totalBill ?? 0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
