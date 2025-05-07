import 'package:flutter/material.dart';
import 'package:heafit/constants/theme.dart';
import 'package:heafit/services/google_auth_service.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  bool _isDarkMode = false;
  bool _showNotifications = true;
  bool _suggestScheduleChanges = true;
  bool _isCalendarConnected = false;
  bool _isSyncingCalendars = false;

  // 동기화할 캘린더 목록
  final List<String> _selectedCalendarsForSync = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Colors.white,
              elevation: 0,
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
                    '홍길동',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'example@email.com',
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
                },
                child: Column(
                  children: [
                    Text(
                      '25,000원',
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
                    '5',
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
              },
            ),
          ),

          // 결제 수단 관리
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
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.credit_card,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              title: const Text('결제 수단 관리'),
              subtitle: const Text('카드 및 간편결제 설정'),
              trailing: const Icon(
                Icons.keyboard_arrow_right,
                color: Colors.grey,
              ),
              onTap: () {
                // 결제 수단 관리 모달 표시
              },
            ),
          ),
        ],
      ),
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
              subtitle: Text(_isCalendarConnected ? '연결됨' : '연결 필요'),
              trailing: const Icon(
                Icons.keyboard_arrow_right,
                color: Colors.grey,
              ),
              onTap: () {
                if (_isCalendarConnected) {
                  _disconnectGoogleCalendar();
                } else {
                  _connectGoogleCalendar();
                }
              },
            ),
          ),

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

  // 관심 카테고리 선택 다이얼로그
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
