import 'package:flutter/material.dart';

import 'package:sendme_outlet/flutter_project_imports.dart';
import 'package:sendme_outlet/src/ui/outlet/outletOrder/get_outlet_order_list.dart';
import 'package:sendme_outlet/src/ui/outlet/outletOrder/orderSummary/order_summary_view.dart';
import 'package:sendme_outlet/src/ui/outlet/outlet_main_screen.dart';

class OutletOrderTab extends StatefulWidget {
  final Outlet? outlet;
  final int? userId;
  final int? index;

  const OutletOrderTab({
    Key? key,
    this.outlet,
    this.userId,
    this.index,
  }) : super(key: key);

  @override
  State<OutletOrderTab> createState() => _OutletOrderTabState();
}

class _OutletOrderTabState extends State<OutletOrderTab>
    with TickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.index ?? 0,
    );
    GlobalConstants.streamController.stream.listen((data) {
      if (data == 'outletNotify' && mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onRefresh() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => OutletMainScreen(
          tabIndex: 1,
          index: _controller.index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.mainAppColor),
            onPressed: _onRefresh,
          ),
        ],
        title: Text(
          widget.outlet?.hotel ?? 'Orders',
          style: TextStyle(
            fontFamily: AssetsFont.textBold,
            color: Colors.black87,
            fontSize: 18,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: TabBar(
              controller: _controller,
              isScrollable: true,
              unselectedLabelColor: Colors.grey.shade400,
              labelColor: AppColors.mainAppColor,
              indicatorColor: AppColors.mainAppColor,
              labelStyle: TextStyle(fontFamily: AssetsFont.textBold),
              tabs: const [
                Tab(text: 'Today Order'),
                Tab(text: 'Pending'),
                Tab(text: 'All Order'),
                Tab(text: 'Order Summary'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _controller,
              children: [
                GetOutletOrderList(
                  tab: 1,
                  outlet: widget.outlet,
                  userId: widget.userId,
                ),
                GetOutletOrderList(
                  tab: 2,
                  outlet: widget.outlet,
                  userId: widget.userId,
                ),
                GetOutletOrderList(
                  tab: 3,
                  outlet: widget.outlet,
                  userId: widget.userId,
                ),
                OrderSummaryView(outlet: widget.outlet),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
