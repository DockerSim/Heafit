import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heafit/constants/theme.dart';
<<<<<<< HEAD
import 'package:heafit/services/google_auth_service.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:shared_preferences/shared_preferences.dart';
=======
import 'package:heafit/screens/statistics_screen.dart';
>>>>>>> origin/feat/category

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

<<<<<<< HEAD
class _ProfileScreenState extends State<ProfileScreen> {
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  bool _isDarkMode = false;
  bool _showNotifications = true;
  bool _suggestScheduleChanges = true;
  bool _isCalendarConnected = false;
  bool _isSyncingCalendars = false;

  // 동기화할 캘린더 목록
  final List<String> _selectedCalendarsForSync = [];
=======
class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  // 컬러 팔레트
  static const Color primaryBlue = Color(0xFF1860C3);
  static const Color mediumBlue = Color(0xFF3D80CB);
  static const Color lightBlue = Color(0xFF71A9DB);
  static const Color accentOrange = Color(0xFFFFBF6B);
>>>>>>> origin/feat/category

  // 결제 수단 리스트
  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': '신한카드', 'type': '카드', 'isRegistered': true},
    {'name': '현대카드', 'type': '카드', 'isRegistered': false},
    {'name': '삼성카드', 'type': '카드', 'isRegistered': false},
    {'name': '네이버페이', 'type': '페이', 'isRegistered': true},
    {'name': '카카오페이', 'type': '페이', 'isRegistered': false},
    {'name': '토스', 'type': '페이', 'isRegistered': true},
  ];

  // 멤버십 리스트
  final List<Map<String, dynamic>> _memberships = [
    {'name': 'SKT', 'type': '통신사', 'isRegistered': true},
    {'name': 'KT', 'type': '통신사', 'isRegistered': false},
    {'name': 'LG U+', 'type': '통신사', 'isRegistered': false},
    {'name': '롯데 L.POINT', 'type': '멤버십', 'isRegistered': false},
    {'name': '현대카드 M포인트', 'type': '멤버십', 'isRegistered': true},
  ];

  // 멤버십 사용자 데이터
  List<String> _userMemberships = ['skt', 'kakao', 'shinhan'];

  // 멤버십 카테고리
  final List<String> _categories = ['전체', '통신사', '간편결제', '카드', '포인트'];
  String _selectedCategory = '전체';

  // 멤버십 검색
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // 통신사 멤버십
  final List<Map<String, dynamic>> _telecomMemberships = [
    {
      'id': 'skt',
      'name': 'SKT T멤버십',
      'category': '통신사',
      'iconColor': Color(0xFFFF4343),
      'description': 'T멤버십으로 다양한 제휴처에서 할인 혜택을 누리세요',
    },
    {
      'id': 'kt',
      'name': 'KT 멤버십',
      'category': '통신사',
      'iconColor': Color(0xFFFF0000),
      'description': 'KT 멤버십으로 다양한 제휴처에서 할인 혜택을 누리세요',
    },
    {
      'id': 'lgu',
      'name': 'LG U+ 멤버십',
      'category': '통신사',
      'iconColor': Color(0xFFE6007E),
      'description': 'U+ 멤버십으로 다양한 제휴처에서 할인 혜택을 누리세요',
    },
  ];

  // 간편결제 멤버십
  final List<Map<String, dynamic>> _paymentMemberships = [
    {
      'id': 'kakao',
      'name': '카카오페이',
      'category': '간편결제',
      'iconColor': Color(0xFFFFEB00),
      'description': '카카오페이로 결제 시 추가 혜택을 받으세요',
    },
    {
      'id': 'naver',
      'name': '네이버페이',
      'category': '간편결제',
      'iconColor': Color(0xFF1EC800),
      'description': '네이버페이로 결제 시 추가 혜택을 받으세요',
    },
    {
      'id': 'samsung',
      'name': '삼성페이',
      'category': '간편결제',
      'iconColor': Color(0xFF142C8E),
      'description': '삼성페이로 결제 시 추가 혜택을 받으세요',
    },
    {
      'id': 'toss',
      'name': '토스',
      'category': '간편결제',
      'iconColor': Color(0xFF0064FF),
      'description': '토스로 결제 시 추가 혜택을 받으세요',
    },
  ];

  // 카드 멤버십
  final List<Map<String, dynamic>> _cardMemberships = [
    {
      'id': 'shinhan',
      'name': '신한카드',
      'category': '카드',
      'iconColor': Color(0xFF0046FF),
      'description': '신한카드로 결제 시 할인 혜택을 누리세요',
    },
    {
      'id': 'hyundai',
      'name': '현대카드',
      'category': '카드',
      'iconColor': Color(0xFF000000),
      'description': '현대카드로 결제 시 할인 혜택을 누리세요',
    },
    {
      'id': 'kb',
      'name': 'KB국민카드',
      'category': '카드',
      'iconColor': Color(0xFFFFCB00),
      'description': 'KB국민카드로 결제 시 할인 혜택을 누리세요',
    },
    {
      'id': 'samsung_card',
      'name': '삼성카드',
      'category': '카드',
      'iconColor': Color(0xFF071D49),
      'description': '삼성카드로 결제 시 할인 혜택을 누리세요',
    },
    {
      'id': 'lotte',
      'name': '롯데카드',
      'category': '카드',
      'iconColor': Color(0xFFE40F22),
      'description': '롯데카드로 결제 시 할인 혜택을 누리세요',
    },
  ];

  // 포인트 멤버십
  final List<Map<String, dynamic>> _pointMemberships = [
    {
      'id': 'okcashbag',
      'name': 'OK캐쉬백',
      'category': '포인트',
      'iconColor': Color(0xFF00754A),
      'description': 'OK캐쉬백 적립 및 사용 가능한 제휴처',
    },
    {
      'id': 'hpoint',
      'name': 'H.Point',
      'category': '포인트',
      'iconColor': Color(0xFFFF5A5A),
      'description': '현대백화점그룹 통합 포인트',
    },
    {
      'id': 'cjone',
      'name': 'CJ ONE',
      'category': '포인트',
      'iconColor': Color(0xFFFF0000),
      'description': 'CJ 계열사 통합 포인트',
    },
    {
      'id': 'happy',
      'name': '해피포인트',
      'category': '포인트',
      'iconColor': Color(0xFFE51F20),
      'description': '롯데리아, 엔제리너스 등에서 적립 및 사용',
    },
  ];

  // 모든 멤버십
  List<Map<String, dynamic>> _availableMemberships = [];

  // 관심 카테고리
  final List<String> _allCategories = [
    '카페',
    '음식점',
    '쇼핑',
    '영화',
    '뷰티',
    '여행',
    '교통',
    '통신',
    '생활',
  ];
  final List<String> _selectedCategories = ['카페', '영화', '쇼핑'];

  // 임시 프로필 데이터
  final Map<String, dynamic> _userData = {
    'name': '김혜택',
    'email': 'benefit@example.com',
    'savedAmount': 120000,
    'favoriteCategories': ['레스토랑', '쇼핑', '영화/공연'],
    'schedulesCount': 12,
    'benefitsCount': 24,
  };

  bool _isDarkMode = false;
  bool _showNotifications = true;
  bool _suggestScheduleChanges = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scrollController.addListener(() {
      setState(() {
        _isScrolled = _scrollController.offset > 0;
      });
    });

    // 멤버십 데이터 초기화
    _availableMemberships = [
      ..._telecomMemberships,
      ..._paymentMemberships,
      ..._cardMemberships,
      ..._pointMemberships,
    ];
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // 현재 선택된 카테고리와 검색어에 맞는 멤버십 필터링
  List<Map<String, dynamic>> _getFilteredMemberships() {
    List<Map<String, dynamic>> filteredByCategory;

    if (_selectedCategory == '전체') {
      filteredByCategory = _availableMemberships;
    } else {
      filteredByCategory =
          _availableMemberships
              .where(
                (membership) => membership['category'] == _selectedCategory,
              )
              .toList();
    }

    if (_searchQuery.isEmpty) {
      return filteredByCategory;
    } else {
      return filteredByCategory
          .where(
            (membership) =>
                membership['name'].toString().toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                membership['description'].toString().toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }
  }

  // 멤버십 추가/제거
  void _toggleMembership(String membershipId) {
    setState(() {
      if (_userMemberships.contains(membershipId)) {
        _userMemberships.remove(membershipId);
      } else {
        _userMemberships.add(membershipId);
      }
    });
  }

  // 멤버십 카테고리에 따른 아이콘
  IconData _getMembershipIcon(String category) {
    switch (category) {
      case '통신사':
        return Icons.cell_tower;
      case '간편결제':
        return Icons.payment;
      case '카드':
        return Icons.credit_card;
      case '포인트':
        return Icons.loyalty;
      default:
        return Icons.card_membership;
    }
  }

  @override
  void initState() {
    super.initState();
    _checkCalendarConnection();
  }

  Future<void> _checkCalendarConnection() async {
    await _googleAuthService.init();
    setState(() {
      _isCalendarConnected = _googleAuthService.isCalendarConnected;
    });
  }

  // 구글 계정으로 로그인하고 캘린더 연결
  Future<void> _connectGoogleCalendar() async {
    final success = await _googleAuthService.signIn();

    setState(() {
      _isCalendarConnected = success;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('구글 캘린더가 성공적으로 연결되었습니다!'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('구글 캘린더 연결에 실패했습니다. 다시 시도해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 구글 계정 로그아웃
  Future<void> _disconnectGoogleCalendar() async {
    await _googleAuthService.signOut();

    setState(() {
      _isCalendarConnected = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('구글 계정 연결이 해제되었습니다.'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  // 캘린더 동기화 설정 다이얼로그
  void _showSyncCalendarDialog() {
    if (!_isCalendarConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('구글 계정에 연결되어 있지 않습니다. 먼저 계정을 연결해주세요.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 현재 동기화 설정 불러오기
    _selectedCalendarsForSync.clear();
    _selectedCalendarsForSync.addAll(_googleAuthService.syncSourceCalendarIds);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('일정 동기화 설정'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Heafit 캘린더에 동기화할 캘린더',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '선택한 캘린더의 일정이 앱 전용 캘린더에 복사되고 지속적으로 동기화됩니다.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child:
                          _googleAuthService.userCalendars.isEmpty
                              ? const Center(child: Text('캘린더 목록을 불러오는 중...'))
                              : ListView.builder(
                                itemCount:
                                    _googleAuthService.userCalendars.length,
                                itemBuilder: (context, index) {
                                  final calendar =
                                      _googleAuthService.userCalendars[index];

                                  // Heafit 캘린더는 제외
                                  if (calendar.id ==
                                      _googleAuthService.heafitCalendarId) {
                                    return const SizedBox.shrink();
                                  }

                                  final calendarId = calendar.id ?? '';
                                  final isSelected = _selectedCalendarsForSync
                                      .contains(calendarId);

                                  // 캘린더 색상 표시
                                  Color calendarColor = AppTheme.primaryColor;
                                  if (calendar.backgroundColor != null) {
                                    try {
                                      final colorCode = calendar
                                          .backgroundColor!
                                          .replaceFirst('#', '0xFF');
                                      calendarColor = Color(
                                        int.parse(colorCode),
                                      );
                                    } catch (e) {
                                      debugPrint('색상 변환 오류: $e');
                                    }
                                  }

                                  return CheckboxListTile(
                                    title: Text(calendar.summary ?? '이름 없음'),
                                    subtitle: Text(
                                      calendar.id == 'primary' ? '기본 캘린더' : '',
                                    ),
                                    secondary: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: calendarColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    value: isSelected,
                                    activeColor: AppTheme.primaryColor,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == true) {
                                          _selectedCalendarsForSync.add(
                                            calendarId,
                                          );
                                        } else {
                                          _selectedCalendarsForSync.remove(
                                            calendarId,
                                          );
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                    ),
                    // 선택된 캘린더 상태 표시
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child:
                          _selectedCalendarsForSync.isEmpty
                              ? const Text(
                                '선택된 캘린더가 없습니다. 동기화를 해제합니다.',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 13,
                                ),
                              )
                              : Text(
                                '${_selectedCalendarsForSync.length}개의 캘린더가 선택됨',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 13,
                                ),
                              ),
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('취소'),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          if (_selectedCalendarsForSync.isEmpty) {
                            // 선택된 캘린더가 없을 때 - 동기화 해제 설정
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('모든 캘린더 동기화가 해제되었습니다.'),
                                backgroundColor: Colors.blue,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            _googleAuthService.syncSourceCalendarIds.clear();
                            // 저장 처리
                            SharedPreferences.getInstance().then((prefs) {
                              prefs.setStringList(
                                'sync_source_calendar_ids',
                                [],
                              );
                            });
                          } else {
                            // 선택된 캘린더가 있을 때 - 동기화 진행
                            _showSyncConfirmationDialog();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child:
                            _selectedCalendarsForSync.isEmpty
                                ? const Text('동기화 해제')
                                : const Text('적용'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 동기화 확인 다이얼로그
  void _showSyncConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('캘린더 동기화 확인'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sync, color: AppTheme.primaryColor, size: 48),
              const SizedBox(height: 16),
              const Text(
                '선택한 캘린더의 일정을 Heafit 캘린더로 동기화합니다.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                '이후 해당 캘린더에 생성되는 새 일정도 자동으로 동기화되며, 이 정보는 AI 추천 기능에 활용됩니다.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              const Text(
                '동기화 범위: 현재 월 및 이전 달의 일정만 동기화됩니다. 삭제된 일정은 자동으로 앱에서도 제거됩니다.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('취소'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _syncSelectedCalendars();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('동기화 수락'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // 선택한 캘린더를 Heafit 캘린더로 동기화
  Future<void> _syncSelectedCalendars() async {
    if (_selectedCalendarsForSync.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모든 캘린더 동기화가 해제되었습니다.'),
          backgroundColor: Colors.blue,
        ),
      );

      // 동기화 설정 초기화
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('sync_source_calendar_ids', []);
      return;
    }

    if (!_isCalendarConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('구글 캘린더 연결이 필요합니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSyncingCalendars = true;
    });

    try {
      // 동기화 기간 설정: 현재 월 및 이전 월의 일정만 동기화
      final now = DateTime.now();
      // 현재 년도의 1월 1일 (1월이면 전년도의 12월 1일)
      final startMonth = now.month > 1 ? 1 : 12;
      final startYear = now.month > 1 ? now.year : now.year - 1;
      final startTime = DateTime(startYear, startMonth, 1);

      // 현재 월의 마지막 날
      final endTime = DateTime(now.year, now.month + 1, 0);

      final syncedCount = await _googleAuthService.syncCalendarToHeafit(
        sourceCalendarIds: _selectedCalendarsForSync,
        startTime: startTime,
        endTime: endTime,
      );

      setState(() {
        _isSyncingCalendars = false;
      });

      // 동기화 완료 알림
      if (syncedCount > 0) {
        _showSyncCompletedDialog(syncedCount);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('동기화할 일정이 없습니다.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSyncingCalendars = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('동기화 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 동기화 완료 다이얼로그
  void _showSyncCompletedDialog(int count) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('동기화 완료'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 16),
              Text(
                '$count개의 일정이 Heafit 캘린더에 동기화되었습니다',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                '이후 추가되는 일정도 자동으로 동기화됩니다.\n동기화된 일정은 AI의 일정 변경 추천 및 혜택 추천에 활용됩니다.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('확인'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              floating: true,
              elevation: _isScrolled ? 4 : 0,
              backgroundColor: _isScrolled ? Colors.white : Colors.transparent,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
              ),
              expandedHeight: 0,
              title: Text(
                '내 정보',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              centerTitle: true,
              actions: [],
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileCard(),
              _buildStatisticsCard(),
              _buildMenuSection(),
              _buildAppSettings(),
              _buildInfoSection(),
              _buildActivitySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 프로필 이미지
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, size: 40, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 16),

            // 사용자 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userData['name'],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userData['email'],
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // 프로필 편집 아이콘
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                // 프로필 편집 화면으로 이동
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 절약 금액
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // 이번달 아낀 금액 페이지로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StatisticsScreen(),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Text(
                      '${_userData['savedAmount']}원',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '절약 금액',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            // 구분선
            Container(
              height: 40,
              width: 1,
              color: Colors.grey.withOpacity(0.2),
            ),

            // 스케줄 수
            Expanded(
              child: Column(
                children: [
                  Text(
                    '${_userData['schedulesCount']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '일정',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '혜택 관리',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // 멤버십 관리
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.card_membership,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              title: const Text('멤버십 관리'),
              subtitle: const Text('멤버십 및 통신사 혜택 설정'),
              trailing: const Icon(
                Icons.keyboard_arrow_right,
                color: Colors.grey,
              ),
              onTap: () {
                // 멤버십 관리 모달 표시
                _showMembershipManagementDialog();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showMembershipManagementDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // 필터링된 멤버십 목록
            final filteredMemberships = _getFilteredMemberships();

            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (_, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // 앱바
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Text(
                              '멤버십 관리',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('멤버십 정보가 저장되었습니다'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pop(context);
                              },
                              child: const Text(
                                '저장',
                                style: TextStyle(
                                  color: primaryBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 검색 필드
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: '멤버십 검색',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon:
                                _searchQuery.isNotEmpty
                                    ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                    : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),

                      // 카테고리 선택 탭
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            final isSelected = category == _selectedCategory;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? primaryBlue
                                          : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.black54,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // 등록된 멤버십 수
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '등록된 멤버십 ${_userMemberships.length}개',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),

                      // 멤버십 목록
                      Expanded(
                        child:
                            filteredMemberships.isEmpty
                                ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        '검색 결과가 없습니다',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : ListView.builder(
                                  controller: scrollController,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: filteredMemberships.length,
                                  itemBuilder: (context, index) {
                                    final membership =
                                        filteredMemberships[index];
                                    final isSelected = _userMemberships
                                        .contains(membership['id']);

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      elevation: 2,
                                      shadowColor: Colors.black.withOpacity(
                                        0.1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(12),
                                        onTap: () {
                                          setState(() {
                                            _toggleMembership(membership['id']);
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              // 멤버십 아이콘
                                              Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: membership['iconColor']
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Center(
                                                  child: Icon(
                                                    _getMembershipIcon(
                                                      membership['category'],
                                                    ),
                                                    color:
                                                        membership['iconColor'],
                                                    size: 24,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),

                                              // 멤버십 정보
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      membership['name'],
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      membership['description'],
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // 선택 체크박스
                                              Checkbox(
                                                value: isSelected,
                                                activeColor: primaryBlue,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _toggleMembership(
                                                      membership['id'],
                                                    );
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
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAppSettings() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '앱 설정',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // 알림 설정
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('알림 받기'),
                  subtitle: const Text('혜택 및 일정 관련 알림 수신'),
                  value: _showNotifications,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _showNotifications = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('일정 변경 제안'),
                  subtitle: const Text('더 좋은 혜택을 위한 일정 변경 추천'),
                  value: _suggestScheduleChanges,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _suggestScheduleChanges = value;
                    });
                  },
                ),
              ],
            ),
          ),

          // 관심 카테고리 설정
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.category,
                  color: Colors.deepPurple,
                  size: 20,
                ),
              ),
              title: const Text('관심 카테고리 설정'),
              subtitle: const Text('알림을 받을 카테고리 선택'),
              trailing: const Icon(
                Icons.keyboard_arrow_right,
                color: Colors.grey,
              ),
              onTap: () {
                _showCategorySelectionDialog();
              },
            ),
          ),

<<<<<<< HEAD
        // 캘린더 설정
        _buildSubSectionHeader('캘린더 설정'),
        ListTile(
          title: const Text('구글 계정 연결'),
          subtitle: Text(_isCalendarConnected ? '연결됨' : '연결 필요'),
          trailing:
              _isCalendarConnected
                  ? TextButton(
                    onPressed: _disconnectGoogleCalendar,
                    child: const Text(
                      '로그아웃',
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                  : const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _isCalendarConnected ? null : _connectGoogleCalendar,
        ),

        // 캘린더 동기화 설정
        ListTile(
          title: const Text('캘린더 동기화 설정'),
          subtitle: const Text('다른 캘린더의 일정을 Heafit 캘린더로 복사'),
          trailing:
              _isSyncingCalendars
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                  )
                  : const Icon(Icons.arrow_forward_ios, size: 16),
          enabled: _isCalendarConnected,
          onTap: _showSyncCalendarDialog,
        ),
=======
          // 캘린더 설정
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_month,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              title: const Text('구글 계정 연결'),
              subtitle: Text(_isDarkMode ? '연결됨' : '연결 필요'),
              trailing: const Icon(
                Icons.keyboard_arrow_right,
                color: Colors.grey,
              ),
              onTap: () {
                // 구글 계정 연결 기능
              },
            ),
          ),
>>>>>>> origin/feat/category

          // 테마 설정
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              secondary: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.color_lens,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              title: const Text('다크 모드'),
              subtitle: const Text('어두운 테마 사용'),
              value: _isDarkMode,
              activeColor: AppTheme.primaryColor,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '정보',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          Card(
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  title: const Text('앱 버전'),
                  subtitle: const Text('1.0.0 (빌드 1)'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.email_outlined,
                      color: Colors.teal,
                      size: 20,
                    ),
                  ),
                  title: const Text('개발자 정보'),
                  subtitle: const Text('heafit@example.com'),
                  onTap: () {
                    // 이메일 앱 열기
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.privacy_tip_outlined,
                      color: Colors.indigo,
                      size: 20,
                    ),
                  ),
                  title: const Text('개인정보 처리방침'),
                  trailing: const Icon(
                    Icons.keyboard_arrow_right,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    // 개인정보 처리방침 페이지로 이동
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: Colors.purple,
                      size: 20,
                    ),
                  ),
                  title: const Text('이용약관'),
                  trailing: const Icon(
                    Icons.keyboard_arrow_right,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    // 이용약관 페이지로 이동
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '최근 활동',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // 활동 내역 카드
          Card(
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // 활동 항목 1
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.teal,
                      size: 20,
                    ),
                  ),
                  title: const Text('스타벅스 혜택 관심 등록'),
                  subtitle: const Text('2023년 11월 15일'),
                  trailing: const Icon(
                    Icons.keyboard_arrow_right,
                    color: Colors.grey,
                  ),
                ),
                const Divider(height: 1),

                // 활동 항목 2
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                  title: const Text('CGV 영화 일정 등록'),
                  subtitle: const Text('2023년 11월 10일'),
                  trailing: const Icon(
                    Icons.keyboard_arrow_right,
                    color: Colors.grey,
                  ),
                ),
                const Divider(height: 1),

                // 활동 항목 3
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.pink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.local_offer,
                      color: Colors.pink,
                      size: 20,
                    ),
                  ),
                  title: const Text('올리브영 혜택 정보 확인'),
                  subtitle: const Text('2023년 11월 5일'),
                  trailing: const Icon(
                    Icons.keyboard_arrow_right,
                    color: Colors.grey,
                  ),
                ),

                // 더보기 버튼
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextButton(
                    onPressed: () {
                      // 활동 내역 전체 보기
                    },
                    child: const Text('전체 활동 내역 보기'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCategorySelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('관심 카테고리 선택'),
              content: SizedBox(
                width: double.maxFinite,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _allCategories.map((category) {
                        final isSelected = _selectedCategories.contains(
                          category,
                        );
                        return FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCategories.add(category);
                              } else {
                                _selectedCategories.remove(category);
                              }
                            });
                          },
                          selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                          checkmarkColor: AppTheme.primaryColor,
                        );
                      }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 선택한 카테고리 저장
                    Navigator.pop(context);
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
      },
    );
  }
}
