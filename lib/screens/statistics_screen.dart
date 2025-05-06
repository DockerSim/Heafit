import 'package:flutter/material.dart';
import 'package:heafit/constants/theme.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  // 탭 컨트롤러 - 다양한 통계 뷰를 탭으로 전환
  late TabController _tabController;

  // 금액 포맷터
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'ko_KR',
    symbol: '',
    decimalDigits: 0,
  );

  // 통계 데이터 (실제 앱에서는 API나 로컬 DB에서 가져옴)
  final Map<String, List<double>> _savingsByMonth = {
    '1월': [45000, 38000, 12000, 8000, 15000],
    '2월': [38000, 42000, 18000, 5000, 12000],
    '3월': [55000, 28000, 15000, 10000, 5000],
    '4월': [42000, 35000, 22000, 12000, 8000],
    '5월': [48500, 40000, 25000, 15000, 10000],
  };

  final List<Color> _categoryColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.amber,
    Colors.purple,
  ];

  final List<String> _categories = ['카페/식당', '쇼핑', '영화/공연', '교통', '기타'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 혜택 통계'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '월별 추이'),
            Tab(text: '카테고리별'),
            Tab(text: '카드/멤버십별'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMonthlyTrendTab(),
          _buildCategoryTab(),
          _buildMembershipTab(),
        ],
      ),
    );
  }

  // 월별 추이 탭
  Widget _buildMonthlyTrendTab() {
    // 월별 총 절약액
    final List<double> monthlyTotals =
        _savingsByMonth.entries
            .map((entry) => entry.value.reduce((a, b) => a + b))
            .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이번 달 요약 카드
          _buildSummaryCard(),

          const SizedBox(height: 24),

          // 월별 추이 그래프
          const Text(
            '월별 절약 추이',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 200,
            child: Container(
              color: Colors.grey.shade200,
              child: const Center(child: Text('절약 추이 그래프가 표시됩니다')),
            ),
          ),

          const SizedBox(height: 32),

          // 목표 달성률
          const Text(
            '월간 절약 목표 달성률',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildGoalProgressBar(),

          const SizedBox(height: 32),

          // 이번 달 인기 혜택
          const Text(
            '이번 달 인기 혜택',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildPopularBenefitsList(),
        ],
      ),
    );
  }

  // 카테고리별 통계 탭
  Widget _buildCategoryTab() {
    // 현재 달(5월) 데이터 기준
    final currentMonthData = _savingsByMonth['5월']!;
    final totalAmount = currentMonthData.reduce((a, b) => a + b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '카테고리별 절약 금액',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // 파이 차트 자리
          SizedBox(
            height: 280,
            child: Container(
              color: Colors.grey.shade200,
              child: const Center(child: Text('카테고리별 파이 차트가 표시됩니다')),
            ),
          ),

          const SizedBox(height: 24),

          // 범례 및 금액 목록
          ...List.generate(
            _categories.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    color: _categoryColors[index],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _categories[index],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    '${_currencyFormat.format(currentMonthData[index])}원',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 32),

          // 총 금액
          Row(
            children: [
              const Text(
                '총 절약 금액',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '${_currencyFormat.format(totalAmount)}원',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 카드/멤버십별 통계 탭
  Widget _buildMembershipTab() {
    // 임시 데이터
    final List<Map<String, dynamic>> membershipData = [
      {'name': '신한카드', 'amount': 20000, 'count': 8},
      {'name': '현대카드', 'amount': 15000, 'count': 5},
      {'name': 'SKT 멤버십', 'amount': 12000, 'count': 4},
      {'name': '네이버페이', 'amount': 8000, 'count': 3},
      {'name': '카카오페이', 'amount': 5000, 'count': 2},
    ];

    membershipData.sort((a, b) => b['amount'].compareTo(a['amount']));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '카드/멤버십별 혜택 사용량',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // 바 차트 자리
          SizedBox(
            height: 200,
            child: Container(
              color: Colors.grey.shade200,
              child: const Center(child: Text('카드/멤버십별 바 차트가 표시됩니다')),
            ),
          ),

          const SizedBox(height: 32),

          // 상세 목록
          const Text(
            '카드/멤버십별 혜택 상세',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ...membershipData
              .map(
                (data) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // 카드/멤버십 아이콘 또는 이니셜
                        CircleAvatar(
                          backgroundColor: AppTheme.primaryColor.withOpacity(
                            0.1,
                          ),
                          child: Text(
                            data['name'][0],
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // 카드/멤버십 정보
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${data['count']}회 사용',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 절약 금액
                        Text(
                          '${_currencyFormat.format(data['amount'])}원',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  // 요약 카드 위젯
  Widget _buildSummaryCard() {
    final currentMonthTotal = _savingsByMonth['5월']!.reduce((a, b) => a + b);
    final previousMonthTotal = _savingsByMonth['4월']!.reduce((a, b) => a + b);
    final percentChange =
        ((currentMonthTotal - previousMonthTotal) / previousMonthTotal * 100)
            .round();

    return Container(
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
            '5월 절약 금액',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currencyFormat.format(currentMonthTotal),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      percentChange >= 0
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${percentChange.abs()}%',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('사용 혜택', '12건'),
              _buildSummaryItem('절약 횟수', '22회'),
              _buildSummaryItem('이용 매장', '8곳'),
            ],
          ),
        ],
      ),
    );
  }

  // 요약 아이템 위젯
  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }

  // 목표 달성률 프로그레스 바
  Widget _buildGoalProgressBar() {
    // 목표: 6만원 절약, 현재: 48500원 절약
    const double goalAmount = 60000;
    const double currentAmount = 48500;
    final double percentage = (currentAmount / goalAmount * 100).clamp(0, 100);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('5월 목표', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              '${percentage.toInt()}% 달성',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            // 배경 바
            Container(
              height: 20,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // 진행 바
            Container(
              height: 20,
              width:
                  MediaQuery.of(context).size.width * (percentage / 100) -
                  32, // 패딩 고려
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.7),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_currencyFormat.format(currentAmount)}원',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              '목표: ${_currencyFormat.format(goalAmount)}원',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  // 인기 혜택 목록
  Widget _buildPopularBenefitsList() {
    // 임시 데이터
    final List<Map<String, dynamic>> popularBenefits = [
      {'title': '스타벅스 아메리카노 1+1', 'saved': 8000, 'usageCount': 4},
      {'title': 'CGV 영화 티켓 30% 할인', 'saved': 12000, 'usageCount': 3},
      {'title': '교촌치킨 10% 할인', 'saved': 6000, 'usageCount': 2},
    ];

    return Column(
      children:
          popularBenefits
              .map(
                (benefit) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // 순위 표시
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${popularBenefits.indexOf(benefit) + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // 혜택 정보
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                benefit['title'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${benefit['usageCount']}회 사용',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 절약 금액
                        Text(
                          '${_currencyFormat.format(benefit['saved'])}원',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }
}
