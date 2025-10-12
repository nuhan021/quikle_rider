import 'package:get/get.dart';
import 'package:flutter/material.dart';

class BottomNavbarController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  void changeIndex(int index) {
    // Ensure the index is within valid bounds (0 for Home, 1 for All Orders, 2 for Map, 3 for Wallet, 4 for Aanya)
    if (index >= 0 && index < navItems.length) {
      selectedIndex.value = index;
      print(
        'BottomNavbarController: Changed index to $index (${navItems[index].label})',
      );
    } else {
      print(
        'BottomNavbarController: Invalid index: $index. Must be between 0 and ${navItems.length - 1}',
      );
    }
  }

  List<NavItem> get navItems => [
    // Index 0: Home
    NavItem(
      icon: 'assets/icons/home.png',
      label: 'Home',
      fallbackIcon: Icons.home,
    ),
    // Index 1: All Orders
    NavItem(
      icon: 'assets/icons/ordericon.png',
      label: 'All Orders',
      fallbackIcon: Icons.receipt_long,
    ),
    // Index 2: Map
    NavItem(
      icon: 'assets/icons/map.png',
      label: 'Map',
      fallbackIcon: Icons.map,
    ),
    // Index 3: Wallet
    NavItem(
      icon: 'assets/icons/wallet.png',
      label: 'Wallet',
      fallbackIcon: Icons.wallet,
    ),
    // Index 4: Aanya (Profile)
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
