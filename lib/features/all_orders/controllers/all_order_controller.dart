import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllOrdersController extends GetxController {
  RxBool isOnline = true.obs;
  late TabController tabController;
  RxInt selectedIndex = 0.obs;

  void toggleOnline() {
    isOnline.toggle();
  }

  void changeTab(int index) {
    tabController.animateTo(index);
    selectedIndex.value = index;
  }
}