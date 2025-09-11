import 'package:get/get.dart';
import 'package:flutter/material.dart';

class BottomNavbarController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  // Navigation items configuration
  List<NavItem> get navItems => [
    NavItem(
      icon: 'assets/icons/home.png',
      label: 'Home',
      fallbackIcon: Icons.home,
    ),
    NavItem(
      icon: 'assets/icons/ordericon.png',
      label: 'All Orders', 
      fallbackIcon: Icons.receipt_long,
    ),
    NavItem(
      icon: 'assets/icons/map.png',
      label: 'Map',
      fallbackIcon: Icons.map,
    ),
    NavItem(
      icon: 'assets/icons/wallet.png',
      label: 'Wallet',
      fallbackIcon: Icons.wallet,
    ),
    NavItem(
      icon: 'assets/icons/profile.png',
      label: 'Aanya',
      fallbackIcon: Icons.person,
      isProfile: true,
    ),
  ];
}

class NavItem {
  final String icon;
  final String label;
  final IconData fallbackIcon;
  final bool isProfile;

  NavItem({
    required this.icon,
    required this.label,
    required this.fallbackIcon,
    this.isProfile = false,
  });
}
