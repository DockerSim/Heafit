import 'package:flutter/material.dart';
import 'package:heafit/constants/theme.dart';
import 'package:heafit/widgets/benefit_card.dart';
import 'package:heafit/widgets/category_item.dart';
import 'package:heafit/widgets/section_title.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
            // 나를 위한 혜택 섹션
            const SectionTitle(title: '나를 위한 혜택'),
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _benefits.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: BenefitCard(
                      title: _benefits[index]['title'],
                      description: _benefits[index]['description'],
                      imageUrl: _benefits[index]['imageUrl'],
                      period: _benefits[index]['period'],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // 페이지 인디케이터
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _benefits.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _currentPage == index
                            ? AppTheme.primaryColor
                            : Colors.grey.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 카테고리별 혜택 섹션
            const SectionTitle(title: '카테고리별 혜택'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.0,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  return CategoryItem(
                    name: _categories[index]['name'],
                    icon: _categories[index]['icon'],
                  );
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
}
