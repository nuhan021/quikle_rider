import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/features/profile/data/services/profile_services.dart';
import 'package:quikle_rider/features/profile/presentation/controller/profile_controller.dart';
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
    : _walletServices = walletServices ?? WalletServices(),
      _profileServices = ProfileServices();
  static const List<String> _periodFilters = ['week', 'month', 'year'];
  late TabController tabController;
  final WalletServices _walletServices;
  final ProfileServices _profileServices;
  late final ProfileController _profileController;
  Worker? _verificationWorker;
  final walletSummary = Rxn<WalletSummary>();
  final monthlyForecast = Rxn<WalletForecast>();
  final isWalletLoading = false.obs;
  final walletError = RxnString();
  final riderPerformance = Rxn<RiderPerformance>();
  final leaderboardStanding = Rxn<LeaderboardStanding>();
  final currentBalance = 0.0.obs;
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
  final RxnDouble riderRating = RxnDouble();
  final RxnInt riderReviewCount = RxnInt();
  final RxBool isRatingLoading = false.obs;
  final RxnString ratingError = RxnString();
  final RxList<Map<String, dynamic>> withdrawalHistory =
      <Map<String, dynamic>>[].obs;
  final RxBool isWithdrawalHistoryLoading = false.obs;
  final RxBool isMoreWithdrawalHistoryLoading = false.obs;
  final RxnString withdrawalHistoryError = RxnString();
  final RxnInt withdrawalHistoryCount = RxnInt();
  
  // New stats reactive variables
  final Rxn<Map<String, dynamic>> allStats = Rxn<Map<String, dynamic>>();
  final Rxn<Map<String, dynamic>> weeklyStats = Rxn<Map<String, dynamic>>();
  final Rxn<Map<String, dynamic>> monthlyStats = Rxn<Map<String, dynamic>>();
  final Rxn<Map<String, dynamic>> annualStats = Rxn<Map<String, dynamic>>();
  
  final RxBool isAllStatsLoading = false.obs;
  final RxBool isWeeklyStatsLoading = false.obs;
  final RxBool isMonthlyStatsLoading = false.obs;
  final RxBool isAnnualStatsLoading = false.obs;
  final RxBool isBonusProgressLoading = false.obs;
  final RxBool isMonthlyForecastLoading = false.obs;
  bool _hasLoadedWalletData = false;
  
  final RxnString allStatsError = RxnString();
  final RxnString weeklyStatsError = RxnString();
  final RxnString monthlyStatsError = RxnString();
  final RxnString annualStatsError = RxnString();
  final RxnString bonusProgressError = RxnString();
  final RxnString monthlyForecastError = RxnString();
  
  // Bonus progress data
  final bonusProgress = Rxn<Map<String, dynamic>>();
  
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
    _profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    tabController = TabController(length: 4, vsync: this);
    tabController.addListener(() {
      if (tabController.indexIsChanging) return;
      update(); // Trigger GetBuilder to rebuild when tab changes
      updateDataForPeriod(tabController.index);
    });
    
    if (_isVerified) {
      _loadWalletData();
    } else {
      _verificationWorker =
          ever<String?>(_profileController.isVerified, (_) {
        if (_isVerified) {
          _loadWalletData();
        }
      });
    }
  }

  bool get _isVerified => _profileController.isVerifiedApproved;

  void _loadWalletData() {
    if (_hasLoadedWalletData) {
      return;
    }
    _hasLoadedWalletData = true;
    // Fetch all stats on init
    fetchAllStats();
    updateDataForPeriod(0);
    fetchPerformanceData();
    fetchLeaderboardData();
    fetchWithdrawalHistory();
    fetchRiderRating();
    fetchMonthlyForecast();
    fetchBonusProgress();
  }

  void updateDataForPeriod(int index) {
    _selectedPeriodIndex = index;
    _applyDeliveriesForPeriod(index);
    walletError.value = null;
    final period = _currentPeriod;
    walletSummary.value = _periodSummaries[period];
    if (walletSummary.value != null) {
      currentBalance.value = walletSummary.value!.currentBalance;
    }
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
    if (!_isVerified) {
      return;
    }
    final accessToken = StorageService.accessToken;
    final period = periodOverride ?? _currentPeriod;
    if (accessToken == null || accessToken.isEmpty) {
      if (period == _currentPeriod) {
        walletError.value = 'Missing access token. Please login again.';
        walletSummary.value = null;
        currentBalance.value = 0;
      }
      _periodSummaries.remove(period);
      return;
    }

    if (period == _currentPeriod) {
      isWalletLoading.value = true;
      walletError.value = null;
    }

    try {
      final response = await _walletServices.fetchWalletSummaryWithBalance(
        accessToken: accessToken,
        period: period,
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        final body = response.responseData as Map<String, dynamic>;
        final summary = WalletSummary.fromJson(body);
        _periodSummaries[period] = summary;
        if (period == _currentPeriod) {
          walletSummary.value = summary;
          final value = body['current_balance'];
          if (value is num) {
            currentBalance.value = value.toDouble();
          } else if (value is String) {
            currentBalance.value = double.tryParse(value) ?? 0;
          } else {
            currentBalance.value = 0;
          }
        }
      } else {
        if (period == _currentPeriod) {
          walletSummary.value = null;
          currentBalance.value = 0;
          walletError.value = response.errorMessage.isNotEmpty
              ? response.errorMessage
              : 'Failed to load wallet data.';
        }
      }
    } catch (_) {
      if (period == _currentPeriod) {
        walletSummary.value = null;
        currentBalance.value = 0;
        walletError.value = 'Failed to load wallet data.';
      }
    } finally {
      if (period == _currentPeriod) {
        isWalletLoading.value = false;
      }
    }
  }

  Future<void> fetchPerformanceData() async {
    if (!_isVerified) {
      return;
    }
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
    if (!_isVerified) {
      return;
    }
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

  Future<void> fetchRiderRating() async {
    if (!_isVerified) {
      return;
    }
    final accessToken = StorageService.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      ratingError.value = 'Missing access token.';
      riderRating.value = null;
      riderReviewCount.value = null;
      return;
    }

    isRatingLoading.value = true;
    ratingError.value = null;
    try {
      final response = await _profileServices.getRiderRatings(
        accessToken: accessToken,
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        final body = response.responseData as Map<String, dynamic>;
        riderRating.value = (body['avg_rating'] as num?)?.toDouble() ?? 0.0;
        riderReviewCount.value = (body['total_reviews'] as num?)?.toInt() ?? 0;
      } else {
        ratingError.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Failed to load ratings.';
        riderRating.value = null;
        riderReviewCount.value = null;
      }
    } catch (_) {
      ratingError.value = 'Failed to load ratings.';
      riderRating.value = null;
      riderReviewCount.value = null;
    } finally {
      isRatingLoading.value = false;
    }
  }

  String get ratingDisplay =>
      riderRating.value?.toStringAsFixed(1) ?? '0.0';

  String get totalRatingsText {
    final count = riderReviewCount.value ?? 0;
    return count == 1 ? '1 Rating' : '$count Ratings';
  }

  Future<void> fetchCurrentBalance() async {
    if (!_isVerified) {
      return;
    }
    final accessToken = StorageService.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      currentBalance.value = 0;
      return;
    }

    try {
      final response = await _walletServices.getCurrentBalance(
        accessToken: accessToken,
      );
      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        final body = response.responseData as Map<String, dynamic>;
        final value = body['current_balance'];
        if (value is num) {
          currentBalance.value = value.toDouble();
        } else if (value is String) {
          currentBalance.value = double.tryParse(value) ?? 0;
        } else {
          currentBalance.value = 0;
        }
      } else {
        currentBalance.value = 0;
      }
    } catch (_) {
      currentBalance.value = 0;
    }
  }

  Future<void> fetchMonthlyForecast() async {
    if (!_isVerified) {
      return;
    }
    final accessToken = StorageService.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      monthlyForecastError.value = 'Missing access token.';
      monthlyForecast.value = null;
      return;
    }

    isMonthlyForecastLoading.value = true;
    monthlyForecastError.value = null;

    try {
      final response = await _walletServices.fetchMonthlyForecast(
        accessToken: accessToken,
      );
      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        final body = response.responseData as Map<String, dynamic>;
        final mapped = <String, dynamic>{
          'current': body['subtotal'],
          'percentage': body['percentage'],
          'remaining_deliveries': body['remaining_deliveries'],
          'target': body['target'],
        };
        monthlyForecast.value = WalletForecast.fromJson(mapped);
      } else {
        monthlyForecast.value = null;
        monthlyForecastError.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Failed to load monthly forecast.';
      }
    } catch (_) {
      monthlyForecast.value = null;
      monthlyForecastError.value = 'Failed to load monthly forecast.';
    } finally {
      isMonthlyForecastLoading.value = false;
    }
  }

  bool get canLoadMoreWithdrawals =>
      (withdrawalHistoryCount.value ?? 0) > withdrawalHistory.length;

  Future<void> fetchWithdrawalHistory({
    int skip = 0,
    int limit = 20,
    bool append = false,
  }) async {
    if (!_isVerified) {
      return;
    }
    final accessToken = StorageService.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      withdrawalHistory.clear();
      withdrawalHistoryError.value = 'Missing access token.';
      withdrawalHistoryCount.value = 0;
      return;
    }

    if (append) {
      isMoreWithdrawalHistoryLoading.value = true;
    } else {
      isWithdrawalHistoryLoading.value = true;
    }
    withdrawalHistoryError.value = null;

    try {
      final response = await _walletServices.fetchWithdrawalHistory(
        accessToken: accessToken,
        skip: skip,
        limit: limit,
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        final body = response.responseData as Map<String, dynamic>;
        final items = body['data'];
        if (items is List) {
          final fetchedItems = List<Map<String, dynamic>>.from(items);
          fetchedItems.sort((a, b) {
            final aDate = _parseDateTime(a['created_at']);
            final bDate = _parseDateTime(b['created_at']);
            return bDate.compareTo(aDate); // latest first
          });
          if (append) {
            withdrawalHistory.addAll(fetchedItems);
          } else {
            withdrawalHistory.assignAll(fetchedItems);
          }
        } else {
          withdrawalHistory.clear();
        }
        withdrawalHistoryCount.value = (body['count'] as num?)?.toInt();
      } else {
        withdrawalHistory.clear();
        withdrawalHistoryCount.value = 0;
        withdrawalHistoryError.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Unable to load withdrawal history.';
      }
    } catch (_) {
      withdrawalHistory.clear();
      withdrawalHistoryCount.value = 0;
      withdrawalHistoryError.value = 'Unable to load withdrawal history.';
    } finally {
      isWithdrawalHistoryLoading.value = false;
      isMoreWithdrawalHistoryLoading.value = false;
    }
  }

  Future<void> loadMoreWithdrawalHistory({int limit = 20}) async {
    if (isWithdrawalHistoryLoading.value ||
        isMoreWithdrawalHistoryLoading.value ||
        !canLoadMoreWithdrawals) {
      return;
    }
    await fetchWithdrawalHistory(
      skip: withdrawalHistory.length,
      limit: limit,
      append: true,
    );
  }

  DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    if (value is num) {
      // Assume milliseconds since epoch
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  Future<void> refreshCurrentPeriod() async {
    if (!_isVerified) {
      return;
    }
    await Future.wait([
      fetchWalletSummary(periodOverride: _currentPeriod),
      fetchPerformanceData(),
      fetchLeaderboardData(),
      fetchMonthlyForecast(),
      fetchBonusProgress(),
    ]);
  }

  WalletSummary? get _summary => walletSummary.value;

  WalletForecast? get _activeForecast =>
      monthlyForecast.value ?? _summary?.forecast;

  String get finalEarningsText =>
      _summary == null ? '₹0' : formatCurrency(_summary!.finalEarnings);

  String get balanceSubtitle {
    final summary = _summary;
    if (summary == null) {
      return 'Latest payout details will appear here';
    }
    return 'Subtotal ${formatCurrency(summary.subtotal)} • Top up ${formatCurrency(summary.topUp)}';
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
    final forecast = _activeForecast;
    if (forecast == null) return '--';
    final safePercentage = forecast.percentage;
    final displayPercentage = safePercentage == 0
        ? '0%'
        : '${safePercentage.toStringAsFixed(0)}%';
    return '${formatCurrency(forecast.current)} / ${formatCurrency(forecast.target)} ($displayPercentage)';
  }

  String get bonusDeliveriesText => _summary?.bonusDeliveries ?? '--';

  String get bonusAcceptanceText => _summary?.bonusAcceptance ?? '--';

  String get bonusOnTimeText => _summary?.bonusOnTime ?? '--';

  String get forecastProjectedAmountText {
    final forecast = _activeForecast;
    if (forecast == null) {
      return 'On track for: --';
    }
    return 'On track for: ${formatCurrency(forecast.target)}';
  }

  String get forecastBasisNoteText {
    final forecast = _activeForecast;
    if (forecast == null) {
      return '(Based on current pace)';
    }
    return 'Remaining deliveries: ${_formatCount(forecast.remainingDeliveries)}';
  }

  double get forecastCurrentValue => _activeForecast?.current ?? 0;

  double get _rawForecastTarget => _activeForecast?.target ?? 0;

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
    return formatCurrency(value);
  }

  String formatCurrency(double value) {
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

  /// Fetch all rider stats
  Future<void> fetchAllStats() async {
    if (!_isVerified) {
      return;
    }
    try {
      isAllStatsLoading.value = true;
      allStatsError.value = null;
      
      final accessToken = StorageService.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        allStatsError.value = 'Missing access token';
        return;
      }

      final response = await _walletServices.fetchRiderStats(
        accessToken: accessToken,
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        allStats.value = response.responseData as Map<String, dynamic>;
        allStatsError.value = null;
      } else {
        allStatsError.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Unable to fetch stats';
      }
    } catch (e) {
      allStatsError.value = 'Error fetching stats: $e';
    } finally {
      isAllStatsLoading.value = false;
    }
  }

  /// Fetch weekly rider stats
  Future<void> fetchWeeklyStats() async {
    if (!_isVerified) {
      return;
    }
    try {
      isWeeklyStatsLoading.value = true;
      weeklyStatsError.value = null;
      
      final accessToken = StorageService.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        weeklyStatsError.value = 'Missing access token';
        return;
      }

      final response = await _walletServices.fetchWeeklyStats(
        accessToken: accessToken,
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        weeklyStats.value = response.responseData as Map<String, dynamic>;
        weeklyStatsError.value = null;
      } else {
        weeklyStatsError.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Unable to fetch weekly stats';
      }
    } catch (e) {
      weeklyStatsError.value = 'Error fetching weekly stats: $e';
    } finally {
      isWeeklyStatsLoading.value = false;
    }
  }

  /// Fetch monthly rider stats
  Future<void> fetchMonthlyStats() async {
    if (!_isVerified) {
      return;
    }
    try {
      isMonthlyStatsLoading.value = true;
      monthlyStatsError.value = null;
      
      final accessToken = StorageService.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        monthlyStatsError.value = 'Missing access token';
        return;
      }

      final response = await _walletServices.fetchMonthlyStats(
        accessToken: accessToken,
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        monthlyStats.value = response.responseData as Map<String, dynamic>;
        monthlyStatsError.value = null;
      } else {
        monthlyStatsError.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Unable to fetch monthly stats';
      }
    } catch (e) {
      monthlyStatsError.value = 'Error fetching monthly stats: $e';
    } finally {
      isMonthlyStatsLoading.value = false;
    }
  }

  /// Fetch annual/yearly rider stats
  Future<void> fetchAnnualStats() async {
    if (!_isVerified) {
      return;
    }
    try {
      isAnnualStatsLoading.value = true;
      annualStatsError.value = null;
      
      final accessToken = StorageService.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        annualStatsError.value = 'Missing access token';
        return;
      }

      final response = await _walletServices.fetchAnnualStats(
        accessToken: accessToken,
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        annualStats.value = response.responseData as Map<String, dynamic>;
        annualStatsError.value = null;
      } else {
        annualStatsError.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Unable to fetch annual stats';
      }
    } catch (e) {
      annualStatsError.value = 'Error fetching annual stats: $e';
    } finally {
      isAnnualStatsLoading.value = false;
    }
  }

  Future<void> fetchBonusProgress() async {
    if (!_isVerified) {
      return;
    }
    try {
      isBonusProgressLoading.value = true;
      bonusProgressError.value = null;
      
      final accessToken = StorageService.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        bonusProgressError.value = 'Missing access token';
        return;
      }

      final response = await _walletServices.fetchBonusProgress(
        accessToken: accessToken,
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        bonusProgress.value = response.responseData as Map<String, dynamic>;
        bonusProgressError.value = null;
      } else {
        bonusProgressError.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Unable to fetch bonus progress';
      }
    } catch (e) {
      bonusProgressError.value = 'Error fetching bonus progress: $e';
    } finally {
      isBonusProgressLoading.value = false;
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    _verificationWorker?.dispose();
    super.onClose();
  }

  void toggleOnlineStatus() => isOnline.toggle();
}
