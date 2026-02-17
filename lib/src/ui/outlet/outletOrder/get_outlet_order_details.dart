import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:intl/intl.dart';

import 'package:sendme_outlet/flutter_project_imports.dart';
import 'package:sendme_outlet/src/api/api_call.dart';
import 'package:sendme_outlet/src/ui/common/no_internet_page.dart';

class GetOutletOrderDetails extends StatefulWidget {
  final OutletOrderOrUserOrderDetail? order;

  const GetOutletOrderDetails({
    Key? key,
    this.order,
  }) : super(key: key);

  @override
  State<GetOutletOrderDetails> createState() => _GetOutletOrderDetailsState();
}

class _GetOutletOrderDetailsState extends State<GetOutletOrderDetails> {
  Future<OutletOrderOrUserOrderDetail?>? _orderDetailFuture;

  @override
  void initState() {
    super.initState();
    _orderDetailFuture = _fetchOrderDetail();
  }

  Future<OutletOrderOrUserOrderDetail?> _fetchOrderDetail() async {
    if (!await GlobalConstants.checkInternetConnection()) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NoInternetPage()),
        );
      }
      return null;
    }

    final o = widget.order!;
    final outletId = o.hotelId;
    if (outletId == null) {
      return o;
    }

    try {
      final url =
          '${ApiPath.getHotelsOrderDetail}outletId=$outletId&orderId=${o.orderId}&isAdmin=1'
          '&userType=${GlobalConstants.Outlet}&deviceType=${GlobalConstants.Device_Type}'
          '&version=${GlobalConstants.App_Version}&deviceId=${GlobalConstants.Device_Id}';

      final response = await apiCall(url, '', 'get', 0, context);
      if (!mounted) return null;

      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['Data'] != null && data['Status'] == 1) {
        return OutletOrderOrUserOrderDetail.fromJson(
            data['Data'] as Map<String, dynamic>);
      }
    } catch (e) {
      logPrint('fetchOrderDetail error: $e');
    }
    return o;
  }

  Future<void> _updateOrderStatus(int orderStatus, {String reason = ''}) async {
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
      final o = widget.order!;
      final url =
          '${ApiPath.orderStatusUpdates}orderId=${o.orderId}'
          '&reason=$reason&userId=${o.userId}'
          '&orderStatus=$orderStatus&actionType=2'
          '&userType=${GlobalConstants.Outlet}&deviceType=${GlobalConstants.Device_Type}'
          '&version=${GlobalConstants.App_Version}&deviceId=${GlobalConstants.Device_Id}';

      await apiCall(url, '', 'get', 0, context);
      if (!mounted) return;

      showToast('Status updated');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => OutletMainScreen(tabIndex: 1)),
      );
    } catch (e) {
      logPrint('updateOrderStatus error: $e');
      if (mounted) showToast('Something went wrong');
    }
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Order'),
        content: const Text(
          'Are you sure you want to reject this order?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateOrderStatus(GlobalConstants.HOTEL_CANCELLED,
                  reason: 'Rejected by outlet');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OutletOrderOrUserOrderDetail?>(
      future: _orderDetailFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Order Details')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('Something went wrong',
                      style: TextStyle(color: Colors.grey.shade700)),
                ],
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.none) {
          return Scaffold(
            appBar: AppBar(title: const Text('Order Details')),
            body: ListView(
              children: [
                const Padding(padding: EdgeInsets.all(16)),
                ListTileShimmer(),
                const Divider(),
                ListTileShimmer(),
                const Divider(),
                ListTileShimmer(),
              ],
            ),
          );
        }

        final order = snapshot.data ?? widget.order;
        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Order Details')),
            body: const Center(child: Text('Order not found')),
          );
        }

        return _OrderDetailScreen(
          order: order,
          onAccept: () => _updateOrderStatus(GlobalConstants.HOTEL_ACCEPTED),
          onReject: _showRejectDialog,
          onOrderPrepared: () =>
              _updateOrderStatus(GlobalConstants.ORDER_PREPARED),
        );
      },
    );
  }
}

class _OrderDetailScreen extends StatelessWidget {
  final OutletOrderOrUserOrderDetail order;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onOrderPrepared;

  const _OrderDetailScreen({
    required this.order,
    required this.onAccept,
    required this.onReject,
    required this.onOrderPrepared,
  });

  String _formatDate(String? s) {
    if (s == null || s.isEmpty || s == 'null') return '-';
    try {
      return DateFormat('dd-MM-yyyy h:mm a')
          .format(DateFormat('MM/dd/yyyy h:mm:s a', 'en').parse(s));
    } catch (_) {
      return s;
    }
  }

  String _deliveryTypeText() {
    if (order.deliveryType == GlobalConstants.HOME_DELIVERY) return 'Home Delivery';
    if (order.deliveryType == GlobalConstants.TAKE_AWAY) return 'Take Away';
    return 'Delivery';
  }

  String _orderStatusText() {
    if (order.orderStatus == GlobalConstants.ORDER_PENDING) return 'PENDING';
    if (order.orderStatus == GlobalConstants.USER_CANCELLED) return 'USER CANCELLED';
    if (order.orderStatus == GlobalConstants.HOTEL_CANCELLED ||
        order.orderStatus == GlobalConstants.ADMIN_CANCELLED) return 'CANCELLED';
    if (order.orderStatus == GlobalConstants.SENDME_CANCELLED) return 'CANCELLED';
    if (order.orderStatus == GlobalConstants.HOTEL_ACCEPTED ||
        order.orderStatus == GlobalConstants.ADMIN_ACCEPTED ||
        order.orderStatus == GlobalConstants.SENDME_ACCEPTED) return 'ACCEPTED';
    if (order.orderStatus == GlobalConstants.ORDER_PREPARED) return 'PREPARED';
    if (order.orderStatus == GlobalConstants.ORDER_DELIVERED) return 'DELIVERED';
    return 'ORDER #${order.orderStatus}';
  }

  Color _orderStatusColor() {
    if (order.orderStatus == GlobalConstants.ORDER_PENDING) return Colors.red;
    if (order.orderStatus == GlobalConstants.USER_CANCELLED ||
        order.orderStatus == GlobalConstants.HOTEL_CANCELLED ||
        order.orderStatus == GlobalConstants.ADMIN_CANCELLED ||
        order.orderStatus == GlobalConstants.SENDME_CANCELLED) return Colors.red;
    if (order.orderStatus == GlobalConstants.HOTEL_ACCEPTED ||
        order.orderStatus == GlobalConstants.ADMIN_ACCEPTED ||
        order.orderStatus == GlobalConstants.SENDME_ACCEPTED ||
        order.orderStatus == GlobalConstants.ORDER_PREPARED) return Colors.green;
    if (order.orderStatus == GlobalConstants.ORDER_DELIVERED) return AppColors.mainAppColor;
    return AppColors.mainAppColor;
  }

  @override
  Widget build(BuildContext context) {
    final isPending = order.orderStatus == GlobalConstants.ORDER_PENDING;
    final canOrderPrepared = order.orderStatus == GlobalConstants.HOTEL_ACCEPTED ||
        order.orderStatus == GlobalConstants.ADMIN_ACCEPTED ||
        order.orderStatus == GlobalConstants.SENDME_ACCEPTED;
    final isCancelled = order.orderStatus == GlobalConstants.USER_CANCELLED ||
        order.orderStatus == GlobalConstants.HOTEL_CANCELLED ||
        order.orderStatus == GlobalConstants.ADMIN_CANCELLED ||
        order.orderStatus == GlobalConstants.SENDME_CANCELLED;

    final itemTotal = order.itemTotal ?? order.netBill ?? 0.0;
    final cur = order.currency ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.orderId}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Call Rider
            if (order.riderNumber != null &&
                order.riderNumber!.isNotEmpty) ...[
              Card(
                child: ListTile(
                  title: ElevatedButton.icon(
                    onPressed: () => appLaunchUrl('tel:${order.riderNumber}'),
                    icon: const Icon(Icons.phone, color: Colors.white),
                    label: const Text('Call Rider',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainAppColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Order items
            Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                      child: Text('PRODUCTS',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87)),
                    ),
                    if (order.orderDetail != null &&
                        order.orderDetail!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ...order.orderDetail!.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        final name = funToString(item['name'] ?? item['itemName'] ?? item['ItemName'] ?? item['Name']) ?? '-';
                        final qty = funToInt(item['qty'] ?? item['Qty']) ?? 1;
                        final price =
                            funToDouble(item['price'] ?? item['Price']) ?? 0.0;
                        final total = funToDouble(
                                item['totalAmount'] ?? item['TotalAmount']) ??
                            (price * qty);
                        String subName = '';
                        if (order.requestOrderDetails != null &&
                            idx < order.requestOrderDetails!.length) {
                          subName = funToString(
                              order.requestOrderDetails![idx]
                                  ['subItemName']) ??
                              '';
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subName.isNotEmpty
                                    ? '$name ($subName)'
                                    : name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 14),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$qty x ${GlobalConstants.formatCurrency(cur, price)}',
                                    style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 13),
                                  ),
                                  Text(
                                    '${GlobalConstants.formatCurrency(cur, total)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              if (idx < order.orderDetail!.length - 1)
                                const Divider(),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Order summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.mainAppColor, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.mainAppColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('ORDER SUMMARY',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 14)),
                    ),
                  ),
                  if (itemTotal > 0) _summaryRow('Bill Total', itemTotal),
                  if ((order.additionalCharges ?? 0) > 0)
                    _summaryRow('Additional Charge', order.additionalCharges!),
                  if ((order.deliveryCharge ?? 0) > 0)
                    _summaryRow('Delivery Charge', order.deliveryCharge!),
                  if ((order.cGST ?? 0) > 0) _summaryRow('CGST', order.cGST!),
                  if ((order.sGST ?? 0) > 0) _summaryRow('SGST', order.sGST!),
                  const Divider(),
                  _summaryRow('Total',
                      order.totalBill ?? order.netBill ?? itemTotal,
                      bold: true),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Payment Mode: ',
                          style: TextStyle(
                              color: AppColors.mainAppColor,
                              fontWeight: FontWeight.w600)),
                      Text(order.paymentType ?? '-',
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  if ((order.deliveryOn != null && order.deliveryOn!.isNotEmpty) ||
                      (order.slot != null && order.slot!.isNotEmpty))
                    Row(
                      children: [
                        Text('Delivery at: ',
                            style: TextStyle(color: Colors.green.shade700)),
                        Text(
                            order.slot != null && order.slot!.isNotEmpty
                                ? order.slot!
                                : _formatDate(order.deliveryOn),
                            style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  Row(
                    children: [
                      Text('Order Type: ',
                          style: TextStyle(
                              color: AppColors.mainAppColor,
                              fontWeight: FontWeight.w600)),
                      Text(_deliveryTypeText()),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _orderStatusColor(),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _orderStatusText(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            // Remarks
            if (order.remarks != null && order.remarks!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _sectionTitle('Remark'),
              Text(order.remarks!,
                  style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ],
            if (order.adminRemark != null && order.adminRemark!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _sectionTitle('Admin Remark'),
              Text(order.adminRemark!,
                  style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ],

            const SizedBox(height: 16),
            const Divider(),

            // Customer info
            _sectionTitle('Customer Info'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.userName ?? '-',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(order.mobile ?? '-',
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 14)),
                  ],
                ),
                if (order.mobile != null && order.mobile!.isNotEmpty)
                  IconButton(
                    onPressed: () =>
                        appLaunchUrl('tel:${order.mobile}'),
                    icon: Icon(Icons.phone, color: AppColors.mainAppColor),
                  ),
              ],
            ),

            // Address (Home Delivery)
            if (order.address != null &&
                order.deliveryType == GlobalConstants.HOME_DELIVERY) ...[
              const SizedBox(height: 16),
              const Divider(),
              _sectionTitle('Delivery Address'),
              const SizedBox(height: 8),
              Text(
                order.address!.floor != null &&
                        order.address!.floor!.isNotEmpty
                    ? '${order.address!.address}, ${order.address!.floor} Floor, ${order.address!.landMark ?? ''}'
                    : '${order.address!.address ?? ''}${order.address!.landMark != null && order.address!.landMark!.isNotEmpty ? ', ${order.address!.landMark}' : ''}',
                style: const TextStyle(fontSize: 14),
              ),
              if (order.address!.contactName != null ||
                  order.address!.contactNo != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        '${order.address!.contactName ?? ''} ${order.address!.contactNo ?? ''}'
                            .trim(),
                        style: const TextStyle(fontSize: 14)),
                    if (order.address!.contactNo != null &&
                        order.address!.contactNo!.isNotEmpty)
                      IconButton(
                        onPressed: () => appLaunchUrl(
                            'tel:${order.address!.contactNo}'),
                        icon: Icon(Icons.phone,
                            color: AppColors.mainAppColor),
                      ),
                  ],
                ),
            ],

            // Cancellation reason
            if (isCancelled && order.reason != null && order.reason!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              _sectionTitle('Reason'),
              Text(order.reason!,
                  style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                      fontSize: 14)),
            ],

            const SizedBox(height: 24),

            // Action buttons
            if (isPending)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('REJECT'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('ACCEPT'),
                    ),
                  ),
                ],
              )
            else if (canOrderPrepared)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onOrderPrepared,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Order Prepared'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainAppColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87));
  }

  Widget _summaryRow(String label, double amount, {bool bold = false}) {
    final cur = order.currency ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text('$cur ${GlobalConstants.formatCurrency(cur, amount)}',
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
