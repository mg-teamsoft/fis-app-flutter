part of '../page/receipt_process_page.dart';

mixin _ConnectionReceiptProcess on State<PageReceiptProcess> {
  final _s3 = S3UploadService();
  final _jobs = JobService();
  bool _processing = false;
  final Map<String, Future<Uint8List>> _bytesCache = {};
  late Size _size;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _size = MediaQuery.of(context).size;
  }

  String _extractDioErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final backendMessage =
          map['error']?.toString() ?? map['message']?.toString();
      if (backendMessage != null && backendMessage.trim().isNotEmpty) {
        return backendMessage;
      }
    }
    return e.message ?? 'İşlem hatası';
  }

  Future<void> _showErrorDialog(String message) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: ThemeTypography.bodyLarge(
          context,
          'Hata',
          color: ctx.colorScheme.onSurface,
          weight: FontWeight.w800,
        ),
        content: ThemeTypography.bodyLarge(
          context,
          message,
          color: ctx.colorScheme.error,
          weight: FontWeight.w500,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: ThemeTypography.bodyLarge(
              context,
              'Tamam',
              color: ctx.colorScheme.onSurface,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _process() async {
    setState(() => _processing = true);
    final items = widget.files.map(SelectedItem.new).toList();

    try {
      for (final item in items) {
        final uploadFile = File(item.file.path);

        final bytes = await uploadFile.readAsBytes();
        final size = bytes.length;
        const maxBytes = S3UploadService.maxImageBytes;
        const minBytes = 10 * 1024;

        if (size > maxBytes) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: ThemeTypography.bodyLarge(
                  context,
                  '⚠️ Resim en fazla 7 MB olabilir.',
                  color: context.theme.error,
                  weight: FontWeight.w600,
                ),
                duration: const Duration(seconds: 5),
              ),
            );
          }
          continue;
        } else if (size < minBytes) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: ThemeTypography.bodyLarge(
                  context,
                  '⚠️ Resim en az 10 KB olabilir.',
                  color: context.theme.error,
                  weight: FontWeight.w600,
                ),
                duration: const Duration(seconds: 5),
              ),
            );
          }
          continue;
        }

        final mime = guessMime(uploadFile.path);
        // 1) init
        final checksum = crc32Base64(bytes);
        final sha = crytoSHA256Hex(bytes);

        final init = await _s3.initUpload(
          contentType: mime,
          filename: p.basename(uploadFile.path),
          checksumCRC32: checksum,
          sha256: sha,
        );
        item
          ..key = init.key
          // Derive the permanent public URL by stripping the presigned query string
          ..imageUrl = init.presignedUrl.split('?').first;

        // 2) put to s3
        await _s3.putToS3(
          presignedUrl: init.presignedUrl,
          file: uploadFile,
          headers: {
            'Content-Type': mime,
            // Optional but fine to include for clarity:
            // 'x-amz-checksum-crc32': checksum,
          },
        );

        // 3) confirm
        await _s3.confirmUpload(
          key: init.key,
          size: size,
          mime: mime,
          sha256: sha,
        );

        // 4) start processing by key
        item.jobId = await _jobs.startByKey(init.key, mime: mime);
      }

      if (!mounted || items.every((item) => item.jobId == null)) return;
      await Navigator.pushReplacementNamed(
        context,
        '/receipt/results',
        arguments: items,
      );
    } on DioException catch (e) {
      if (!mounted) return;
      await _showErrorDialog(_extractDioErrorMessage(e));
    } on Exception catch (e) {
      if (!mounted) return;
      await _showErrorDialog(e.toString());
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }
}
