part of '../page/receipt_page.dart';

mixin _ConnectionReceiptInitial on State<PageReceipt> {
  final _picker = ImagePicker();
  List<XFile> _picked = [];
  final Map<String, Future<Uint8List>> _bytesCache = {};
  late Size _size;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _size = MediaQuery.of(context).size;
  }

  Future<void> _pickMultiGallery() async {
    final selected = await _picker.pickMultiImage();
    final files = <XFile>[];
    try {
      for (final file in selected) {
        files.add(await ReceiptImageService.prepare(file));
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Görsel hazırlanamadı: $e')),
        );
      }
      return;
    }
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
    late XFile? file;
    try {
      file = await ReceiptService.captureWithCamera(context);
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Görsel hazırlanamadı: $e')),
        );
      }
      return;
    }
    final capturedFile = file;
    if (!mounted || capturedFile == null) return;
    setState(() {
      if (_picked.every((item) => item.path != capturedFile.path)) {
        _picked = [..._picked, capturedFile];
      }
    });
  }

  Future<void> _processSelected() async {
    if (_picked.isEmpty) return;
    await Navigator.pushNamed(
      context,
      '/receipt/process',
      arguments: List<XFile>.from(_picked),
    );
  }

  Future<void> _openManualForm() async {
    await Navigator.of(context).pushNamed('/receipt/manuel');
  }

  String get _processButtonLabel {
    if (_picked.isEmpty) return 'Devam Et';
    final count = _picked.length;
    final suffix = count == 1 ? 'Fiş' : 'Fiş';
    return '$count $suffix Seçildi - Devam Et';
  }
}
