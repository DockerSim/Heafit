import 'package:flutter/material.dart';
import 'package:heafit/constants/theme.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // 임시 일정 데이터
  final Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  // 임시 이벤트 데이터 로드
  void _loadEvents() {
    final now = DateTime.now();

    // 오늘 일정
    final today = DateTime(now.year, now.month, now.day);
    _events[today] = [
      {
        'title': '스타벅스 방문',
        'time': '15:00',
        'benefit': '신한카드 50% 할인',
        'isUsed': true,
      },
      {
        'title': 'CGV 영화 관람',
        'time': '19:30',
        'benefit': '토스 결제 시 1+1',
        'isUsed': false,
      },
    ];

    // 내일 일정
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    _events[tomorrow] = [
      {
        'title': '배달의민족 주문',
        'time': '12:00',
        'benefit': '네이버페이 3,000원 할인',
        'isUsed': null,
      },
    ];

    // 일주일 후 일정
    final nextWeek = DateTime(now.year, now.month, now.day + 7);
    _events[nextWeek] = [
      {
        'title': '올리브영 방문',
        'time': '14:00',
        'benefit': '현대카드 20% 할인',
        'isUsed': null,
      },
    ];
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 혜택 일정'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // 캘린더 필터 옵션 표시
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 캘린더 위젯
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              markersMaxCount: 3,
              markerDecoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 8),

          // 선택된 날짜 표시
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.event, size: 20, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  _selectedDay != null
                      ? '${_selectedDay!.year}년 ${_selectedDay!.month}월 ${_selectedDay!.day}일 일정'
                      : '오늘의 일정',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 선택된 날짜의 일정 목록
          Expanded(
            child:
                _selectedDay != null
                    ? _buildEventsList(_getEventsForDay(_selectedDay!))
                    : _buildEventsList(_getEventsForDay(DateTime.now())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 혜택 일정 추가
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventsList(List<Map<String, dynamic>> events) {
    if (events.isEmpty) {
      return const Center(
        child: Text(
          '등록된 혜택 일정이 없습니다.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final Color statusColor =
            event['isUsed'] == null
                ? Colors.grey
                : event['isUsed']
                ? Colors.green
                : Colors.red;
        final String statusText =
            event['isUsed'] == null
                ? '예정'
                : event['isUsed']
                ? '사용 완료'
                : '미사용';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      event['time'],
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  event['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.card_giftcard,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event['benefit'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (event['isUsed'] == null)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // 사용 안함으로 표시
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('사용 안함'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // 사용함으로 표시
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                          ),
                          child: const Text('사용함'),
                        ),
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
}
