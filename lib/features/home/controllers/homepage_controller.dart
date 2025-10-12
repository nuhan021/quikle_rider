import 'package:get/get.dart';
import 'package:quikle_rider/features/home/presentation/screen/goonline.dart';
import 'package:quikle_rider/features/home/presentation/screen/gooffline.dart';
class HomepageController extends GetxController {
  var isOnline = false.obs;

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



  
}
