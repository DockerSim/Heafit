import 'package:flutter/material.dart';
import 'package:heafit/constants/theme.dart';
import 'package:heafit/widgets/section_title.dart';
import 'package:heafit/services/google_auth_service.dart';
import 'package:intl/intl.dart';
import 'package:heafit/screens/statistics_screen.dart';

class BenefitDetail {
  final String title;
  final String company;
  final String description;
  final String period;
  final String imageUrl;
  final List<String> tags;
  final String paymentMethod;
  final double discountRate;
  final bool isFavorite;

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
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  // Google 인증 서비스
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  bool _isCalendarConnected = false;

  // 선택된 메인 카테고리 인덱스
  int _selectedCategoryIndex = 0;
  // 선택된 탭 인덱스
  int _selectedTabIndex = 0;

  // 혜택 상세 정보 표시 여부
  bool _showBenefitDetail = false;

  // 선택된 혜택
  BenefitDetail? _selectedBenefit;

  // 하위 카테고리 화면 표시 여부
  bool _showSubCategory = false;

  // 브랜드 목록 화면 표시 여부
  bool _showBrandList = false;

  // 브랜드 혜택 목록 화면 표시 여부
  bool _showBrandBenefits = false;

  // 전체 혜택 목록 화면 표시 여부
  bool _showAllBenefits = false;

  // 현재 전체보기 카테고리
  String _allBenefitsCategory = '';

  // 혜택 정렬 방식
  String _sortType = '인기순';

  // 정렬 옵션 목록
  final List<String> _sortOptions = ['인기순', '최신순', '마감임박순'];

  // 선택된 브랜드
  String _selectedBrand = '';

  // 현재 선택된 카테고리
  String _selectedCategory = '한식';

  // 메인 탭 목록
  final List<Map<String, dynamic>> _mainTabs = [
    {'name': '음식', 'icon': Icons.restaurant},
    {'name': '쇼핑', 'icon': Icons.shopping_bag},
    {'name': '엔터테인먼트', 'icon': Icons.movie},
    {'name': '교통', 'icon': Icons.directions_car},
  ];

  // 음식 카테고리 목록
  final List<Map<String, dynamic>> _foodCategories = [
    {'name': '한식', 'icon': Icons.restaurant},
    {'name': '중식', 'icon': Icons.ramen_dining},
    {'name': '일식', 'icon': Icons.set_meal},
    {'name': '양식', 'icon': Icons.dining},
    {'name': '카페/디저트', 'icon': Icons.coffee},
  ];

  // 쇼핑 카테고리 목록
  final List<Map<String, dynamic>> _shoppingCategories = [
    {'name': '패션/의류', 'icon': Icons.checkroom},
    {'name': '뷰티/화장품', 'icon': Icons.face},
    {'name': '디지털/가전', 'icon': Icons.devices},
    {'name': '생활/가구', 'icon': Icons.chair},
    {'name': '스포츠/레저', 'icon': Icons.sports_basketball},
    {'name': '도서/문구', 'icon': Icons.book},
  ];

  // 엔터테인먼트 카테고리 목록
  final List<Map<String, dynamic>> _entertainmentCategories = [
    {'name': '영화/공연', 'icon': Icons.movie},
    {'name': '스포츠', 'icon': Icons.sports_soccer},
    {'name': '게임', 'icon': Icons.videogame_asset},
    {'name': '테마파크', 'icon': Icons.attractions},
    {'name': '전시/박물관', 'icon': Icons.museum},
    {'name': '음악/콘서트', 'icon': Icons.music_note},
  ];

  // 교통 카테고리 목록
  final List<Map<String, dynamic>> _transportCategories = [
    {'name': '대중교통', 'icon': Icons.directions_bus},
    {'name': '택시/콜', 'icon': Icons.local_taxi},
    {'name': '주차', 'icon': Icons.local_parking},
    {'name': '렌터카', 'icon': Icons.car_rental},
    {'name': '주유/충전', 'icon': Icons.ev_station},
    {'name': '교통카드', 'icon': Icons.credit_card},
  ];

  // 주요 체인점 목록 - 카테고리별
  final Map<String, List<Map<String, dynamic>>> _chainsByCategory = {
    '한식': [
      {'name': '본죽', 'imageUrl': 'assets/images/bonjuk.jpg'},
      {'name': '비비고', 'imageUrl': 'assets/images/bibigo.jpg'},
      {'name': '교촌치킨', 'imageUrl': 'assets/images/kyochon.jpg'},
      {'name': 'BHC', 'imageUrl': 'assets/images/bhc.jpg'},
      {'name': '굽네치킨', 'imageUrl': 'assets/images/goobne.jpg'},
    ],
    '중식': [
      {'name': '홍콩반점', 'imageUrl': 'assets/images/hongkong.jpg'},
      {'name': '짬뽕타임', 'imageUrl': 'assets/images/jjamppong.jpg'},
      {'name': '교동짬뽕', 'imageUrl': 'assets/images/gyodong.jpg'},
    ],
    '일식': [
      {'name': '스시로', 'imageUrl': 'assets/images/sushiro.jpg'},
      {'name': '미소야', 'imageUrl': 'assets/images/misoya.jpg'},
      {'name': '하코야', 'imageUrl': 'assets/images/hakoya.jpg'},
    ],
    '양식': [
      {'name': '아웃백', 'imageUrl': 'assets/images/outback.jpg'},
      {'name': '애슐리', 'imageUrl': 'assets/images/ashley.jpg'},
      {'name': '빕스', 'imageUrl': 'assets/images/vips.jpg'},
    ],
    '카페/디저트': [
      {'name': '스타벅스', 'imageUrl': 'assets/images/starbucks.jpg'},
      {'name': '투썸플레이스', 'imageUrl': 'assets/images/twosome.jpg'},
      {'name': '이디야', 'imageUrl': 'assets/images/ediya.jpg'},
      {'name': '커피빈', 'imageUrl': 'assets/images/coffeebean.jpg'},
      {'name': '할리스', 'imageUrl': 'assets/images/hollys.jpg'},
      {'name': '설빙', 'imageUrl': 'assets/images/sulbing.jpg'},
      {'name': '베스킨라빈스', 'imageUrl': 'assets/images/baskinrobbins.jpg'},
    ],
  };

  // 카테고리별 혜택 정보
  final Map<String, List<BenefitDetail>> _benefitsByCategory = {
    '영화/공연': [
      BenefitDetail(
        title: 'CGV 영화 티켓 30% 할인',
        company: 'CGV',
        description: 'CGV 영화 티켓 구매 시 30% 할인 혜택을 드립니다.',
        period: '2025.05.05 ~ 2025.06.04',
        imageUrl: 'assets/images/cgv_logo.jpg',
        tags: ['30% 할인', 'CGV', '영화'],
        paymentMethod: 'SKT 멤버십, 현대카드',
        discountRate: 30.0,
      ),
      BenefitDetail(
        title: '메가박스 1+1 이벤트',
        company: '메가박스',
        description: '메가박스 영화 티켓 1장 구매 시 1장 무료 혜택을 드립니다.',
        period: '2025.05.01 ~ 2025.05.15',
        imageUrl: 'assets/images/megabox_logo.jpg',
        tags: ['1+1', '메가박스', '영화'],
        paymentMethod: '삼성카드, KB국민카드',
        discountRate: 50.0,
      ),
      BenefitDetail(
        title: '롯데시네마 주중 2천원 할인',
        company: '롯데시네마',
        description: '평일(월~금) 롯데시네마 영화 티켓 2천원 할인 혜택을 제공합니다.',
        period: '2025.05.01 ~ 2025.07.31',
        imageUrl: 'assets/images/lottecinema_logo.jpg',
        tags: ['2천원 할인', '롯데시네마', '평일'],
        paymentMethod: '롯데카드, 하나카드',
        discountRate: 15.0,
      ),
    ],
    '한식': [
      BenefitDetail(
        title: '본죽 5,000원 할인',
        company: '본죽',
        description: '본죽 20,000원 이상 주문 시 5,000원 할인을 제공합니다.',
        period: '2025.05.01 ~ 2025.06.30',
        imageUrl: 'assets/images/bonjuk.jpg',
        tags: ['5,000원 할인', '본죽', '한식'],
        paymentMethod: '신한카드, 삼성카드',
        discountRate: 25.0,
      ),
      BenefitDetail(
        title: '교촌치킨 10% 할인',
        company: '교촌치킨',
        description: '교촌치킨 모든 메뉴 10% 할인 혜택을 제공합니다.',
        period: '2025.05.15 ~ 2025.07.15',
        imageUrl: 'assets/images/kyochon.jpg',
        tags: ['10% 할인', '교촌치킨', '치킨'],
        paymentMethod: '현대카드, 롯데카드',
        discountRate: 10.0,
      ),
    ],
    '카페/디저트': [
      BenefitDetail(
        title: '스타벅스 아메리카노 1+1',
        company: '스타벅스',
        description: '스타벅스 아메리카노 구매 시 1잔 더 제공합니다.',
        period: '2025.05.10 ~ 2025.05.20',
        imageUrl: 'assets/images/starbucks.jpg',
        tags: ['1+1', '스타벅스', '아메리카노'],
        paymentMethod: '현대카드, 삼성카드',
        discountRate: 50.0,
      ),
      BenefitDetail(
        title: '투썸플레이스 디저트 30% 할인',
        company: '투썸플레이스',
        description: '투썸플레이스 디저트 메뉴 30% 할인 혜택을 제공합니다.',
        period: '2025.05.01 ~ 2025.06.15',
        imageUrl: 'assets/images/twosome.jpg',
        tags: ['30% 할인', '투썸플레이스', '디저트'],
        paymentMethod: '신한카드, KB국민카드',
        discountRate: 30.0,
      ),
      BenefitDetail(
        title: '이디야 카페라떼 500원 할인',
        company: '이디야',
        description: '이디야 카페라떼 주문 시 500원 할인 혜택을 제공합니다.',
        period: '2025.06.01 ~ 2025.06.30',
        imageUrl: 'assets/images/ediya.jpg',
        tags: ['500원 할인', '이디야', '카페라떼'],
        paymentMethod: '삼성페이, 신한카드',
        discountRate: 10.0,
      ),
    ],
    '패션/의류': [
      BenefitDetail(
        title: '무신사 신규가입 15% 할인쿠폰',
        company: '무신사',
        description: '무신사 신규가입 시 15% 할인쿠폰을 제공합니다 (최대 5만원 할인).',
        period: '2025.05.01 ~ 2025.12.31',
        imageUrl: 'assets/images/musinsa.jpg',
        tags: ['15% 할인', '무신사', '신규가입'],
        paymentMethod: '전 카드 사용 가능',
        discountRate: 15.0,
      ),
      BenefitDetail(
        title: 'UNIQLO 주말 특가 20% 할인',
        company: 'UNIQLO',
        description: '주말에 유니클로 매장 및 온라인에서 특정 상품 20% 할인 혜택을 제공합니다.',
        period: '2025.05.01 ~ 2025.05.31 (매주 토,일)',
        imageUrl: 'assets/images/uniqlo.jpg',
        tags: ['20% 할인', '유니클로', '주말특가'],
        paymentMethod: 'UNIQLO 앱 결제 시',
        discountRate: 20.0,
      ),
    ],
    '게임': [
      BenefitDetail(
        title: '넥슨캐시 10% 추가 충전',
        company: '넥슨',
        description: '넥슨캐시 3만원 이상 충전 시 10% 추가 충전 혜택을 제공합니다.',
        period: '2025.05.01 ~ 2025.05.31',
        imageUrl: 'assets/images/nexon.jpg',
        tags: ['10% 추가', '넥슨', '게임캐시'],
        paymentMethod: '카카오페이, 토스',
        discountRate: 10.0,
      ),
      BenefitDetail(
        title: '스팀 월렛 충전 5% 캐시백',
        company: 'Steam',
        description: '스팀 월렛 5만원 이상 충전 시 5% 캐시백 혜택을 제공합니다.',
        period: '2025.05.15 ~ 2025.06.15',
        imageUrl: 'assets/images/steam.jpg',
        tags: ['5% 캐시백', '스팀', '게임'],
        paymentMethod: '현대카드, 삼성카드',
        discountRate: 5.0,
      ),
    ],
    '대중교통': [
      BenefitDetail(
        title: '버스/지하철 환승 100원 할인',
        company: '교통카드',
        description: '버스와 지하철 환승 시 100원 추가 할인 혜택을 제공합니다.',
        period: '2025.05.01 ~ 2025.08.31',
        imageUrl: 'assets/images/transit_card.jpg',
        tags: ['100원 할인', '환승', '대중교통'],
        paymentMethod: '티머니, 캐시비',
        discountRate: 5.0,
      ),
      BenefitDetail(
        title: 'KTX 주중 30% 할인',
        company: '코레일',
        description: '평일(월~목) KTX 승차권 30% 할인 혜택을 제공합니다.',
        period: '2025.06.01 ~ 2025.06.30',
        imageUrl: 'assets/images/korail.jpg',
        tags: ['30% 할인', 'KTX', '평일'],
        paymentMethod: '신한카드, KB국민카드',
        discountRate: 30.0,
      ),
    ],
    '렌터카': [
      BenefitDetail(
        title: '제주 렌터카 주중 40% 할인',
        company: '제주렌터카',
        description: '제주도 여행 시 주중(월~목) 렌터카 40% 할인 혜택을 제공합니다.',
        period: '2025.05.01 ~ 2025.06.30',
        imageUrl: 'assets/images/jeju_car.jpg',
        tags: ['40% 할인', '제주도', '렌터카'],
        paymentMethod: 'KB국민카드, 현대카드',
        discountRate: 40.0,
      ),
      BenefitDetail(
        title: '쏘카 신규가입 1시간 무료',
        company: '쏘카',
        description: '쏘카 신규가입 회원에게 1시간 무료 이용권을 제공합니다.',
        period: '2025.05.01 ~ 2025.12.31',
        imageUrl: 'assets/images/socar.jpg',
        tags: ['1시간 무료', '쏘카', '신규가입'],
        paymentMethod: '신규가입 회원 전용',
        discountRate: 100.0,
      ),
    ],
  };

  // 쇼핑 이미지 분류
  final Map<String, List<Map<String, dynamic>>> _shoppingImagesByCategory = {
    '패션/의류': [
      {'name': '아우터', 'imageUrl': 'assets/images/fashion_outer.jpg'},
      {'name': '상의', 'imageUrl': 'assets/images/fashion_top.jpg'},
      {'name': '하의', 'imageUrl': 'assets/images/fashion_bottom.jpg'},
      {'name': '신발', 'imageUrl': 'assets/images/fashion_shoes.jpg'},
      {'name': '가방', 'imageUrl': 'assets/images/fashion_bags.jpg'},
      {'name': '액세서리', 'imageUrl': 'assets/images/fashion_accessories.jpg'},
    ],
    '뷰티/화장품': [
      {'name': '스킨케어', 'imageUrl': 'assets/images/beauty_skincare.jpg'},
      {'name': '메이크업', 'imageUrl': 'assets/images/beauty_makeup.jpg'},
      {'name': '향수', 'imageUrl': 'assets/images/beauty_perfume.jpg'},
      {'name': '헤어케어', 'imageUrl': 'assets/images/beauty_haircare.jpg'},
    ],
    '디지털/가전': [
      {'name': '스마트폰', 'imageUrl': 'assets/images/digital_smartphone.jpg'},
      {'name': '노트북', 'imageUrl': 'assets/images/digital_laptop.jpg'},
      {'name': 'TV', 'imageUrl': 'assets/images/digital_tv.jpg'},
      {'name': '오디오', 'imageUrl': 'assets/images/digital_audio.jpg'},
    ],
  };

  // 엔터테인먼트 이미지 분류
  final Map<String, List<Map<String, dynamic>>> _entertainmentImagesByCategory =
      {
        '영화/공연': [
          {'name': '액션', 'imageUrl': 'assets/images/movie_action.jpg'},
          {'name': '코미디', 'imageUrl': 'assets/images/movie_comedy.jpg'},
          {'name': '로맨스', 'imageUrl': 'assets/images/movie_romance.jpg'},
          {'name': '공포/스릴러', 'imageUrl': 'assets/images/movie_horror.jpg'},
          {'name': '애니메이션', 'imageUrl': 'assets/images/movie_animation.jpg'},
        ],
        '스포츠': [
          {'name': '축구', 'imageUrl': 'assets/images/sports_soccer.jpg'},
          {'name': '야구', 'imageUrl': 'assets/images/sports_baseball.jpg'},
          {'name': '농구', 'imageUrl': 'assets/images/sports_basketball.jpg'},
          {'name': '배구', 'imageUrl': 'assets/images/sports_volleyball.jpg'},
        ],
        '게임': [
          {'name': '온라인게임', 'imageUrl': 'assets/images/game_online.jpg'},
          {'name': '콘솔게임', 'imageUrl': 'assets/images/game_console.jpg'},
          {'name': '모바일게임', 'imageUrl': 'assets/images/game_mobile.jpg'},
        ],
      };

  // 교통 이미지 분류
  final Map<String, List<Map<String, dynamic>>> _transportImagesByCategory = {
    '대중교통': [
      {'name': '버스', 'imageUrl': 'assets/images/transport_bus.jpg'},
      {'name': '지하철', 'imageUrl': 'assets/images/transport_subway.jpg'},
      {'name': '기차', 'imageUrl': 'assets/images/transport_train.jpg'},
    ],
    '택시/콜': [
      {'name': '일반택시', 'imageUrl': 'assets/images/transport_taxi.jpg'},
      {'name': '모범택시', 'imageUrl': 'assets/images/transport_premium_taxi.jpg'},
      {'name': '콜택시', 'imageUrl': 'assets/images/transport_call_taxi.jpg'},
    ],
    '렌터카': [
      {'name': '소형', 'imageUrl': 'assets/images/transport_small_car.jpg'},
      {'name': '중형', 'imageUrl': 'assets/images/transport_medium_car.jpg'},
      {'name': '대형', 'imageUrl': 'assets/images/transport_large_car.jpg'},
      {'name': 'SUV', 'imageUrl': 'assets/images/transport_suv.jpg'},
    ],
  };

  // 브랜드별 혜택 정보
  final Map<String, List<BenefitDetail>> _benefitsByBrand = {
    '본죽': [
      BenefitDetail(
        title: '본죽 5,000원 할인',
        company: '본죽',
        description: '본죽 20,000원 이상 주문 시 5,000원 할인을 제공합니다.',
        period: '2025.05.01 ~ 2025.06.30',
        imageUrl: 'assets/images/bonjuk.jpg',
        tags: ['5,000원 할인', '본죽', '한식'],
        paymentMethod: '신한카드, 삼성카드',
        discountRate: 25.0,
      ),
      BenefitDetail(
        title: '본죽 신메뉴 10% 할인',
        company: '본죽',
        description: '본죽 신메뉴 주문 시 10% 할인 혜택을 제공합니다.',
        period: '2025.06.01 ~ 2025.06.30',
        imageUrl: 'assets/images/bonjuk.jpg',
        tags: ['10% 할인', '본죽', '신메뉴'],
        paymentMethod: '모든 결제수단',
        discountRate: 10.0,
      ),
    ],
    '교촌치킨': [
      BenefitDetail(
        title: '교촌치킨 10% 할인',
        company: '교촌치킨',
        description: '교촌치킨 모든 메뉴 10% 할인 혜택을 제공합니다.',
        period: '2025.05.15 ~ 2025.07.15',
        imageUrl: 'assets/images/kyochon.jpg',
        tags: ['10% 할인', '교촌치킨', '치킨'],
        paymentMethod: '현대카드, 롯데카드',
        discountRate: 10.0,
      ),
      BenefitDetail(
        title: '교촌 신메뉴 출시 기념 2천원 할인',
        company: '교촌치킨',
        description: '교촌치킨 신메뉴 주문 시 2천원 할인 혜택을 제공합니다.',
        period: '2025.05.01 ~ 2025.05.31',
        imageUrl: 'assets/images/kyochon.jpg',
        tags: ['2천원 할인', '교촌치킨', '신메뉴'],
        paymentMethod: '모든 결제수단',
        discountRate: 8.0,
      ),
    ],
    '스타벅스': [
      BenefitDetail(
        title: '스타벅스 아메리카노 1+1',
        company: '스타벅스',
        description: '스타벅스 아메리카노 구매 시 1잔 더 제공합니다.',
        period: '2025.05.10 ~ 2025.05.20',
        imageUrl: 'assets/images/starbucks.jpg',
        tags: ['1+1', '스타벅스', '아메리카노'],
        paymentMethod: '현대카드, 삼성카드',
        discountRate: 50.0,
      ),
    ],
    '투썸플레이스': [
      BenefitDetail(
        title: '투썸플레이스 디저트 30% 할인',
        company: '투썸플레이스',
        description: '투썸플레이스 디저트 메뉴 30% 할인 혜택을 제공합니다.',
        period: '2025.05.01 ~ 2025.06.15',
        imageUrl: 'assets/images/twosome.jpg',
        tags: ['30% 할인', '투썸플레이스', '디저트'],
        paymentMethod: '신한카드, KB국민카드',
        discountRate: 30.0,
      ),
    ],
    '이디야': [
      BenefitDetail(
        title: '이디야 카페라떼 500원 할인',
        company: '이디야',
        description: '이디야 카페라떼 주문 시 500원 할인 혜택을 제공합니다.',
        period: '2025.06.01 ~ 2025.06.30',
        imageUrl: 'assets/images/ediya.jpg',
        tags: ['500원 할인', '이디야', '카페라떼'],
        paymentMethod: '삼성페이, 신한카드',
        discountRate: 10.0,
      ),
    ],
    'CGV': [
      BenefitDetail(
        title: 'CGV 영화 티켓 30% 할인',
        company: 'CGV',
        description: 'CGV 영화 티켓 구매 시 30% 할인 혜택을 드립니다.',
        period: '2025.05.05 ~ 2025.06.04',
        imageUrl: 'assets/images/cgv_logo.jpg',
        tags: ['30% 할인', 'CGV', '영화'],
        paymentMethod: 'SKT 멤버십, 현대카드',
        discountRate: 30.0,
      ),
    ],
    '메가박스': [
      BenefitDetail(
        title: '메가박스 1+1 이벤트',
        company: '메가박스',
        description: '메가박스 영화 티켓 1장 구매 시 1장 무료 혜택을 드립니다.',
        period: '2025.05.01 ~ 2025.05.15',
        imageUrl: 'assets/images/megabox_logo.jpg',
        tags: ['1+1', '메가박스', '영화'],
        paymentMethod: '삼성카드, KB국민카드',
        discountRate: 50.0,
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    _checkCalendarConnection();
  }

  // 캘린더 연결 상태 확인
  Future<void> _checkCalendarConnection() async {
    await _googleAuthService.init();
    setState(() {
      _isCalendarConnected = _googleAuthService.isCalendarConnected;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showBenefitDetail && _selectedBenefit != null) {
      return _buildBenefitDetailScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(),
        elevation: 0,
        centerTitle: true,
        leading: _buildBackButton(),
        actions: [
          TextButton(
            onPressed: () {
              _navigateToAllBenefits();
            },
            child: const Text('전체보기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          // 상단 탭 메뉴 - 하위 카테고리 화면일 때는 표시하지 않음
          if (!_showSubCategory &&
              !_showBrandList &&
              !_showBrandBenefits &&
              !_showAllBenefits)
            Container(
              height: 70,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_mainTabs.length, (index) {
                  final tab = _mainTabs[index];
                  final isSelected = _selectedTabIndex == index;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = index;
                        // 각 탭 선택 시 초기 카테고리 설정
                        if (index == 0) {
                          _selectedCategory = '한식';
                        } else if (index == 1) {
                          _selectedCategory = '패션/의류';
                        } else if (index == 2) {
                          _selectedCategory = '영화/공연';
                        } else if (index == 3) {
                          _selectedCategory = '대중교통';
                        }
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tab['icon'],
                          color:
                              isSelected ? AppTheme.primaryColor : Colors.grey,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tab['name'],
                          style: TextStyle(
                            color:
                                isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.grey,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                        if (isSelected)
                          Container(
                            height: 2,
                            width: 40,
                            margin: const EdgeInsets.only(top: 4),
                            color: AppTheme.primaryColor,
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),

          // 카테고리 경로 표시 (브레드크럼)
          if (_showSubCategory ||
              _showBrandList ||
              _showBrandBenefits ||
              _showAllBenefits)
            _buildBreadcrumb(),

          // 탭 컨텐츠
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  // 현재 상태에 따른 앱바 타이틀 반환
  Widget _buildAppBarTitle() {
    if (_showAllBenefits) {
      if (_allBenefitsCategory.isNotEmpty) {
        return Text('$_allBenefitsCategory 혜택 전체보기');
      } else {
        return Text('${_mainTabs[_selectedTabIndex]['name']} 혜택 전체보기');
      }
    } else if (_showBrandBenefits) {
      return Text(_selectedBrand);
    } else if (_showBrandList) {
      return Text('$_selectedCategory 브랜드');
    } else if (_showSubCategory) {
      return Text(_selectedCategory);
    } else {
      return Text('${_mainTabs[_selectedTabIndex]['name']} 카테고리');
    }
  }

  // 뒤로가기 버튼
  Widget? _buildBackButton() {
    if (_showAllBenefits) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          setState(() {
            _showAllBenefits = false;
            // 이전 상태에 따라 돌아가기
            if (_showBrandBenefits) {
              _showBrandBenefits = true;
            } else if (_showBrandList) {
              _showBrandList = true;
            } else if (_showSubCategory) {
              _showSubCategory = true;
            }
          });
        },
      );
    } else if (_showBrandBenefits) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          setState(() {
            _showBrandBenefits = false;
            _showBrandList = true;
          });
        },
      );
    } else if (_showBrandList) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          setState(() {
            _showBrandList = false;
            _showSubCategory = true;
          });
        },
      );
    } else if (_showSubCategory) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          setState(() {
            _showSubCategory = false;
          });
        },
      );
    }
    return null;
  }

  // 카테고리 경로 표시 (브레드크럼)
  Widget _buildBreadcrumb() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Row(
        children: [
          // 대분류 (음식, 쇼핑 등)
          GestureDetector(
            onTap: () {
              if (_showAllBenefits ||
                  _showBrandBenefits ||
                  _showBrandList ||
                  _showSubCategory) {
                setState(() {
                  _showAllBenefits = false;
                  _showBrandBenefits = false;
                  _showBrandList = false;
                  _showSubCategory = false;
                });
              }
            },
            child: Text(
              _mainTabs[_selectedTabIndex]['name'],
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          if (_showSubCategory ||
              _showBrandList ||
              _showBrandBenefits ||
              (_showAllBenefits && _allBenefitsCategory.isNotEmpty)) ...[
            const Text(' > ', style: TextStyle(color: Colors.grey)),
            // 중분류 (한식, 중식 등)
            GestureDetector(
              onTap: () {
                if (_showAllBenefits || _showBrandBenefits || _showBrandList) {
                  setState(() {
                    _showAllBenefits = false;
                    _showBrandBenefits = false;
                    _showBrandList = false;
                    _showSubCategory = true;
                  });
                }
              },
              child: Text(
                _selectedCategory,
                style: TextStyle(
                  color:
                      _showSubCategory &&
                              !_showBrandList &&
                              !_showBrandBenefits &&
                              !_showAllBenefits
                          ? Colors.black
                          : AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

          if (_showBrandList || _showBrandBenefits) ...[
            const Text(' > ', style: TextStyle(color: Colors.grey)),
            // 브랜드 목록
            Text(
              '브랜드',
              style: TextStyle(
                color:
                    _showBrandList && !_showBrandBenefits
                        ? Colors.black
                        : AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],

          if (_showBrandBenefits) ...[
            const Text(' > ', style: TextStyle(color: Colors.grey)),
            // 선택한 브랜드
            Text(
              _selectedBrand,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],

          if (_showAllBenefits) ...[
            const Text(' > ', style: TextStyle(color: Colors.grey)),
            // 전체보기
            const Text(
              '전체혜택',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 현재 상태에 따른 컨텐츠 반환
  Widget _buildContent() {
    if (_showAllBenefits) {
      return _buildAllBenefitsContent();
    } else if (_showBrandBenefits) {
      return _buildBrandBenefitsContent();
    } else if (_showBrandList) {
      return _buildBrandListContent();
    } else if (_showSubCategory) {
      return _buildSubCategoryContent();
    } else {
      return _buildTabContent();
    }
  }

  // 전체 혜택 목록 화면
  Widget _buildAllBenefitsContent() {
    List<BenefitDetail> allBenefits = [];

    // 메인 탭 혜택
    if (_allBenefitsCategory.isEmpty) {
      // 현재 선택된 탭에 해당하는 모든 혜택 가져오기
      switch (_selectedTabIndex) {
        case 0: // 음식
          _benefitsByCategory.forEach((category, benefits) {
            if (['한식', '중식', '일식', '양식', '카페/디저트'].contains(category)) {
              allBenefits.addAll(benefits);
            }
          });
          break;
        case 1: // 쇼핑
          _benefitsByCategory.forEach((category, benefits) {
            if (['패션/의류', '뷰티/화장품', '디지털/가전'].contains(category)) {
              allBenefits.addAll(benefits);
            }
          });
          break;
        case 2: // 엔터테인먼트
          _benefitsByCategory.forEach((category, benefits) {
            if (['영화/공연', '게임'].contains(category)) {
              allBenefits.addAll(benefits);
            }
          });
          break;
        case 3: // 교통
          _benefitsByCategory.forEach((category, benefits) {
            if (['대중교통', '렌터카'].contains(category)) {
              allBenefits.addAll(benefits);
            }
          });
          break;
      }
    }
    // 하위 카테고리 혜택
    else if (_benefitsByCategory.containsKey(_allBenefitsCategory)) {
      allBenefits = _benefitsByCategory[_allBenefitsCategory]!;
    }

    // 정렬 적용
    _sortBenefits(allBenefits);

    return Column(
      children: [
        // 정렬 옵션 바
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _allBenefitsCategory.isEmpty
                    ? '${_mainTabs[_selectedTabIndex]['name']} 혜택'
                    : '$_allBenefitsCategory 혜택',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              // 정렬 드롭다운
              DropdownButton<String>(
                value: _sortType,
                icon: const Icon(Icons.keyboard_arrow_down),
                underline: Container(height: 0),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _sortType = newValue;
                    });
                  }
                },
                items:
                    _sortOptions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),

        // 혜택 목록
        Expanded(
          child:
              allBenefits.isEmpty
                  ? Center(child: Text('혜택 정보가 없습니다.'))
                  : ListView.builder(
                    itemCount: allBenefits.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final benefit = allBenefits[index];
                      return _buildBenefitCard(benefit);
                    },
                  ),
        ),
      ],
    );
  }

  // 혜택 정렬 함수
  void _sortBenefits(List<BenefitDetail> benefits) {
    switch (_sortType) {
      case '인기순':
        // 일정등록 및 관심등록이 많은 순으로 정렬 (여기서는 임의의 값으로 구현)
        benefits.sort((a, b) => b.isFavorite ? 1 : -1);
        break;
      case '최신순':
        // 혜택 시작일이 최근인 순으로 정렬
        benefits.sort((a, b) {
          // 기간 문자열에서 시작일 추출 (예: '2025.05.01 ~ 2025.06.30')
          final aStartDate = _getStartDate(a.period);
          final bStartDate = _getStartDate(b.period);
          return bStartDate.compareTo(aStartDate); // 내림차순 정렬
        });
        break;
      case '마감임박순':
        // 종료일이 가까운 순으로 정렬
        benefits.sort((a, b) {
          final aEndDate = _getEndDate(a.period);
          final bEndDate = _getEndDate(b.period);
          return aEndDate.compareTo(bEndDate); // 오름차순 정렬 (더 가까운 날짜가 앞으로)
        });
        break;
    }
  }

  // 시작일 파싱 함수
  DateTime _getStartDate(String period) {
    try {
      // '2025.05.01 ~ 2025.06.30' 형식에서 시작일 추출
      final parts = period.split(' ~ ');
      final dateStr = parts[0].trim();
      final dateParts = dateStr.split('.');

      if (dateParts.length >= 3) {
        return DateTime(
          int.parse(dateParts[0]), // 연도
          int.parse(dateParts[1]), // 월
          int.parse(dateParts[2]), // 일
        );
      }
    } catch (e) {
      // 파싱 오류 시 현재 날짜 리턴
    }
    return DateTime.now();
  }

  // 종료일 파싱 함수
  DateTime _getEndDate(String period) {
    try {
      // '2025.05.01 ~ 2025.06.30' 형식에서 종료일 추출
      final parts = period.split(' ~ ');

      // 종료일이 없으면 시작일과 동일하게 설정
      if (parts.length < 2) {
        return _getStartDate(period);
      }

      final dateStr = parts[1].trim();
      final dateParts = dateStr.split('.');

      if (dateParts.length >= 3) {
        return DateTime(
          int.parse(dateParts[0]), // 연도
          int.parse(dateParts[1]), // 월
          int.parse(dateParts[2]), // 일
        );
      }
    } catch (e) {
      // 파싱 오류 시 먼 미래 날짜 리턴
    }
    return DateTime.now().add(const Duration(days: 365));
  }

  // 브랜드 혜택 목록 화면
  Widget _buildBrandBenefitsContent() {
    if (_benefitsByBrand.containsKey(_selectedBrand)) {
      final benefits = _benefitsByBrand[_selectedBrand]!;

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_selectedBrand 혜택',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                benefits.isEmpty
                    ? Center(child: Text('$_selectedBrand에 대한 혜택이 없습니다.'))
                    : ListView.builder(
                      itemCount: benefits.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final benefit = benefits[index];
                        return _buildBenefitCard(benefit);
                      },
                    ),
          ),
        ],
      );
    }

    return Center(child: Text('$_selectedBrand에 대한 혜택이 없습니다.'));
  }

  // 브랜드 목록 화면
  Widget _buildBrandListContent() {
    // 선택된 카테고리에 해당하는 브랜드 목록 가져오기
    List<Map<String, dynamic>> brands = [];

    if (_chainsByCategory.containsKey(_selectedCategory)) {
      brands = _chainsByCategory[_selectedCategory]!;
    }

    if (brands.isEmpty) {
      return Center(child: Text('$_selectedCategory에 해당하는 브랜드가 없습니다.'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_selectedCategory 브랜드',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: brands.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final brand = brands[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        brand['name'].substring(0, 1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    brand['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('할인 및 혜택 보기'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // 브랜드 상세 페이지로 이동
                    setState(() {
                      _selectedBrand = brand['name'];
                      _showBrandList = false;
                      _showBrandBenefits = true;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 하위 카테고리 화면 (음식 카테고리의 경우)
  Widget _buildSubCategoryContent() {
    // 현재 선택된 탭에 따라 다른 카테고리 목록 표시
    List<Map<String, dynamic>> categories = [];

    switch (_selectedTabIndex) {
      case 0: // 음식
        categories = _foodCategories;
        break;
      case 1: // 쇼핑
        categories = _shoppingCategories;
        break;
      case 2: // 엔터테인먼트
        categories = _entertainmentCategories;
        break;
      case 3: // 교통
        categories = _transportCategories;
        break;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_mainTabs[_selectedTabIndex]['name']} 카테고리',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              TextButton(
                onPressed: () {
                  _navigateToAllBenefits();
                },
                child: const Text('혜택 전체보기'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: categories.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _selectedCategory == category['name'];

              return ListTile(
                leading: Icon(
                  category['icon'],
                  color: isSelected ? AppTheme.primaryColor : Colors.grey,
                ),
                title: Text(
                  category['name'],
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  setState(() {
                    _selectedCategory = category['name'];

                    // 혜택이 있는 카테고리는 바로 혜택으로 이동
                    if (_benefitsByCategory.containsKey(category['name'])) {
                      _allBenefitsCategory = category['name'];
                      _showSubCategory = false;
                      _showAllBenefits = true;
                    }
                    // 혜택이 없으면 브랜드 목록으로 이동
                    else {
                      _showBrandList = true;
                      _showSubCategory = false;
                    }
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // 선택된 탭에 따라 다른 컨텐츠 표시
  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildFoodContent();
      case 1:
        return _buildShoppingContent();
      case 2:
        return _buildEntertainmentContent();
      case 3:
        return _buildTransportContent();
      default:
        return const SizedBox.shrink();
    }
  }

  // 음식 탭 컨텐츠
  Widget _buildFoodContent() {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '음식 카테고리',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              // 혜택 전체보기 버튼 제거
            ],
          ),
        ),
        // 카테고리 목록
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _foodCategories.length,
          itemBuilder: (context, index) {
            final category = _foodCategories[index];
            final isSelected = _selectedCategory == category['name'];

            return ListTile(
              onTap: () {
                setState(() {
                  _selectedCategory = category['name'];
                  // 바로 브랜드 목록으로 이동
                  _showBrandList = true;
                });
              },
              leading: Icon(
                category['icon'],
                color: isSelected ? AppTheme.primaryColor : Colors.grey,
              ),
              title: Text(
                category['name'],
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            );
          },
        ),
      ],
    );
  }

  // 쇼핑 탭 컨텐츠
  Widget _buildShoppingContent() {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '쇼핑 카테고리',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              // 혜택 전체보기 버튼 제거
            ],
          ),
        ),
        // 카테고리 목록
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _shoppingCategories.length,
          itemBuilder: (context, index) {
            final category = _shoppingCategories[index];
            final isSelected = _selectedCategory == category['name'];

            return ListTile(
              onTap: () {
                setState(() {
                  _selectedCategory = category['name'];
                  // 바로 브랜드 목록으로 이동
                  _showBrandList = true;
                });
              },
              leading: Icon(
                category['icon'],
                color: isSelected ? AppTheme.primaryColor : Colors.grey,
              ),
              title: Text(
                category['name'],
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            );
          },
        ),
      ],
    );
  }

  // 엔터테인먼트 탭 컨텐츠
  Widget _buildEntertainmentContent() {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '엔터테인먼트 카테고리',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              // 혜택 전체보기 버튼 제거
            ],
          ),
        ),
        // 카테고리 목록
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _entertainmentCategories.length,
          itemBuilder: (context, index) {
            final category = _entertainmentCategories[index];
            final isSelected = _selectedCategory == category['name'];

            return ListTile(
              onTap: () {
                setState(() {
                  _selectedCategory = category['name'];
                  // 바로 브랜드 목록으로 이동
                  _showBrandList = true;
                });
              },
              leading: Icon(
                category['icon'],
                color: isSelected ? AppTheme.primaryColor : Colors.grey,
              ),
              title: Text(
                category['name'],
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            );
          },
        ),
      ],
    );
  }

  // 교통 탭 컨텐츠
  Widget _buildTransportContent() {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '교통 카테고리',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              // 혜택 전체보기 버튼 제거
            ],
          ),
        ),
        // 카테고리 목록
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _transportCategories.length,
          itemBuilder: (context, index) {
            final category = _transportCategories[index];
            final isSelected = _selectedCategory == category['name'];

            return ListTile(
              onTap: () {
                setState(() {
                  _selectedCategory = category['name'];
                  // 바로 브랜드 목록으로 이동
                  _showBrandList = true;
                });
              },
              leading: Icon(
                category['icon'],
                color: isSelected ? AppTheme.primaryColor : Colors.grey,
              ),
              title: Text(
                category['name'],
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            );
          },
        ),
      ],
    );
  }

  // 각 탭별 혜택 전체보기 기능
  void _navigateToFoodBenefits() {
    setState(() {
      _showSubCategory = true;
      // 한식 카테고리로 이동
      _selectedCategory = '한식';
    });
  }

  void _navigateToShoppingBenefits() {
    setState(() {
      _showSubCategory = true;
      // 패션/의류 카테고리로 이동
      _selectedCategory = '패션/의류';
    });
  }

  void _navigateToEntertainmentBenefits() {
    setState(() {
      _showSubCategory = true;
      // 영화/공연 카테고리로 이동
      _selectedCategory = '영화/공연';
    });
  }

  void _navigateToTransportBenefits() {
    setState(() {
      _showSubCategory = true;
      // 대중교통 카테고리로 이동
      _selectedCategory = '대중교통';
    });
  }

  // 전체보기 기능 구현
  void _navigateToAllBenefits() {
    setState(() {
      // 현재 상태에 따라 다른 카테고리 저장
      if (_showBrandBenefits) {
        _allBenefitsCategory = _selectedBrand;
      } else if (_showBrandList) {
        _allBenefitsCategory = _selectedCategory;
      } else if (_showSubCategory) {
        _allBenefitsCategory = _selectedCategory;
      } else {
        _allBenefitsCategory = '';
      }

      // 전체보기 화면으로 전환
      _showAllBenefits = true;
      _showBrandBenefits = false;
      _showBrandList = false;
      _showSubCategory = false;
    });
  }

  // 혜택 카드 위젯
  Widget _buildBenefitCard(BenefitDetail benefit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedBenefit = benefit;
            _showBenefitDetail = true;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 회사 정보 및 할인율
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 회사 로고 영역
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        benefit.company.substring(0, 1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 타이틀 및 회사명
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          benefit.company,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          benefit.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // 할인률 태그
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${benefit.discountRate.toInt()}% 할인',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 구분선
            Divider(height: 1, thickness: 1, color: Colors.grey.shade200),

            // 혜택 기간
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  const Icon(Icons.date_range, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '기간: ${benefit.period}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // 하단 버튼 영역
            Container(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 태그 (최대 2개만 표시)
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      children:
                          benefit.tags
                              .take(2)
                              .map(
                                (tag) => Chip(
                                  label: Text(
                                    tag,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: Colors.grey.shade100,
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: const VisualDensity(
                                    horizontal: -4,
                                    vertical: -4,
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),

                  // 상세보기 버튼
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedBenefit = benefit;
                        _showBenefitDetail = true;
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('상세보기', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 혜택 상세 화면 구현
  Widget _buildBenefitDetailScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedBenefit!.title),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _showBenefitDetail = false;
            });
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              _selectedBenefit!.isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // 공유 기능
              _showShareOptions();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 혜택 이미지
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey.shade300,
              child: Center(
                child: Text(
                  _selectedBenefit!.company,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // 혜택 정보
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 할인율 태그
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_selectedBenefit!.discountRate.toInt()}% 할인',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 타이틀
                  Text(
                    _selectedBenefit!.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 기간
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        benefit['description'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            benefit['period'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              children:
                                  (benefit['tags'] as List<String>).map((tag) {
                                    return Chip(
                                      label: Text(
                                        tag,
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      padding: EdgeInsets.zero,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      backgroundColor: AppTheme.primaryColor
                                          .withOpacity(0.1),
                                    );
                                  }).toList(),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _showSaveBenefitDialog(benefit),
                            icon: const Icon(Icons.event_available, size: 16),
                            label: const Text('일정 저장'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
                        '기간: ${_selectedBenefit!.period}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 결제 수단
                  Row(
                    children: [
                      const Icon(
                        Icons.credit_card,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '필요 멤버십: ${_selectedBenefit!.paymentMethod}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 혜택 상세 설명
                  const Text(
                    '혜택 상세 설명',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _selectedBenefit!.description,
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 16),

                  // 유의사항
                  const Text(
                    '유의사항',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    '• 본 혜택은 현장에서 멤버십 카드(또는 앱) 제시 시 적용됩니다.\n'
                    '• 다른 할인 및 쿠폰과 중복 적용이 불가합니다.\n'
                    '• 일부 품목 및 매장에서는 적용이 제한될 수 있습니다.\n'
                    '• 기간 및 조건은 제공처 사정에 따라 변경될 수 있습니다.',
                    style: TextStyle(fontSize: 14),
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
                                backgroundColor: Colors.grey.shade200,
                              ),
                            )
                            .toList(),
                  ),

                  const SizedBox(height: 24),

                  // 비슷한 혜택
                  _buildSimilarBenefits(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 관심 등록 버튼
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _toggleFavorite,
                  icon: Icon(
                    _selectedBenefit!.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color:
                        _selectedBenefit!.isFavorite ? Colors.red : Colors.grey,
                  ),
                  label: Text(
                    _selectedBenefit!.isFavorite ? '관심 등록됨' : '관심 등록',
                    style: TextStyle(
                      color:
                          _selectedBenefit!.isFavorite
                              ? Colors.red
                              : Colors.grey,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(
                      color:
                          _selectedBenefit!.isFavorite
                              ? Colors.red
                              : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 일정에 추가하기 버튼
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _addToCalendar,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('일정에 추가하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 관심 등록 기능
  void _toggleFavorite() {
    setState(() {
      // 임시 데이터용
      final benefit = _selectedBenefit!;

      // BenefitDetail은 불변 객체이므로 새로운 객체 생성
      _selectedBenefit = BenefitDetail(
        title: benefit.title,
        company: benefit.company,
        description: benefit.description,
        period: benefit.period,
        imageUrl: benefit.imageUrl,
        tags: benefit.tags,
        paymentMethod: benefit.paymentMethod,
        discountRate: benefit.discountRate,
        isFavorite: !benefit.isFavorite,
      );

      final message =
          _selectedBenefit!.isFavorite ? '관심 혜택에 등록되었습니다' : '관심 혜택에서 삭제되었습니다';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));

      // 실제 구현에서는 여기서 관심 목록 데이터베이스에 저장
    });
  }

  // 일정에 추가하기 기능
  void _addToCalendar() {
    // 혜택 기간 문자열에서 시작일과 종료일 파싱
    final periodParts = _selectedBenefit!.period.split(' ~ ');
    final startDateStr = periodParts[0].trim();
    final endDateStr =
        periodParts.length > 1 ? periodParts[1].trim() : startDateStr;

    // 시작일 파싱
    DateTime startDate = _getStartDate(_selectedBenefit!.period);

    // 종료일 파싱
    DateTime endDate = _getEndDate(_selectedBenefit!.period);

    // 시간 기본값 설정 (12:00)
    TimeOfDay startTime = const TimeOfDay(hour: 12, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 13, minute: 0);

    // 시작일 선택 다이얼로그 표시
    _showDateTimePickerDialog(
      startDate: startDate,
      endDate: endDate,
      startTime: startTime,
      endTime: endTime,
    );
  }

  // 날짜 및 시간 선택 다이얼로그
  void _showDateTimePickerDialog({
    required DateTime startDate,
    required DateTime endDate,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) {
    // 날짜 포맷터
    final dateFormatter = DateFormat('yyyy.MM.dd');

    // 시간 포맷터 (12시간제)
    String formatTimeOfDay(TimeOfDay time) {
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final period = time.period == DayPeriod.am ? '오전' : '오후';
      return '$period $hour:${time.minute.toString().padLeft(2, '0')}';
    }

    // 상태 변수
    DateTime _selectedStartDate = startDate;
    DateTime _selectedEndDate = endDate;
    TimeOfDay _selectedStartTime = startTime;
    TimeOfDay _selectedEndTime = endTime;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('일정에 추가'),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('혜택: ${_selectedBenefit!.title}'),
                    const SizedBox(height: 20),

                    // 시작 날짜 선택
                    const Text(
                      '시작 날짜 및 시간',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: _selectedStartDate,
                                firstDate: DateTime.now().subtract(
                                  const Duration(days: 365),
                                ),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365 * 2),
                                ),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  _selectedStartDate = pickedDate;
                                  // 종료일이 시작일보다 빠르면 종료일도 수정
                                  if (_selectedEndDate.isBefore(
                                    _selectedStartDate,
                                  )) {
                                    _selectedEndDate = _selectedStartDate;
                                  }
                                });
                              }
                            },
                            child: Text(
                              dateFormatter.format(_selectedStartDate),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: _selectedStartTime,
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  _selectedStartTime = pickedTime;
                                });
                              }
                            },
                            child: Text(formatTimeOfDay(_selectedStartTime)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 종료 날짜 선택
                    const Text(
                      '종료 날짜 및 시간',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: _selectedEndDate,
                                firstDate: _selectedStartDate,
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365 * 2),
                                ),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  _selectedEndDate = pickedDate;
                                });
                              }
                            },
                            child: Text(dateFormatter.format(_selectedEndDate)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: _selectedEndTime,
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  _selectedEndTime = pickedTime;
                                });
                              }
                            },
                            child: Text(formatTimeOfDay(_selectedEndTime)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      '알림',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      value: '10분 전',
                      items:
                          [
                            '없음',
                            '5분 전',
                            '10분 전',
                            '30분 전',
                            '1시간 전',
                            '1일 전',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {},
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();

                    // 선택한 날짜와 시간으로 DateTime 객체 생성
                    final startDateTime = DateTime(
                      _selectedStartDate.year,
                      _selectedStartDate.month,
                      _selectedStartDate.day,
                      _selectedStartTime.hour,
                      _selectedStartTime.minute,
                    );

                    final endDateTime = DateTime(
                      _selectedEndDate.year,
                      _selectedEndDate.month,
                      _selectedEndDate.day,
                      _selectedEndTime.hour,
                      _selectedEndTime.minute,
                    );

                    // Google 캘린더 형식으로 변환 (ISO 8601 형식)
                    final startIso = startDateTime.toIso8601String();
                    final endIso = endDateTime.toIso8601String();

                    // 일정 정보 표시
                    _showCalendarSuccessDialog(startDateTime, endDateTime);

                    // 실제 구현에서는 여기서 Google 캘린더 API를 호출하여 일정 추가
                    // 예: GoogleCalendarApi.addEvent(title, startIso, endIso);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('추가'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 일정 추가 성공 다이얼로그
  void _showCalendarSuccessDialog(
    DateTime startDateTime,
    DateTime endDateTime,
  ) {
    // 날짜/시간 포맷터
    final dateTimeFormatter = DateFormat('yyyy.MM.dd HH:mm');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('일정 추가 완료'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${_selectedBenefit!.title} 일정이 캘린더에 추가되었습니다.'),
              const SizedBox(height: 8),
              Text('시작: ${dateTimeFormatter.format(startDateTime)}'),
              Text('종료: ${dateTimeFormatter.format(endDateTime)}'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 비슷한 혜택 위젯
  Widget _buildSimilarBenefits() {
    // 현재 선택된 혜택과 같은 카테고리의 다른 혜택들
    List<BenefitDetail> similarBenefits = [];

    // 현재 혜택의 카테고리 찾기
    String? currentCategory;
    for (var category in _benefitsByCategory.keys) {
      if (_benefitsByCategory[category]!.contains(_selectedBenefit)) {
        currentCategory = category;
        break;
      }
    }

    // 같은 카테고리에서 현재 혜택을 제외한 다른 혜택들 추가
    if (currentCategory != null &&
        _benefitsByCategory.containsKey(currentCategory)) {
      similarBenefits =
          _benefitsByCategory[currentCategory]!
              .where((benefit) => benefit != _selectedBenefit)
              .toList();
    }

    // 비슷한 혜택이 없는 경우
    if (similarBenefits.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 제목
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            '비슷한 혜택',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: similarBenefits.length,
            itemBuilder: (context, index) {
              final benefit = similarBenefits[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedBenefit = benefit;
                  });
                },
                child: Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 회사 정보
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  benefit.company.substring(0, 1),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                benefit.company,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 혜택 제목
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          benefit.title,
                          style: const TextStyle(fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      // 할인율 표시
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${benefit.discountRate.toInt()}% 할인',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 공유 옵션 표시 다이얼로그
  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    '공유하기',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildShareOption(
                      icon: Icons.chat_bubble,
                      label: '카카오톡',
                      color: Colors.yellow.shade700,
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('카카오톡으로 공유합니다')),
                        );
                      },
                    ),
                    _buildShareOption(
                      icon: Icons.sms,
                      label: '문자',
                      color: Colors.green,
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('문자로 공유합니다')),
                        );
                      },
                    ),
                    _buildShareOption(
                      icon: Icons.chat,
                      label: '라인',
                      color: Colors.green.shade700,
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('라인으로 공유합니다')),
                        );
                      },
                    ),
                    _buildShareOption(
                      icon: Icons.copy,
                      label: '링크복사',
                      color: Colors.grey.shade700,
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('링크가 복사되었습니다')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 공유 옵션 아이템
  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              radius: 24,
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  // 아낀 금액 요약 카드
  Widget _buildSavingsSummaryCard() {
    return GestureDetector(
      onTap: () {
        // 통계 화면 페이지 추가 후 활성화
        //Navigator.push(
        //  context,
        //  MaterialPageRoute(builder: (context) => const StatisticsScreen()),
        //);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('통계 화면 준비 중입니다.')));
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
                const Text(
                  '48,500',
                  style: TextStyle(
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

  // 같은 날짜에 동일한 제목의 이벤트가 있는지 확인
  Future<Map<String, dynamic>> _checkDuplicateEvent(
    String title,
    DateTime date,
  ) async {
    if (!_isCalendarConnected || _googleAuthService.heafitCalendarId == null) {
      return {'isDuplicate': false, 'duplicateEvents': []};
    }

    // 해당 날짜의 시작과 끝
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59);

    // Heafit 캘린더의 이벤트 가져오기
    final events = await _googleAuthService.getEvents(
      startTime: dayStart,
      endTime: dayEnd,
      calendarId: _googleAuthService.heafitCalendarId,
    );

    // 제목이 동일하거나 유사한 이벤트 검색
    final duplicateEvents =
        events.where((event) {
          // 제목이 완전히 동일한 경우
          if (event.summary == title) {
            return true;
          }

          // 제목에 키워드가 포함된 경우 (예: "스타벅스 50% 할인" vs "스타벅스 방문")
          final keywords = title.split(' ');
          for (final keyword in keywords) {
            if (keyword.length > 1 &&
                event.summary != null &&
                event.summary!.contains(keyword)) {
              return true;
            }
          }

          return false;
        }).toList();

    return {
      'isDuplicate': duplicateEvents.isNotEmpty,
      'duplicateEvents': duplicateEvents,
    };
  }

  // 혜택을 일정으로 저장하는 다이얼로그 표시
  void _showSaveBenefitDialog(Map<String, dynamic> benefit) {
    if (!_isCalendarConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('구글 캘린더 연결이 필요합니다. 프로필 탭에서 연결해주세요.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final titleController = TextEditingController(text: benefit['title']);
    final descriptionController = TextEditingController(
      text: benefit['description'],
    );

    // 현재 날짜와 시간을 기본값으로 설정
    DateTime selectedDate = DateTime.now();
    TimeOfDay startTime = TimeOfDay.now();
    TimeOfDay endTime = TimeOfDay(
      hour: TimeOfDay.now().hour + 1,
      minute: TimeOfDay.now().minute,
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('혜택 일정 저장'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: '제목'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: '혜택 설명'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          '날짜: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                          child: Text(
                            '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          '시작 시간: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () async {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (pickedTime != null) {
                              setState(() {
                                startTime = pickedTime;
                                // 종료 시간이 시작 시간보다 이전이면 조정
                                if (startTime.hour > endTime.hour ||
                                    (startTime.hour == endTime.hour &&
                                        startTime.minute >= endTime.minute)) {
                                  endTime = TimeOfDay(
                                    hour: startTime.hour + 1,
                                    minute: startTime.minute,
                                  );
                                }
                              });
                            }
                          },
                          child: Text(
                            '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          '종료 시간: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () async {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: endTime,
                            );
                            if (pickedTime != null) {
                              setState(() {
                                endTime = pickedTime;
                              });
                            }
                          },
                          child: Text(
                            '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // 일정 중복 확인
                    final result = await _checkDuplicateEvent(
                      titleController.text,
                      selectedDate,
                    );

                    if (result['isDuplicate']) {
                      // 중복 일정이 있는 경우 확인 다이얼로그 표시
                      final duplicateEvents = result['duplicateEvents'];
                      final shouldContinue = await _showDuplicateWarningDialog(
                        duplicateEvents,
                      );

                      if (!shouldContinue) {
                        Navigator.pop(context);
                        return;
                      }
                    }

                    // 일정 추가
                    final startDateTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      startTime.hour,
                      startTime.minute,
                    );

                    final endDateTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      endTime.hour,
                      endTime.minute,
                    );

                    // 혜택 태그 정보 추가
                    final tags = benefit['tags'] as List<String>;
                    final tagsInfo =
                        tags.isNotEmpty ? '태그: ${tags.join(', ')}\n' : '';
                    final period = benefit['period'] ?? '';

                    // 혜택 메타데이터를 포함한 설명 구성
                    final enhancedDescription =
                        '${descriptionController.text}\n\n'
                        '기간: $period\n'
                        '$tagsInfo'
                        '[Heafit 앱에서 저장한 혜택 정보]\n'
                        '저장 시간: ${DateTime.now()}';

                    final success = await _googleAuthService.addEventToCalendar(
                      title: titleController.text,
                      description: enhancedDescription,
                      startTime: startDateTime,
                      endTime: endDateTime,
                      calendarId: _googleAuthService.heafitCalendarId,
                    );

                    Navigator.pop(context);

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('혜택 일정이 추가되었습니다.'),
                          backgroundColor: AppTheme.primaryColor,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('일정 추가에 실패했습니다.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 중복 일정 경고 다이얼로그
  Future<bool> _showDuplicateWarningDialog(
    List<dynamic> duplicateEvents,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('유사한 일정 감지됨'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('선택한 날짜에 이미 유사한 혜택 일정이 존재합니다:'),
                    const SizedBox(height: 12),
                    ...duplicateEvents
                        .take(3)
                        .map(
                          (event) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.summary ?? '제목 없음',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (event.start?.dateTime != null)
                                  Text(
                                    '시간: ${event.start!.dateTime!.hour}:${event.start!.dateTime!.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    if (duplicateEvents.length > 3)
                      Text('외 ${duplicateEvents.length - 3}개 일정'),
                    const SizedBox(height: 12),
                    const Text('그래도 이 혜택 일정을 추가하시겠습니까?'),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('계속 추가'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
