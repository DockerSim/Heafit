import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:heafit/screens/main_screen.dart';
import 'package:heafit/constants/theme.dart';
import 'package:heafit/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isFirstLaunch = true;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();

    // 앱 최초 실행 여부 확인
    _checkFirstLaunch();

    // 3초 후 다음 화면으로 이동
    Timer(const Duration(seconds: 3), () {
      if (_isFirstLaunch) {
        Get.off(() => const OnboardingScreen());
      } else {
        Get.off(() => const MainScreen());
      }
    });
  }

  // 최초 실행 여부 확인
  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;

    setState(() {
      _isFirstLaunch = isFirstLaunch;
    });

    // 첫 실행이 아님을 저장
    if (isFirstLaunch) {
      await prefs.setBool('is_first_launch', false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // 연한 베이지색 배경
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Heafit 로고 이미지 애니메이션 적용
                  Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF7043).withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/logo/heafit-logo.png',
                          width: 180,
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 앱 이름
                  Opacity(
                    opacity: _fadeAnimation.value,
                    child: const Text(
                      'Heafit',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF7043), // 주황색 텍스트
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // 로딩 인디케이터
                  Opacity(
                    opacity: _fadeAnimation.value,
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFFF7043),
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 로딩 텍스트
                  Opacity(
                    opacity: _fadeAnimation.value,
                    child: const Text(
                      'LOADING',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 안내 문구
                  Opacity(
                    opacity: _fadeAnimation.value,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        '캘린더를 연동하여 나만을 위한 혜택을 찾아보세요!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ),

                  const Spacer(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
