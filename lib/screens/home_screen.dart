import 'package:flutter/material.dart';
import 'package:heafit/constants/theme.dart';
import 'package:heafit/widgets/benefit_card.dart';
import 'package:heafit/widgets/category_item.dart';
import 'package:heafit/widgets/section_title.dart';
import 'package:heafit/screens/statistics_screen.dart';
import 'package:heafit/screens/calendar_screen.dart';
import 'package:heafit/screens/category_screen.dart';

// 알림 상태 변경 콜백 타입 정의
typedef NotificationStateCallback = void Function(bool isShowing);

class HomeScreen extends StatefulWidget {
  // 알림 상태 변경 콜백
  final NotificationStateCallback? onNotificationStateChanged;

  const HomeScreen({super.key, this.onNotificationStateChanged});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  // 알림 화면 표시 여부
  bool _showNotifications = false;

  // 선택된 알림 인덱스 (알림 상세 UI 표시용)
  int? _selectedNotificationIndex;

  // 사용 여부 버튼 표시 여부
  bool _showUsageButtons = false;

  final PageController _pageController = PageController(
    viewportFraction: 0.85,
    initialPage: 0,
  );
  int _currentPage = 0;

  final List<Map<String, dynamic>> _benefits = [
    {
      'title': '스타벅스 50% 할인',
      'description': '신한카드로 결제 시 최대 5,000원 할인',
      'imageUrl': 'assets/logo/heafit-logo2.png',
      'period': '2023-05-01 ~ 2023-06-30',
      'discount': '-2,500원',
      'category': '음식',
      'subcategory': '카페',
    },
    {
      'title': '배달의민족 3,000원 할인',
      'description': '2만원 이상 주문 시 네이버페이 결제 할인',
      'imageUrl': 'assets/logo/heafit-logo2.png',
      'period': '2023-05-15 ~ 2023-05-31',
      'discount': '-3,000원',
      'category': '음식',
      'subcategory': '배달',
    },
    {
      'title': 'CGV 영화 1+1',
      'description': '토스로 결제 시 동반 1인 무료',
      'imageUrl': 'assets/logo/heafit-logo2.png',
      'period': '2023-05-10 ~ 2023-06-10',
      'discount': '-12,000원',
      'category': '엔터테인먼트',
      'subcategory': '영화',
    },
  ];

  final List<Map<String, dynamic>> _categories = [
    {'name': '음식', 'icon': Icons.restaurant},
    {'name': '쇼핑', 'icon': Icons.shopping_bag},
    {'name': '교통', 'icon': Icons.directions_car},
    {'name': '엔터테인먼트', 'icon': Icons.movie},
  ];

  final List<Map<String, dynamic>> _aiSuggestions = [
    {
      'title': '일정 변경 제안',
      'description':
          '5일에 예정되어 있던 버거킹 일정을 12일로 바꾸는 건 어떨까요? 12일부터 버거킹의 와퍼 소고기 버거를 2,500원 할인해주는 행사가 있어요!',
      'imageUrl': 'assets/logo/heafit-logo2.png',
      'days_ago': '3일 전',
      'from_date': 5,
      'to_date': 12,
    },
    {
      'title': '일정 변경 제안',
      'description':
          '5일에 예정되어 있던 버거킹 일정을 12일로 바꾸는 건 어떨까요? 12일부터 버거킹의 와퍼 소고기 버거를 2,500원 할인해주는 행사가 있어요!',
      'imageUrl': 'assets/logo/heafit-logo2.png',
      'days_ago': '4일 전',
      'from_date': 5,
      'to_date': 12,
    },
  ];

  // 절약한 금액
  double _savedAmount = 48500;

  final List<Map<String, dynamic>> _notifications = [
    {
      'type': '혜택 사용 여부',
      'title': '일정에 담아두신 혜택을 사용하셨나요?',
      'description':
          '일정에 담아두신 혜택에 대한 사용 여부를 알려주세요!\nBenefit plus가 캘린더에 확인하기 쉽게 정리해드릴게요!',
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

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // 알림 화면 표시 상태 설정 메서드
  void _setShowNotifications(bool value) {
    setState(() {
      _showNotifications = value;
      _selectedNotificationIndex = null;
      _showUsageButtons = false;
    });

    // 콜백 호출
    widget.onNotificationStateChanged?.call(value);
  }

  // 혜택 사용 여부 처리
  void _handleBenefitUsage(bool used) {
    if (_selectedNotificationIndex == null) return;

    // 사용함을 선택한 경우 아낀 금액에 반영
    if (used) {
      final discountAmount =
          _notifications[_selectedNotificationIndex!]['discount_amount']
              as double?;
      if (discountAmount != null) {
        setState(() {
          _savedAmount += discountAmount;
        });
      }

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

  // 혜택 카테고리로 이동
  void _navigateToCategoryScreen(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryScreen(initialCategory: category),
      ),
    );
  }

  // 캘린더 화면으로 이동
  void _navigateToCalendarScreen({int? fromDate, int? toDate}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CalendarScreen(
              highlightDates: [
                if (fromDate != null) fromDate,
                if (toDate != null) toDate,
              ],
            ),
      ),
    );
  }

  // 관심 카테고리 혜택 화면으로 이동
  void _navigateToFavoriteCategoryScreen(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CategoryScreen(
              initialCategory: category,
              showFavoritesOnly: true,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 알림 화면이 활성화된 경우
    if (_showNotifications) {
      return _buildNotificationsScreen();
    }

    // 메인 홈 화면
    return Scaffold(
      backgroundColor: Colors.white,
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
              onPressed: () {
                _setShowNotifications(true);
              },
            ),
          ],
        ),
        leadingWidth: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 아낀 금액 요약 카드
            _buildSavingsSummaryCard(),

            // 나를 위한 혜택 섹션
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '나를 위한 혜택',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),

            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _benefits.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _navigateToCategoryScreen(_benefits[index]['category']);
                    },
                    child: _buildBenefitCard(_benefits[index]),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // 카테고리별 혜택 섹션
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                '카테고리별 혜택',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),

            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _navigateToCategoryScreen(_categories[index]['name']);
                    },
                    child: _buildCategoryCard(_categories[index]),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // AI 일정 변경 제안 섹션
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'AI 일정 변경 제안',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _aiSuggestions.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _navigateToCalendarScreen(
                      fromDate: _aiSuggestions[index]['from_date'],
                      toDate: _aiSuggestions[index]['to_date'],
                    );
                  },
                  child: _buildAISuggestionCard(_aiSuggestions[index]),
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 알림 화면 구현
  Widget _buildNotificationsScreen() {
    return WillPopScope(
      onWillPop: () async {
        _setShowNotifications(false);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              _setShowNotifications(false);
            },
          ),
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        body: ListView.separated(
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
                // 각 알림 타입에 따른 동작 처리
                if (isUsageType) {
                  setState(() {
                    // 이미 선택된 알림을 다시 탭하면 버튼 토글
                    if (isSelected) {
                      _showUsageButtons = !_showUsageButtons;
                    } else {
                      _selectedNotificationIndex = index;
                      _showUsageButtons = true;
                    }
                  });
                } else if (notification['type'] == '일정 변경 제안') {
                  _navigateToCalendarScreen(
                    fromDate: notification['from_date'],
                    toDate: notification['to_date'],
                  );
                } else if (notification['type'] == '관심 카테고리 혜택') {
                  _navigateToFavoriteCategoryScreen(notification['category']);
                }
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(notification['icon']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    notification['type'],
                                    style: const TextStyle(
                                      color: Color(0xFF5E5E5E),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    notification['days_ago'],
                                    style: const TextStyle(
                                      color: Color(0xFF5E5E5E),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                notification['title'],
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                notification['description'],
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
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
                                backgroundColor: AppTheme.primaryColor,
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
        ),
      ),
    );
  }

  // 아낀 금액 요약 카드
  Widget _buildSavingsSummaryCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StatisticsScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '이번 달 아낀 금액',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _savedAmount.toStringAsFixed(0),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '원',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.arrow_upward, color: Colors.white, size: 14),
                      SizedBox(width: 2),
                      Text(
                        '15%',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 혜택 카드 위젯
  Widget _buildBenefitCard(Map<String, dynamic> benefit) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD9D9D9)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(9),
                topRight: Radius.circular(9),
              ),
              child: Container(
                color: Colors.grey[200],
                child: Center(
                  child:
                      benefit['imageUrl'] != null
                          ? Image.asset(
                            benefit['imageUrl'],
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                          : Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit['title'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  benefit['discount'] ?? '',
                  style: const TextStyle(fontSize: 10, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 카테고리 카드 위젯
  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Container(
      width: 131,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD9D9D9)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(category['icon'], size: 40, color: AppTheme.primaryColor),
          const SizedBox(height: 12),
          Text(
            category['name'],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  // AI 일정 변경 제안 카드 위젯
  Widget _buildAISuggestionCard(Map<String, dynamic> suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD9D9D9)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    suggestion['imageUrl'],
                    width: 100,
                    height: 35,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 90, color: const Color(0xFFD9D9D9)),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '재료부터 다른 건강한 베이커리 뚜레쥬르',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1천원당 50원 할인',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
