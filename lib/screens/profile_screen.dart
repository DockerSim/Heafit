import 'package:flutter/material.dart';
import 'package:heafit/constants/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = false;
  bool _showNotifications = true;
  bool _suggestScheduleChanges = true;

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프로필'), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 결제 수단 섹션
            _buildSectionHeader('결제 수단'),
            _buildPaymentMethodsList(),
            const Divider(height: 32),

            // 멤버십 섹션
            _buildSectionHeader('멤버십'),
            _buildMembershipsList(),
            const Divider(height: 32),

            // 앱 설정 섹션
            _buildSectionHeader('앱 설정'),
            _buildAppSettings(),
            const Divider(height: 32),

            // 정보 섹션
            _buildSectionHeader('정보'),
            _buildInfoSection(),
            const SizedBox(height: 40),
          ],
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

  Widget _buildPaymentMethodsList() {
    return Column(
      children: [
        // 카드사 목록
        _buildSubSectionHeader('카드'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _paymentMethods
                    .where((method) => method['type'] == '카드')
                    .map(
                      (method) => _buildSelectableChip(
                        method['name'],
                        method['isRegistered'],
                        (selected) {
                          setState(() {
                            method['isRegistered'] = selected;
                          });
                        },
                      ),
                    )
                    .toList(),
          ),
        ),

        // 페이 목록
        _buildSubSectionHeader('페이'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _paymentMethods
                    .where((method) => method['type'] == '페이')
                    .map(
                      (method) => _buildSelectableChip(
                        method['name'],
                        method['isRegistered'],
                        (selected) {
                          setState(() {
                            method['isRegistered'] = selected;
                          });
                        },
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMembershipsList() {
    return Column(
      children: [
        // 통신사 목록
        _buildSubSectionHeader('통신사'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _memberships
                    .where((method) => method['type'] == '통신사')
                    .map(
                      (method) => _buildSelectableChip(
                        method['name'],
                        method['isRegistered'],
                        (selected) {
                          setState(() {
                            method['isRegistered'] = selected;
                          });
                        },
                      ),
                    )
                    .toList(),
          ),
        ),

        // 멤버십 목록
        _buildSubSectionHeader('멤버십'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _memberships
                    .where((method) => method['type'] == '멤버십')
                    .map(
                      (method) => _buildSelectableChip(
                        method['name'],
                        method['isRegistered'],
                        (selected) {
                          setState(() {
                            method['isRegistered'] = selected;
                          });
                        },
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSubSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSelectableChip(
    String label,
    bool isSelected,
    Function(bool) onSelected,
  ) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }

  Widget _buildAppSettings() {
    return Column(
      children: [
        // 알림 설정
        _buildSubSectionHeader('알림 설정'),
        SwitchListTile(
          title: const Text('알림 받기'),
          subtitle: const Text('혜택 및 일정 관련 알림 수신'),
          value: _showNotifications,
          onChanged: (value) {
            setState(() {
              _showNotifications = value;
            });
          },
        ),

        // 맞춤형 혜택 설정
        _buildSubSectionHeader('맞춤형 혜택 설정'),
        SwitchListTile(
          title: const Text('일정 변경 제안'),
          subtitle: const Text('더 좋은 혜택을 위한 일정 변경 추천'),
          value: _suggestScheduleChanges,
          onChanged: (value) {
            setState(() {
              _suggestScheduleChanges = value;
            });
          },
        ),

        // 관심 카테고리 설정
        ListTile(
          title: const Text('관심 카테고리 설정'),
          subtitle: const Text('알림을 받을 카테고리 선택'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showCategorySelectionDialog();
          },
        ),

        // 캘린더 설정
        _buildSubSectionHeader('캘린더 설정'),
        ListTile(
          title: const Text('구글 계정 연결'),
          subtitle: Text(_isDarkMode ? '연결됨' : '연결 필요'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // 구글 계정 연결 기능
          },
        ),

        // 테마 설정
        _buildSubSectionHeader('테마 설정'),
        SwitchListTile(
          title: const Text('다크 모드'),
          subtitle: const Text('어두운 테마 사용'),
          value: _isDarkMode,
          onChanged: (value) {
            setState(() {
              _isDarkMode = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Column(
      children: [
        ListTile(
          title: const Text('앱 버전'),
          subtitle: const Text('1.0.0 (빌드 1)'),
        ),
        ListTile(
          title: const Text('개발자 정보'),
          subtitle: const Text('heafit@example.com'),
          onTap: () {
            // 이메일 앱 열기
          },
        ),
        ListTile(
          title: const Text('개인정보 처리방침'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // 개인정보 처리방침 페이지로 이동
          },
        ),
        ListTile(
          title: const Text('이용약관'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // 이용약관 페이지로 이동
          },
        ),
      ],
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
