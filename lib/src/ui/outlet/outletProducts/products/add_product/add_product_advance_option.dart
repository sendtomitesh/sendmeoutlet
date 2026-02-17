import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:sendme_outlet/flutter_project_imports.dart';
import 'package:sendme_outlet/src/api/api_call.dart';
import 'package:sendme_outlet/src/ui/common/no_internet_page.dart';

/// Advanced Option – Variants + Addons. Builds Pricedetails for ManageMenuItem.
class AddProductDetailWithAdvanceOptionView extends StatefulWidget {
  final Outlet? outlet;
  final String menuName;
  final String? description;
  final String price;
  final int categoryId;
  final String categoryName;
  final int? subCategoryId;
  final String? subCategoryName;
  final int? unitId;
  final String? weight;
  final List<Units> units;
  final String? imagePath;
  final int visibility;
  final VoidCallback? onSaved;

  const AddProductDetailWithAdvanceOptionView({
    super.key,
    this.outlet,
    required this.menuName,
    this.description,
    required this.price,
    required this.categoryId,
    required this.categoryName,
    this.subCategoryId,
    this.subCategoryName,
    this.unitId,
    this.weight,
    this.units = const [],
    this.imagePath,
    this.visibility = 1,
    this.onSaved,
  });

  @override
  State<AddProductDetailWithAdvanceOptionView> createState() =>
      _AddProductDetailWithAdvanceOptionViewState();
}

class _AddProductDetailWithAdvanceOptionViewState
    extends State<AddProductDetailWithAdvanceOptionView> {
  int _idTitle = 0;
  int _idVariant = 0;
  int _idAddon = 0;

  /// Pricedetails: [{ titleId, title, variantData: [{ Price, subItemName, variantId, isDefault, addOn: [...] }] }]
  List<Map<String, dynamic>> _pricedetails = [];
  final _titleController = TextEditingController();
  final _variantNameController = TextEditingController();
  final _variantPriceController = TextEditingController();
  final _addonNameController = TextEditingController();
  final _addonPriceController = TextEditingController();

  int? _editingVariantIndex;
  int? _editingAddonIndex;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _variantNameController.dispose();
    _variantPriceController.dispose();
    _addonNameController.dispose();
    _addonPriceController.dispose();
    super.dispose();
  }

  void _addVariantGroup() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      showToast('Enter variant group title');
      return;
    }
    setState(() {
      _idTitle++;
      _idVariant++;
      _pricedetails.add({
        'titleId': _idTitle,
        'title': title,
        'variantData': [
          {
            'Price': widget.price,
            'subItemName': 'Default',
            'variantId': _idVariant,
            'isDefault': 1,
            'isSpecial': 0,
            'addOn': <Map<String, dynamic>>[],
            'Name_AR': '',
            'Name_Hindi': '',
            'Name_Gujrati': '',
            'Name_French': '',
            'type': 0,
            'itemUnit': widget.unitId,
            'itemWeight': widget.weight,
            'netWeight': null,
            'netUnit': null,
            'isExport': '0',
            'itemFoodType': 0,
            'status': '1',
          }
        ]
      });
      _titleController.clear();
      _variantNameController.clear();
      _variantPriceController.clear();
    });
  }

  void _addVariant(int groupIndex) {
    final name = _variantNameController.text.trim();
    final price = _variantPriceController.text.trim();
    if (name.isEmpty || price.isEmpty) {
      showToast('Enter variant name and price');
      return;
    }
    if (double.tryParse(price) == null) {
      showToast('Invalid price');
      return;
    }
    setState(() {
      _idVariant++;
      final group = _pricedetails[groupIndex];
      final variantData = List<Map<String, dynamic>>.from(group['variantData'] as List);
      for (var i = 0; i < variantData.length; i++) {
        variantData[i]['isDefault'] = 0;
      }
      variantData.add({
        'Price': price,
        'subItemName': name,
        'variantId': _idVariant,
        'isDefault': variantData.isEmpty ? 1 : 0,
        'isSpecial': 0,
        'addOn': <Map<String, dynamic>>[],
        'Name_AR': '',
        'Name_Hindi': '',
        'Name_Gujrati': '',
        'Name_French': '',
        'type': 0,
        'itemUnit': widget.unitId,
        'itemWeight': widget.weight,
        'netWeight': null,
        'netUnit': null,
        'isExport': '0',
        'itemFoodType': 0,
        'status': '1',
      });
      _pricedetails[groupIndex] = {...group, 'variantData': variantData};
      _variantNameController.clear();
      _variantPriceController.clear();
      _editingVariantIndex = null;
    });
  }

  void _addAddon(int groupIndex, int variantIndex) {
    final name = _addonNameController.text.trim();
    final price = _addonPriceController.text.trim();
    if (name.isEmpty || price.isEmpty) {
      showToast('Enter addon name and price');
      return;
    }
    if (double.tryParse(price) == null) {
      showToast('Invalid price');
      return;
    }
    setState(() {
      _idAddon++;
      final group = _pricedetails[groupIndex];
      final variantData = List<Map<String, dynamic>>.from(group['variantData'] as List);
      final variant = Map<String, dynamic>.from(variantData[variantIndex]);
      final addons = List<Map<String, dynamic>>.from((variant['addOn'] as List?) ?? []);
      addons.add({
        'subItemId': _idTitle,
        'addonId': _idAddon,
        'name': name,
        'price': price,
        'type': 0,
      });
      variant['addOn'] = addons;
      variantData[variantIndex] = variant;
      _pricedetails[groupIndex] = {...group, 'variantData': variantData};
      _addonNameController.clear();
      _addonPriceController.clear();
      _editingAddonIndex = null;
    });
  }

  List<Map<String, dynamic>> _buildPriceDetailListFinal() {
    final list = <Map<String, dynamic>>[];
    var k = 0;
    for (var i = 0; i < _pricedetails.length; i++) {
      final group = _pricedetails[i];
      final variantData = group['variantData'] as List;
      for (var j = 0; j < variantData.length; j++) {
        final v = variantData[j] as Map<String, dynamic>;
        list.add({
          'subItemCategoryId': group['titleId'],
          'Price': v['Price'],
          'singleOptionTitle': group['title'],
          'multiOptionTitle': group['title'],
          'isDefault': v['isDefault'] ?? 0,
          'isSpecial': v['isSpecial'] ?? 0,
          'subItemId': v['variantId'],
          'subItemName': v['subItemName'],
          'addon': v['addOn'] ?? [],
          'Name_AR': v['Name_AR'] ?? '',
          'Name_Hindi': v['Name_Hindi'] ?? '',
          'Name_Gujrati': v['Name_Gujrati'] ?? '',
          'Name_French': v['Name_French'] ?? '',
          'type': v['type'] ?? 0,
          'itemUnit': v['itemUnit'],
          'itemWeight': v['itemWeight'],
          'netWeight': v['netWeight'],
          'netUnit': v['netUnit'],
          'isExport': v['isExport'] ?? '0',
          'itemFoodType': v['itemFoodType'] ?? 0,
          'status': v['status'] ?? '1',
        });
        k++;
      }
    }
    return list;
  }

  Future<void> _save() async {
    if (_pricedetails.isEmpty) {
      showToast('Add at least one variant group');
      return;
    }
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

    setState(() => _saving = true);

    try {
      List<String> imagePathList = [];
      if (widget.imagePath != null) {
        final bytes = await File(widget.imagePath!).readAsBytes();
        final base64Images = ['data:image/jpeg;base64,${base64Encode(bytes)}'];
        final s3Param = {
          'bucket': 'sendme-images',
          'filePath': 'Images/fooditems/',
          'imageURLs': base64Images,
          'userType': '${GlobalConstants.Outlet}',
          'deviceId': '${GlobalConstants.Device_Id}',
          'deviceType': '${GlobalConstants.Device_Type}',
          'version': '${GlobalConstants.App_Version}',
        };
        final s3Response = await apiCall(ApiPath.uploadToS3, s3Param, 'post', 2, context);
        if (!mounted) return;
        final s3Data = json.decode(utf8.decode(s3Response.bodyBytes));
        if (s3Data['Data'] != null && s3Data['Status'] == 1) {
          for (var loc in s3Data['Data'] as List) {
            imagePathList.add((loc as Map)['Location']?.toString() ?? '');
          }
        }
      }

      final priceDetailListFinal = _buildPriceDetailListFinal();
      final param = {
        'action': 'add',
        'CategoryItemId': 0,
        'itemName': widget.menuName,
        'Name_AR': '',
        'Name_Gujrati': '',
        'Name_French': '',
        'Name_Hindi': '',
        'ItemId': 0,
        'description': widget.description ?? '',
        'Pricedetails': priceDetailListFinal,
        'fileName': '',
        'imagePathList': imagePathList,
        'isSubItem': '1',
        'endTime': null,
        'startTime': null,
        'visibility': '${widget.visibility}',
        'CategoryName': widget.categoryName,
        'CategoryId': widget.categoryId,
        'subCategoryId': widget.subCategoryId ?? '',
        'subCategoryName': widget.subCategoryName ?? '',
        'OutletId': widget.outlet!.hotelId,
        'userType': '${GlobalConstants.Outlet}',
        'deviceType': '${GlobalConstants.Device_Type}',
        'version': '${GlobalConstants.App_Version}',
        'deviceId': '${GlobalConstants.Device_Id}',
      };

      final response = await apiCall(ApiPath.manageMenuItem, param, 'post', 2, context);
      if (!mounted) return;
      final data = json.decode(utf8.decode(response.bodyBytes));
      setState(() => _saving = false);

      if (data['Status'] == 1) {
        widget.onSaved?.call();
        if (mounted) {
          Navigator.pop(context);
          showToast(data['Message']?.toString() ?? 'Product added');
        }
      } else {
        showToast(data['Message']?.toString() ?? 'Failed to add product');
      }
    } catch (e) {
      logPrint('Add product advance error: $e');
      if (mounted) {
        setState(() => _saving = false);
        showToast('Something went wrong');
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
          'Advanced Option (Variants + Addons)',
          style: TextStyle(
            fontFamily: AssetsFont.textBold,
            color: AppColors.mainAppColor,
            fontSize: 18,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Product: ${widget.menuName}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Add variant groups (e.g. Size, Toppings). Each group has variants; each variant can have addons.',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Group title (e.g. Size)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _addVariantGroup,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Group'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainAppColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...List.generate(_pricedetails.length, (gi) {
              final group = _pricedetails[gi];
              final title = group['title'] as String;
              final variantData = group['variantData'] as List;
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      ...List.generate(variantData.length, (vi) {
                        final v = variantData[vi] as Map<String, dynamic>;
                        final addons = (v['addOn'] as List?) ?? [];
                        return Card(
                          color: Colors.grey.shade100,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${v['subItemName']} - ${v['Price']}',
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    if (addons.isNotEmpty)
                                      Text('+ ${addons.length} addon(s)', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                                  ],
                                ),
                                if (addons.isNotEmpty)
                                  ...addons.map<Widget>((a) => Padding(
                                        padding: const EdgeInsets.only(left: 16, top: 4),
                                        child: Text(
                                          '  + ${a['name']} - ${a['price']}',
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                        ),
                                      )),
                                if (_editingAddonIndex == vi)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _addonNameController,
                                            decoration: const InputDecoration(
                                              hintText: 'Addon name',
                                              isDense: true,
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          width: 80,
                                          child: TextField(
                                            controller: _addonPriceController,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              hintText: 'Price',
                                              isDense: true,
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.check),
                                          onPressed: () => _addAddon(gi, vi),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () => setState(() => _editingAddonIndex = null),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  TextButton.icon(
                                    onPressed: () => setState(() {
                                      _editingAddonIndex = vi;
                                      _addonNameController.clear();
                                      _addonPriceController.clear();
                                    }),
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text('Add addon'),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _variantNameController,
                              decoration: const InputDecoration(
                                hintText: 'Variant name',
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: _variantPriceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Price',
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _addVariant(gi),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainAppColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Save Product'),
            ),
          ],
        ),
      ),
    );
  }
}
