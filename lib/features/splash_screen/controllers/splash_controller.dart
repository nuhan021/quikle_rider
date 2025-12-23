import 'dart:async';
import 'package:get/get.dart';
import 'package:quikle_rider/core/services/firebase/notification_service.dart';
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/core/utils/logging/logger.dart';
import 'package:quikle_rider/features/profile/presentation/controller/profile_controller.dart';
import 'package:quikle_rider/routes/app_routes.dart';
import 'package:video_player/video_player.dart';

class SplashController extends GetxController {
  late final VideoPlayerController video;
  final RxBool isReady = false.obs;
  final RxBool shouldShrink = false.obs;

  static const double _ellipseTopIdle = 812.0;
  static const double _ellipseTopPlaying = 666.0;
  final RxDouble ellipseTop = _ellipseTopIdle.obs;
  final RxBool showEllipse = false.obs;
  final RxBool showLogin = false.obs;

  final Duration shrinkDelay = const Duration(milliseconds: 20);
  final Duration ellipseTriggerAt = const Duration(seconds: 2);
  final Duration playDuration = const Duration(seconds: 3);
  bool _ellipseMoved = false;

  //put controller
  final ProfileController profileController = Get.put(
    ProfileController(),
    permanent: true,
  );

  @override
  void onInit() {
    super.onInit();
    _initVideo();
  }

  Future<void> _initVideo() async {
    video = VideoPlayerController.asset('assets/videos/splash_intro.mp4');
    await video.initialize();
    // await video.setPlaybackSpeed(0.1);
    await video.setVolume(0);
    await video.play();
    isReady.value = true;

    Future.delayed(shrinkDelay, () {
      shouldShrink.value = true;
    });

    video.addListener(_progressWatcher);
    video.addListener(_listenDuration);
  }

  void _progressWatcher() {
    final v = video.value;
    if (!_ellipseMoved && v.isInitialized && v.position >= ellipseTriggerAt) {
      _ellipseMoved = true;
      startEllipseAnimation();
      video.removeListener(_progressWatcher);
    }
  }

  void startEllipseAnimation() {
    showEllipse.value = true;
    ellipseTop.value = _ellipseTopPlaying;
  }

  void _listenDuration() {
    final v = video.value;
    if (v.isInitialized && v.position >= playDuration) {
      video.pause();
      AppLoggerHelper.debug('has token ${StorageService.tokenType}');
      _handleNavigation();

      video.removeListener(_listenDuration);
    }
  }

  void _handleNavigation() {
    final bool hasToken = StorageService.accessToken != null;
    final bool isVerified = profileController.isVerified.value == true;
    final bool isDocumentUploaded =
        profileController.isDocumentUploaded.value == true;

    if (hasToken && isVerified && isDocumentUploaded) {
      Get.offAllNamed(AppRoute.getBottomNavBar());
      AppLoggerHelper.debug(
        "documnets uploaded ${profileController.isDocumentUploaded.value}",
      );
      AppLoggerHelper.debug(
        "Profile verified ${profileController.isVerified.value}",
      );
      AppLoggerHelper.debug(
        "is doocument uploaded ${profileController.isDocumentUploaded.value}",
      );
      AppLoggerHelper.debug(
        "Navigating to Home ${profileController.isDocumentUploaded.value}",
      );
      return;
    } else if (hasToken && isVerified ==false) {
      Get.offAllNamed(AppRoute.uploaddocuments);
    } else {
      Get.offAllNamed(AppRoute.loginScreen);
    }
    // if (hasToken) {
    //   Get.offAllNamed(AppRoute.uploaddocuments);
    //   return;
    // }
  }

  @override
  void onClose() {
    video.removeListener(_progressWatcher);
    video.removeListener(_listenDuration);
    video.dispose();
    super.onClose();
  }
}
