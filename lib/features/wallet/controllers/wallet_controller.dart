import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/features/wallet/data/services/wallet_services.dart';
import 'package:quikle_rider/features/wallet/models/leaderboard_standing.dart';
import 'package:quikle_rider/features/wallet/models/rider_performance.dart';
import 'package:quikle_rider/features/wallet/models/wallet_summary.dart';
import 'package:quikle_rider/features/wallet/widgets/delevery_card.dart';

// This model was inside the wallet screen, moving it here and making it public
class DeliveryItem {
  final String id;
  final DeliveryStatus status;
  final String amount;
  final String customer;
  final String dateTime;
  final String? distance;
  final String? rightSubline;
  final String? bottomNote;

  const DeliveryItem({
    required this.id,
    required this.status,
    required this.amount,
    required this.customer,
    required this.dateTime,
    this.distance,
    this.rightSubline,
    this.bottomNote,
  });
}

class WalletController extends GetxController
    with GetSingleTickerProviderStateMixin {
  WalletController({WalletServices? walletServices})
    : _walletServices = walletServices ?? WalletServices();
  static const List<String> _periodFilters = ['week', 'month', 'year'];
  late TabController tabController;
  final WalletServices _walletServices;
  final walletSummary = Rxn<WalletSummary>();
  final isWalletLoading = false.obs;
  final walletError = RxnString();
  final riderPerformance = Rxn<RiderPerformance>();
  final leaderboardStanding = Rxn<LeaderboardStanding>();
  final isPerformanceLoading = false.obs;
  final isLeaderboardLoading = false.obs;
  final performanceError = RxnString();
  final leaderboardError = RxnString();
  final avgDeliveryTime = '18'.obs;
  final customerRating = '4.8'.obs;
  final completionRate = '98%'.obs;
  var isOnline = true.obs;
  int _selectedPeriodIndex = 0;
  final Map<String, WalletSummary> _periodSummaries = {};
  // Data for different periods
  final _weekDeliveries = <DeliveryItem>[
    const DeliveryItem(
      id: '1023',
      status: DeliveryStatus.delivered,
      amount: '\$12.50',
      customer: 'John Doe',
      dateTime: 'Sep 8, 2025 10:15 AM',
      distance: '2.1 miles',
      rightSubline: '+\$1.50 tip',
    ),
  ].obs;

  final _monthDeliveries = <DeliveryItem>[
    const DeliveryItem(
      id: '1023',
      status: DeliveryStatus.delivered,
      amount: '\$12.50',
      customer: 'John Doe',
      dateTime: 'Sep 8, 2025 10:15 AM',
      distance: '2.1 miles',
      rightSubline: '+\$1.50 tip',
    ),
    const DeliveryItem(
      id: '1022',
      status: DeliveryStatus.cancelled,
      amount: '\$0.00',
      customer: 'Jane Smith',
      dateTime: 'Sep 7, 2025 4:20 PM',
      distance: '—',
      bottomNote: 'Customer cancelled',
    ),
  ].obs;

  final _yearDeliveries = <DeliveryItem>[
    const DeliveryItem(
      id: '1023',
      status: DeliveryStatus.delivered,
      amount: '\$12.50',
      customer: 'John Doe',
      dateTime: 'Sep 8, 2025 10:15 AM',
      distance: '2.1 miles',
      rightSubline: '+\$1.50 tip',
    ),
    const DeliveryItem(
      id: '1022',
      status: DeliveryStatus.cancelled,
      amount: '\$0.00',
      customer: 'Jane Smith',
      dateTime: 'Sep 7, 2025 4:20 PM',
      distance: '—',
      bottomNote: 'Customer cancelled',
    ),
    const DeliveryItem(
      id: '1021',
      status: DeliveryStatus.delivered,
      amount: '\$8.20',
      customer: 'Alice Johnson',
      dateTime: 'Sep 6, 2025 1:05 PM',
      distance: '1.3 miles',
    ),
  ].obs;

  var deliveries = <DeliveryItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: _periodFilters.length, vsync: this);
    tabController.addListener(() {
      if (tabController.indexIsChanging) return;
      updateDataForPeriod(tabController.index);
    });
    updateDataForPeriod(0);
    fetchPerformanceData();
    fetchLeaderboardData();
  }

  void updateDataForPeriod(int index) {
    _selectedPeriodIndex = index;
    _applyDeliveriesForPeriod(index);
    walletError.value = null;
    final period = _currentPeriod;
    walletSummary.value = _periodSummaries[period];
    fetchWalletSummary(periodOverride: period);
  }

  void _applyDeliveriesForPeriod(int index) {
    switch (index) {
      case 0: // Week
        avgDeliveryTime.value = '15';
        customerRating.value = '4.9';
        completionRate.value = '100%';
        deliveries.value = _weekDeliveries;
        break;
      case 1: // Month
        avgDeliveryTime.value = '17';
        customerRating.value = '4.8';
        completionRate.value = '99%';
        deliveries.value = _monthDeliveries;
        break;
      case 2: // Year
      default:
        avgDeliveryTime.value = '20';
        customerRating.value = '4.7';
        completionRate.value = '97%';
        deliveries.value = _yearDeliveries;
        break;
    }
  }

  String get _currentPeriod =>
      _periodFilters[_selectedPeriodIndex.clamp(0, _periodFilters.length - 1)];

  Future<void> fetchWalletSummary({String? periodOverride}) async {
    final accessToken = StorageService.accessToken;
    final period = periodOverride ?? _currentPeriod;
    if (accessToken == null || accessToken.isEmpty) {
      if (period == _currentPeriod) {
        walletError.value = 'Missing access token. Please login again.';
        walletSummary.value = null;
      }
      _periodSummaries.remove(period);
      return;
    }

    if (period == _currentPeriod) {
      isWalletLoading.value = true;
      walletError.value = null;
    }

    try {
      final response = await _walletServices.fetchWalletSummary(
        accessToken: accessToken,
        period: period,
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        final summary = WalletSummary.fromJson(
          response.responseData as Map<String, dynamic>,
        );
        _periodSummaries[period] = summary;
        if (period == _currentPeriod) {
          walletSummary.value = summary;
        }
      } else {
        if (period == _currentPeriod) {
          walletSummary.value = null;
          walletError.value = response.errorMessage.isNotEmpty
              ? response.errorMessage
              : 'Failed to load wallet data.';
        }
      }
    } catch (_) {
      if (period == _currentPeriod) {
        walletSummary.value = null;
        walletError.value = 'Failed to load wallet data.';
      }
    } finally {
      if (period == _currentPeriod) {
        isWalletLoading.value = false;
      }
    }
  }

  Future<void> fetchPerformanceData() async {
    final accessToken = StorageService.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      performanceError.value = 'Missing access token.';
      riderPerformance.value = null;
      return;
    }

    isPerformanceLoading.value = true;
    performanceError.value = null;

    try {
      final response = await _walletServices.fetchPerformance(
        accessToken: accessToken,
      );
      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        riderPerformance.value = RiderPerformance.fromJson(
          response.responseData as Map<String, dynamic>,
        );
      } else {
        performanceError.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Failed to load performance data.';
        riderPerformance.value = null;
      }
    } catch (_) {
      performanceError.value = 'Failed to load performance data.';
      riderPerformance.value = null;
    } finally {
      isPerformanceLoading.value = false;
    }
  }

  Future<void> fetchLeaderboardData() async {
    final accessToken = StorageService.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      leaderboardError.value = 'Missing access token.';
      leaderboardStanding.value = null;
      return;
    }

    isLeaderboardLoading.value = true;
    leaderboardError.value = null;

    try {
      final response = await _walletServices.fetchLeaderboard(
        accessToken: accessToken,
      );
      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        leaderboardStanding.value = LeaderboardStanding.fromJson(
          response.responseData as Map<String, dynamic>,
        );
      } else {
        leaderboardError.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Failed to load leaderboard.';
        leaderboardStanding.value = null;
      }
    } catch (_) {
      leaderboardError.value = 'Failed to load leaderboard.';
      leaderboardStanding.value = null;
    } finally {
      isLeaderboardLoading.value = false;
    }
  }

  Future<void> refreshCurrentPeriod() async {
    await Future.wait([
      fetchWalletSummary(periodOverride: _currentPeriod),
      fetchPerformanceData(),
      fetchLeaderboardData(),
    ]);
  }

  WalletSummary? get _summary => walletSummary.value;

  String get finalEarningsText =>
      _summary == null ? '₹0' : _formatCurrency(_summary!.finalEarnings);

  String get balanceSubtitle {
    final summary = _summary;
    if (summary == null) {
      return 'Latest payout details will appear here';
    }
    return 'Subtotal ${_formatCurrency(summary.subtotal)} • Top up ${_formatCurrency(summary.topUp)}';
  }

  String get totalDeliveriesText => _summary?.deliveries.toString() ?? '--';

  String get deliveryPayText => _currencyOrPlaceholder(_summary?.deliveryPay);

  String get weeklyBonusText => _currencyOrPlaceholder(_summary?.weeklyBonuses);

  String get excellenceBonusText =>
      _currencyOrPlaceholder(_summary?.excellenceBonus);

  String get subtotalText => _currencyOrPlaceholder(_summary?.subtotal);

  String get topUpText => _currencyOrPlaceholder(_summary?.topUp);

  String get finalEarningsStatText => finalEarningsText;

  String get forecastProgressText {
    final summary = _summary;
    if (summary == null) return '--';
    final safePercentage = summary.forecast.percentage;
    final displayPercentage = safePercentage == 0
        ? '0%'
        : '${safePercentage.toStringAsFixed(0)}%';
    return '${_formatCurrency(summary.forecast.current)} / ${_formatCurrency(summary.forecast.target)} ($displayPercentage)';
  }

  String get bonusDeliveriesText => _summary?.bonusDeliveries ?? '--';

  String get bonusAcceptanceText => _summary?.bonusAcceptance ?? '--';

  String get bonusOnTimeText => _summary?.bonusOnTime ?? '--';

  String get forecastProjectedAmountText {
    final summary = _summary;
    if (summary == null) {
      return 'On track for: --';
    }
    return 'On track for: ${_formatCurrency(summary.forecast.target)}';
  }

  String get forecastBasisNoteText {
    final summary = _summary;
    if (summary == null) {
      return '(Based on current pace)';
    }
    return 'Remaining deliveries: ${_formatCount(summary.forecast.remainingDeliveries)}';
  }

  double get forecastCurrentValue => _summary?.forecast.current ?? 0;

  double get _rawForecastTarget => _summary?.forecast.target ?? 0;

  double get forecastTargetValue {
    final target = _rawForecastTarget;
    return target <= 0 ? 1 : target;
  }

  List<WeeklyStatus> get weeklyStatuses =>
      _summary?.weeklyStatuses ?? const <WeeklyStatus>[];

  RiderPerformance? get performanceData => riderPerformance.value;

  LeaderboardStanding? get leaderboardData => leaderboardStanding.value;

  String _currencyOrPlaceholder(double? value) {
    if (value == null) return '--';
    return _formatCurrency(value);
  }

  String _formatCurrency(double value) {
    final hasFraction = value % 1 != 0;
    final formatted = hasFraction
        ? value.toStringAsFixed(2)
        : value.toStringAsFixed(0);
    return '₹$formatted';
  }

  String _formatCount(double value) {
    final hasFraction = value % 1 != 0;
    final formatted = hasFraction
        ? value.toStringAsFixed(1)
        : value.toStringAsFixed(0);
    return '$formatted';
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void toggleOnlineStatus() => isOnline.toggle();
}
