part of '../page/gallery_upload.dart';

mixin _ConnectionGalleryUpload on State<PageGalleryUpload> {
  XFile? _picked;
  Uint8List? _pickedBytes;
  bool _uploading = false;
  final _uploader = UploadService();

  late Image? _img;

  @override
  void initState() {
    super.initState();
    _img = _picked != null
        ? kIsWeb
            ? (_pickedBytes != null ? Image.memory(_pickedBytes!) : null)
            : Image.file(File(_picked!.path))
        : null;
  }

  Future<void> _pick() async {
    final file = await ReceiptService.pickFromGallery(context);
    Uint8List? bytes;

    if (kIsWeb && file != null) {
      bytes = await file.readAsBytes();
    }

    if (!mounted) return;
    setState(() {
      _picked = file;
      _pickedBytes = bytes;
    });
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Herhangi bir görsel seçilmedi')),
      );
    }
  }

  Future<void> _upload() async {
    if (_picked == null) return;
    setState(() => _uploading = true);

    final res = await _uploader.uploadReceiptImage(_picked!);

    if (!mounted) return;
    setState(() => _uploading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res.message)),
    );
  }
}
