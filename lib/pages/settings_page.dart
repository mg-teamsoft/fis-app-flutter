import 'package:fis_app_flutter/theme/extension.dart';
import 'package:flutter/material.dart';

import '../model/receipt_detail.dart';
import '../services/settings_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _settingsService = SettingsService();
  final _minLimitController = TextEditingController(text: '₺100,00');
  final _maxLimitController = TextEditingController(text: '₺5.000,00');
  final _monthlyTargetController = TextEditingController(text: '₺15.000,00');

  bool _food = true;
  bool _meal = true;
  bool _fuel = true;
  bool _parking = true;
  bool _electronic = true;
  bool _medication = true;
  bool _stationery = true;
  bool _makeup = false;

  bool _saving = false;
  bool _loading = true;
  bool _hasChanges = false;
  bool _suppressChanges = false;

  @override
  void initState() {
    super.initState();
    _minLimitController.addListener(_onFormChanged);
    _maxLimitController.addListener(_onFormChanged);
    _monthlyTargetController.addListener(_onFormChanged);
    _loadSettings();
  }

  @override
  void dispose() {
    _minLimitController.dispose();
    _maxLimitController.dispose();
    _monthlyTargetController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _loading = true);
    try {
      final response = await _settingsService.fetchRules();
      if (!mounted || response == null) {
        setState(() {
          _loading = false;
          _hasChanges = false;
        });
        return;
      }

      final Map<String, dynamic> rules = {};
      final serverRules = response['rules'];
      if (serverRules is Map<String, dynamic>) {
        rules.addAll(serverRules);
      } else {
        rules.addAll(_parseRulesString(response['rulesString'] as String?));
      }
      _applyRules(rules);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ayarlar getirilemedi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _applyRules(Map<String, dynamic> rules) {
    final min = double.tryParse(rules['MIN_AMOUNT_LIMIT']?.toString() ?? '');
    final max = double.tryParse(rules['MAX_AMOUNT_LIMIT']?.toString() ?? '');
    final target =
        double.tryParse(rules['MOUNTLY_TARGET_AMOUNT']?.toString() ?? '');
    final excluded = _parseExcludedList(rules['TRANSACTION_TYPE_EXCLUDE_LIST']);

    _suppressChanges = true;
    if (min != null) {
      _minLimitController.text = _formatCurrencyDisplay(min);
    }
    if (max != null) {
      _maxLimitController.text = _formatCurrencyDisplay(max);
    }
    if (target != null) {
      _monthlyTargetController.text = _formatCurrencyDisplay(target);
    }

    setState(() {
      _food = !excluded.contains(ReceiptCategory.food.label);
      _meal = !excluded.contains(ReceiptCategory.meal.label);
      _fuel = !excluded.contains(ReceiptCategory.fuel.label);
      _parking = !excluded.contains(ReceiptCategory.parking.label);
      _electronic = !excluded.contains(ReceiptCategory.electronic.label);
      _medication = !excluded.contains(ReceiptCategory.medication.label);
      _stationery = !excluded.contains(ReceiptCategory.stationery.label);
      _makeup = !excluded.contains(ReceiptCategory.personalCare.label);
      _hasChanges = false;
    });
    _suppressChanges = false;
  }

  Map<String, String> _parseRulesString(String? rulesString) {
    if (rulesString == null || rulesString.isEmpty) return {};
    final Map<String, String> result = {};
    for (final part in rulesString.split(';')) {
      final trimmed = part.trim();
      if (trimmed.isEmpty) continue;
      final idx = trimmed.indexOf('=');
      if (idx == -1) continue;
      final key = trimmed.substring(0, idx).trim();
      final value = trimmed.substring(idx + 1).trim();
      if (key.isNotEmpty) {
        result[key] = value;
      }
    }
    return result;
  }

  List<String> _parseExcludedList(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value
          .map((e) => e.toString().trim().toUpperCase())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    final str = value.toString();
    if (str.trim().isEmpty) return const [];
    return str
        .split(',')
        .map((e) => e.trim().toUpperCase())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  double _parseCurrency(String value) {
    var cleaned = value.replaceAll(RegExp(r'[^0-9,\. ,]'), '');
    cleaned = cleaned.replaceAll(' ', '');
    cleaned = cleaned.replaceAll('.', '');
    cleaned = cleaned.replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0;
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  String _formatCurrencyDisplay(double value) {
    return '₺${_formatNumber(value).replaceAll('.', ',')}';
  }

  void _onFormChanged() {
    if (_suppressChanges || !mounted) return;
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _saveSettings() async {
    if (_saving || _loading) return;

    final minLimit = _formatNumber(_parseCurrency(_minLimitController.text));
    final maxLimit = _formatNumber(_parseCurrency(_maxLimitController.text));
    final target = _formatNumber(_parseCurrency(_monthlyTargetController.text));

    final excludedTypes = <String>[];
    if (!_food) excludedTypes.add(ReceiptCategory.food.label);
    if (!_meal) excludedTypes.add(ReceiptCategory.meal.label);
    if (!_fuel) excludedTypes.add(ReceiptCategory.fuel.label);
    if (!_parking) excludedTypes.add(ReceiptCategory.parking.label);
    if (!_electronic) excludedTypes.add(ReceiptCategory.electronic.label);
    if (!_medication) excludedTypes.add(ReceiptCategory.medication.label);
    if (!_stationery) excludedTypes.add(ReceiptCategory.stationery.label);
    if (!_makeup) excludedTypes.add(ReceiptCategory.personalCare.label);

    final rulesString = [
      'MIN_AMOUNT_LIMIT=$minLimit',
      'MAX_AMOUNT_LIMIT=$maxLimit',
      'MOUNTLY_TARGET_AMOUNT=$target',
      'TRANSACTION_TYPE_EXCLUDE_LIST=${excludedTypes.join(',')}',
    ].join(';');

    setState(() => _saving = true);
    try {
      await _settingsService.updateRules(rulesString: rulesString);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ayarlar kaydedildi.')),
      );
      setState(() {
        _hasChanges = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kaydetme başarısız: $e')),
      );
      setState(() {
        _hasChanges = true;
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Center(
          child: Text(
            'Ayarlar',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Invoice Limits
        Row(
          children: const [
            Icon(Icons.receipt_long, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              'Fiş Limitleri',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Fişler için minimum ve maksimum tutarları ayarlayın.',
          style: TextStyle(color: context.colorScheme.onPrimary),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _minLimitController,
          decoration: const InputDecoration(
            labelText: 'Minimum Tutar Limiti',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _maxLimitController,
          decoration: const InputDecoration(
            labelText: 'Maksimum Tutar Limiti',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _monthlyTargetController,
          decoration: const InputDecoration(
            labelText: 'Aylık Hedef Tutarı',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 28),

        // Transaction Types
        Row(
          children: const [
            Icon(Icons.settings, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              'İşlem Yönetimi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Dahil edilecek işlem türlerini seçin.',
          style: TextStyle(color: context.colorScheme.onPrimary),
        ),
        const SizedBox(height: 12),
        _buildCheckboxTile(ReceiptCategory.food.label, _food, (value) {
          setState(() {
            _food = value!;
            if (!_suppressChanges) _hasChanges = true;
          });
        }),
        _buildCheckboxTile(ReceiptCategory.meal.label, _meal, (value) {
          setState(() {
            _meal = value!;
            if (!_suppressChanges) _hasChanges = true;
          });
        }),
        _buildCheckboxTile(ReceiptCategory.fuel.label, _fuel, (value) {
          setState(() {
            _fuel = value!;
            if (!_suppressChanges) _hasChanges = true;
          });
        }),
        _buildCheckboxTile(ReceiptCategory.parking.label, _parking, (value) {
          setState(() {
            _parking = value!;
            if (!_suppressChanges) _hasChanges = true;
          });
        }),
        _buildCheckboxTile(ReceiptCategory.electronic.label, _electronic,
            (value) {
          setState(() {
            _electronic = value!;
            if (!_suppressChanges) _hasChanges = true;
          });
        }),
        _buildCheckboxTile(ReceiptCategory.medication.label, _medication,
            (value) {
          setState(() {
            _medication = value!;
            if (!_suppressChanges) _hasChanges = true;
          });
        }),
        _buildCheckboxTile(ReceiptCategory.stationery.label, _stationery,
            (value) {
          setState(() {
            _stationery = value!;
            if (!_suppressChanges) _hasChanges = true;
          });
        }),
        _buildCheckboxTile(ReceiptCategory.personalCare.label, _makeup,
            (value) {
          setState(() {
            _makeup = value!;
            if (!_suppressChanges) _hasChanges = true;
          });
        }),

        const SizedBox(height: 32),

        // Save Button
        ElevatedButton(
          onPressed: (_saving || !_hasChanges) ? null : _saveSettings,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colorScheme.secondary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _saving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Değişiklikleri Kaydet',
                  style: TextStyle(
                      fontSize: 16, color: context.colorScheme.onSecondary),
                ),
        ),
      ],
    );
  }

  Widget _buildCheckboxTile(
      String title, bool value, ValueChanged<bool?> onChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CheckboxListTile(
        title: Text(title),
        value: value,
        onChanged: onChanged,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}
