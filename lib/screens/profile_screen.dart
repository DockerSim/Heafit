import 'package:flutter/material.dart';
import 'package:heafit/constants/theme.dart';
import 'package:heafit/services/google_auth_service.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

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
