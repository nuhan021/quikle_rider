import 'package:get/get.dart';
import 'package:quikle_rider/features/all_orders/presentation/screen/all_orders.dart';
import 'package:quikle_rider/features/bottom_nav_bar/screen/bottom_nav_bar.dart';
import 'package:quikle_rider/features/home/presentation/screen/homepage.dart';
import '../features/splash_screen/presentation/screens/splash_screen.dart';
import '../features/authentication/presentation/screens/login_screen.dart';
import '../features/authentication/presentation/screens/login_otp.dart';
import '../features/authentication/presentation/screens/create_account.dart';
import '../features/welcomescreen/welcomescreen.dart';
import '../features/map/map.dart';
import '../features/categories/categories.dart';
import '../features/profile/profile.dart';

class AppRoute {
  // Route names
  static String splashScreen = "/splashScreen";
  static String loginScreen = "/loginScreen";
  static String loginOtp = "/loginOtp";
  static String createAccount = "/createAccount";
  static String welcomeScreen = "/welcomeScreen";
  static String bottomNavBar = "/bottomNavBar";
  static String homePage = "/homePage";
  static String allOrders = "/allOrders";
  static String mapPage = "/mapPage";
  static String categories = "/categories";
  static String profilePage = "/profilePage";

  // Route getters
  static String getSplashScreen() => splashScreen;
  static String getLoginScreen() => loginScreen;
  static String getLoginOtp() => loginOtp;
  static String getCreateAccount() => createAccount;
  static String getWelcomeScreen() => welcomeScreen;
  static String getBottomNavBar() => bottomNavBar;
  static String getHomePage() => homePage;
  static String getAllOrders() => allOrders;
  static String getMapPage() => mapPage;
  static String getCategories() => categories;
  static String getProfilePage() => profilePage;

  // Routes list
  static List<GetPage> routes = [
    GetPage(name: splashScreen, page: () => SplashScreen()),
    GetPage(name: loginScreen, page: () => const LoginScreen()),
    GetPage(name: loginOtp, page: () => const LoginOtp()),
    GetPage(name: createAccount, page: () => const CreateAccount()),
    GetPage(name: welcomeScreen, page: () => const WelcomeScreen()),
    GetPage(name: bottomNavBar, page: () => const BottomNavBar()),
    GetPage(name: homePage, page: () => const HomePage()),
    GetPage(name: allOrders, page: () => const AllOrders()),
    GetPage(name: mapPage, page: () => const MapPage()),
    GetPage(name: categories, page: () => const Categories()),
    GetPage(name: profilePage, page: () => const ProfilePage()),
  ];
}
