import 'dart:io';
import 'dart:typed_data';

import 'package:fis_app_flutter/app/widget/build_action_button.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../app/import/theme.dart';
import '../app/services/receipt_service.dart';

class ReceiptPage extends StatefulWidget {
  const ReceiptPage({super.key});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  final _picker = ImagePicker();
  List<XFile> _picked = [];
  final Map<String, Future<Uint8List>> _bytesCache = {};

  Future<void> _pickMultiGallery() async {
    final files = await _picker.pickMultiImage(imageQuality: 90);
    if (!mounted || files.isEmpty) return;
    setState(() {
      final existing = _picked.map((f) => f.path).toSet();
      _picked = [
        ..._picked,
        ...files.where((file) => !existing.contains(file.path)),
      ];
    });
  }

  Future<void> _captureCamera() async {
    final file = await ReceiptService.captureWithCamera(context);
    if (!mounted || file == null) return;
    setState(() {
      if (_picked.every((item) => item.path != file.path)) {
        _picked = [..._picked, file];
      }
    });
  }

  void _processSelected() {
    if (_picked.isEmpty) return;
    Navigator.pushNamed(
      context,
      '/receipt/process',
      arguments: List<XFile>.from(_picked),
    );
  }

  void _openManualForm() {
    Navigator.of(context).pushNamed('/receipt/manuel');
  }

  String get _processButtonLabel {
    if (_picked.isEmpty) return 'Devam Et';
    final count = _picked.length;
    final suffix = count == 1 ? 'Fiş' : 'Fiş';
    return '$count $suffix Seçildi - Devam Et';
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              WidgetBuildActionButton(
                onPressed: _pickMultiGallery,
                icon: Icons.photo_library_outlined,
                label: 'Galeriden Resim Seç',
              ),
              const SizedBox(height: 12),
              WidgetBuildActionButton(
                onPressed: _captureCamera,
                icon: Icons.photo_camera_outlined,
                label: 'Kamerayla Çek',
              ),
              const SizedBox(height: 12),
              WidgetBuildActionButton(
                onPressed: _openManualForm,
                icon: Icons.edit_note,
                label: 'Manuel Fatura Ekle',
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _picked.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: context.colorScheme.primary
                                .withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Henüz fiş seçilmedi.',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Galerinizden fiş seçin veya kamerayla çekin.',
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1,
                        ),
                        itemCount: _picked.length,
                        itemBuilder: (_, i) {
                          final file = _picked[i];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: kIsWeb
                                ? FutureBuilder<Uint8List>(
                                    future: _bytesCache.putIfAbsent(
                                      file.path,
                                      () => file.readAsBytes(),
                                    ),
                                    builder: (context, snap) {
                                      if (!snap.hasData) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }
                                      return Image.memory(
                                        snap.data!,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                                : Image.file(
                                    File(file.path),
                                    fit: BoxFit.cover,
                                  ),
                          );
                        },
                      ),
              ),
              ElevatedButton(
                onPressed: _picked.isEmpty ? null : _processSelected,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colorScheme.secondary,
                  foregroundColor: context.colorScheme.onSecondary,
                  padding: ThemePadding.verticalSymmetricMedium(),
                  textStyle: ThemeTypography.bodyLarge(
                    context,
                    '',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ).style,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(_processButtonLabel),
              ),
              SizedBox(
                height: size.height * 0.03,
              )
            ],
          ),
        ),
      ),
    );
  }
}
