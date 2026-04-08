part of '../page/excel_page.dart';

mixin _ConnectionExcel on State<PageExcel> {
  final _excelFilesApi = ExcelService();
  final _downloader = FileDownloadService();
  final _scrollController = ScrollController();

  late Future<List<ExcelFileEntry>> _future;
  final Set<String> _busy = {}; // rows busy state (by idOrKey)

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<ExcelFileEntry>> _load() async {
    if (widget.initialEntries != null && widget.initialEntries!.isNotEmpty) {
      return widget.initialEntries!;
    }
    final list = await _excelFilesApi.listFiles(); // backend list
    // Map to entries. Expect one record per user.
    return list.map((rec) {
      final id = (rec['_id'] ?? rec['s3Key']).toString();
      final fileName = (rec['fileName'] ?? 'Fis_Listesi.xlsx').toString();
      final sheetName =
          (rec['sheets'] is List && (rec['sheets'] as List).isNotEmpty)
              ? (rec['sheets'] as List).last.toString()
              : '';
      return ExcelFileEntry(
        idOrKey: id,
        fileName: fileName,
        sheetName: sheetName,
      );
    }).toList();
  }

  Future<void> _open(ExcelFileEntry row) async {
    if (_busy.contains(row.idOrKey)) return;
    setState(() => _busy.add(row.idOrKey));

    try {
      // 1) Get fresh presigned GET
      final url = await _excelFilesApi.presignGet(row.idOrKey);

      // 2) Download to temp and open
      final path = await _downloader.downloadToTemp(
        url,
        fileName: row.fileName,
      );
      final result = await _downloader.openLocal(path);

      if (!mounted) return;
      if (result.type.name != StatusType.done.name) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Açılamadı: ${result.message}')));
      }
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Açma hatası: $e')));
    } finally {
      if (mounted) setState(() => _busy.remove(row.idOrKey));
    }
  }

  Future<void> _download(ExcelFileEntry row) async {
    if (_busy.contains(row.idOrKey)) return;
    setState(() => _busy.add(row.idOrKey));

    try {
      // 1) Fresh presign
      final url = await _excelFilesApi.presignGet(row.idOrKey);

      // 2) Save under app docs (persistent)
      final path = await _downloader.downloadToAppDocs(
        url,
        fileName: row.fileName,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('İndirildi: $path')));

      await OpenFilex.open(path);
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('İndirme hatası: $e')));
    } finally {
      if (mounted) setState(() => _busy.remove(row.idOrKey));
    }
  }
}
