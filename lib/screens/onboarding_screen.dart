import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heafit/constants/theme.dart';
import 'package:heafit/screens/main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // 온보딩 데이터
  final List<Map<String, String>> _onboardingData = [
    {
      'title': '다양한 혜택 정보',
      'description': '일상 속 다양한 혜택과 할인 정보를 한눈에 확인하세요.',
      'image': 'assets/logo/heafit-logo.png',
    },
    {
      'title': 'AI 맞춤형 스케줄 관리',
      'description': 'AI가 당신의 일정에 맞는 혜택을 추천해 드려요.',
      'image': 'assets/logo/heafit-logo.png',
    },
    {
      'title': '혜택 기록 및 분석',
      'description': '사용한 혜택을 기록하고 얼마나 절약했는지 확인하세요.',
      'image': 'assets/logo/heafit-logo.png',
    },
    {
      'title': '일상 속 자연스러운 사용',
      'description': '어떤 상황에서도 쉽게 이용할 수 있는 직관적인 경험을 제공합니다.',
      'image': 'assets/logo/heafit-logo.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 로고 영역
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 로고
                  Image.asset(
                    'assets/logo/heafit-logo.png',
                    width: 60,
                    height: 60,
                  ),
                ],
              ),
            ),

            // 온보딩 콘텐츠
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(
                    _onboardingData[index]['title']!,
                    _onboardingData[index]['description']!,
                    _onboardingData[index]['image']!,
                  );
                },
              ),
            ),

            // 페이지 인디케이터와 버튼 영역
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  // 페이지 인디케이터
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => _buildDotIndicator(index),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 하단 버튼들 (Skip과 Next/Start)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip 버튼 (왼쪽 하단)
                      TextButton(
                        onPressed: () => _goToMainScreen(),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Color(0xFFFF7043),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // 다음/시작 버튼 (오른쪽 하단)
                      ElevatedButton(
                        onPressed: () {
                          if (_currentPage == _onboardingData.length - 1) {
                            _goToMainScreen();
                          } else {
                            _pageController.animateToPage(
                              _currentPage + 1,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7043),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          minimumSize: Size.zero,
                        ),
                        child: Text(
                          _currentPage == _onboardingData.length - 1
                              ? '시작하기'
                              : '다음',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 온보딩 페이지 위젯
  Widget _buildOnboardingPage(
    String title,
    String description,
    String imagePath,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 이미지
        Container(
          height: 300,
          width: 300,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 40),

        // 제목
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 20),

        // 설명
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // 페이지 인디케이터 점
  Widget _buildDotIndicator(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: _currentPage == index ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color:
            _currentPage == index
                ? const Color(0xFFFF7043)
                : Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // 메인 화면으로 이동
  void _goToMainScreen() {
    Get.off(() => const MainScreen());
  }
}
