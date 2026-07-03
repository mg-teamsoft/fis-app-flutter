part of '../page/excel_page.dart';

mixin _ConnectionExcel on State<PageExcel> {
  final _excelFilesApi = ExcelService();
  final _customerService = CustomerService();
  final _downloader = FileDownloadService();
  final _scrollController = ScrollController();

  late Future<List<ExcelFileEntry>> _future;
  bool _isLoadingCustomers = true;
  List<CustomerListItemDto> _customerItems = [];
  List<SupervisorContactDto> _supervisors = [];
  late String? _selectedCustomerId;
  late String? _appliedCustomerId;
  final Set<String> _busy = {}; // rows busy state (by idOrKey)
  bool _isNotifying = false;
  bool _isManagerNotified = false;

  @override
  void initState() {
    super.initState();
    _isLoadingCustomers = true;
    _customerItems = [];
    _supervisors = [];
    _selectedCustomerId = widget.initialCustomerId;
    _appliedCustomerId = widget.initialCustomerId;
    _future = _initData();
  }

  Future<List<ExcelFileEntry>> _initData() async {
    await Future.wait([
      _loadCustomers(),
      _loadSupervisors(),
    ]);
    return _load();
  }

  Future<void> _loadSupervisors() async {
    try {
      final connectionsService = ConnectionsService();
      final list = await connectionsService.fetchSupervisors();
      if (!mounted) return;
      setState(() {
        _supervisors = list;
      });
    } on Exception catch (_) {
      if (!mounted) return;
      setState(() {
        _supervisors = [];
      });
    }
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

    // If no specific customer is selected, and user has customers (is manager)
    if (_appliedCustomerId == null && _customerItems.isNotEmpty) {
      final allEntries = <ExcelFileEntry>[];
      for (final customer in _customerItems) {
        try {
          final list =
              await _excelFilesApi.listFiles(customerUserId: customer.id);
          allEntries.addAll(
            list.map((rec) {
              final id = (rec['_id'] ?? rec['s3Key']).toString();
              final fileName =
                  (rec['fileName'] ?? 'Fis_Listesi.xlsx').toString();
              final sheetName =
                  (rec['sheets'] is List && (rec['sheets'] as List).isNotEmpty)
                      ? (rec['sheets'] as List).last.toString()
                      : '';
              return ExcelFileEntry(
                idOrKey: id,
                fileName: fileName,
                sheetName: sheetName,
                customerUserId: customer.id,
              );
            }),
          );
        } on Exception catch (_) {
          // Ignore errors for individual customers to not break the whole list
        }
      }
      return allEntries;
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

  Future<void> _notifyManager() async {
    if (_supervisors.isEmpty || _isNotifying || _isManagerNotified) return;

    setState(() => _isNotifying = true);

    try {
      for (final sup in _supervisors) {
        await _excelFilesApi.sendUpdateNotification(sup.email);
      }
      if (!mounted) return;
      setState(() => _isManagerNotified = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ThemeTypography.bodyLarge(
            context,
            'Yönetici başarıyla bilgilendirildi.',
            color: context.theme.success,
            weight: FontWeight.w700,
          ),
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ThemeTypography.bodyLarge(
            context,
            'Bildirim gönderilemedi: $e',
            color: context.theme.error,
            weight: FontWeight.w700,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isNotifying = false);
    }
  }

  Future<void> _notifyUpdate() async {
    if (_appliedCustomerId == null || _isNotifying) return;

    final matchingCustomers =
        _customerItems.where((c) => c.id == _appliedCustomerId).toList();
    final customer =
        matchingCustomers.isNotEmpty ? matchingCustomers.first : null;
    final email = customer?.email;
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ThemeTypography.bodyLarge(
            context,
            'Seçili kullanıcının e-posta adresi bulunamadı.',
            color: context.theme.error,
            weight: FontWeight.w700,
          ),
        ),
      );
      return;
    }

    setState(() => _isNotifying = true);

    try {
      await _excelFilesApi.sendUpdateNotification(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ThemeTypography.bodyLarge(
            context,
            'Bildirim başarıyla gönderildi.',
            color: context.theme.success,
            weight: FontWeight.w700,
          ),
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ThemeTypography.bodyLarge(
            context,
            'Bildirim gönderilemedi: $e',
            color: context.theme.error,
            weight: FontWeight.w700,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isNotifying = false);
    }
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
