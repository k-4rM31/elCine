import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/di/service_locator.dart';
import 'core/network/hive_boxes.dart';
import 'core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox(HiveBoxes.home);

  await setupServiceLocator();

  runApp(const ProviderScope(child: ElCineApp()));
}

class ElCineApp extends StatelessWidget {
  const ElCineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'el Cine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E14),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFCFFF04),
          brightness: Brightness.dark,
        ),
      ),
      routerConfig: appRouter,
    );
  }
}