import 'package:flutter/material.dart';
import 'package:heafit/constants/theme.dart';

// MembershipManagementPage 클래스 정의
class MembershipManagementPage extends StatefulWidget {
  const MembershipManagementPage({super.key});

  @override
  State<MembershipManagementPage> createState() =>
      _MembershipManagementPageState();
}

class _MembershipManagementPageState extends State<MembershipManagementPage> {
  // 멤버십 데이터
  List<String> _userMemberships = ['skt', 'kakao', 'shinhan'];
  List<Map<String, dynamic>> _availableMemberships = [];

  // 선택된 멤버십 카테고리
  String _selectedCategory = '전체';

  // 컬러 팔레트
  static const Color primaryBlue = Color(0xFF1860C3);
  static const Color mediumBlue = Color(0xFF3D80CB);
  static const Color lightBlue = Color(0xFF71A9DB);
  static const Color accentOrange = Color(0xFFFFBF6B);

  // 멤버십 카테고리
  final List<String> _categories = ['전체', '통신사', '간편결제', '카드', '포인트'];

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

  @override
  void initState() {
    super.initState();

    // 모든 멤버십 통합
    _availableMemberships = [
      ..._telecomMemberships,
      ..._paymentMemberships,
      ..._cardMemberships,
      ..._pointMemberships,
    ];
  }

  // 현재 선택된 카테고리에 맞는 멤버십 필터링
  List<Map<String, dynamic>> _getFilteredMemberships() {
    if (_selectedCategory == '전체') {
      return _availableMemberships;
    } else {
      return _availableMemberships
          .where((membership) => membership['category'] == _selectedCategory)
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

  @override
  Widget build(BuildContext context) {
    // 필터링된 멤버십 목록
    final filteredMemberships = _getFilteredMemberships();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '멤버십 관리',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 변경사항 저장 로직
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('멤버십 정보가 저장되었습니다'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context, _userMemberships);
            },
            child: const Text(
              '저장',
              style: TextStyle(
                color: primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryBlue : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              isSelected
                                  ? primaryBlue
                                  : Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 등록된 멤버십 수 및 안내 메시지
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '등록된 멤버십: ${_userMemberships.length}개',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '멤버십을 등록하면 관련 혜택을 자동으로 추천해 드립니다.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // 멤버십 목록
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredMemberships.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final membership = filteredMemberships[index];
                final bool isRegistered = _userMemberships.contains(
                  membership['id'],
                );

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: membership['iconColor'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(membership['category']),
                      color: membership['iconColor'],
                      size: 24,
                    ),
                  ),
                  title: Text(
                    membership['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    membership['description'],
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  trailing: Switch(
                    value: isRegistered,
                    activeColor: primaryBlue,
                    onChanged: (value) {
                      _toggleMembership(membership['id']);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 카테고리에 따른 아이콘 반환
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '통신사':
        return Icons.phone_android;
      case '간편결제':
        return Icons.account_balance_wallet;
      case '카드':
        return Icons.credit_card;
      case '포인트':
        return Icons.star;
      default:
        return Icons.card_membership;
    }
  }
}

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();

  // 사용자 정보 컨트롤러
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // 알림 설정
  bool _notificationEnabled = true;
  bool _emailNotificationEnabled = false;

  // 캘린더 연동 상태
  bool _googleCalendarConnected = false;
  String? _connectedEmail;
  bool _isLoading = false;

  // 컬러 팔레트
  static const Color primaryBlue = Color(0xFF1860C3);
  static const Color mediumBlue = Color(0xFF3D80CB);
  static const Color lightBlue = Color(0xFF71A9DB);
  static const Color accentOrange = Color(0xFFFFBF6B);

  // 임시 사용자 프로필 데이터
  final Map<String, dynamic> _userData = {
    'name': '김혜택',
    'email': 'benefit@example.com',
    'phone': '010-1234-5678',
    'memberships': ['skt', 'kakao', 'shinhan'],
  };

  @override
  void initState() {
    super.initState();

    // 샘플 데이터로 초기화
    _nameController.text = _userData['name'];
    _emailController.text = _userData['email'];
    _phoneController.text = _userData['phone'];

    // 구글 캘린더 연결 상태 확인 (실제로는 Mock 데이터 사용)
    _checkGoogleCalendarConnection();
  }

  // Mock 구글 캘린더 연결 상태 확인
  Future<void> _checkGoogleCalendarConnection() async {
    setState(() => _isLoading = true);

    // 실제 구현에서는 서비스를 통해 확인해야 함
    await Future.delayed(const Duration(milliseconds: 500));
    _googleCalendarConnected = false;

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '프로필 편집',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              '저장',
              style: TextStyle(
                color: primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 프로필 이미지 섹션
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: lightBlue,
                              child: const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: primaryBlue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 기본 정보 섹션
                      const Text(
                        '기본 정보',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 이름 필드
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: '이름',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '이름을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 이메일 필드
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: '이메일',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '이메일을 입력해주세요';
                          }
                          if (!value.contains('@')) {
                            return '유효한 이메일 주소를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 전화번호 필드
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: '전화번호',
                          prefixIcon: Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '전화번호를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // 멤버십 관리 섹션
                      const Text(
                        '멤버십 관리',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),

                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: accentOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.card_membership,
                            color: accentOrange,
                          ),
                        ),
                        title: const Text('멤버십 등록 및 관리'),
                        subtitle: Text(
                          '${_userData['memberships'].length}개의 멤버십이 등록되어 있습니다',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          // 멤버십 관리 화면으로 이동
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const MembershipManagementPage(),
                            ),
                          );

                          // 결과 처리
                          if (result != null) {
                            setState(() {
                              _userData['memberships'] = result;
                            });
                          }
                        },
                      ),
                      const Divider(height: 32),

                      // 알림 설정 섹션
                      const Text(
                        '알림 설정',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),

                      SwitchListTile(
                        title: const Text('앱 푸시 알림'),
                        subtitle: const Text('새로운 혜택 및 할인 정보를 받아보세요'),
                        value: _notificationEnabled,
                        activeColor: primaryBlue,
                        onChanged: (value) {
                          setState(() {
                            _notificationEnabled = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        title: const Text('이메일 알림'),
                        subtitle: const Text('주간 혜택 요약 및 맞춤 추천을 이메일로 받기'),
                        value: _emailNotificationEnabled,
                        activeColor: primaryBlue,
                        onChanged: (value) {
                          setState(() {
                            _emailNotificationEnabled = value;
                          });
                        },
                      ),
                      const Divider(height: 32),

                      // 외부 서비스 연동 섹션
                      const Text(
                        '외부 서비스 연동',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.event,
                                      color: Colors.red,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      '구글 캘린더',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Switch(
                                  value: _googleCalendarConnected,
                                  activeColor: primaryBlue,
                                  onChanged: (value) {
                                    if (value) {
                                      _connectGoogleCalendar();
                                    } else {
                                      _disconnectGoogleCalendar();
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _googleCalendarConnected
                                  ? '연결된 계정: $_connectedEmail'
                                  : '구글 캘린더에 혜택 일정을 추가하고 관리할 수 있습니다.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (!_googleCalendarConnected)
                              const SizedBox(height: 12),
                            if (!_googleCalendarConnected)
                              ElevatedButton(
                                onPressed: _connectGoogleCalendar,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryBlue,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                                child: const Text('구글 계정 연결'),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
    );
  }

  // 구글 캘린더 연결 (Mock)
  Future<void> _connectGoogleCalendar() async {
    setState(() => _isLoading = true);

    // 실제 구현에서는 구글 인증 과정 필요
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _googleCalendarConnected = true;
      _connectedEmail = _emailController.text;
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('구글 캘린더가 성공적으로 연결되었습니다'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // 구글 캘린더 연결 해제 (Mock)
  Future<void> _disconnectGoogleCalendar() async {
    setState(() => _isLoading = true);

    // 실제 구현에서는 구글 연결 해제 과정 필요
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _googleCalendarConnected = false;
      _connectedEmail = null;
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('구글 캘린더 연결이 해제되었습니다'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // 프로필 저장 로직 (실제로는 상태 관리 또는 DB 연동 필요)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('프로필이 성공적으로 저장되었습니다'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }
}
