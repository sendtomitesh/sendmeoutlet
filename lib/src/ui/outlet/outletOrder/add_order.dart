import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:sendme_outlet/flutter_project_imports.dart';
import 'package:sendme_outlet/src/api/api_call.dart';
import 'package:sendme_outlet/src/api/api_path.dart';
import 'package:sendme_outlet/src/ui/common/no_internet_page.dart';
import 'package:sendme_outlet/src/ui/outlet/outlet_main_screen.dart';

/// Cart item for Add Order
class _CartItem {
  final MenuItems product;
  int qty;

  _CartItem({required this.product, required this.qty});
}

/// Add Order flow for restaurant - Phase 6.
/// Manual order creation: select customer, items, address, place order.
class AddOrder extends StatefulWidget {
  final Outlet? outlet;
  final int? outletId;
  final String? outletName;
  final int? quantity;
  final int? cityId;

  const AddOrder({
    Key? key,
    this.outlet,
    this.outletId,
    this.outletName,
    this.quantity = 0,
    this.cityId,
  }) : super(key: key);

  @override
  State<AddOrder> createState() => _AddOrderState();
}

class _AddOrderState extends State<AddOrder> {
  int _currentStep = 0;
  final _mobileController = TextEditingController();
  final _nameController = TextEditingController();
  String? _customerMessage;

  bool _customerLoading = false;
  int? _userId;
  int? _cityId;
  int? _areaId;
  int _addressId = 0;

  bool _productsLoading = false;
  List<MenuItems>? _products;
  final List<_CartItem> _cart = [];

  bool _addressesLoading = false;
  List<AddressModel>? _addresses;
  AddressModel? _selectedAddress;

  bool _placeOrderLoading = false;

  @override
  void initState() {
    super.initState();
    _cityId = widget.cityId ?? GlobalConstants.outletCityId;
    GlobalConstants.userAddressLatitude = GlobalConstants.latitude;
    GlobalConstants.userAddressLongitude = GlobalConstants.longitude;
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _lookupCustomer() async {
    final mobile = _mobileController.text.trim();
    if (mobile.isEmpty) {
      showToast('Enter mobile number');
      return;
    }
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
      _customerLoading = true;
      _customerMessage = null;
    });

    try {
      final url =
          '${ApiPath.getUserFromMobileNumber}mobileNumber=$mobile'
          '&userType=${GlobalConstants.Outlet}'
          '&deviceId=${GlobalConstants.Device_Id}'
          '&deviceType=${GlobalConstants.Device_Type}'
          '&version=${GlobalConstants.App_Version}';

      final response = await apiCall(url, '', 'get', 0, context);
      if (!mounted) return;

      final data = json.decode(utf8.decode(response.bodyBytes));

      if (data['Data'] != null && data['Status'] == 1) {
        final d = data['Data'] as Map<String, dynamic>;
        _userId = funToInt(d['userId']);
        final exist = funToInt(d['exist']) ?? 0;
        if (exist == 1 && d['userName'] != null) {
          _nameController.text = funToString(d['userName']) ?? '';
        }
        setState(() {
          _customerLoading = false;
          _customerMessage =
              _userId != null && _userId! > 0
                  ? 'Customer found'
                  : 'Customer not found – must be registered in app';
          _currentStep = 1;
        });
      } else {
        setState(() {
          _customerLoading = false;
          _userId = null;
          _customerMessage =
              data['Message']?.toString() ?? 'Customer not found';
          _currentStep = 1;
        });
      }
    } catch (e) {
      logPrint('Customer lookup error: $e');
      if (mounted) {
        setState(() {
          _customerLoading = false;
          showToast('Something went wrong');
        });
      }
    }
  }

  Future<void> _loadProducts() async {
    if (widget.outlet == null) return;
    if (!await GlobalConstants.checkInternetConnection()) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NoInternetPage()),
        );
      }
      return;
    }

    setState(() => _productsLoading = true);

    try {
      final url =
          '${ApiPath.getProductsByOutletId}pageIndex=0&search='
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
          _products = rest != null
              ? rest
                  .map<MenuItems>(
                      (j) => MenuItems.fromJson(j as Map<String, dynamic>))
                  .toList()
              : [];
          _productsLoading = false;
        });
      } else {
        setState(() {
          _products = [];
          _productsLoading = false;
        });
      }
    } catch (e) {
      logPrint('Products load error: $e');
      if (mounted) {
        setState(() => _productsLoading = false);
        showToast('Failed to load menu');
      }
    }
  }

  void _addToCart(MenuItems product, [int qty = 1]) {
    final existing = _cart.where((c) => c.product.priceId == product.priceId);
    if (existing.isNotEmpty) {
      existing.first.qty += qty;
    } else {
      _cart.add(_CartItem(product: product, qty: qty));
    }
    setState(() {});
  }

  void _updateCartQty(_CartItem item, int delta) {
    item.qty += delta;
    if (item.qty <= 0) {
      _cart.remove(item);
    }
    setState(() {});
  }

  double get _cartTotal {
    double t = 0;
    for (final c in _cart) {
      t += (c.product.price ?? 0) * c.qty;
    }
    return t;
  }

  Future<void> _loadAddresses() async {
    if (_userId == null || _userId! <= 0) {
      showToast('Invalid customer');
      return;
    }
    if (!await GlobalConstants.checkInternetConnection()) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NoInternetPage()),
        );
      }
      return;
    }

    setState(() => _addressesLoading = true);

    try {
      final url =
          '${ApiPath.getAddressListByUserId}userId=$_userId'
          '&deviceId=${GlobalConstants.Device_Id}'
          '&deviceType=${GlobalConstants.Device_Type}'
          '&userType=${GlobalConstants.Outlet}'
          '&version=${GlobalConstants.App_Version}';

      final response = await apiCall(url, '', 'get', 0, context);
      if (!mounted) return;

      final data = json.decode(utf8.decode(response.bodyBytes));

      if (data['Data'] != null && data['Status'] == 1) {
        final rest = data['Data'] as List;
        var list = rest
            .map<AddressModel>(
                (j) => AddressModel.fromJson(j as Map<String, dynamic>))
            .toList();
        if (GlobalConstants.isOutlet == 1 || GlobalConstants.userType == 1) {
          final cityId = _cityId ?? GlobalConstants.outletCityId;
          if (cityId != null) {
            list = list.where((a) => a.cityId == cityId).toList();
          }
        }
        setState(() {
          _addresses = list;
          _addressesLoading = false;
          _selectedAddress = list.isNotEmpty ? list.first : null;
          if (_selectedAddress != null) {
            _addressId = _selectedAddress!.addressId ?? 0;
            _areaId = _selectedAddress!.areaId;
            if (_selectedAddress!.latitude != null &&
                _selectedAddress!.longitude != null) {
              GlobalConstants.userAddressLatitude =
                  _selectedAddress!.latitude ?? 0;
              GlobalConstants.userAddressLongitude =
                  _selectedAddress!.longitude ?? 0;
            }
          }
        });
      } else {
        setState(() {
          _addresses = [];
          _addressesLoading = false;
          _selectedAddress = null;
        });
      }
    } catch (e) {
      logPrint('Address load error: $e');
      if (mounted) {
        setState(() => _addressesLoading = false);
        showToast('Failed to load addresses');
      }
    }
  }

  Future<void> _placeOrder() async {
    if (_userId == null || _userId! <= 0) {
      showToast('Invalid customer');
      return;
    }
    if (_cart.isEmpty) {
      showToast('Add at least one item');
      return;
    }
    if (_selectedAddress == null || _addressId <= 0) {
      showToast('Select delivery address');
      return;
    }
    if (!await GlobalConstants.checkInternetConnection()) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NoInternetPage()),
        );
      }
      return;
    }

    setState(() => _placeOrderLoading = true);

    try {
      final itemData = <Map<String, dynamic>>[];
      for (final c in _cart) {
        itemData.add({
          'priceId': c.product.priceId.toString(),
          'quantity': c.qty.toString(),
        });
      }

      final checkoutParam = {
        'userId': '$_userId',
        'hotelId': widget.outlet!.hotelId,
        'apiVersion': '1',
        'userLatitude': '${GlobalConstants.userAddressLatitude}',
        'userLongitude': '${GlobalConstants.userAddressLongitude}',
        'userType': '${GlobalConstants.userType}',
        'areaId': _areaId != null ? '$_areaId' : null,
        'deliveryType': '${GlobalConstants.HOME_DELIVERY}',
        'todayDate': DateFormat('yyyy/MM/dd').format(DateTime.now()),
        'appVersion': '${GlobalConstants.App_Version}',
        'deliveryOn': '',
        'CityId': _cityId != null ? '$_cityId' : null,
        'CountryCode':
            GlobalConstants.outletCountryCode ?? '',
        'deviceType': '${GlobalConstants.Device_Type}',
        'deviceId': '${GlobalConstants.Device_Id}',
        'addressId': _addressId,
        'items': itemData,
        'total': '$_cartTotal',
        'storeType': 0,
      };

      final checkoutResponse =
          await apiCall(ApiPath.checkoutOrder, checkoutParam, 'post', 2, context);
      if (!mounted) return;

      final checkoutData =
          json.decode(utf8.decode(checkoutResponse.bodyBytes));
      final message = checkoutData['Message']?.toString() ?? '';

      if (checkoutData['Data'] == null || checkoutData['Status'] != 1) {
        setState(() => _placeOrderLoading = false);
        showToast(message);
        return;
      }

      final checkoutOrder = checkoutData['Data'] as Map<String, dynamic>;
      final priceDetail = checkoutOrder['priceDetail'] as List? ?? [];

      final orderDetail = <Map<String, dynamic>>[];
      double sgst = 0;
      double cgst = 0;

      if (checkoutOrder['SGST'] != null) {
        sgst = (checkoutOrder['SGST']['SGSTAmount'] as num?)?.toDouble() ?? 0;
      }
      if (checkoutOrder['CGST'] != null) {
        cgst = (checkoutOrder['CGST']['CGSTAmount'] as num?)?.toDouble() ?? 0;
      }

      for (var i = 0; i < priceDetail.length; i++) {
        final p = priceDetail[i] as Map<String, dynamic>;
        final subitems = p['subitems'];
        if (subitems != null) {
          orderDetail.add({
            'MenuPriceId': p['subItemPriceId'] ?? p['PriceId'],
            'qty': p['qty'],
            'amount': (p['Price'] as num) * (p['qty'] as num),
            'subitems': subitems,
          });
        } else {
          orderDetail.add({
            'MenuPriceId': p['subItemPriceId'] ?? p['PriceId'],
            'qty': p['qty'],
            'amount': (p['Price'] as num) * (p['qty'] as num),
          });
        }
      }

      final addOrderParam = {
        'deliveryCharge': checkoutOrder['DeliveryCharge'],
        'addressId': _addressId,
        'apiVersion': '1',
        'deliveryChargeWithoutGST':
            checkoutOrder['deliveryChargeWithoutGST'] ?? 0,
        'GSTOnDeliveryCharge': checkoutOrder['GSTOnDeliveryCharge'] ?? 0,
        'userLatitude': '${GlobalConstants.userAddressLatitude}',
        'userLongitude': '${GlobalConstants.userAddressLongitude}',
        'areaId': _areaId,
        'CityId': _cityId,
        'CountryCode': GlobalConstants.outletCountryCode ?? '',
        'userId': _userId,
        'outletId': widget.outlet!.hotelId,
        'remarks': '',
        'OrderDetail': orderDetail,
        'orderType': GlobalConstants.HOME_DELIVERY,
        'deliveryOn': '',
        'additionalCharges': checkoutOrder['additionalCharagePer'] ?? 0,
        'grandTotal': checkoutOrder['GrandTotal'],
        'netTotal': checkoutOrder['NetTotal'],
        'cgst': cgst,
        'sgst': sgst,
        'deviceId': '${GlobalConstants.Device_Id}',
        'deviceType': '${GlobalConstants.Device_Type}',
        'version': '${GlobalConstants.App_Version}',
        'paymentMode': GlobalConstants.CASH,
        'userType': GlobalConstants.userType,
        'billType': checkoutOrder['billType'] ?? 0,
        'checkrazor': 1,
        'transStatus': 1,
        'transRequestJson': null,
        'Slot': null,
        'tnxNumber': null,
        'Offer': checkoutOrder['CashDiscountOffer'] != null ||
            checkoutOrder['ItemFreeOffer'] != null ||
            checkoutOrder['TakeAwayOffer'] != null ||
            checkoutOrder['FacebookOffer'] != null ||
            checkoutOrder['DeliveryChargeDiscountOffer'] != null,
        'CashOfferId':
            checkoutOrder['CashDiscountOffer']?['OfferId'] ?? 0,
        'CashDiscountAmount':
            checkoutOrder['CashDiscountOffer']?['CashDiscountAmount'] ?? 0,
        'CashOfferTitle':
            checkoutOrder['CashDiscountOffer']?['Title'] ?? '',
        'DeliveryChargeOfferId':
            checkoutOrder['DeliveryChargeDiscountOffer']?['OfferId'] ?? 0,
        'DeliveryChargeOfferAmount':
            checkoutOrder['DeliveryChargeDiscountOffer']?['CashDiscountAmount'] ??
                0,
        'DeliveryChargeOfferTitle':
            checkoutOrder['DeliveryChargeDiscountOffer']?['Title'] ?? '',
        'ItemFreeOfferId': checkoutOrder['ItemFreeOffer']?['OfferId'] ?? 0,
        'ItemFreeOfferTitle':
            checkoutOrder['ItemFreeOffer']?['Title'] ?? '',
        'TakeAwayOfferId':
            checkoutOrder['TakeAwayOffer']?['OfferId'] ?? 0,
        'TakeAwayDiscountAmount':
            checkoutOrder['TakeAwayOffer']?['TakeAwayDiscountAmount'] ?? 0,
        'facebookOfferId':
            checkoutOrder['FacebookOffer']?['OfferId'] ?? 0,
        'facebookDiscountAmount':
            checkoutOrder['FacebookOffer']?['FacebookDiscountAmount'] ?? 0,
        'headerCountry': checkoutOrder['headerCountry'] ?? '',
        'placeOrderFromOutlet': 1,
        'orderFrom': GlobalConstants.Outlet,
        'storeType': 0,
        'totalProductQauntity':
            checkoutOrder['totalProductQauntity'] ?? 0,
        'totalProductWeight': checkoutOrder['totalProductWeight'] ?? 0,
      };

      final addOrderResponse =
          await apiCall(ApiPath.addOrder, addOrderParam, 'post', 2, context);
      if (!mounted) return;

      final addOrderData =
          json.decode(utf8.decode(addOrderResponse.bodyBytes));
      final addMessage = addOrderData['Message']?.toString() ?? '';

      setState(() => _placeOrderLoading = false);

      if (addOrderData['Data'] != null && addOrderData['Status'] == 1) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const OutletMainScreen(tabIndex: 0, index: 0),
            ),
            (_) => false,
          );
        }
        showToast(addMessage);
      } else {
        showToast(addMessage);
      }
    } catch (e) {
      logPrint('Place order error: $e');
      if (mounted) {
        setState(() => _placeOrderLoading = false);
        showToast('Failed to place order');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Order',
          style: TextStyle(
            fontFamily: AssetsFont.textBold,
            color: AppColors.mainAppColor,
            fontSize: 20,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildStepContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Customer', 'Items', 'Address', 'Confirm'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.grey.shade100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          steps.length,
          (i) => Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: i <= _currentStep
                    ? AppColors.mainAppColor
                    : Colors.grey.shade300,
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    color: i <= _currentStep
                        ? Colors.white
                        : Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (i < steps.length - 1)
                Container(
                  width: 24,
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  color: i < _currentStep
                      ? AppColors.mainAppColor
                      : Colors.grey.shade300,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildCustomerStep();
      case 1:
        return _buildItemsStep();
      case 2:
        return _buildAddressStep();
      case 3:
        return _buildConfirmStep();
      default:
        return _buildCustomerStep();
    }
  }

  Widget _buildCustomerStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Enter customer mobile number',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _mobileController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Mobile number',
            hintText: 'Enter customer mobile',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Customer name',
            hintText: 'Enter name (for new customers)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
        ),
        if (_customerMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            _customerMessage!,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _customerLoading ? null : _lookupCustomer,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mainAppColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: _customerLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Next: Select items'),
        ),
      ],
    );
  }

  Widget _buildItemsStep() {
    if (_products == null && !_productsLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadProducts());
      return Center(
        child: CircularProgressIndicator(color: AppColors.mainAppColor),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select items from menu',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        if (_productsLoading)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: CircularProgressIndicator(color: AppColors.mainAppColor),
            ),
          )
        else if (_products == null || _products!.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.restaurant_menu,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No menu items available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...(_products!.map((p) {
            final inCart = _cart.where((c) => c.product.priceId == p.priceId);
            final qty = inCart.isEmpty ? 0 : inCart.first.qty;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(p.name ?? 'Item'),
                subtitle: Text(
                  '${GlobalConstants.formatCurrency(GlobalConstants.outletCurrency ?? '', p.price)}'
                  '${qty > 0 ? ' × $qty in cart' : ''}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (qty > 0) ...[
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _updateCartQty(inCart.first, -1),
                      ),
                      Text('$qty'),
                    ],
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => _addToCart(p),
                    ),
                  ],
                ),
              ),
            );
          })),
        if (_cart.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            color: AppColors.mainAppColor.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cart total: ${GlobalConstants.formatCurrency(GlobalConstants.outletCurrency ?? '', _cartTotal)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text('${_cart.length} item(s)'),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 0),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _cart.isEmpty
                    ? null
                    : () => setState(() => _currentStep = 2),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainAppColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Next: Address'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddressStep() {
    if (_userId == null || _userId! <= 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Customer not found. Please go back and enter a registered customer mobile.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => setState(() => _currentStep = 0),
              child: const Text('Back to Customer'),
            ),
          ],
        ),
      );
    }
    if (_addresses == null && !_addressesLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadAddresses());
      return Center(
        child: CircularProgressIndicator(color: AppColors.mainAppColor),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Delivery address',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        if (_addressesLoading)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: CircularProgressIndicator(color: AppColors.mainAppColor),
            ),
          )
        else if (_addresses == null || _addresses!.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.location_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No addresses found for this customer',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...(_addresses!.map((a) {
            final isSelected = _selectedAddress?.addressId == a.addressId;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: isSelected
                  ? AppColors.mainAppColor.withValues(alpha: 0.1)
                  : null,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedAddress = a;
                    _addressId = a.addressId ?? 0;
                    _areaId = a.areaId;
                    if (a.latitude != null && a.longitude != null) {
                      GlobalConstants.userAddressLatitude = a.latitude ?? 0;
                      GlobalConstants.userAddressLongitude = a.longitude ?? 0;
                    }
                  });
                },
                child: ListTile(
                  title: Text(a.address ?? 'Address'),
                  subtitle: Text(
                    '${a.areaName ?? a.area ?? ''} ${a.cityName ?? ''}',
                  ),
                  leading: Icon(
                    Icons.location_on,
                    color: isSelected
                        ? AppColors.mainAppColor
                        : Colors.grey,
                  ),
                ),
              ),
            );
          })),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 1),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed:
                    (_addresses == null ||
                            _addresses!.isEmpty ||
                            _selectedAddress == null)
                        ? null
                        : () => setState(() => _currentStep = 3),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainAppColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Next: Confirm'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfirmStep() {
    final addressText = _selectedAddress?.address ??
        _selectedAddress?.areaName ??
        '–';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Review and place order',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildConfirmRow(
                  'Customer',
                  _nameController.text.isNotEmpty
                      ? _nameController.text
                      : _mobileController.text,
                ),
                _buildConfirmRow('Mobile', _mobileController.text),
                _buildConfirmRow(
                  'Items',
                  _cart
                      .map((c) =>
                          '${c.product.name} × ${c.qty}')
                      .join(', '),
                ),
                _buildConfirmRow('Address', addressText),
                _buildConfirmRow(
                  'Total',
                  GlobalConstants.formatCurrency(
                      GlobalConstants.outletCurrency ?? '', _cartTotal),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 2),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _placeOrderLoading ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainAppColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _placeOrderLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Place Order'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfirmRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '–',
              style: TextStyle(color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }
}
