import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:sendme_outlet/AppConfig.dart';
import 'package:sendme_outlet/flutter_project_imports.dart';
import 'package:sendme_outlet/src/ui/outlet/outletProducts/products/add_product/add_product_advance_option.dart';
import 'package:sendme_outlet/src/ui/outlet/outletProducts/products/add_product/add_product_variant_option.dart';
import 'package:sendme_outlet/src/api/api_call.dart';
import 'package:sendme_outlet/src/ui/common/no_internet_page.dart';

/// Add Product – base form. Paths: Simple, Advanced Option (variants+addons), Variants.
class AddProductView extends StatefulWidget {
  final Outlet? outlet;
  final VoidCallback? onSaved;
  /// If true, shows "Variants" link for ecom-style products
  final bool? isEcom;

  const AddProductView({
    super.key,
    this.outlet,
    this.onSaved,
    this.isEcom,
  });

  @override
  State<AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  List<Categories> _categories = [];
  List<SubCategory> _subCategories = [];
  bool _loadingCategories = true;
  bool _loadingSubCategories = false;

  int? _categoryId;
  String? _categoryName;
  int? _subCategoryId;
  String? _subCategoryName;

  int _visibility = 1;
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();
  bool _saving = false;

  List<Units> _units = [];
  bool _loadingUnits = false;
  int? _unitId;
  String? _weight;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    if (!await GlobalConstants.checkInternetConnection()) return;
    setState(() => _loadingUnits = true);
    try {
      final url =
          '${ApiPath.getAllUnits}deviceType=${GlobalConstants.Device_Type}'
          '&userType=${GlobalConstants.Outlet}'
          '&version=${GlobalConstants.App_Version}'
          '&deviceId=${GlobalConstants.Device_Id}';
      final response = await apiCall(url, '', 'get', 0, context);
      if (!mounted) return;
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['Data'] != null && data['Status'] == 1) {
        final rest = data['Data'] as List;
        setState(() {
          _units = rest.map<Units>((j) => Units.fromJson(j as Map<String, dynamic>)).toList();
          _loadingUnits = false;
        });
      } else {
        setState(() => _loadingUnits = false);
      }
    } catch (e) {
      if (mounted) setState(() => _loadingUnits = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    if (widget.outlet == null) return;
    if (!await GlobalConstants.checkInternetConnection()) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NoInternetPage()),
        );
      }
      setState(() => _loadingCategories = false);
      return;
    }
    setState(() => _loadingCategories = true);
    try {
      final param = {
        'search': '',
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
          _categories = rest
              .map<Categories>(
                  (j) => Categories.fromJson(j as Map<String, dynamic>))
              .toList();
          _loadingCategories = false;
          if (_categories.isNotEmpty && _categoryId == null) {
            _categoryId = _categories.first.categoryId;
            _categoryName = _categories.first.catName;
            _loadSubCategories();
          }
        });
      } else {
        setState(() {
          _categories = [];
          _loadingCategories = false;
        });
      }
    } catch (e) {
      logPrint('Categories error: $e');
      if (mounted) {
        setState(() => _loadingCategories = false);
        showToast('Failed to load categories');
      }
    }
  }

  Future<void> _loadSubCategories() async {
    if (widget.outlet == null || _categoryId == null) return;
    if (!await GlobalConstants.checkInternetConnection()) return;
    setState(() => _loadingSubCategories = true);
    try {
      final param = {
        'search': '',
        'isWeb': '1',
        'dynamo': '0',
        'outletId': '${widget.outlet!.hotelId}',
        'categoryId': '$_categoryId',
        'userType': '${GlobalConstants.Outlet}',
        'pagination': '{}',
        'isPagination': '1',
        'deviceType': '${GlobalConstants.Device_Type}',
        'deviceId': '${GlobalConstants.Device_Id}',
        'version': '${GlobalConstants.App_Version}',
      };
      final response = await apiCall(
          ApiPath.getOutletSubCategories, param, 'post', 2, context);
      if (!mounted) return;
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['Data'] != null && data['Status'] == 1) {
        final rest = data['Data'] as List;
        setState(() {
          _subCategories = rest
              .map<SubCategory>(
                  (j) => SubCategory.fromJson(j as Map<String, dynamic>))
              .toList();
          _loadingSubCategories = false;
          _subCategoryId = null;
          _subCategoryName = null;
          if (_subCategories.isNotEmpty) {
            _subCategoryId = _subCategories.first.subCategoryId;
            _subCategoryName = _subCategories.first.subCategoryName;
          }
        });
      } else {
        setState(() {
          _subCategories = [];
          _loadingSubCategories = false;
        });
      }
    } catch (e) {
      logPrint('SubCategories error: $e');
      if (mounted) setState(() => _loadingSubCategories = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() => _imagePath = picked.path);
      }
    } catch (e) {
      logPrint('Image pick error: $e');
      if (mounted) showToast('Could not pick image');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      showToast('Select a category');
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
      if (_imagePath != null) {
        final bytes = await File(_imagePath!).readAsBytes();
        final base64Images = [
          'data:image/jpeg;base64,${base64Encode(bytes)}'
        ];
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

      final priceStr = _priceController.text.trim();
      final priceDetail = [
        {
          'Price': priceStr,
          'isDefault': 1,
          'isSpecial': 0,
          'subItemId': 0,
          'Name_AR': '',
          'Name_Gujrati': '',
          'Name_Hindi': '',
          'Name_French': '',
          'isExport': '0',
          'itemFoodType': '0',
          'itemUnit': null,
          'itemWeight': null,
          'status': '1',
          'type': '0',
        }
      ];

      final param = {
        'action': 'add',
        'CategoryItemId': 0,
        'itemName': _nameController.text.trim(),
        'Name_AR': '',
        'Name_Gujrati': '',
        'Name_French': '',
        'Name_Hindi': '',
        'ItemId': 0,
        'description': _descriptionController.text.trim(),
        'Pricedetails': priceDetail,
        'fileName': '',
        'imagePathList': imagePathList,
        'isSubItem': '0',
        'endTime': null,
        'startTime': null,
        'visibility': '$_visibility',
        'CategoryName': _categoryName ?? '',
        'CategoryId': _categoryId,
        'subCategoryId': _subCategoryId ?? '',
        'subCategoryName': _subCategoryName ?? '',
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
      logPrint('Add product error: $e');
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
          'Add Product',
          style: TextStyle(
            fontFamily: AssetsFont.textBold,
            color: AppColors.mainAppColor,
            fontSize: 20,
          ),
        ),
        elevation: 0,
      ),
      body: _loadingCategories
          ? Center(child: CircularProgressIndicator(color: AppColors.mainAppColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.shopping_bag_outlined),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Price *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v.trim()) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    if (!_loadingUnits && _units.isNotEmpty)
                      DropdownButtonFormField<int>(
                        value: _unitId,
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.straighten_outlined),
                        ),
                        items: _units
                            .map((u) => DropdownMenuItem<int>(
                                  value: u.id,
                                  child: Text(u.unit ?? ''),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _unitId = v),
                      ),
                    if (!_loadingUnits && _units.isNotEmpty) const SizedBox(height: 16),
                    TextFormField(
                      onChanged: (v) => _weight = v,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Weight (optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.scale_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _categoryId,
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: _categories
                          .map((c) => DropdownMenuItem<int>(
                                value: c.categoryId,
                                child: Text(c.catName ?? 'Category'),
                              ))
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _categoryId = v;
                          final cat = _categories.where((c) => c.categoryId == v);
                          _categoryName = cat.isEmpty ? null : cat.first.catName;
                          _loadSubCategories();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_loadingSubCategories)
                      const Center(child: CircularProgressIndicator())
                    else if (_subCategories.isNotEmpty)
                      DropdownButtonFormField<int>(
                        value: _subCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Subcategory',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.folder_outlined),
                        ),
                        items: _subCategories
                            .map((s) => DropdownMenuItem<int>(
                                  value: s.subCategoryId,
                                  child: Text(s.subCategoryName ?? 'Subcategory'),
                                ))
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            _subCategoryId = v;
                            final sub = _subCategories.where((s) => s.subCategoryId == v);
                            _subCategoryName = sub.isEmpty ? null : sub.first.subCategoryName;
                          });
                        },
                      ),
                    const SizedBox(height: 16),
                    const Text('Product image', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        height: 110,
                        width: 110,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _imagePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_imagePath!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _placeholderImage(),
                                ),
                              )
                            : _placeholderImage(),
                      ),
                    ),
                    if (_imagePath != null) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => setState(() => _imagePath = null),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Remove image'),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (activeApp.id != 'send_me_lebanon') ...[
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () {
                          if (_nameController.text.trim().isEmpty) {
                            showToast('Enter product name');
                            return;
                          }
                          if (_categoryId == null) {
                            showToast('Select category');
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddProductDetailWithAdvanceOptionView(
                                outlet: widget.outlet,
                                menuName: _nameController.text.trim(),
                                description: _descriptionController.text.trim(),
                                price: _priceController.text.trim(),
                                categoryId: _categoryId!,
                                categoryName: _categoryName ?? '',
                                subCategoryId: _subCategoryId,
                                subCategoryName: _subCategoryName,
                                unitId: _unitId,
                                weight: _weight,
                                units: _units,
                                imagePath: _imagePath,
                                visibility: _visibility,
                                onSaved: widget.onSaved,
                              ),
                            ),
                          ).then((_) {
                            if (mounted) Navigator.pop(context);
                          });
                        },
                        icon: const Icon(Icons.tune),
                        label: const Text('Advanced Option (Variants + Addons)'),
                      ),
                    ],
                    if ((widget.isEcom ?? false) && activeApp.id != 'send_me_lebanon') ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          if (_nameController.text.trim().isEmpty) {
                            showToast('Enter product name');
                            return;
                          }
                          if (_categoryId == null) {
                            showToast('Select category');
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddProductDetailWithVariantView(
                                outlet: widget.outlet,
                                menuName: _nameController.text.trim(),
                                description: _descriptionController.text.trim(),
                                price: _priceController.text.trim(),
                                categoryId: _categoryId!,
                                categoryName: _categoryName ?? '',
                                subCategoryId: _subCategoryId,
                                subCategoryName: _subCategoryName,
                                unitId: _unitId,
                                weight: _weight,
                                units: _units,
                                imagePath: _imagePath,
                                visibility: _visibility,
                                onSaved: widget.onSaved,
                              ),
                            ),
                          ).then((_) {
                            if (mounted) Navigator.pop(context);
                          });
                        },
                        icon: const Icon(Icons.layers),
                        label: const Text('Variants (Size/Color)'),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Visible', style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(width: 16),
                        Switch(
                          value: _visibility == 1,
                          onChanged: (v) => setState(() => _visibility = v ? 1 : 0),
                          activeColor: AppColors.mainAppColor,
                        ),
                      ],
                    ),
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
                          : const Text('Add Product'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _placeholderImage() {
    return Center(
      child: Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey.shade600),
    );
  }
}
