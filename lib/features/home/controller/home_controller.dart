import 'package:get/get.dart';
import 'package:quikle_rider/features/home/model/home_model.dart';
import 'package:quikle_rider/features/home/presentation/screen/goonline.dart';
import 'package:quikle_rider/features/home/presentation/screen/gooffline.dart';
import 'package:quikle_rider/features/home/presentation/screen/ask_order.dart';
import 'package:quikle_rider/features/home/presentation/screen/ask_cancel.dart';
import 'package:quikle_rider/features/home/presentation/screen/order_accepted.dart';
import 'package:quikle_rider/features/home/presentation/screen/order_cancel.dart';

class HomeController extends GetxController {
  // Observable data
  final _homeModel = const HomeModel(
    isOnline: false,
    assignments: [],
    stats: StatsModel(
      todayDeliveries: '5',
      weekDeliveries: '32',
      rating: '4.8',
    ),
  ).obs;

  // Getters
  HomeModel get homeModel => _homeModel.value;
  bool get isOnline => _homeModel.value.isOnline;
  List<AssignmentModel> get assignments => _homeModel.value.assignments;
  StatsModel get stats => _homeModel.value.stats;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Load sample assignments
    final sampleAssignments = [
      const AssignmentModel(
        orderId: '#5678',
        customerName: 'Aanya Desai',
        arrivalTime: 'Arrives by 4:00 PM',
        address: '456 Oak Ave, Downtown',
        distance: '2.1 mile',
        total: '\$24.00',
        isUrgent: true,
        isCombined: true,
      ),
      const AssignmentModel(
        orderId: '#5679',
        customerName: 'Aanya Desai',
        arrivalTime: 'Arrives by 4:00 PM',
        address: '456 Oak Ave, Downtown',
        distance: '2.1 mile',
        total: '\$24.00',
        isUrgent: false,
        isCombined: false,
      ),
    ];

    _homeModel.value = _homeModel.value.copyWith(
      assignments: sampleAssignments,
    );
  }

  // Toggle online/offline status
  Future<void> onToggleSwitch() async {
    if (!isOnline) {
      // Show go online dialog
      final result = await Get.to(
        () => const GoOnlinePage(),
        opaque: false,
        fullscreenDialog: true,
        transition: Transition.fade,
      );
      if (result == true) {
        _updateOnlineStatus(true);
      }
    } else {
      // Show go offline dialog
      final result = await Get.to(
        () => const GoOfflinePage(),
        opaque: false,
        fullscreenDialog: true,
        transition: Transition.fade,
      );
      if (result == true) {
        _updateOnlineStatus(false);
      }
    }
  }

  void _updateOnlineStatus(bool status) {
    _homeModel.value = _homeModel.value.copyWith(isOnline: status);
  }

  // Handle order acceptance
  Future<void> onAcceptOrder(AssignmentModel assignment) async {
    // Navigate to AskOrderPage
    final result = await Get.to(
      () => const AskOrderPage(),
      opaque: false,
      fullscreenDialog: true,
      transition: Transition.fade,
    );
    if (result == true) {
      // Navigate to OrderAcceptedPage
      await Get.to(
        () => const OrderAcceptedPage(),
        opaque: false,
        fullscreenDialog: true,
        transition: Transition.fade,
      );
      // Remove assignment from list after acceptance
      _removeAssignment(assignment);
    }
  }

  // Handle order rejection
  Future<void> onRejectOrder(AssignmentModel assignment) async {
    // Navigate to AskCancelPage
    final result = await Get.to(
      () => const AskCancelPage(),
      opaque: false,
      fullscreenDialog: true,
      transition: Transition.fade,
    );
    if (result == true) {
      // Navigate to OrderCancelPage
      await Get.to(
        () => const OrderCancelPage(),
        opaque: false,
        fullscreenDialog: true,
        transition: Transition.fade,
      );
      // Remove assignment from list after rejection
      _removeAssignment(assignment);
    }
  }

  void _removeAssignment(AssignmentModel assignment) {
    final updatedAssignments = List<AssignmentModel>.from(assignments);
    updatedAssignments.removeWhere(
      (item) => item.orderId == assignment.orderId,
    );
    _homeModel.value = _homeModel.value.copyWith(
      assignments: updatedAssignments,
    );
  }

  // Update stats (can be called from external sources)
  void updateStats({
    String? todayDeliveries,
    String? weekDeliveries,
    String? rating,
  }) {
    final updatedStats = stats.copyWith(
      todayDeliveries: todayDeliveries,
      weekDeliveries: weekDeliveries,
      rating: rating,
    );
    _homeModel.value = _homeModel.value.copyWith(stats: updatedStats);
  }

  // Add new assignment (can be called when new orders arrive)
  void addAssignment(AssignmentModel assignment) {
    final updatedAssignments = List<AssignmentModel>.from(assignments);
    updatedAssignments.add(assignment);
    _homeModel.value = _homeModel.value.copyWith(
      assignments: updatedAssignments,
    );
  }
}
