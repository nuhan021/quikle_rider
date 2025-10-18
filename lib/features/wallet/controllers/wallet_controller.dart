import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

class WalletController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  var isOnline = true.obs;

  // Data for different periods
  final _allDeliveries = <DeliveryItem>[
    const DeliveryItem(id: '1023', status: DeliveryStatus.delivered, amount: '\$12.50', customer: 'John Doe', dateTime: 'Sep 8, 2025 10:15 AM', distance: '2.1 miles', rightSubline: '+\$1.50 tip'),
    const DeliveryItem(id: '1022', status: DeliveryStatus.cancelled, amount: '\$0.00', customer: 'Jane Smith', dateTime: 'Sep 7, 2025 4:20 PM', distance: '—', bottomNote: 'Customer cancelled'),
    const DeliveryItem(id: '1021', status: DeliveryStatus.delivered, amount: '\$8.20', customer: 'Alice Johnson', dateTime: 'Sep 6, 2025 1:05 PM', distance: '1.3 miles'),
  ].obs;

  final _weekDeliveries = <DeliveryItem>[
    const DeliveryItem(id: '1023', status: DeliveryStatus.delivered, amount: '\$12.50', customer: 'John Doe', dateTime: 'Sep 8, 2025 10:15 AM', distance: '2.1 miles', rightSubline: '+\$1.50 tip'),
  ].obs;

  final _monthDeliveries = <DeliveryItem>[
    const DeliveryItem(id: '1023', status: DeliveryStatus.delivered, amount: '\$12.50', customer: 'John Doe', dateTime: 'Sep 8, 2025 10:15 AM', distance: '2.1 miles', rightSubline: '+\$1.50 tip'),
    const DeliveryItem(id: '1022', status: DeliveryStatus.cancelled, amount: '\$0.00', customer: 'Jane Smith', dateTime: 'Sep 7, 2025 4:20 PM', distance: '—', bottomNote: 'Customer cancelled'),
  ].obs;

  final _yearDeliveries = <DeliveryItem>[
    const DeliveryItem(id: '1023', status: DeliveryStatus.delivered, amount: '\$12.50', customer: 'John Doe', dateTime: 'Sep 8, 2025 10:15 AM', distance: '2.1 miles', rightSubline: '+\$1.50 tip'),
    const DeliveryItem(id: '1022', status: DeliveryStatus.cancelled, amount: '\$0.00', customer: 'Jane Smith', dateTime: 'Sep 7, 2025 4:20 PM', distance: '—', bottomNote: 'Customer cancelled'),
    const DeliveryItem(id: '1021', status: DeliveryStatus.delivered, amount: '\$8.20', customer: 'Alice Johnson', dateTime: 'Sep 6, 2025 1:05 PM', distance: '1.3 miles'),
  ].obs;

  var deliveries = <DeliveryItem>[].obs;

  // Stats data
  var currentBalance = '\$459'.obs;
  var totalDeliveries = '42'.obs;
  var avgDeliveryTime = '18'.obs;
  var customerRating = '4.8'.obs;
  var completionRate = '98%'.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
    tabController.addListener(() {
      updateDataForPeriod(tabController.index);
    });
    // Initial data
    updateDataForPeriod(0);
  }

  void updateDataForPeriod(int index) {
    switch (index) {
      case 0: // All
        currentBalance.value = '\$459';
        totalDeliveries.value = '42';
        avgDeliveryTime.value = '18';
        customerRating.value = '4.8';
        completionRate.value = '98%';
        deliveries.value = _allDeliveries;
        break;
      case 1: // Week
        currentBalance.value = '\$120';
        totalDeliveries.value = '10';
        avgDeliveryTime.value = '15';
        customerRating.value = '4.9';
        completionRate.value = '100%';
        deliveries.value = _weekDeliveries;
        break;
      case 2: // Month
        currentBalance.value = '\$350';
        totalDeliveries.value = '30';
        avgDeliveryTime.value = '17';
        customerRating.value = '4.8';
        completionRate.value = '99%';
        deliveries.value = _monthDeliveries;
        break;
      case 3: // Year
        currentBalance.value = '\$2500';
        totalDeliveries.value = '200';
        avgDeliveryTime.value = '20';
        customerRating.value = '4.7';
        completionRate.value = '97%';
        deliveries.value = _yearDeliveries;
        break;
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void toggleOnlineStatus() => isOnline.toggle();
}
