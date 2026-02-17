import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:sendme_outlet/flutter_project_imports.dart';
import 'package:sendme_outlet/src/api/api_call.dart';
import 'package:sendme_outlet/src/ui/common/no_internet_page.dart';
import 'package:sendme_outlet/src/ui/outlet/outletProducts/categories/add_category_view.dart';

class CategoriesView extends StatefulWidget {
  final Outlet? outlet;
  final void Function(int indexId, int categoryId, int subCategoryId)?
      tabController;
  final String search;

  const CategoriesView({
    Key? key,
    this.outlet,
    this.tabController,
    this.search = '',
  }) : super(key: key);

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  bool _loading = true;
  bool _statusChanging = false;
  int? _statusChangeIndex;
  List<Categories>? _categoriesList;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void didUpdateWidget(covariant CategoriesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.search != widget.search) {
      _loading = true;
      _fetchCategories();
    }
  }

  Future<void> _fetchCategories() async {
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

    try {
      final param = {
        'search': widget.search,
        'isWeb': '1',
        'dynamo': '0',
        'outletId': '${widget.outlet!.hotelId}',
        'userType': '${GlobalConstants.Outlet}',
        'pagination': '{}',
        'deviceType': '${GlobalConstants.Device_Type}',
        'deviceId': '${GlobalConstants.Device_Id}',
        'version': '${GlobalConstants.App_Version}',
      };

      final response = await apiCall(
          ApiPath.getOutletWiseProductCategories, param, 'post', 2, context);
      if (!mounted) return;

      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['Data'] != null && data['Status'] == 1) {
        final rest = data['Data'] as List;
        setState(() {
          _categoriesList =
              rest.map<Categories>((j) => Categories.fromJson(j as Map<String, dynamic>)).toList();
          _loading = false;
        });
      } else {
        setState(() {
          _categoriesList = [];
          _loading = false;
        });
      }
    } catch (e) {
      logPrint('Categories error: $e');
      setState(() {
        _categoriesList = [];
        _loading = false;
      });
      if (mounted) showToast('Something went wrong');
    }
  }

  Future<void> _toggleStatus(int index) async {
    if (!await GlobalConstants.checkInternetConnection()) {
      if (mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const NoInternetPage()));
      return;
    }

    final cat = _categoriesList![index];
    final newStatus = (cat.categoryStatus ?? 0) == 1 ? 0 : 1;
    setState(() {
      _statusChangeIndex = index;
      _statusChanging = true;
      _categoriesList![index] = Categories(
        catId: cat.catId,
        hotelId: cat.hotelId,
        outletTypeId: cat.outletTypeId,
        themeId: cat.themeId,
        categoryId: cat.categoryId,
        isMedicine: cat.isMedicine,
        isFoodType: cat.isFoodType,
        categoryStatus: newStatus,
        priority: cat.priority,
        categoryOutletId: cat.categoryOutletId,
        isCombo: cat.isCombo,
        catName: cat.catName,
        catImage: cat.catImage,
        category: cat.category,
        imageUrl: cat.imageUrl,
      );
    });

    try {
      final url =
          '${ApiPath.updateOutletCategoryStatus}OutletId=${widget.outlet!.hotelId}'
          '&CategoryStatus=$newStatus&CategoryId=${cat.categoryId}'
          '&userType=${GlobalConstants.Outlet}'
          '&deviceType=${GlobalConstants.Device_Type}'
          '&version=${GlobalConstants.App_Version}'
          '&deviceId=${GlobalConstants.Device_Id}';

      await apiCall(url, '', 'get', 0, context);
      if (!mounted) return;
      showToast('Status updated');
    } catch (e) {
      if (mounted) {
        setState(() {
          _categoriesList![index] = cat;
          showToast('Failed to update');
        });
      }
    } finally {
      if (mounted) setState(() {
        _statusChanging = false;
        _statusChangeIndex = null;
      });
    }
  }

  void _rebuildCallback() {
    setState(() => _loading = true);
    _fetchCategories();
  }

  void _shareCategory(Categories cat) {
    final name = cat.category ?? cat.catName ?? 'Category';
    final text = '${widget.outlet?.hotel ?? "Outlet"} - $name';
    Clipboard.setData(ClipboardData(text: text));
    showToast('Copied to clipboard');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(
        child: SpinKitThreeBounce(color: AppColors.mainAppColor),
      );
    }

    if (_categoriesList == null || _categoriesList!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No categories',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _categoriesList!.length,
        itemBuilder: (context, index) {
          final cat = _categoriesList![index];
          final hasImage = cat.imageUrl != null &&
              cat.imageUrl!.isNotEmpty &&
              !cat.imageUrl!.contains('??');
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                widget.tabController?.call(1, cat.categoryId ?? 0, 0);
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: hasImage
                          ? CachedNetworkImage(
                              imageUrl: cat.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: Colors.grey.shade300,
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              ),
                              errorWidget: (_, __, ___) => Icon(
                                Icons.category,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                            )
                          : Container(
                              color: Colors.grey.shade300,
                              child: Icon(
                                Icons.category,
                                size: 40,
                                color: Colors.grey.shade500,
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat.category ?? cat.catName ?? 'Category',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (cat.categoryStatus ?? 1) == 1
                                ? 'Active'
                                : 'Inactive',
                            style: TextStyle(
                              color: (cat.categoryStatus ?? 1) == 1
                                  ? Colors.green
                                  : Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddCategoryView(
                                  outletId: widget.outlet!.hotelId,
                                  edit: true,
                                  categoryId: cat.categoryId,
                                  categoryName: cat.category ?? cat.catName ?? '',
                                  imageUrl: cat.imageUrl,
                                  rebuildCallback: _rebuildCallback,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.share_outlined),
                          onPressed: () => _shareCategory(cat),
                        ),
                        if (_statusChanging && _statusChangeIndex == index)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: SizedBox(
                              width: 40,
                              height: 24,
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(right: 8, bottom: 4),
                            child: FlutterSwitch(
                              value: (cat.categoryStatus ?? 1) == 1,
                              onToggle: (_) => _toggleStatus(index),
                              width: 40,
                              height: 22,
                              toggleSize: 18,
                              padding: 1,
                              activeColor: AppColors.mainAppColor,
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddCategoryView(
                outletId: widget.outlet!.hotelId,
                edit: false,
                rebuildCallback: _rebuildCallback,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.mainAppColor,
      ),
    );
  }
}
