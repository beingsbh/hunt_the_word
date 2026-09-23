import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/audio/audio_haptic_service.dart';
import 'core/network/api_endpoints.dart';
import 'core/storage/hive_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveStorageService().init();
  AudioHapticService().init();
  await ApiEndpoints.init();
  runApp(const WordHuntApp());
}
