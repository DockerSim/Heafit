import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:heafit/screens/splash_screen.dart';
import 'package:heafit/constants/theme.dart';
import 'package:heafit/services/google_auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화
  await Hive.initFlutter();

  // Google Auth Service 초기화
  final googleAuthService = GoogleAuthService();
  await googleAuthService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Heafit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // 항상 라이트 테마 적용
      home: const SplashScreen(),
    );
  }
}
