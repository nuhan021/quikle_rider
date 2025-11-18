import 'package:flutter/material.dart';
import 'package:quikle_rider/app.dart';
import 'package:quikle_rider/core/services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  runApp(const MyApp());
}
