import 'package:fis_app_flutter/models/excel_file_entry.dart';
import 'package:fis_app_flutter/models/status_type.dart';
import 'package:fis_app_flutter/services/excel_service.dart';
import 'package:fis_app_flutter/services/file_download_service.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

class ExcelFilesPage extends StatefulWidget {
  /// You can pass initial entries (built from /excel/write response),
  /// but this page can also fetch from /excel/files itself.
  final List<ExcelFileEntry>? initialEntries;

  const ExcelFilesPage({super.key, this.initialEntries});

  @override
  State<ExcelFilesPage> createState() => _ExcelFilesPageState();
}

class _ExcelFilesPageState extends State<ExcelFilesPage> {
  final _excelFilesApi = ExcelService();
  final _downloader = FileDownloadService();

  late Future<List<ExcelFileEntry>> _future;
  final Set<String> _busy = {}; // rows busy state (by idOrKey)

  @override
  void initState() {
    super.initState();
    _future = _load();
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
    } catch (e) {
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('İndirme hatası: $e')));
    } finally {
      if (mounted) setState(() => _busy.remove(row.idOrKey));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: Alignment.center,
            child: Text(
              'Excel Dosyaları',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<ExcelFileEntry>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Hata: ${snap.error}'));
                }
                final rows = snap.data ?? const <ExcelFileEntry>[];
                if (rows.isEmpty) {
                  return const Center(child: Text('Kayıtlı Excel bulunamadı.'));
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Dosya Adı')),
                        DataColumn(label: Text('Sayfa (Ay/Yıl)')),
                        DataColumn(label: Text('İşlemler')),
                      ],
                      rows: rows.map((r) {
                        final isBusy = _busy.contains(r.idOrKey);
                        return DataRow(
                          cells: [
                            DataCell(Text(r.fileName)),
                            DataCell(Text(r.sheetName)),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FilledButton.icon(
                                    onPressed: isBusy ? null : () => _open(r),
                                    icon: const Icon(Icons.open_in_new),
                                    label: Text(isBusy ? 'Açılıyor...' : 'Aç'),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed:
                                        isBusy ? null : () => _download(r),
                                    icon: const Icon(Icons.download),
                                    label: Text(
                                        isBusy ? 'İndiriliyor...' : 'İndir'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
