import 'package:get/get.dart';

class LanguageController extends GetxController {
  final List<String> languages = const [
    'English',
    'Spanish',
    'French',
    'German',
  ];

  late final RxString selectedLanguage = languages.first.obs;

  void setLanguage(String value) {
    if (!languages.contains(value)) return;
    selectedLanguage.value = value;
  }

  void clearForLogout() {
    selectedLanguage.value = languages.first;
  }
}
