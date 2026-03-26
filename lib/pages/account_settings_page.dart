import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/plan_option.dart';
import '../model/purchase_transaction.dart';
import '../model/user_profile.dart';
import '../providers/purchase_provider.dart';
import '../providers/user_plan_provider.dart';
import '../services/plan_service.dart';
import '../services/purchase_transaction_service.dart';
import '../services/user_service.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

const fallbackProductIds = <String>{
  'com.myfisapp.sub.monthly100',
  'com.myfisapp.sub.yearly1200',
  'com.myfisapp.consumable.100scans',
};

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _userService = UserService();
  final _planService = PlanService();
  final _purchaseTransactionService = PurchaseTransactionService();

  UserProfile? _user;
  List<PlanOption> _allPlans = const [];
  List<PlanOption> _subscriptionPlans = const [];
  PlanOption? _currentPlan;
  List<PlanOption> _plans = const [];
  String? _selectedPlanKey;
  String? _currentPlanKey;
  String? _userPlanId;
  List<PurchaseTransaction> _transactions = const [];
  String? _transactionError;

  bool _loading = true;
  bool _updatingPlan = false;
  bool _resendingVerification = false;
  String? _error;
  bool _iapInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = await _userService.fetchCurrentUser();
      final fetchedPlans = await _planService.fetchPlans();
      final sortedAllPlans = PlanService.sortPlansWithFreeFirst(fetchedPlans);
      final subscriptionPlans = sortedAllPlans.where((plan) {
        return (plan.productType ?? '').toLowerCase() == 'subscription' &&
            plan.active;
      }).toList();
      final userPlan = await _planService.fetchUserPlanKey();
      List<PurchaseTransaction> transactions = const [];
      String? transactionError;
      try {
        transactions = await _purchaseTransactionService.listTransactions();
      } catch (e) {
        transactionError = e.toString();
      }

      if (!mounted) return;
      setState(() {
        _user = user;
        final up = Provider.of<UserPlanProvider?>(context, listen: false);
        final providerPlanKey = up?.planKey.trim().toUpperCase();
        final serverPlanKey = userPlan?.planKey.trim();
        final providerHasAppleEntitlement = providerPlanKey != null &&
            providerPlanKey.isNotEmpty &&
            providerPlanKey != 'FREE';
        _currentPlanKey = providerHasAppleEntitlement
            ? providerPlanKey
            : (serverPlanKey != null && serverPlanKey.isNotEmpty)
                ? serverPlanKey
                : (providerPlanKey != null && providerPlanKey.isNotEmpty)
                    ? providerPlanKey
                    : (subscriptionPlans.isNotEmpty
                        ? subscriptionPlans.first.planKey
                        : null);
        _currentPlan = sortedAllPlans
                .where((plan) => plan.planKey == _currentPlanKey)
                .isNotEmpty
            ? sortedAllPlans
                .firstWhere((plan) => plan.planKey == _currentPlanKey)
            : null;
        _allPlans = sortedAllPlans
            .where((plan) => plan.planKey != _currentPlanKey)
            .toList();
        _subscriptionPlans = subscriptionPlans;
        _plans = subscriptionPlans
            .where((plan) => plan.planKey != _currentPlanKey)
            .toList();
        debugPrint('Current plan key: $_currentPlanKey');
        debugPrint(
            'Available plans: ${_plans.map((p) => p.planKey).join(', ')}');

        _selectedPlanKey = null;
        _userPlanId = userPlan?.id;
        _transactions = transactions;
        _transactionError = transactionError;
      });

      if (!_iapInitialized) {
        final pp = Provider.of<PurchaseProvider>(context, listen: false);
        await pp.init(_productIdsFromPlans());
        _iapInitialized = true;
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _onRefresh() => _loadAll();

  String? _productIdForPlanKey(String planKey) {
    switch (planKey) {
      case 'MONTHLY_100':
        return 'com.myfisapp.sub.monthly100';
      case 'YEARLY_1200':
        return 'com.myfisapp.sub.yearly1200';
      case 'ADDITIONAL_100':
        return 'com.myfisapp.consumable.100scans';
      default:
        return null;
    }
  }

  String? _productIdForPlan(PlanOption plan) {
    if (plan.storeIds.isNotEmpty) {
      final match = plan.storeIds.entries.firstWhere(
        (entry) {
          final key = entry.key.toLowerCase();
          return key.contains('apple') ||
              key.contains('ios') ||
              key.contains('appstore') ||
              key.contains('storekit');
        },
        orElse: () => const MapEntry('', ''),
      );
      if (match.value.isNotEmpty) {
        return match.value;
      }
    }
    return _productIdForPlanKey(plan.planKey);
  }

  Set<String> _productIdsFromPlans() {
    final ids = <String>{};
    for (final plan in _allPlans) {
      final id = _productIdForPlan(plan);
      if (id != null && id.isNotEmpty) {
        ids.add(id);
      }
    }
    return ids.isNotEmpty ? ids : fallbackProductIds;
  }

  List<PlanOption> _availablePlansForCurrent(String? currentPlanKey) {
    return _subscriptionPlans
        .where((plan) => plan.planKey != currentPlanKey)
        .toList();
  }

  PlanOption? _findPlanByKey(String? key) {
    if (key == null) return null;
    for (final plan in _allPlans) {
      if (plan.planKey == key) return plan;
    }
    return null;
  }

  PlanOption? get _selectedPlan {
    final key = _selectedPlanKey;
    if (key == null) return null;
    for (final plan in _plans) {
      if (plan.planKey == key) return plan;
    }
    return null;
  }

  PlanOption? get _activePlan {
    if (_currentPlan != null) return _currentPlan;
    final current = _findPlanByKey(_currentPlanKey);
    if (current != null) return current;
    if (_subscriptionPlans.isNotEmpty) return _subscriptionPlans.first;
    return _allPlans.isNotEmpty ? _allPlans.first : null;
  }

  PlanOption? get _additionalPlan {
    for (final plan in _allPlans) {
      final key = plan.planKey.toLowerCase();
      final type = (plan.productType ?? '').toLowerCase();
      if (key.contains('additional') || type == 'consumable') {
        return plan;
      }
    }
    return null;
  }

  Color _availablePlanBackground(int index) {
    const palette = <Color>[
      Color(0xFFDCEEFF),
      Color(0xFFDCF7EA),
      Color(0xFFFFECD6),
    ];
    return palette[index % palette.length];
  }

  Color _availablePlanBorder(int index) {
    const palette = <Color>[
      Color(0xFF84CAFF),
      Color(0xFF75E0A7),
      Color(0xFFFDBA74),
    ];
    return palette[index % palette.length];
  }

  Future<void> _buyPlan(
    PlanOption plan, {
    required bool syncCurrentPlan,
  }) async {
    final pp = Provider.of<PurchaseProvider>(context, listen: false);
    if (!_iapInitialized) {
      await pp.init(_productIdsFromPlans());
      _iapInitialized = true;
    }
    if (!mounted) return;

    final productId = _productIdForPlan(plan);
    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu plan bulunamadı.')),
      );
      return;
    }

    ProductDetails? product;
    for (final p in pp.products) {
      if (p.id == productId) {
        product = p;
        break;
      }
    }

    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan App Store\'da mevcut değil.')),
      );
      return;
    }

    await pp.buy(product);

    if (!syncCurrentPlan || !mounted) return;
    final up = Provider.of<UserPlanProvider?>(context, listen: false);
    if (up != null) {
      await up.loadMyPlan();
      if (!mounted) return;
      setState(() {
        _currentPlanKey = up.planKey;
        _currentPlan = _subscriptionPlans
                .where((plan) => plan.planKey == _currentPlanKey)
                .isNotEmpty
            ? _subscriptionPlans
                .firstWhere((plan) => plan.planKey == _currentPlanKey)
            : _currentPlan;
        _plans = _availablePlansForCurrent(_currentPlanKey);
        _selectedPlanKey = null;
      });
    }
  }

  Future<void> _onUpdatePlan() async {
    final selected = _selectedPlanKey;
    if (selected == null || selected == _currentPlanKey) return;

    final selectedPlan = _selectedPlan;
    if (selectedPlan == null) return;

    setState(() => _updatingPlan = true);
    try {
      if (selected == 'FREE') {
        if (_userPlanId == null || _userPlanId!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Güncellenecek kullanıcı planı bulunamadı.')),
          );
          return;
        }
        await _planService.updateUserPlan(
          userPlanId: _userPlanId!,
          planKey: selected,
        );

        if (!mounted) return;
        setState(() {
          _currentPlanKey = selected;
          _currentPlan = null;
          _plans = _availablePlansForCurrent(_currentPlanKey);
          _selectedPlanKey = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plan güncellendi.')),
        );
        return;
      }

      await _buyPlan(selectedPlan, syncCurrentPlan: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan güncellendi.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Plan güncelleme başarısız: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingPlan = false);
      }
    }
  }

  Future<void> _onBuyAdditional() async {
    final plan = _additionalPlan;
    if (plan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ek paket mevcut değil.')),
      );
      return;
    }

    setState(() => _updatingPlan = true);
    try {
      await _buyPlan(plan, syncCurrentPlan: false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ek kota satın alındı.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Satın alma başarısız: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingPlan = false);
      }
    }
  }

  Future<void> _onResendVerification() async {
    final email = _user?.email ?? '';
    if (email.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-posta adresi bulunamadı.')),
      );
      return;
    }

    setState(() => _resendingVerification = true);
    try {
      await _userService.resendVerificationEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doğrulama e-postası gönderildi.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İşlem başarısız: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _resendingVerification = false);
      }
    }
  }

  void _onResetPassword() {
    Navigator.of(context).pushNamed('/forgotPassword');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F5F7),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Hesap Ayarları',
          style: TextStyle(
            color: Color(0xFF101828),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _ErrorView(
        message: 'Hesap ayarları yüklenemedi.',
        details: _error,
        onRetry: _loadAll,
      );
    }

    if (_user == null) {
      return _ErrorView(
        message: 'Kullanıcı profili bulunamadı.',
        onRetry: _loadAll,
      );
    }

    final activePlan = _activePlan;
    final navSpacer = kBottomNavigationBarHeight + 12;
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          _SectionTitle(text: 'Hesap Detayları'),
          const SizedBox(height: 12),
          _AccountDetailsCard(
            user: _user!,
            resendingVerification: _resendingVerification,
            onResendVerification: _onResendVerification,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _onResetPassword,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              side: const BorderSide(color: Color(0xFFD0D5DD)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.lock_reset, color: Color(0xFF98A2B3)),
            label: const Text(
              'Şifreyi Sıfırla',
              style: TextStyle(
                color: Color(0xFF101828),
                fontWeight: FontWeight.w700,
                fontSize: 28 / 2,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle(text: 'Aktif Plan'),
          const SizedBox(height: 12),
          if (activePlan != null)
            _ActivePlanCard(
              plan: activePlan,
              onBuyAdditional: _updatingPlan ? null : _onBuyAdditional,
            )
          else
            const _EmptyPlanCard(),
          const SizedBox(height: 24),
          _SectionTitle(text: 'Mevcut Planlar'),
          const SizedBox(height: 12),
          if (_plans.isEmpty)
            const _EmptyPlanCard()
          else
            ..._plans.asMap().entries.map(
              (entry) {
                final index = entry.key;
                final plan = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AvailablePlanTile(
                    plan: plan,
                    selected: _selectedPlanKey == plan.planKey,
                    backgroundColor: _availablePlanBackground(index),
                    borderColor: _availablePlanBorder(index),
                    onTap: () =>
                        setState(() => _selectedPlanKey = plan.planKey),
                  ),
                );
              },
            ),
          const SizedBox(height: 18),
          SizedBox(
            height: 68,
            child: ElevatedButton(
              onPressed: (_selectedPlanKey == null ||
                      _selectedPlanKey == _currentPlanKey ||
                      _updatingPlan)
                  ? null
                  : _onUpdatePlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E1A3A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _updatingPlan
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Planı Güncelle',
                      style: TextStyle(
                          fontSize: 32 / 2, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle(text: 'Ödeme Detayları'),
          const SizedBox(height: 12),
          _PaymentDetailsTable(
            transactions: _transactions,
            error: _transactionError,
          ),
          const SizedBox(height: 14),
          const Text(
            'Plan değişiklikleri hemen uygulanır. Mevcut fatura dönemindeki kullanılmayan kota için iade yapılmaz.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF98A2B3),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(height: navSpacer),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        fontSize: 14,
        color: Color(0xFF475467),
      ),
    );
  }
}

class _AccountDetailsCard extends StatelessWidget {
  const _AccountDetailsCard({
    required this.user,
    required this.resendingVerification,
    required this.onResendVerification,
  });

  final UserProfile user;
  final bool resendingVerification;
  final VoidCallback onResendVerification;

  @override
  Widget build(BuildContext context) {
    final createdAt = user.createdAt;
    final createdAtLabel = createdAt != null
        ? DateFormat('d MMMM yyyy', 'tr_TR').format(createdAt)
        : '-';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD0D5DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kullanıcı Adı',
              style: TextStyle(color: Color(0xFF667085))),
          const SizedBox(height: 6),
          Text(
            user.userName,
            style: const TextStyle(
              color: Color(0xFF101828),
              fontWeight: FontWeight.w600,
              fontSize: 32 / 2,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFEAECF0)),
          const SizedBox(height: 14),
          const Text('E-posta', style: TextStyle(color: Color(0xFF667085))),
          const SizedBox(height: 6),
          Text(
            user.email,
            style: const TextStyle(
              color: Color(0xFF101828),
              fontWeight: FontWeight.w500,
              fontSize: 32 / 2,
            ),
          ),
          if (!user.emailVerified) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6E8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF2D7A7)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFB54708), size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'E-posta doğrulanmadı',
                      style: TextStyle(
                        color: Color(0xFFB54708),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed:
                        resendingVerification ? null : onResendVerification,
                    child: resendingVerification
                        ? const SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Tekrar Gönder'),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFEAECF0)),
          const SizedBox(height: 14),
          const Text('Hesap Oluşturma',
              style: TextStyle(color: Color(0xFF667085))),
          const SizedBox(height: 6),
          Text(
            createdAtLabel,
            style: const TextStyle(
              color: Color(0xFF101828),
              fontWeight: FontWeight.w500,
              fontSize: 32 / 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivePlanCard extends StatelessWidget {
  const _ActivePlanCard({
    required this.plan,
    required this.onBuyAdditional,
  });

  final PlanOption plan;
  final VoidCallback? onBuyAdditional;

  @override
  Widget build(BuildContext context) {
    final price = plan.priceLabel;
    final renewLabel = _renewLabel(plan.period);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1570EF), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF2FF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'MEVCUT PLAN',
                        style: TextStyle(
                          color: Color(0xFF1570EF),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      plan.name,
                      style: const TextStyle(
                        color: Color(0xFF101828),
                        fontWeight: FontWeight.w700,
                        fontSize: 36 / 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${plan.quota ?? 0} fatura/ay  •  $renewLabel',
                      style: const TextStyle(
                          color: Color(0xFF667085), fontSize: 28 / 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      color: Color(0xFF101828),
                      fontWeight: FontWeight.w800,
                      fontSize: 44 / 2,
                    ),
                  ),
                  const Text(
                    'aylık',
                    style: TextStyle(color: Color(0xFF667085)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onBuyAdditional,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1570EF),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.shopping_cart_checkout),
              label: const Text(
                'Ek 100 Satın Al',
                style: TextStyle(fontSize: 32 / 2, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _renewLabel(String period) {
    final value = period.toLowerCase();
    if (value.contains('month')) return 'Aylık yenilenir';
    if (value.contains('year') || value.contains('annual')) {
      return 'Yıllık yenilenir';
    }
    return 'Otomatik yenilenir';
  }
}

class _PaymentDetailsTable extends StatelessWidget {
  const _PaymentDetailsTable({
    required this.transactions,
    required this.error,
  });

  final List<PurchaseTransaction> transactions;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('d MMM yyyy HH:mm', 'tr_TR');

    final sortedTransactions = [...transactions]..sort((a, b) {
        final aDate = a.purchaseDate ??
            a.expiresDate ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.purchaseDate ??
            b.expiresDate ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

    final rows = sortedTransactions.isEmpty
        ? <DataRow>[
            const DataRow(cells: [
              DataCell(Text('-')),
              DataCell(Text('-')),
              DataCell(Text('-')),
              DataCell(Text('-')),
            ]),
          ]
        : sortedTransactions.map((transaction) {
            final purchaseDate = transaction.purchaseDate != null
                ? dateFormatter.format(transaction.purchaseDate!)
                : '-';
            final expiresDate = transaction.expiresDate != null
                ? dateFormatter.format(transaction.expiresDate!)
                : '-';
            return DataRow(cells: [
              DataCell(Text(
                transaction.transactionId.isNotEmpty
                    ? transaction.transactionId
                    : '-',
              )),
              DataCell(Text(
                transaction.originalTransactionId.isNotEmpty
                    ? transaction.originalTransactionId
                    : '-',
              )),
              DataCell(Text(purchaseDate)),
              DataCell(Text(expiresDate)),
            ]);
          }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD0D5DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (error != null && error!.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Text(
                'Odeme detaylari alinamadi.',
                style: TextStyle(
                  color: Color(0xFFB42318),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('transactionId')),
                DataColumn(label: Text('originalTransactionId')),
                DataColumn(label: Text('purchaseDate')),
                DataColumn(label: Text('expiresDate')),
              ],
              rows: rows,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailablePlanTile extends StatelessWidget {
  const _AvailablePlanTile({
    required this.plan,
    required this.selected,
    required this.backgroundColor,
    required this.borderColor,
    required this.onTap,
  });

  final PlanOption plan;
  final bool selected;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor =
        selected ? const Color(0xFF1570EF) : borderColor;
    final effectiveBackgroundColor =
        selected ? const Color(0xFFEAF2FF) : backgroundColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: effectiveBorderColor,
            width: selected ? 2.2 : 1.4,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selected) ...[
              Container(
                margin: const EdgeInsets.only(right: 10, top: 2),
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1570EF),
                ),
                child: const Icon(
                  Icons.check,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    style: const TextStyle(
                      color: Color(0xFF101828),
                      fontWeight: FontWeight.w700,
                      fontSize: 36 / 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.description.isNotEmpty
                        ? plan.description
                        : 'Abonelik planı',
                    style: const TextStyle(
                        color: Color(0xFF667085), fontSize: 30 / 2),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${plan.quota ?? 0} FATURA   •   ${_periodLabel(plan.period).toUpperCase()}',
                    style: const TextStyle(
                      color: Color(0xFF1570EF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  plan.priceLabel,
                  style: const TextStyle(
                    color: Color(0xFF101828),
                    fontWeight: FontWeight.w700,
                    fontSize: 44 / 2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _periodLabel(plan.period),
                  style: const TextStyle(color: Color(0xFF98A2B3)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _periodLabel(String period) {
    final value = period.toLowerCase();
    if (value.contains('month')) return 'Aylık';
    if (value.contains('year') || value.contains('annual')) return 'Yıllık';
    if (value.contains('week')) return 'Haftalık';
    return 'Plan';
  }
}

class _EmptyPlanCard extends StatelessWidget {
  const _EmptyPlanCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD0D5DD)),
      ),
      child: const Text(
        'Plan bulunamadı.',
        style: TextStyle(color: Color(0xFF667085)),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    this.details,
    required this.onRetry,
  });

  final String message;
  final String? details;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_rounded,
                size: 48, color: context.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (details != null && details!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                details!,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }
}
