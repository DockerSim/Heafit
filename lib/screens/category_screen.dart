import 'package:flutter/material.dart';
import 'package:heafit/constants/theme.dart';
import 'package:heafit/widgets/section_title.dart';
import 'package:heafit/services/google_auth_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  // Google 인증 서비스
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  bool _isCalendarConnected = false;

  // 선택된 메인 카테고리 인덱스
  int _selectedCategoryIndex = 0;

  // 메인 카테고리 목록
  final List<Map<String, dynamic>> _mainCategories = [
    {'name': '전체', 'icon': Icons.apps},
    {'name': '카페', 'icon': Icons.coffee},
    {'name': '음식점', 'icon': Icons.restaurant},
    {'name': '쇼핑', 'icon': Icons.shopping_bag},
    {'name': '영화', 'icon': Icons.movie},
    {'name': '뷰티', 'icon': Icons.face},
    {'name': '여행', 'icon': Icons.flight},
  ];

  // 서브 카테고리 (브랜드/체인점) 목록 - 카페 카테고리 예시
  final List<Map<String, dynamic>> _cafeSubCategories = [
    {'name': '스타벅스', 'imageUrl': 'assets/images/starbucks.jpg'},
    {'name': '투썸플레이스', 'imageUrl': 'assets/images/twosome.jpg'},
    {'name': '이디야', 'imageUrl': 'assets/images/ediya.jpg'},
    {'name': '커피빈', 'imageUrl': 'assets/images/coffeebean.jpg'},
    {'name': '할리스', 'imageUrl': 'assets/images/hollys.jpg'},
    {'name': '폴바셋', 'imageUrl': 'assets/images/paulbassett.jpg'},
  ];

  // 혜택 목록 - 스타벅스 예시
  final List<Map<String, dynamic>> _benefits = [
    {
      'title': '스타벅스 50% 할인',
      'description': '신한카드로 결제 시 최대 5,000원 할인',
      'period': '2023-05-01 ~ 2023-06-30',
      'tags': ['신한카드', '50%', '할인'],
    },
    {
      'title': '스타벅스 1+1',
      'description': '아메리카노 주문 시 케이크 1개 무료',
      'period': '2023-05-15 ~ 2023-05-31',
      'tags': ['1+1', '아메리카노', '케이크'],
    },
    {
      'title': '스타벅스 사이렌 오더 추가 할인',
      'description': '사이렌 오더로 주문 시 10% 추가 할인',
      'period': '2023-05-10 ~ 2023-06-10',
      'tags': ['사이렌 오더', '10%', '추가 할인'],
    },
  ];

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
    return Scaffold(
      appBar: AppBar(title: const Text('카테고리'), elevation: 0),
      body: Column(
        children: [
          // 메인 카테고리 목록
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _mainCategories.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedCategoryIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppTheme.primaryColor
                              : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _mainCategories[index]['icon'],
                          color:
                              isSelected
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _mainCategories[index]['name'],
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isSelected
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 서브 카테고리와 혜택 목록
          Expanded(
            child:
                _selectedCategoryIndex == 0
                    ? _buildAllCategories()
                    : _buildCategoryDetail(),
          ),
        ],
      ),
    );
  }

  Widget _buildAllCategories() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _mainCategories.length - 1, // '전체' 제외
      itemBuilder: (context, index) {
        final category = _mainCategories[index + 1]; // '전체' 제외
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategoryIndex = index + 1;
            });
          },
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      category['icon'],
                      size: 40,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryDetail() {
    // 선택된 카테고리에 따라 다른 서브 카테고리 표시
    // 여기서는 예시로 카페 카테고리만 구현
    return Column(
      children: [
        // 서브 카테고리 (브랜드/체인점) 섹션
        const SectionTitle(title: '브랜드'),
        SizedBox(
          height: 120,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _cafeSubCategories.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // 브랜드 선택 시 해당 브랜드의 혜택 표시
                },
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            _cafeSubCategories[index]['name'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _cafeSubCategories[index]['name'],
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // 혜택 목록 섹션
        const SectionTitle(title: '혜택'),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _benefits.length,
            itemBuilder: (context, index) {
              final benefit = _benefits[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        benefit['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
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
