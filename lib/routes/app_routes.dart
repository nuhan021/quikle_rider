import 'package:get/get.dart';
import 'package:quikle_rider/features/all_orders/presentation/screen/all_orders.dart';
import 'package:quikle_rider/features/bottom_nav_bar/screen/bottom_nav_bar.dart';
import 'package:quikle_rider/features/home/presentation/screen/homepage.dart';
import '../features/splash_screen/presentation/screens/splash_screen.dart';
import '../features/authentication/presentation/screens/login_screen.dart';
import '../features/authentication/presentation/screens/login_otp.dart';
import '../features/authentication/presentation/screens/create_account.dart';
import '../features/welcomescreen/presentation/screens/welcomescreen.dart';
import '../features/map/presentation/screen/map.dart';
import '../features/wallet/presentation/screen/wallet.dart';
import '../features/profile/presentation/screen/profile.dart';

class AppRoute {
  // Route names
  static String splashScreen = "/splashScreen";
  static String loginScreen = "/loginScreen";
  static String loginOtp = "/loginOtp";
  static String createAccount = "/createAccount";
  static String welcomeScreen = "/welcomeScreen";
  static String bottomNavBar = "/bottomNavBar";
  static String homeScreen = "/homeScreen";
  static String allOrders = "/allOrders";
  static String mapScreen = "/mapScreen";
  static String walletScreen = "/walletScreen";
  static String profileScreen = "/profileScreen";

  // Route getters
  static String getSplashScreen() => splashScreen;
  static String getLoginScreen() => loginScreen;
  static String getLoginOtp() => loginOtp;
  static String getCreateAccount() => createAccount;
  static String getWelcomeScreen() => welcomeScreen;
  static String getBottomNavBar() => bottomNavBar;
  static String getHomeScreen() => homeScreen;
  static String getAllOrders() => allOrders;
  static String getMapScreen() => mapScreen;
  static String getWalletScreen() => walletScreen;
  static String getProfileScreen() => profileScreen;

  // Routes list
  static List<GetPage> routes = [
    GetPage(name: splashScreen, page: () => SplashScreen()),
    GetPage(name: loginScreen, page: () => const LoginScreen()),
    GetPage(name: loginOtp, page: () => const LoginOtp()),
    GetPage(name: createAccount, page: () => const CreateAccount()),
    GetPage(name: welcomeScreen, page: () => const WelcomeScreen()),
    GetPage(name: bottomNavBar, page: () => const BottomNavBar()),
    GetPage(name: homeScreen, page: () => const HomeScreen()),
    GetPage(name: allOrders, page: () => const AllOrders()),
    GetPage(name: mapScreen, page: () => const MapScreen()),
    GetPage(name: walletScreen, page: () => const WalletScreen()),
    GetPage(name: profileScreen, page: () => const ProfileScreen()),
  ];
}
