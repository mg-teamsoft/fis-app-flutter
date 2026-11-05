part of '../page/receipt_page.dart';

mixin _ConnectionReceiptInitial on State<PageReceipt> {
  final _picker = ImagePicker();
  List<XFile> _picked = [];
  final Map<String, Future<Uint8List>> _bytesCache = {};
  late Size _size;
  bool _preparing = false;
  int _preparedCount = 0;

  @override
  void initState() {
    super.initState();
    unawaited(ReceiptImageService.cleanExpired());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _size = MediaQuery.of(context).size;
  }

  Future<void> _pickMultiGallery() async {
    if (_preparing) return;
    final files = await _picker.pickMultiImage();
    if (!mounted || files.isEmpty) return;
    setState(() {
      final existing = _picked.map((f) => f.path).toSet();
      _picked = [
        ..._picked,
        ...files.where((file) => !existing.contains(file.path)),
      ];
    });
  }

  void _removeSelected(XFile file) {
    if (_preparing) return;
    setState(() {
      _picked.remove(file);
      unawaited(_bytesCache.remove(file.path));
    });
  }

  Future<void> _captureCamera() async {
    if (_preparing) return;
    late XFile? file;
    try {
      file =
          await ReceiptService.captureWithCamera(context, prepareImage: false);
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
    if (_picked.isEmpty || _preparing) return;
    final selected = List<XFile>.of(_picked);
    final batch = ReceiptImageBatch();
    setState(() {
      _preparing = true;
      _preparedCount = 0;
    });
    try {
      final prepared = await batch.prepareAll(
        selected,
        isCancelled: () => !mounted,
        onProgress: (completed, total) {
          if (mounted) setState(() => _preparedCount = completed);
        },
      );
      if (!mounted) return;
      setState(() => _preparing = false);
      await Navigator.pushNamed<void>(
        context,
        '/receipt/process',
        arguments: prepared,
      );
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Görseller hazırlanamadı: $e')),
        );
      }
    } finally {
      // Review stays beneath results, so local images remain valid until both close.
      await batch.dispose();
      if (mounted) setState(() => _preparing = false);
    }
  }

  Future<void> _openManualForm() async {
    await Navigator.of(context).pushNamed('/receipt/manuel');
  }

  String get _processButtonLabel {
    if (_picked.isEmpty) return 'Devam Et';
    final count = _picked.length;
    return '$count resim seçildi - Devam Et';
  }
}
