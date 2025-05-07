import 'package:flutter/material.dart';
import 'package:heafit/constants/theme.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:heafit/services/google_auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  bool _isLoadingAuth = true;
  bool _isCalendarConnected = false;
  bool _isLoadingEvents = false;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // 이벤트 데이터
  Map<DateTime, List<calendar.Event>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _checkCalendarConnection();
  }

  // 구글 캘린더 연결 상태 확인
  Future<void> _checkCalendarConnection() async {
    await _googleAuthService.init();
    setState(() {
      _isCalendarConnected = _googleAuthService.isCalendarConnected;
      _isLoadingAuth = false;
    });

    if (_isCalendarConnected) {
      // 먼저 이벤트를 로드
      await _loadEvents();

      // 동기화 설정이 있는 경우에만 자동 동기화 수행
      final syncSourceCalendarIds = _googleAuthService.syncSourceCalendarIds;
      if (syncSourceCalendarIds.isNotEmpty) {
        // 자동 동기화 로직 실행
        await _syncSelectedCalendars();
      } else {
        setState(() {
          _isLoadingEvents = false;
        });
      }
    }
  }

  // 동기화 설정에 따라 캘린더 동기화 수행
  Future<void> _syncSelectedCalendars() async {
    if (!_isCalendarConnected) return;

    // 저장된 동기화 설정 가져오기
    final syncSourceCalendarIds = _googleAuthService.syncSourceCalendarIds;

    if (syncSourceCalendarIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('캘린더 동기화가 해제되어 있습니다. 프로필에서 동기화 설정을 확인해주세요.'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );
      setState(() {
        _isLoadingEvents = false;
      });
      return;
    }

    setState(() {
      _isLoadingEvents = true;
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

      debugPrint(
        '캘린더 동기화 시작 - 범위: ${startTime.toString()} ~ ${endTime.toString()}',
      );

      final syncedCount = await _googleAuthService.syncCalendarToHeafit(
        sourceCalendarIds: syncSourceCalendarIds,
        startTime: startTime,
        endTime: endTime,
      );

      if (syncedCount > 0) {
        // 동기화 후 이벤트 다시 로드
        await _loadEvents();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$syncedCount개의 일정이 동기화되었습니다.\n현재 월과 이전 월의 일정만 동기화됩니다.',
            ),
            backgroundColor: AppTheme.primaryColor,
            duration: const Duration(seconds: 3),
          ),
        );
      } else if (syncedCount == 0) {
        // 동기화할 내용이 없는 경우
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('새로운 동기화 대상이 없습니다. 모든 일정이 최신 상태입니다.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('자동 동기화 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('동기화 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingEvents = false;
      });
    }
  }

  // 구글 계정으로 로그인하고 캘린더 연결
  Future<void> _connectGoogleCalendar() async {
    setState(() {
      _isLoadingAuth = true;
    });

    final success = await _googleAuthService.signIn();

    setState(() {
      _isCalendarConnected = success;
      _isLoadingAuth = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('구글 캘린더가 성공적으로 연결되었습니다!'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      await _loadEvents();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('구글 캘린더 연결에 실패했습니다. 다시 시도해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 캘린더 설정 다이얼로그 표시
  void _showCalendarSettings() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('캘린더 설정'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '표시할 캘린더',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _googleAuthService.userCalendars.length,
                        itemBuilder: (context, index) {
                          final calendar =
                              _googleAuthService.userCalendars[index];
                          final calendarId = calendar.id ?? '';
                          final isVisible = _googleAuthService
                              .isCalendarVisible(calendarId);

                          return CheckboxListTile(
                            title: Text(calendar.summary ?? '이름 없음'),
                            subtitle: Text(
                              calendar.id == _googleAuthService.heafitCalendarId
                                  ? 'Heafit 캘린더'
                                  : calendar.id == 'primary'
                                  ? '기본 캘린더'
                                  : '',
                            ),
                            value: isVisible,
                            activeColor: AppTheme.primaryColor,
                            onChanged: (value) async {
                              if (value == true) {
                                await _googleAuthService.addVisibleCalendar(
                                  calendarId,
                                );
                              } else {
                                await _googleAuthService.removeVisibleCalendar(
                                  calendarId,
                                );
                              }

                              setState(() {});

                              // 메인 상태 업데이트를 위한 이벤트 다시 로드
                              if (mounted) {
                                await _loadEvents();
                                this.setState(() {});
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 일정 추가 다이얼로그 표시
  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();

    DateTime selectedDate = _selectedDay ?? DateTime.now();
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
              title: const Text('혜택 일정 추가'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: '제목',
                        hintText: '예: 스타벅스 방문',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: '혜택 설명',
                        hintText: '예: 신한카드 50% 할인',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: '위치 (선택)',
                        hintText: '예: 강남역점',
                      ),
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
                    if (titleController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('제목을 입력해주세요.')),
                      );
                      return;
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

                    final success = await _googleAuthService.addEventToCalendar(
                      title: titleController.text,
                      description: descriptionController.text,
                      startTime: startDateTime,
                      endTime: endDateTime,
                      location:
                          locationController.text.isEmpty
                              ? null
                              : locationController.text,
                      calendarId: _googleAuthService.heafitCalendarId,
                    );

                    Navigator.pop(context);

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('일정이 추가되었습니다.'),
                          backgroundColor: AppTheme.primaryColor,
                        ),
                      );

                      // 이벤트 목록 새로고침
                      await _loadEvents();
                      setState(() {});
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
                  child: const Text('추가'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 구글 캘린더에서 이벤트 로드
  Future<void> _loadEvents() async {
    if (!_isCalendarConnected) return;

    setState(() {
      _isLoadingEvents = true;
    });

    try {
      // 캘린더 기간 설정 (현재 달력에서 보여지는 범위에 맞춰 조정)
      final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

      // 이벤트 불러오기
      final events = await _googleAuthService.getEvents(
        startTime: firstDay,
        endTime: lastDay,
      );

      debugPrint('로드된 이벤트 수: ${events.length}');

      // 날짜별로 이벤트 정리
      final Map<DateTime, List<calendar.Event>> groupedEvents = {};

      for (final event in events) {
        DateTime? eventDate;

        // 날짜 추출 (dateTime이 있으면 사용하고, date만 있으면 date 사용)
        if (event.start?.dateTime != null) {
          eventDate = DateTime(
            event.start!.dateTime!.year,
            event.start!.dateTime!.month,
            event.start!.dateTime!.day,
          );
        } else if (event.start?.date != null) {
          eventDate = event.start!.date;
        }

        // 날짜가 있는 이벤트만 추가
        if (eventDate != null) {
          if (groupedEvents[eventDate] == null) {
            groupedEvents[eventDate] = [];
          }

          groupedEvents[eventDate]!.add(event);
        }
      }

      setState(() {
        _events = groupedEvents;
        _isLoadingEvents = false;
      });
    } catch (e) {
      debugPrint('이벤트 로드 오류: $e');
      setState(() {
        _isLoadingEvents = false;
      });
    }
  }

  // 날짜에 해당하는 이벤트 목록 반환
  List<calendar.Event> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    // 로딩 중이면 로딩 화면 표시
    if (_isLoadingAuth) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
      );
    }

    // 캘린더 미연결 상태라면 연결 안내 화면 표시
    if (!_isCalendarConnected) {
      return _buildCalendarConnectionScreen();
    }

    // 캘린더 연결 완료된 상태라면 일정 화면 표시
    return _buildCalendarScreen();
  }

  // 캘린더 연결 안내 화면
  Widget _buildCalendarConnectionScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('내 혜택 일정'), elevation: 0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 캘린더 아이콘
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_month,
                  size: 64,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 32),

              // 안내 텍스트
              const Text(
                '구글 캘린더 연결하기',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                '구글 캘린더를 연결하면 혜택 정보를 일정에 손쉽게 추가하고 관리할 수 있어요. 캘린더에 저장된 일정을 기반으로 혜택도 추천받을 수 있습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.secondaryTextColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // 구글 연결 버튼
              ElevatedButton.icon(
                onPressed: _connectGoogleCalendar,
                icon: const Icon(Icons.calendar_month),
                label: const Text('구글 캘린더 연결하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 캘린더 화면 (연결 완료 시)
  Widget _buildCalendarScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 혜택 일정'),
        elevation: 0,
        actions: [
          // 새로고침 버튼 (동기화 중이면 로딩 인디케이터 표시)
          _isLoadingEvents
              ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              )
              : IconButton(
                icon: const Icon(Icons.sync),
                onPressed: _syncSelectedCalendars,
                tooltip: '설정된 캘린더 동기화하기',
              ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showCalendarSettings,
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
              _loadEvents(); // 페이지 변경 시 해당 달의 이벤트 로드
              // 페이지 변경 시 동기화 수행 (선택적으로 활성화)
              // _syncSelectedCalendars();
            },
            eventLoader: _getEventsForDay,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return const SizedBox.shrink();

                // 최대 표시할 마커 개수
                final maxMarkers = 3;

                return Positioned(
                  bottom: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        events.take(maxMarkers).map((event) {
                          // 이벤트가 속한 캘린더 결정
                          final calendarId =
                              (event as calendar.Event).organizer?.email ?? '';
                          Color markerColor = AppTheme.primaryColor;

                          // Heafit 캘린더 여부 확인
                          if (calendarId ==
                              _googleAuthService.heafitCalendarId) {
                            markerColor = AppTheme.primaryColor;
                          } else {
                            // 캘린더 목록에서 해당 캘린더 찾기
                            final calendarEntry = _googleAuthService
                                .userCalendars
                                .firstWhere(
                                  (cal) => cal.id == calendarId,
                                  orElse: () => calendar.CalendarListEntry(),
                                );

                            if (calendarEntry.backgroundColor != null) {
                              try {
                                final colorCode = calendarEntry.backgroundColor!
                                    .replaceFirst('#', '0xFF');
                                markerColor = Color(int.parse(colorCode));
                              } catch (e) {
                                debugPrint('색상 변환 오류: $e');
                              }
                            }
                          }

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1.0),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: markerColor,
                            ),
                          );
                        }).toList(),
                  ),
                );
              },
            ),
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
          _isLoadingEvents
              ? const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                ),
              )
              : Expanded(
                child:
                    _selectedDay != null
                        ? _buildEventsList(_getEventsForDay(_selectedDay!))
                        : _buildEventsList(_getEventsForDay(DateTime.now())),
              ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventsList(List<calendar.Event> events) {
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
        final String title = event.summary ?? '제목 없음';
        final String description = event.description ?? '';
        final DateTime? startTime = event.start?.dateTime;
        final String location = event.location ?? '';

        // 이벤트가 어떤 캘린더에 속하는지 확인
        final String calendarId = event.organizer?.email ?? '';

        // 캘린더별 색상 설정
        Color calendarColor = AppTheme.primaryColor;
        String calendarName = '기본';

        // 캘린더 ID에 따라 적절한 색상 할당
        if (calendarId == _googleAuthService.heafitCalendarId) {
          calendarName = 'Heafit';
          calendarColor = AppTheme.primaryColor;
        } else {
          // 캘린더 목록에서 해당 캘린더 찾기
          final calendarEntry = _googleAuthService.userCalendars.firstWhere(
            (cal) => cal.id == calendarId,
            orElse: () => calendar.CalendarListEntry(),
          );

          if (calendarEntry.backgroundColor != null) {
            // 구글 캘린더 색상 코드(HEX)를 Flutter Color로 변환
            try {
              final colorCode = calendarEntry.backgroundColor!.replaceFirst(
                '#',
                '0xFF',
              );
              calendarColor = Color(int.parse(colorCode));
            } catch (e) {
              debugPrint('색상 변환 오류: $e');
            }
          }

          calendarName = calendarEntry.summary ?? '기타';
        }

        // 이벤트가 Heafit 캘린더에 있는지 확인
        final bool isHeafitEvent =
            calendarId == _googleAuthService.heafitCalendarId ||
            description.contains('혜택');

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: calendarColor, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      startTime != null
                          ? '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}'
                          : '종일',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: calendarColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        calendarName,
                        style: TextStyle(
                          fontSize: 12,
                          color: calendarColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.card_giftcard, size: 16, color: calendarColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          description,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // 일정 공유
                      },
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text('공유'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        // 알림 설정
                      },
                      icon: const Icon(Icons.notifications, size: 16),
                      label: const Text('알림'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
