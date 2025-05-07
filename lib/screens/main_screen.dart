import 'package:flutter/material.dart';
import 'package:heafit/constants/theme.dart';
import 'package:heafit/screens/home_screen.dart';
import 'package:heafit/screens/category_screen.dart';
import 'package:heafit/screens/calendar_screen.dart';
import 'package:heafit/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  // 홈 화면의 알림창 표시 여부
  bool _showingNotifications = false;

  // 각 탭에 해당하는 화면들
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    // HomeScreen에서 알림 표시 상태가 변경될 때 콜백 함수를 전달
    _screens = [
      HomeScreen(
        onNotificationStateChanged: (isShowing) {
          setState(() {
            _showingNotifications = isShowing;
          });
        },
      ),
      const CategoryScreen(),
      const CalendarScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    // 현재 페이지와 새 페이지가 같으면 아무 동작하지 않음
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });

    // 페이지 전환에 애니메이션 추가
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 테마 색상 가져오기
    final primaryColor = Theme.of(context).primaryColor;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
        physics: const NeverScrollableScrollPhysics(), // 스와이프로 페이지 전환 비활성화
      ),
      // 알림창이 표시 중이면 하단 네비게이션 바를 숨김
      bottomNavigationBar:
          _showingNotifications
              ? null
              : Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(0, Icons.home_outlined, Icons.home, '홈'),
                        _buildNavItem(
                          1,
                          Icons.category_outlined,
                          Icons.category,
                          '카테고리',
                        ),
                        _buildNavItem(
                          2,
                          Icons.calendar_month_outlined,
                          Icons.calendar_month,
                          '일정',
                        ),
                        _buildNavItem(
                          3,
                          Icons.settings_outlined,
                          Icons.settings,
                          '설정',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  // 네비게이션 아이템 위젯
  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final bool isSelected = _currentIndex == index;
    final primaryColor = Theme.of(context).primaryColor;
    final Color textColor = isSelected ? primaryColor : Colors.grey;

    return InkWell(
      onTap: () => _onTabTapped(index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘
            Icon(isSelected ? activeIcon : icon, color: textColor, size: 24),
            const SizedBox(height: 4),
            // 라벨
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
