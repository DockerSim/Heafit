import 'package:flutter/material.dart';
import 'package:heafit/constants/theme.dart';
import 'package:heafit/screens/home_screen.dart';
import 'package:heafit/screens/category_screen.dart';
import 'package:heafit/screens/calendar_screen.dart';
import 'package:heafit/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  // 알림창 표시 여부
  bool _showingNotifications = false;

  // 각 탭에 해당하는 화면들
  late final List<Widget> _screens;

  // 알림 데이터
  final List<Map<String, dynamic>> _notifications = [
    {
      'type': '혜택 사용 여부',
      'title': '일정에 담아두신 혜택을 사용하셨나요?',
      'description':
          '일정에 담아두신 혜택에 대한 사용 여부를 알려주세요!\nHeafit이 캘린더에 확인하기 쉽게 정리해드릴게요!',
      'icon': 'assets/logo/heafit-logo2.png',
      'days_ago': '1일 전',
      'discount_amount': 2500.0,
      'benefit_name': '버거킹 할인 혜택',
    },
    {
      'type': '일정 변경 제안',
      'title': '일정을 변경해보는 건 어떨까요?',
      'description':
          '5일에 예정되어 있던 버거킹 일정을 12일로 바꾸는 건 어떨까요? 12일부터 버거킹의 와퍼 소고기 버거를 2,500원 할인해주는 행사가 있어요!',
      'icon': 'assets/logo/heafit-logo2.png',
      'days_ago': '3일 전',
      'from_date': 5,
      'to_date': 12,
    },
    {
      'type': '일정 변경 제안',
      'title': '일정을 변경해보는 건 어떨까요?',
      'description':
          '5일에 예정되어 있던 버거킹 일정을 12일로 바꾸는 건 어떨까요? 12일부터 버거킹의 와퍼 소고기 버거를 2,500원 할인해주는 행사가 있어요!',
      'icon': 'assets/logo/heafit-logo2.png',
      'days_ago': '4일 전',
      'from_date': 5,
      'to_date': 12,
    },
    {
      'type': '관심 카테고리 혜택',
      'title': '마감일이 다가와요!',
      'description': '버거킹의 와퍼 소고기 버거를 2,500원 할인된 가격으로 만나보세요!',
      'icon': 'assets/logo/heafit-logo2.png',
      'days_ago': '10일 전',
      'category': '음식',
    },
  ];

  // 선택된 알림 인덱스
  int? _selectedNotificationIndex;

  // 사용 여부 버튼 표시 여부
  bool _showUsageButtons = false;

  // 혜택 사용 여부 처리
  void _handleBenefitUsage(bool used) {
    if (_selectedNotificationIndex == null) return;

    // 사용함을 선택한 경우 아낀 금액에 반영 (여기서는 표시만 해주고 실제 로직은 연결하지 않음)
    if (used) {
      // 사용 완료 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_notifications[_selectedNotificationIndex!]['benefit_name']} 사용이 완료되었습니다!',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // 알림 제거 및 상태 초기화
    setState(() {
      _notifications.removeAt(_selectedNotificationIndex!);
      _selectedNotificationIndex = null;
      _showUsageButtons = false;
    });
  }

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
      CategoryScreen(
        onNotificationStateChanged: (isShowing) {
          setState(() {
            _showingNotifications = isShowing;
          });
        },
      ),
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

  // 알림 화면 토글 처리
  void _toggleNotifications() {
    setState(() {
      _showingNotifications = !_showingNotifications;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 테마 색상 가져오기
    final primaryColor = Theme.of(context).primaryColor;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo/heafit-logo2.png', width: 100, height: 50),
            const Spacer(),
            IconButton(
              icon: const Icon(
                Icons.notifications_none,
                size: 28,
                color: Colors.black,
              ),
              onPressed: _toggleNotifications,
            ),
          ],
        ),
        leadingWidth: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          _showingNotifications
              ? _buildNotificationScreen()
              : PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                physics: const NeverScrollableScrollPhysics(),
                children: _screens, // 스와이프로 페이지 전환 비활성화
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

  // 알림 화면 구현
  Widget _buildNotificationScreen() {
    return ListView.separated(
      itemCount: _notifications.length,
      separatorBuilder:
          (context, index) => Divider(
            height: 1,
            color: const Color(0xFFECECEC),
            thickness: 1,
            indent: 7,
            endIndent: 7,
          ),
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        final isUsageType = notification['type'] == '혜택 사용 여부';
        final isSelected = _selectedNotificationIndex == index;

        return GestureDetector(
          onTap: () {
            // 혜택 사용 여부 알림인 경우 버튼 표시
            if (isUsageType) {
              setState(() {
                if (_selectedNotificationIndex == index) {
                  // 이미 선택된 알림을 다시 누르면 버튼 토글
                  _showUsageButtons = !_showUsageButtons;
                } else {
                  // 다른 알림을 선택하면 해당 알림으로 변경하고 버튼 표시
                  _selectedNotificationIndex = index;
                  _showUsageButtons = true;
                }
              });
            }
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      child: ClipOval(
                        child: Image.asset(
                          notification['icon'],
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                notification['type'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                notification['days_ago'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            notification['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            notification['description'],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 혜택 사용 여부 버튼 (선택된 경우에만 표시)
              if (isUsageType && isSelected && _showUsageButtons)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // "사용했어요" 버튼
                      SizedBox(
                        width: 120,
                        child: ElevatedButton(
                          onPressed: () => _handleBenefitUsage(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('사용했어요'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // "사용 안했어요" 버튼
                      SizedBox(
                        width: 120,
                        child: OutlinedButton(
                          onPressed: () => _handleBenefitUsage(false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey,
                            side: const BorderSide(color: Colors.grey),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('사용 안했어요'),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
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
