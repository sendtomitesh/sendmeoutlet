import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:sendme_outlet/flutter_project_imports.dart';
import 'package:sendme_outlet/src/api/api_call.dart';
import 'package:sendme_outlet/src/ui/common/no_internet_page.dart';
import 'package:sendme_outlet/src/ui/outlet/outletProducts/products/add_product/add_product_view.dart';
import 'package:sendme_outlet/src/ui/outlet/outletProducts/products/edit_product/edit_product_view.dart';

class ProductsView extends StatefulWidget {
  final Outlet? outlet;
  final String search;
  final int categoryId;
  final int subCategoryId;

  const ProductsView({
    Key? key,
    this.outlet,
    this.search = '',
    this.categoryId = 0,
    this.subCategoryId = 0,
  }) : super(key: key);

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  bool _loading = true;
  bool _statusChanging = false;
  int? _statusChangeIndex;
  List<MenuItems>? _productList;

  int get _categoryId => widget.categoryId;
  int get _subCategoryId => widget.subCategoryId;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void didUpdateWidget(covariant ProductsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.search != widget.search ||
        oldWidget.categoryId != widget.categoryId ||
        oldWidget.subCategoryId != widget.subCategoryId) {
      _loading = true;
      _fetchProducts();
    }
  }

  Future<void> _fetchProducts() async {
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
      if (_categoryId == 0) {
        final url =
            '${ApiPath.getProductsByOutletId}pageIndex=0&search=${widget.search}'
            '&isWeb=1&outletId=${widget.outlet!.hotelId}'
            '&countryCode=${GlobalConstants.outletCountryCode ?? ""}'
            '&userType=${GlobalConstants.Outlet}'
            '&deviceType=${GlobalConstants.Device_Type}'
            '&version=${GlobalConstants.App_Version}'
            '&deviceId=${GlobalConstants.Device_Id}';

        final response = await apiCall(url, '', 'get', 0, context);
        if (!mounted) return;

        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['Data'] != null) {
          final rest = data['Data'] as List?;
          setState(() {
            _productList = rest != null
                ? rest
                    .map<MenuItems>(
                        (j) => MenuItems.fromJson(j as Map<String, dynamic>))
                    .toList()
                : [];
            _loading = false;
          });
        } else {
          setState(() {
            _productList = [];
            _loading = false;
          });
        }
      } else {
        final param = {
          'isWeb': '1',
          'CategoryId': '$_categoryId',
          'pageIndex': '0',
          'subCategoryId': '$_subCategoryId',
          'outletId': '${widget.outlet!.hotelId}',
          'userType': '${GlobalConstants.Outlet}',
          'search': widget.search,
          'pagination': '{}',
          'deviceType': '${GlobalConstants.Device_Type}',
          'deviceId': '${GlobalConstants.Device_Id}',
          'version': '${GlobalConstants.App_Version}',
        };

        final response = await apiCall(
            ApiPath.getCategoriesWiseOutletProducts, param, 'post', 2, context);
        if (!mounted) return;

        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['Data'] != null && data['Status'] == 1) {
          final rest = data['Data'] as List;
          setState(() {
            _productList = rest
                .map<MenuItems>(
                    (j) => MenuItems.fromJson(j as Map<String, dynamic>))
                .toList();
            _loading = false;
          });
        } else {
          setState(() {
            _productList = [];
            _loading = false;
          });
        }
      }
    } catch (e) {
      logPrint('Products error: $e');
      setState(() {
        _productList = [];
        _loading = false;
      });
      if (mounted) showToast('Something went wrong');
    }
  }

  String? _resolveImageUrl(String? raw) {
    if (raw == null || raw.isEmpty || raw.contains('??') || raw == 'null') {
      return null;
    }
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }
    const base = 'https://sls.sendme.today';
    return raw.startsWith('/') ? '$base$raw' : '$base/$raw';
  }

  Widget _defaultProductImage() {
    return Container(
      color: Colors.grey.shade300,
      child: Icon(
        Icons.restaurant,
        size: 36,
        color: Colors.grey.shade500,
      ),
    );
  }

  void _shareProduct(MenuItems item) {
    final text =
        '${widget.outlet?.hotel ?? "Outlet"} - ${item.name}\n'
        '${item.currency ?? ""} ${GlobalConstants.formatCurrency(item.currency ?? "", item.price ?? 0)}';
    Clipboard.setData(ClipboardData(text: text));
    showToast('Copied to clipboard');
  }

  Future<void> _toggleStatus(int index) async {
    if (!await GlobalConstants.checkInternetConnection()) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NoInternetPage()),
        );
      }
      return;
    }

    final item = _productList![index];
    final newStatus = (item.status ?? 1) == 1 ? 0 : 1;
    setState(() {
      _statusChangeIndex = index;
      _statusChanging = true;
      _productList![index] = MenuItems(
        categoryItemId: item.categoryItemId,
        categoryId: item.categoryId,
        subCategoryId: item.subCategoryId,
        priceId: item.priceId,
        status: newStatus,
        outletId: item.outletId,
        price: item.price,
        priority: item.priority,
        name: item.name,
        description: item.description,
        imageUrl: item.imageUrl,
        ImageUrl: item.ImageUrl,
        imagePath: item.imagePath,
        currency: item.currency,
        imagePathList: item.imagePathList,
      );
    });

    try {
      final param = {
        'action': 'updatePriceStatus',
        'priceId': item.priceId,
        'priceStatus': newStatus,
        'userType': GlobalConstants.Outlet,
        'deviceType': '${GlobalConstants.Device_Type}',
        'version': '${GlobalConstants.App_Version}',
        'deviceId': '${GlobalConstants.Device_Id}',
      };

      await apiCall(ApiPath.manageMenuItem, param, 'post', 2, context);
      if (!mounted) return;
      showToast('Status updated');
    } catch (e) {
      if (mounted) {
        setState(() {
          _productList![index] = item;
          showToast('Failed to update');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _statusChanging = false;
          _statusChangeIndex = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(
        child: SpinKitThreeBounce(color: AppColors.mainAppColor),
      );
    }

    if (_productList == null || _productList!.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey.shade200,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined,
                  size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No products',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>           AddProductView(
                  outlet: widget.outlet,
                  isEcom: GlobalConstants.themeId == GlobalConstants.Grocery_Store_UI,
                ),
              ),
            );
            if (mounted) _fetchProducts();
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Product'),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.mainAppColor,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _productList!.length,
        itemBuilder: (context, index) {
          final item = _productList![index];
          final rawUrl = item.imagePathList != null &&
                  item.imagePathList!.isNotEmpty
              ? item.imagePathList!.first
              : (item.ImageUrl ?? item.imageUrl ?? item.imagePath);
          final imgUrl = _resolveImageUrl(rawUrl);
          final hasImage = imgUrl != null && imgUrl.isNotEmpty;
          final cur = item.currency ?? widget.outlet?.currency ?? '';
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: hasImage
                        ? CachedNetworkImage(
                            imageUrl: imgUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _defaultProductImage(),
                            errorWidget: (_, __, ___) => _defaultProductImage(),
                          )
                        : _defaultProductImage(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name ?? 'Product',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$cur ${GlobalConstants.formatCurrency(cur, item.price ?? 0)}',
                          style: TextStyle(
                            color: AppColors.mainAppColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (item.status ?? 1) == 1
                              ? 'In Stock'
                              : 'Out of Stock',
                          style: TextStyle(
                            color: (item.status ?? 1) == 1
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
                              builder: (_) => EditProductView(
                                outlet: widget.outlet,
                                menuItem: item,
                              ),
                            ),
                          );
                          if (mounted) _fetchProducts();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined),
                        onPressed: () => _shareProduct(item),
                      ),
                      if (_statusChanging && _statusChangeIndex == index)
                        const SizedBox(
                          width: 40,
                          height: 24,
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      else
                        FlutterSwitch(
                          value: (item.status ?? 1) == 1,
                          onToggle: (_) => _toggleStatus(index),
                          width: 40,
                          height: 22,
                          toggleSize: 18,
                          padding: 1,
                          activeColor: AppColors.mainAppColor,
                        ),
                    ],
                  ),
                ],
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
              builder: (_) =>           AddProductView(
                  outlet: widget.outlet,
                  isEcom: GlobalConstants.themeId == GlobalConstants.Grocery_Store_UI,
                ),
            ),
          );
          if (mounted) _fetchProducts();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.mainAppColor,
      ),
    );
  }
}
