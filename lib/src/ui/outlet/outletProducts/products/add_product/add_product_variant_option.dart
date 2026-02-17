import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:sendme_outlet/flutter_project_imports.dart';
import 'package:sendme_outlet/src/api/api_call.dart';
import 'package:sendme_outlet/src/ui/common/no_internet_page.dart';

/// Variants (Size/Color style) – builds Pricedetails for ManageMenuItem.
class AddProductDetailWithVariantView extends StatefulWidget {
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

  const AddProductDetailWithVariantView({
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
  State<AddProductDetailWithVariantView> createState() =>
      _AddProductDetailWithVariantViewState();
}

class _AddProductDetailWithVariantViewState
    extends State<AddProductDetailWithVariantView> {
  int _idTitle = 0;
  int _idVariant = 0;

  /// Variant values per group: { "Size": ["S","M","L"], "Color": ["Red","Blue"] }
  final Map<String, List<String>> _variantGroups = {};
  final Map<String, Map<String, String>> _variantPrices = {};
  final _groupNameController = TextEditingController();
  final _valueController = TextEditingController();
  final _priceController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _groupNameController.dispose();
    _valueController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _addGroup() {
    final name = _groupNameController.text.trim();
    if (name.isEmpty) {
      showToast('Enter group name');
      return;
    }
    setState(() {
      _variantGroups[name] = [];
      _variantPrices[name] = {};
      _groupNameController.clear();
      _valueController.clear();
      _priceController.clear();
    });
  }

  void _addValue(String group) {
    final value = _valueController.text.trim();
    final price = _priceController.text.trim().isEmpty ? widget.price : _priceController.text.trim();
    if (value.isEmpty) {
      showToast('Enter value');
      return;
    }
    setState(() {
      _variantGroups[group] = [...(_variantGroups[group] ?? []), value];
      _variantPrices[group] = {...?_variantPrices[group], value: price};
      _valueController.clear();
      _priceController.clear();
    });
  }

  List<Map<String, dynamic>> _buildPriceDetailListFinal() {
    final list = <Map<String, dynamic>>[];
    var idV = 0;
    for (final entry in _variantGroups.entries) {
      final group = entry.key;
      final values = entry.value;
      final prices = _variantPrices[group] ?? {};
      for (final v in values) {
        idV++;
        list.add({
          'Price': prices[v] ?? widget.price,
          'subItemName': v,
          'variantId': idV,
          'isDefault': idV == 1 ? 1 : 0,
          'isSpecial': 0,
          'addOn': <Map<String, dynamic>>[],
          'singleOptionTitle': group,
          'multiOptionTitle': group,
          'subItemCategoryId': idV,
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
      }
    }
    return list;
  }

  Future<void> _save() async {
    if (_variantGroups.isEmpty) {
      showToast('Add at least one variant group');
      return;
    }
    bool hasValues = false;
    for (final values in _variantGroups.values) {
      if (values.isNotEmpty) {
        hasValues = true;
        break;
      }
    }
    if (!hasValues) {
      showToast('Add values to variant groups');
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
      logPrint('Add product variant error: $e');
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
          'Variants (Size/Color)',
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
              'Add variant groups (e.g. Size, Color) with values and optional prices.',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _groupNameController,
                    decoration: const InputDecoration(
                      labelText: 'Group (e.g. Size, Color)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _addGroup,
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
            ..._variantGroups.entries.map((e) {
              final group = e.key;
              final values = e.value;
              final prices = _variantPrices[group] ?? {};
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(group, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: values.map<Widget>((v) => Chip(
                          label: Text('$v - ${prices[v] ?? widget.price}'),
                          onDeleted: () => setState(() {
                            _variantGroups[group] = values.where((x) => x != v).toList();
                            _variantPrices[group] = {...prices}..remove(v);
                          }),
                        )).toList(),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _valueController,
                              decoration: const InputDecoration(
                                hintText: 'Value (e.g. S, M, L)',
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: _priceController,
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
                            onPressed: () => _addValue(group),
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
