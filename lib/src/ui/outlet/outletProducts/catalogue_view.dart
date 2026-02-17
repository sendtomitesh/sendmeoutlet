import 'package:flutter/material.dart';

import 'package:sendme_outlet/flutter_project_imports.dart';
import 'package:sendme_outlet/src/ui/outlet/outletProducts/categories/categories_view.dart';
import 'package:sendme_outlet/src/ui/outlet/outletProducts/products/products_view.dart';

class CatalogueView extends StatefulWidget {
  final Outlet? outlet;

  const CatalogueView({Key? key, this.outlet}) : super(key: key);

  @override
  State<CatalogueView> createState() => _CatalogueViewState();
}

class _CatalogueViewState extends State<CatalogueView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedCategoryId = 0;
  int _selectedSubCategoryId = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    GlobalConstants.tabControllerCategoryId = 0;
    GlobalConstants.tabControllerSubCategoryId = 0;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _tabControllerManage(int indexId, int categoryId, int subCategoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _selectedSubCategoryId = subCategoryId;
      GlobalConstants.tabControllerCategoryId = categoryId;
      GlobalConstants.tabControllerSubCategoryId = subCategoryId;
      _tabController.animateTo(indexId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Catalogue',
          style: TextStyle(
            fontFamily: AssetsFont.textBold,
            color: AppColors.mainAppColor,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.mainAppColor,
              unselectedLabelColor: Colors.grey.shade400,
              indicatorColor: AppColors.mainAppColor,
              tabs: const [
                Tab(text: 'Categories'),
                Tab(text: 'Products'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CategoriesView(
            outlet: widget.outlet,
            tabController: _tabControllerManage,
            search: '',
          ),
          ProductsView(
            outlet: widget.outlet,
            search: '',
            categoryId: 0,
            subCategoryId: 0,
          ),
        ],
      ),
    );
  }
}
