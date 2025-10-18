import 'package:get/get.dart';
import 'package:quikle_rider/features/authentication/controllers/auth_controller.dart';
import 'package:quikle_rider/features/bottom_nav_bar/controller/bottom_nav_bar_controller.dart';
import 'package:quikle_rider/features/home/controllers/homepage_controller.dart';
import 'package:quikle_rider/features/splash_screen/controllers/splash_controller.dart';
import 'package:quikle_rider/features/wallet/controllers/wallet_controller.dart';

class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(SplashController(), permanent: true);
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<HomepageController>(HomepageController(), permanent: true);
    Get.put<WalletController>(WalletController(), permanent: true);

    Get.put<BottomNavbarController>(BottomNavbarController());
  }
}
