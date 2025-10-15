import 'package:get/get.dart';
import 'package:quikle_rider/features/home/models/home_dashboard_models.dart';
import 'package:quikle_rider/features/home/presentation/screen/goonline.dart';
import 'package:quikle_rider/features/home/presentation/screen/gooffline.dart';

class HomepageController extends GetxController {
  var isOnline = false.obs;
  var isLoading = false.obs;
  final errorMessage = RxnString();
  final stats = <HomeStat>[].obs;
  final assignments = <Assignment>[].obs;
  final _pendingActions = <String>{}.obs;

  void onToggleSwitch() async {
    if (!isOnline.value) {
      final result = await Get.to(
        () => const GoOnlinePage(),
        opaque: false,
        fullscreenDialog: true,
        transition: Transition.fade,
      );
      if (result == true) {
        isOnline.value = true;
      }
    } else {
      final result = await Get.to(
        () => const GoOfflinePage(),
        opaque: false,
        fullscreenDialog: true,
        transition: Transition.fade,
      );
      if (result == true) {
        isOnline.value = false;
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final data = await _loadDashboardData();
      stats.assignAll(data.stats);
      assignments.assignAll(data.assignments);
    } catch (error) {
      errorMessage.value = 'Unable to load dashboard data. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<HomeDashboardData> _loadDashboardData() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return HomeDashboardData(
      stats: const [
        HomeStat(
          id: 'today-deliveries',
          title: 'Today',
          subtitle: 'Deliveries',
          value: 5,
        ),
        HomeStat(
          id: 'weekly-deliveries',
          title: 'This Week',
          subtitle: 'Deliveries',
          value: 32,
        ),
        HomeStat(
          id: 'rating',
          title: 'Rating',
          subtitle: 'Out of 5',
          value: 4.8,
        ),
      ],
      assignments: [
        Assignment(
          id: '#5678',
          customerName: 'Aanya Desai',
          expectedArrival: DateTime.now().add(const Duration(hours: 1)),
          address: '456 Oak Ave, Downtown',
          distanceInMiles: 2.1,
          totalAmount: 24.00,
          currency: '',
          isUrgent: true,
          isCombined: true,
        ),
      ],
    );
  }

  bool isAssignmentActionPending(String assignmentId) =>
      _pendingActions.contains(assignmentId);

  Future<bool> acceptAssignment(Assignment assignment) async {
    return _performAssignmentAction(
      assignmentId: assignment.id,
      action: () async {
        await Future.delayed(const Duration(milliseconds: 350));
        return true;
      },
    );
  }

  Future<bool> rejectAssignment(Assignment assignment) async {
    return _performAssignmentAction(
      assignmentId: assignment.id,
      action: () async {
        await Future.delayed(const Duration(milliseconds: 350));
        return true;
      },
    );
  }

  Future<bool> _performAssignmentAction({
    required String assignmentId,
    required Future<bool> Function() action,
  }) async {
    if (_pendingActions.contains(assignmentId)) return false;
    _pendingActions.add(assignmentId);
    try {
      final result = await action();
      return result;
    } finally {
      _pendingActions.remove(assignmentId);
    }
  }
}
