import 'package:flutter/material.dart';
import 'package:heafit/constants/theme.dart';
import 'package:heafit/widgets/benefit_card.dart';
import 'package:heafit/widgets/category_item.dart';
import 'package:heafit/widgets/section_title.dart';
import 'package:heafit/screens/statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(
    viewportFraction: 0.85,
    initialPage: 0,
  );
  int _currentPage = 0;

  final List<Map<String, dynamic>> _benefits = [
    {
      'title': '스타벅스 50% 할인',
      'description': '신한카드로 결제 시 최대 5,000원 할인',
      'imageUrl': 'assets/images/starbucks.jpg',
      'period': '2023-05-01 ~ 2023-06-30',
    },
    {
      'title': '배달의민족 3,000원 할인',
      'description': '2만원 이상 주문 시 네이버페이 결제 할인',
      'imageUrl': 'assets/images/baemin.jpg',
      'period': '2023-05-15 ~ 2023-05-31',
    },
    {
      'title': 'CGV 영화 1+1',
      'description': '토스로 결제 시 동반 1인 무료',
      'imageUrl': 'assets/images/cgv.jpg',
      'period': '2023-05-10 ~ 2023-06-10',
    },
  ];

  final List<Map<String, dynamic>> _categories = [
    {'name': '카페', 'icon': Icons.coffee},
    {'name': '음식점', 'icon': Icons.restaurant},
    {'name': '쇼핑', 'icon': Icons.shopping_bag},
    {'name': '영화', 'icon': Icons.movie},
    {'name': '뷰티', 'icon': Icons.face},
    {'name': '여행', 'icon': Icons.flight},
  ];

  final List<Map<String, dynamic>> _aiSuggestions = [
    {
      'title': '일정 변경 제안: 내일 점심',
      'description': '내일 대신 모레 스타벅스 방문 시 추가 30% 할인',
      'imageUrl': 'assets/images/calendar_change.jpg',
    },
    {
      'title': '두 일정 합치기 제안',
      'description': '내일 영화 관람과 식사를 CGV 콤보로 합치면 50% 할인',
      'imageUrl': 'assets/images/combine_events.jpg',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo/heafit-logo.png', width: 36, height: 36),
            const SizedBox(width: 10),
            const Text(
              'HEAFIT',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 아낀 금액 요약 카드
            _buildSavingsSummaryCard(),

            // 인기 혜택 섹션
            const SectionTitle(title: '인기 혜택'),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return _buildPopularBenefitCard(index);
                },
              ),
            ),
            const SizedBox(height: 20),

            // 임박한 일정 섹션
            const SectionTitle(title: '임박한 일정'),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return _buildUpcomingScheduleCard(index);
                },
              ),
            ),
            const SizedBox(height: 20),

            // AI 일정 변경 제안 섹션
            const SectionTitle(title: 'AI 일정 변경 제안'),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _aiSuggestions.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      child: const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      _aiSuggestions[index]['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(_aiSuggestions[index]['description']),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // 일정 변경 상세 페이지로 이동
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.savings, color: AppTheme.primaryColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  '이번 달 아낀 금액',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(Icons.bar_chart, color: AppTheme.primaryColor, size: 18),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '48,500',
                  style: TextStyle(
                    color: Colors.grey[900],
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '원',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        color: AppTheme.primaryColor,
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '15%',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSavingStatItem('사용 혜택', '12건', false),
                _buildSavingStatItem('저장 혜택', '24건', false),
                _buildSavingStatItem('이용 매장', '8곳', false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingStatItem(String label, String value, bool isWhite) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
      ],
    );
  }

  // 인기 혜택 카드 위젯
  Widget _buildPopularBenefitCard(int index) {
    final titles = [
      '스타벅스 아메리카노 1+1',
      'CGV 영화 티켓 30% 할인',
      '교촌치킨 10% 할인',
      '투썸플레이스 디저트 30% 할인',
      '롯데시네마 2천원 할인',
    ];
    final companies = ['스타벅스', 'CGV', '교촌치킨', '투썸플레이스', '롯데시네마'];
    final discounts = ['50%', '30%', '10%', '30%', '2천원'];

    // 브랜드별 대표 색상
    final brandColors = [
      const Color(0xFF00704A), // 스타벅스 그린
      const Color(0xFFE51937), // CGV 레드
      const Color(0xFFFFCC00), // 교촌 옐로우
      const Color(0xFFA9469C), // 투썸 퍼플
      const Color(0xFF003082), // 롯데시네마 블루
    ];

    return GestureDetector(
      onTap: () {
        // 상세 페이지로 이동
        _navigateToBenefitDetail(index);
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 브랜드 로고 영역
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: brandColors[index].withOpacity(0.15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 로고 대신 임시로 이니셜 사용
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: brandColors[index],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          companies[index][0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      companies[index],
                      style: TextStyle(
                        color: brandColors[index],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 혜택 정보 영역
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: brandColors[index].withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      discounts[index],
                      style: TextStyle(
                        color: brandColors[index],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    titles[index],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF333333),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 12,
                        color: Color(0xFF888888),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "~05.31까지",
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF888888),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 10,
                        color: brandColors[index],
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

  // 임박한 일정 카드 위젯 - 세련된 디자인으로 업데이트
  Widget _buildUpcomingScheduleCard(int index) {
    final schedules = [
      {
        'title': '스타벅스 방문',
        'date': '오늘 15:00',
        'time_left': '3시간 후',
        'type': '카페',
      },
      {
        'title': 'CGV 영화 관람',
        'date': '내일 19:30',
        'time_left': '내일',
        'type': '영화',
      },
      {
        'title': '교촌치킨 주문',
        'date': '모레 18:00',
        'time_left': '모레',
        'type': '음식점',
      },
    ];

    final icons = [Icons.coffee, Icons.movie, Icons.fastfood];

    // 통일된 색상 스킴 사용
    final bgColors = [
      const Color(0xFF7986CB), // 인디고 계열
      const Color(0xFF5C6BC0), // 인디고 조금 더 어두운 색
      const Color(0xFF3F51B5), // 더 어두운 인디고
    ];

    return Container(
      width: 220,
      height: 110,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 왼쪽 아이콘 영역
          Container(
            width: 70,
            decoration: BoxDecoration(
              color: bgColors[index],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: bgColors[index].withOpacity(0.3),
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: const Offset(1, 0),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icons[index], color: Colors.white, size: 34),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      schedules[index]['time_left']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 오른쪽 정보 영역
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    schedules[index]['title']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF333333),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Color(0xFF666666),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        schedules[index]['date']!,
                        style: const TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          schedules[index]['type']!,
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 혜택 상세 페이지 이동 함수
  void _navigateToBenefitDetail(int index) {
    // 상세 페이지로 이동하는 코드 구현
    final titles = [
      '스타벅스 아메리카노 1+1',
      'CGV 영화 티켓 30% 할인',
      '교촌치킨 10% 할인',
      '투썸플레이스 디저트 30% 할인',
      '롯데시네마 2천원 할인',
    ];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${titles[index]} 상세 페이지로 이동합니다'),
        duration: const Duration(seconds: 1),
      ),
    );

    // 실제 구현 시 아래와 같이 주석 해제하여 사용
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => BenefitDetailScreen(
    //       benefitId: index,
    //       title: titles[index],
    //     ),
    //   ),
    // );
  }
}
