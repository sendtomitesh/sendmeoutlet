import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:sendme_outlet/flutter_project_imports.dart';
import 'package:sendme_outlet/src/ui/common/no_internet_page.dart';

/// Manual Add Order for Grocery/Medicine – Phase 6.
/// Upload prescription or items list image, or enter items manually.
class ManualAddOrderForMedicineAndGrocery extends StatefulWidget {
  final Outlet? outlet;

  const ManualAddOrderForMedicineAndGrocery({
    Key? key,
    this.outlet,
  }) : super(key: key);

  @override
  State<ManualAddOrderForMedicineAndGrocery> createState() =>
      _ManualAddOrderForMedicineAndGroceryState();
}

class _ManualAddOrderForMedicineAndGroceryState
    extends State<ManualAddOrderForMedicineAndGrocery> {
  final _picker = ImagePicker();
  bool _imageSelected = false;
  bool _itemSelected = false;
  String? _imagePath;

  bool get _isMedicine => (widget.outlet?.isMedicine ?? 0) == 1;

  Future<void> _pickImage(ImageSource source) async {
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
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() {
          _imagePath = picked.path;
          _imageSelected = true;
          _itemSelected = false;
        });
        showToast('Image selected – upload API integration in progress');
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
            color: Colors.black87,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_imageSelected) ...[
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, size: 64, color: Colors.grey.shade500),
                        const SizedBox(height: 8),
                        Text(
                          'Image selected',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _showImageSourceDialog,
                          child: const Text('Re-upload'),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: _isAvailable ? _showImageSourceDialog : null,
                  icon: const Icon(Icons.upload_file),
                  label: Text(
                    _isMedicine ? 'Upload Prescription' : 'Upload Items List',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainAppColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'OR',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: _isAvailable
                      ? () {
                          setState(() {
                            _itemSelected = true;
                            _imageSelected = false;
                          });
                          showToast('Enter items – Phase 6');
                        }
                      : null,
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Enter Items List'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
              if (_itemSelected) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.edit_note,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Enter items manually – Phase 6',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => setState(() => _itemSelected = false),
                          child: const Text('Back'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool get _isAvailable => GlobalConstants.outletStatus == 1;
}
