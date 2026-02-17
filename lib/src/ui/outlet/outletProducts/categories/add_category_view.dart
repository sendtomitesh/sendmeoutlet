import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:sendme_outlet/flutter_project_imports.dart';
import 'package:sendme_outlet/src/api/api_call.dart';
import 'package:sendme_outlet/src/ui/common/no_internet_page.dart';

class AddCategoryView extends StatefulWidget {
  final int? outletId;
  final bool edit;
  final int? categoryId;
  final String? categoryName;
  final String? imageUrl;
  final VoidCallback? rebuildCallback;

  const AddCategoryView({
    Key? key,
    required this.outletId,
    required this.edit,
    this.categoryId,
    this.categoryName,
    this.imageUrl,
    this.rebuildCallback,
  }) : super(key: key);

  @override
  State<AddCategoryView> createState() => _AddCategoryViewState();
}

class _AddCategoryViewState extends State<AddCategoryView> {
  final _nameController = TextEditingController();
  String? _s3ImageKey;
  bool _saving = false;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.categoryName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final x = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (x == null || !mounted) return;

      if (!await GlobalConstants.checkInternetConnection()) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NoInternetPage()),
          );
        }
        return;
      }

      final bytes = await x.readAsBytes();
      final base64Image = base64Encode(bytes);

      final s3Param = {
        'bucket': 'sendme-images',
        'filePath': 'Images/fooditems/',
        'imageURL': 'data:image/jpeg;base64,$base64Image',
        'userType': '${GlobalConstants.Outlet}',
        'deviceId': '${GlobalConstants.Device_Id}',
        'deviceType': '${GlobalConstants.Device_Type}',
        'version': '${GlobalConstants.App_Version}',
      };

      final s3Response =
          await apiCall(ApiPath.uploadToS3, s3Param, 'post', 2, context);
      if (!mounted) return;

      final s3Data = json.decode(s3Response.body);
      if (s3Data['Data'] != null && s3Data['Data']['key'] != null) {
        setState(() => _s3ImageKey = s3Data['Data']['key'].toString());
      }
    } catch (e) {
      logPrint('Pick image error: $e');
      if (mounted) showToast('Failed to upload image');
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showToast('Enter category name');
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

    setState(() => _saving = true);

    try {
      Map<String, dynamic> param;
      if (widget.edit) {
        param = {
          'Category': name,
          'subCategoryId': 0,
          'Id': widget.categoryId,
          'imageUrl': _s3ImageKey ?? widget.imageUrl ?? '',
          'Name_AR': '',
          'Name_Gujrati': '',
          'Name_French': '',
          'Name_Hindi': '',
          'action': 'edit',
          'isCombo': 0,
          'priority': 0,
          'OutletId': widget.outletId,
          'CategoryId': widget.categoryId,
          'userType': GlobalConstants.Outlet,
          'deviceType': GlobalConstants.Device_Type,
          'version': GlobalConstants.App_Version,
          'deviceId': GlobalConstants.Device_Id,
        };
      } else {
        param = {
          'Category': name,
          'Name_AR': '',
          'Name_Gujrati': '',
          'Name_French': '',
          'Name_Hindi': '',
          'isNew': 0,
          'subCategoryId': 0,
          'action': 'add',
          'imageUrl': _s3ImageKey ?? '',
          'OutletId': widget.outletId,
          'CategoryId': 0,
          'userType': GlobalConstants.Outlet,
          'deviceType': GlobalConstants.Device_Type,
          'version': GlobalConstants.App_Version,
          'deviceId': GlobalConstants.Device_Id,
        };
      }

      final response =
          await apiCall(ApiPath.manageCategory, param, 'post', 2, context);
      if (!mounted) return;

      final data = json.decode(response.body);
      if (data['Status'] == 1) {
        showToast(data['Message']?.toString() ?? 'Saved');
        Navigator.pop(context);
        widget.rebuildCallback?.call();
      } else {
        showToast(data['Message']?.toString() ?? 'Failed');
      }
    } catch (e) {
      logPrint('Save category error: $e');
      if (mounted) showToast('Something went wrong');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.edit ? 'Edit Category' : 'Add Category'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 24),
            const Text('Image (optional)', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _saving ? null : _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Choose Image'),
                ),
                if (_s3ImageKey != null || (widget.imageUrl != null && widget.imageUrl!.isNotEmpty))
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      'Image selected',
                      style: TextStyle(color: Colors.green.shade700, fontSize: 14),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),
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
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(widget.edit ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }
}
