import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:quikle_rider/app.dart';
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await StorageService.init();

  runApp(const MyApp());
}
