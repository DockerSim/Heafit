import 'package:flutter/material.dart';
import 'package:heafit/constants/theme.dart';
import 'package:heafit/widgets/section_title.dart';
import 'package:heafit/services/google_auth_service.dart';
import 'package:intl/intl.dart';

class BenefitDetail {
  final String title;
  final String company;
  final String description;
  final String period;
  final String imageUrl;
  final List<String> tags;
  final String paymentMethod;
  final double discountRate;
  bool isFavorite;

  BenefitDetail({
    required this.title,
    required this.company,
    required this.description,
    required this.period,
    required this.imageUrl,
    required this.tags,
    required this.paymentMethod,
    required this.discountRate,
    this.isFavorite = false,
  });
}

class CategoryScreen extends StatefulWidget {
  final String? initialCategory;
  final bool showFavoritesOnly;

  const CategoryScreen({
    Key? key,
    this.initialCategory,
    this.showFavoritesOnly = false,
  }) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
    with SingleTickerProviderStateMixin {
  // Google 인증 서비스
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  bool _isCalendarConnected = false;

  // 선택된 메인 카테고리 인덱스
  int _selectedCategoryIndex = 0;

  // 선택된 서브 카테고리
  String? _selectedSubCategory;

  // 즐겨찾기 필터링 여부
  bool _showFavoritesOnly = false;

  // 혜택 상세 정보 표시 여부
  bool _showBenefitDetail = false;

  // 선택된 혜택
  BenefitDetail? _selectedBenefit;

  // 메인 카테고리 리스트
  final List<Map<String, dynamic>> _mainCategories = [
    {'name': '음식', 'icon': Icons.restaurant},
    {'name': '쇼핑', 'icon': Icons.shopping_bag},
    {'name': '교통', 'icon': Icons.directions_car},
    {'name': '엔터테인먼트', 'icon': Icons.movie},
  ];

  // 서브 카테고리 리스트 (카테고리별)
  final Map<String, List<Map<String, dynamic>>> _subCategories = {
    '음식': [
      {'name': '한식', 'imageUrl': 'assets/images/category/Bibimbap .png'},
      {'name': '중식', 'imageUrl': 'assets/images/category/Jjajangmyeon .png'},
      {'name': '카페/디저트', 'imageUrl': 'assets/images/category/Coffee.png'},
    ],
    '쇼핑': [
      {'name': '패션/의류', 'imageUrl': 'assets/images/category/Clothes .png'},
      {'name': '뷰티/화장품', 'imageUrl': 'assets/images/category/Makeup.png'},
      {'name': '디지털/가전', 'imageUrl': 'assets/images/category/Laptop.png'},
      {'name': '도서/문구', 'imageUrl': 'assets/images/category/Book.png'},
    ],
    '교통': [
      {'name': '대중교통', 'imageUrl': 'assets/images/category/Bus.png'},
    ],
    '엔터테인먼트': [
      {'name': '영화', 'imageUrl': 'assets/images/category/Movie.png'},
      {'name': '공연', 'imageUrl': 'assets/images/category/Performance .png'},
      {'name': '전시', 'imageUrl': 'assets/images/category/Exhibition .png'},
    ],
  };

  // 혜택 정보 리스트 (카테고리별)
  final Map<String, List<BenefitDetail>> _benefitsList = {
    '한식': [
      BenefitDetail(
        title: '본죽 5,000원 할인',
        company: '본죽',
        description: '본죽 20,000원 이상 주문 시 5,000원 할인을 제공합니다.',
        period: '2025.05.01 ~ 2025.06.30',
        imageUrl: 'assets/logo/heafit-logo2.png',
        tags: ['5,000원 할인', '본죽', '한식'],
        paymentMethod: '신한카드, 삼성카드',
        discountRate: 25.0,
      ),
      BenefitDetail(
        title: '교촌치킨 10% 할인',
        company: '교촌치킨',
        description: '교촌치킨 모든 메뉴 10% 할인 혜택을 제공합니다.',
        period: '2025.05.15 ~ 2025.07.15',
        imageUrl: 'assets/logo/heafit-logo2.png',
        tags: ['10% 할인', '교촌치킨', '치킨'],
        paymentMethod: '현대카드, 롯데카드',
        discountRate: 10.0,
      ),
    ],
    '중식': [
      BenefitDetail(
        title: '홍콩반점 5% 할인',
        company: '홍콩반점',
        description: '홍콩반점 모든 메뉴 5% 할인 혜택을 제공합니다.',
        period: '2025.05.01 ~ 2025.06.30',
        imageUrl: 'assets/logo/heafit-logo2.png',
        tags: ['5% 할인', '홍콩반점', '중식'],
        paymentMethod: '신한카드, 삼성카드',
        discountRate: 5.0,
      ),
    ],
    '카페/디저트': [
      BenefitDetail(
        title: '스타벅스 아메리카노 1+1',
        company: '스타벅스',
        description: '스타벅스 아메리카노 구매 시 1잔 더 제공합니다.',
        period: '2025.05.10 ~ 2025.05.20',
        imageUrl: 'assets/logo/heafit-logo2.png',
        tags: ['1+1', '스타벅스', '아메리카노'],
        paymentMethod: '현대카드, 삼성카드',
        discountRate: 50.0,
      ),
      BenefitDetail(
        title: '투썸플레이스 디저트 30% 할인',
        company: '투썸플레이스',
        description: '투썸플레이스 디저트 메뉴 30% 할인 혜택을 제공합니다.',
        period: '2025.05.01 ~ 2025.06.15',
        imageUrl: 'assets/logo/heafit-logo2.png',
        tags: ['30% 할인', '투썸플레이스', '디저트'],
        paymentMethod: '신한카드, KB국민카드',
        discountRate: 30.0,
      ),
    ],
    '패션/의류': [
      BenefitDetail(
        title: '무신사 신규회원 15% 할인',
        company: '무신사',
        description: '무신사 신규회원 가입 시 15% 할인 쿠폰을 제공합니다.',
        period: '2025.05.01 ~ 2025.06.30',
        imageUrl: 'assets/logo/heafit-logo2.png',
        tags: ['15% 할인', '무신사', '패션/의류'],
        paymentMethod: '전체 결제수단',
        discountRate: 15.0,
      ),
    ],
    '영화': [
      BenefitDetail(
        title: 'CGV 영화 티켓 30% 할인',
        company: 'CGV',
        description: 'CGV 영화 티켓 구매 시 30% 할인 혜택을 드립니다.',
        period: '2025.05.05 ~ 2025.06.04',
        imageUrl: 'assets/logo/heafit-logo2.png',
        tags: ['30% 할인', 'CGV', '영화'],
        paymentMethod: 'SKT 멤버십, 현대카드',
        discountRate: 30.0,
      ),
      BenefitDetail(
        title: '메가박스 1+1 이벤트',
        company: '메가박스',
        description: '메가박스 영화 티켓 1장 구매 시 1장 무료 혜택을 드립니다.',
        period: '2025.05.01 ~ 2025.05.15',
        imageUrl: 'assets/logo/heafit-logo2.png',
        tags: ['1+1', '메가박스', '영화'],
        paymentMethod: '삼성카드, KB국민카드',
        discountRate: 50.0,
      ),
    ],
    '대중교통': [
      BenefitDetail(
        title: '지하철 청소년 요금 할인',
        company: '서울교통공사',
        description: '청소년 교통카드 사용 시 지하철 요금 20% 할인',
        period: '2025.01.01 ~ 2025.12.31',
        imageUrl: 'assets/logo/heafit-logo2.png',
        tags: ['20% 할인', '지하철', '청소년'],
        paymentMethod: '교통카드',
        discountRate: 20.0,
      ),
    ],
  };

  @override
  void initState() {
    super.initState();

    // 초기 카테고리 설정
    if (widget.initialCategory != null) {
      for (int i = 0; i < _mainCategories.length; i++) {
        if (_mainCategories[i]['name'] == widget.initialCategory) {
          _selectedCategoryIndex = i;
          break;
        }
      }
    }

    // 즐겨찾기 필터 설정
    _showFavoritesOnly = widget.showFavoritesOnly;
  }

  // 특정 서브 카테고리의 혜택 목록을 가져오는 메서드
  List<BenefitDetail> _getBenefitsForSubCategory(String subCategory) {
    if (_benefitsList.containsKey(subCategory)) {
      List<BenefitDetail> benefits = _benefitsList[subCategory]!;
      if (_showFavoritesOnly) {
        return benefits.where((benefit) => benefit.isFavorite).toList();
      }
      return benefits;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    // 상세 화면 표시
    if (_showBenefitDetail && _selectedBenefit != null) {
      return _buildBenefitDetailScreen();
    }

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
                // 알림 기능은 구현하지 않음
              },
            ),
          ],
        ),
        leadingWidth: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // 즐겨찾기 필터링 버튼
          if (!_showBenefitDetail)
            IconButton(
              icon: Icon(
                _showFavoritesOnly ? Icons.star : Icons.star_border,
                color: _showFavoritesOnly ? Colors.yellow : null,
              ),
              onPressed: () {
                setState(() {
                  _showFavoritesOnly = !_showFavoritesOnly;
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // 카테고리 네비게이션바
          _buildMainCategoryTabs(),

          // 서브 카테고리 표시
          if (_selectedSubCategory == null)
            _buildSubCategoryGrid()
          else
            // 서브 카테고리의 혜택 목록 표시
            _buildBenefitsList(_selectedSubCategory!),
        ],
      ),
    );
  }

  // 메인 카테고리 탭 구현
  Widget _buildMainCategoryTabs() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _mainCategories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
                _selectedSubCategory = null; // 서브 카테고리 선택 초기화
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color:
                        isSelected ? AppTheme.primaryColor : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                _mainCategories[index]['name'],
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 서브 카테고리 그리드 구현
  Widget _buildSubCategoryGrid() {
    String currentMainCategory =
        _mainCategories[_selectedCategoryIndex]['name'];
    List<Map<String, dynamic>> subCategories =
        _subCategories.containsKey(currentMainCategory)
            ? _subCategories[currentMainCategory]!
            : [];

    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemCount: subCategories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSubCategory = subCategories[index]['name'];
              });
            },
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      subCategories[index]['imageUrl'],
                      width: 70,
                      height: 70,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subCategories[index]['name'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 서브 카테고리 혜택 목록 구현
  Widget _buildBenefitsList(String subCategory) {
    List<BenefitDetail> benefits = _getBenefitsForSubCategory(subCategory);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 서브 카테고리 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _selectedSubCategory = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  subCategory,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 혜택 목록
          Expanded(
            child:
                benefits.isEmpty
                    ? const Center(child: Text('등록된 혜택이 없습니다.'))
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: benefits.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedBenefit = benefits[index];
                              _showBenefitDetail = true;
                            });
                          },
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 혜택 이미지
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      benefits[index].imageUrl,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // 혜택 정보
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          benefits[index].title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          benefits[index].company,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          benefits[index].period,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // 즐겨찾기 버튼
                                  IconButton(
                                    icon: Icon(
                                      benefits[index].isFavorite
                                          ? Icons.star
                                          : Icons.star_border,
                                      color:
                                          benefits[index].isFavorite
                                              ? Colors.yellow
                                              : Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        benefits[index].isFavorite =
                                            !benefits[index].isFavorite;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  // 혜택 상세 정보 화면 구현
  Widget _buildBenefitDetailScreen() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            setState(() {
              _showBenefitDetail = false;
            });
          },
        ),
        title: const Text('혜택 상세 정보', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // 즐겨찾기 버튼
          IconButton(
            icon: Icon(
              _selectedBenefit!.isFavorite ? Icons.star : Icons.star_border,
              color: _selectedBenefit!.isFavorite ? Colors.yellow : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _selectedBenefit!.isFavorite = !_selectedBenefit!.isFavorite;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 혜택 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                _selectedBenefit!.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // 혜택 제목
            Text(
              _selectedBenefit!.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // 회사명
            Text(
              _selectedBenefit!.company,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),

            // 기간
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  _selectedBenefit!.period,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 결제 방법
            Row(
              children: [
                const Icon(Icons.credit_card, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  _selectedBenefit!.paymentMethod,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 할인율 표시
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${_selectedBenefit!.discountRate.toStringAsFixed(0)}% 할인',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 상세 설명
            const Text(
              '상세 정보',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedBenefit!.description,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 24),

            // 태그
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _selectedBenefit!.tags
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          backgroundColor: Colors.grey[200],
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 32),

            // 일정에 추가 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 일정 추가 기능은 백엔드 연동 없이 Toast 메시지만 표시
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('일정에 추가되었습니다.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '일정에 추가하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
