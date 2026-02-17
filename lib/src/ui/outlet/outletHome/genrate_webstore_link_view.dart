import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sendme_outlet/flutter_project_imports.dart';
import 'package:sendme_outlet/src/api/api_call.dart';
import 'package:sendme_outlet/src/ui/common/no_internet_page.dart';

/// Generate and share outlet WebStore link – Phase 6.
class GenrateWebStoreLinkView extends StatefulWidget {
  final Outlet? outlet;

  const GenrateWebStoreLinkView({Key? key, this.outlet}) : super(key: key);

  @override
  State<GenrateWebStoreLinkView> createState() => _GenrateWebStoreLinkViewState();
}

class _GenrateWebStoreLinkViewState extends State<GenrateWebStoreLinkView> {
  final _linkController = TextEditingController();
  bool _loading = false;
  String? _generatedLink;
  String? _error;

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrGenerateLink() async {
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
      _loading = true;
      _error = null;
    });

    try {
      final url =
          '${ApiPath.getOutletWebStoreLink}outletId=${widget.outlet!.hotelId}'
          '&userType=${GlobalConstants.Outlet}'
          '&deviceType=${GlobalConstants.Device_Type}'
          '&version=${GlobalConstants.App_Version}'
          '&deviceId=${GlobalConstants.Device_Id}';

      final response = await apiCall(url, '', 'get', 0, context);
      if (!mounted) return;

      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['Data'] != null && data['Status'] == 1) {
        final link = data['Data'].toString();
        setState(() {
          _generatedLink = link.isNotEmpty ? link : null;
          _loading = false;
        });
      } else {
        setState(() {
          _generatedLink = null;
          _loading = false;
        });
      }
    } catch (e) {
      logPrint('WebStore link error: $e');
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Something went wrong';
        });
      }
    }
  }

  void _copyLink() {
    if (_generatedLink != null && _generatedLink!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _generatedLink!));
      showToast('Copied to clipboard');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchOrGenerateLink();
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
          'WebStore Link',
          style: TextStyle(
            fontFamily: AssetsFont.textBold,
            color: AppColors.mainAppColor,
            fontSize: 18,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: _loading
            ? Center(
                child: CircularProgressIndicator(color: AppColors.mainAppColor),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _error!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_generatedLink != null && _generatedLink!.isNotEmpty) ...[
                      Text(
                        'Your WebStore link:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: SelectableText(
                          _generatedLink!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _copyLink,
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy link'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainAppColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.link_off,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No WebStore link yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Contact support to generate your outlet WebStore link.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton(
                        onPressed: _fetchOrGenerateLink,
                        child: const Text('Retry'),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
