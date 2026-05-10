part of '../page/excel_page.dart';

mixin _ConnectionExcel on State<PageExcel> {
  final _excelFilesApi = ExcelService();
  final _customerService = CustomerService();
  final _downloader = FileDownloadService();
  final _scrollController = ScrollController();

  late Future<List<ExcelFileEntry>> _future;
  late bool _isLoadingCustomers;
  late List<CustomerListItemDto> _customerItems;
  late String? _selectedCustomerId;
  late String? _appliedCustomerId;
  final Set<String> _busy = {}; // rows busy state (by idOrKey)

  @override
  void initState() {
    super.initState();
    _isLoadingCustomers = false;
    _customerItems = [];
    _selectedCustomerId = widget.initialCustomerId;
    _appliedCustomerId = widget.initialCustomerId;
    _future = _load();
    unawaited(_loadCustomers());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<ExcelFileEntry>> _load() async {
    if (_appliedCustomerId == null &&
        widget.initialEntries != null &&
        widget.initialEntries!.isNotEmpty) {
      return widget.initialEntries!;
    }
    final list = await _excelFilesApi.listFiles(
      customerUserId: _appliedCustomerId,
    );
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
        customerUserId: _appliedCustomerId,
      );
    }).toList();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _isLoadingCustomers = true;
    });

    try {
      final customers = await _customerService.fetchCustomers(
        permission: ContactPermission.downloadFiles,
      );
      if (!mounted) return;
      setState(() {
        _customerItems = customers;
        _selectedCustomerId =
            customers.any((item) => item.id == _selectedCustomerId)
                ? _selectedCustomerId
                : null;
        _appliedCustomerId =
            customers.any((item) => item.id == _appliedCustomerId)
                ? _appliedCustomerId
                : null;
        _isLoadingCustomers = false;
      });
    } on Exception {
      if (!mounted) return;
      setState(() {
        _customerItems = [];
        _selectedCustomerId = null;
        _appliedCustomerId = null;
        _isLoadingCustomers = false;
      });
    }
  }

  void _onCustomerChanged(String? customerId) {
    setState(() {
      _selectedCustomerId = customerId;
    });
  }

  Future<void> _applyCustomerSelection() async {
    setState(() {
      _appliedCustomerId = _selectedCustomerId;
      _future = _load();
    });
  }

  Future<void> _open(ExcelFileEntry row) async {
    if (_busy.contains(row.idOrKey)) return;
    setState(() => _busy.add(row.idOrKey));

    try {
      // 1) Get fresh presigned GET
      final url = await _excelFilesApi.presignGet(
        row.idOrKey,
        customerUserId: row.customerUserId,
      );

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
        ).showSnackBar(
          SnackBar(
            content: ThemeTypography.bodyLarge(
              context,
              'Açılamadı: ${result.message}',
              color: context.theme.error,
              weight: FontWeight.w700,
            ),
          ),
        );
      }
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: ThemeTypography.bodyLarge(
            context,
            'Açma hatası: $e',
            color: context.theme.error,
            weight: FontWeight.w700,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy.remove(row.idOrKey));
    }
  }

  Future<void> _download(ExcelFileEntry row) async {
    if (_busy.contains(row.idOrKey)) return;
    setState(() => _busy.add(row.idOrKey));

    try {
      // 1) Fresh presign
      final url = await _excelFilesApi.presignGet(
        row.idOrKey,
        customerUserId: row.customerUserId,
      );

      // 2) Save under app docs (persistent)
      final path = await _downloader.downloadToAppDocs(
        url,
        fileName: row.fileName,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: ThemeTypography.bodyLarge(
            context,
            'İndirildi: $path',
            color: context.theme.success,
            weight: FontWeight.w700,
          ),
        ),
      );

      await OpenFilex.open(path);
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: ThemeTypography.bodyLarge(
            context,
            'İndirme hatası: $e',
            color: context.theme.error,
            weight: FontWeight.w700,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy.remove(row.idOrKey));
    }
  }
}
