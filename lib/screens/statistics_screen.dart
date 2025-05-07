import 'package:flutter/material.dart';
import 'package:heafit/constants/theme.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

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

  // 월별 절약 금액 데이터
  final List<Map<String, dynamic>> _monthlySavings = [
    {'month': '1월', 'amount': 78000, 'percentage': 8},
    {'month': '2월', 'amount': 92000, 'percentage': 12},
    {'month': '3월', 'amount': 88000, 'percentage': 10},
    {'month': '4월', 'amount': 105000, 'percentage': 15},
    {'month': '5월', 'amount': 138500, 'percentage': 20},
  ];

  // 카테고리별 절약 금액 데이터
  final List<Map<String, dynamic>> _categorySavings = [
    {
      'category': '카페/식당',
      'amount': 35000,
      'color': Colors.brown,
      'icon': Icons.coffee,
    },
    {
      'category': '쇼핑',
      'amount': 42000,
      'color': Colors.blue,
      'icon': Icons.shopping_bag,
    },
    {
      'category': '영화/공연',
      'amount': 25000,
      'color': Colors.purple,
      'icon': Icons.movie,
    },
    {
      'category': '교통',
      'amount': 18000,
      'color': Colors.green,
      'icon': Icons.directions_car,
    },
    {
      'category': '기타',
      'amount': 18500,
      'color': Colors.orange,
      'icon': Icons.more_horiz,
    },
  ];

  // 이번달 혜택 데이터
  final List<Map<String, dynamic>> _benefits = [
    {
      'name': '스타벅스 1+1',
      'date': '2023.05.12',
      'amount': 4800,
      'icon': Icons.coffee,
      'color': Colors.green,
    },
    {
      'name': 'CGV 영화 할인',
      'date': '2023.05.08',
      'amount': 6000,
      'icon': Icons.movie,
      'color': Colors.red,
    },
    {
      'name': '올리브영 5천원 할인',
      'date': '2023.05.05',
      'amount': 5000,
      'icon': Icons.shopping_bag,
      'color': Colors.pink,
    },
    {
      'name': '배달의민족 3천원 할인',
      'date': '2023.05.01',
      'amount': 3000,
      'icon': Icons.fastfood,
      'color': Colors.blue,
    },
  ];

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

  // 카드/멤버십 데이터
  final List<Map<String, dynamic>> _membershipData = [
    {'name': '신한카드', 'amount': 20000, 'count': 8, 'color': Colors.blue},
    {'name': '현대카드', 'amount': 15000, 'count': 5, 'color': Colors.black},
    {'name': 'SKT 멤버십', 'amount': 12000, 'count': 4, 'color': Colors.red},
    {'name': '네이버페이', 'amount': 8000, 'count': 3, 'color': Colors.green},
    {'name': '카카오페이', 'amount': 5000, 'count': 2, 'color': Colors.yellow},
  ];

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '나의 혜택 통계',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: '월별 추이'),
            Tab(text: '카테고리별'),
            Tab(text: '멤버십별'),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이번 달 요약 카드
          _buildTotalSavingsCard(),

          // 월별 절약 추이 차트
          _buildMonthlyChart(),

          // 이번 달 인기 혜택
          _buildSavingBenefits(),
        ],
      ),
    );
  }

  // 카테고리별 통계 탭
  Widget _buildCategoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이번 달 요약 카드
          _buildTotalSavingsCard(),

          // 카테고리별 분석
          _buildCategoryBreakdown(),
        ],
      ),
    );
  }

  // 카드/멤버십별 통계 탭
  Widget _buildMembershipTab() {
    _membershipData.sort((a, b) => b['amount'].compareTo(a['amount']));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이번 달 요약 카드
          _buildTotalSavingsCard(),

          // 멤버십별 분석
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '카드/멤버십별 혜택',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 25000,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                          tooltipPadding: const EdgeInsets.all(8),
                          tooltipMargin: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${_membershipData[groupIndex]['name']}\n${_currencyFormat.format(_membershipData[groupIndex]['amount'])}원',
                              const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value >= _membershipData.length ||
                                  value < 0) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  _membershipData[value.toInt()]['name']
                                      .toString()
                                      .substring(0, 2),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${(value / 1000).toInt()}천',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              );
                            },
                            reservedSize: 30,
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: 5000,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withOpacity(0.2),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      barGroups: List.generate(
                        _membershipData.length,
                        (index) => BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: _membershipData[index]['amount'].toDouble(),
                              color: _membershipData[index]['color'],
                              width: 20,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 멤버십별 상세 목록
                ...List.generate(
                  _membershipData.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _membershipData[index]['color'].withOpacity(
                              0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.card_membership,
                            color: _membershipData[index]['color'],
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _membershipData[index]['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${_membershipData[index]['count']}회 사용',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${_currencyFormat.format(_membershipData[index]['amount'])}원',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 총 절약 금액 카드
  Widget _buildTotalSavingsCard() {
    final currentMonthTotal = _savingsByMonth['5월']!.reduce((a, b) => a + b);
    final previousMonthTotal = _savingsByMonth['4월']!.reduce((a, b) => a + b);
    final percentChange =
        ((currentMonthTotal - previousMonthTotal) / previousMonthTotal * 100)
            .round();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '이번달 총 절약 금액',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            '${_currencyFormat.format(138500)}원',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '지난달보다 ${percentChange.abs()}% 증가',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
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

  // 월별 추이 차트
  Widget _buildMonthlyChart() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '월별 절약 추이',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= _monthlySavings.length ||
                            value < 0) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _monthlySavings[value.toInt()]['month'],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20000,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value / 10000).toInt()}만',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      _monthlySavings.length,
                      (index) => FlSpot(
                        index.toDouble(),
                        _monthlySavings[index]['amount'].toDouble(),
                      ),
                    ),
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 6,
                          color: AppTheme.primaryColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryColor.withOpacity(0.1),
                    ),
                  ),
                ],
                minY: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 카테고리별 분석
  Widget _buildCategoryBreakdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '카테고리별 절약 금액',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // 파이 차트
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: List.generate(_categorySavings.length, (index) {
                  final total = _categorySavings.fold(
                    0.0,
                    (sum, item) => sum + item['amount'],
                  );
                  final percentage = _categorySavings[index]['amount'] / total;

                  return PieChartSectionData(
                    color: _categorySavings[index]['color'],
                    value: _categorySavings[index]['amount'].toDouble(),
                    title: '${(percentage * 100).round()}%',
                    radius: 70,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                startDegreeOffset: -90,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 카테고리 목록
          ..._categorySavings.map((category) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: category['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      category['icon'],
                      color: category['color'],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category['category'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: category['amount'] / 50000,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            category['color'],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_currencyFormat.format(category['amount'])}원',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // 혜택 내역
  Widget _buildSavingBenefits() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '이번달 혜택 내역',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ..._benefits.map((benefit) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: benefit['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      benefit['icon'],
                      color: benefit['color'],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          benefit['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          benefit['date'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${_currencyFormat.format(benefit['amount'])}원',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
