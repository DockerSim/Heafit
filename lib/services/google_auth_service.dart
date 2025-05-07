import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:heafit/config/secrets.dart';

/// 구글 인증 및 캘린더 API 연동을 위한 서비스 클래스
class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/calendar',
      'https://www.googleapis.com/auth/calendar.events',
    ],
  );

  GoogleSignInAccount? _currentUser;
  calendar.CalendarApi? _calendarApi;
  bool _isCalendarConnected = false;

  // 앱 전용 캘린더 ID
  String? _heafitCalendarId;

  // 표시할 캘린더 목록
  List<calendar.CalendarListEntry> _userCalendars = [];
  List<String> _visibleCalendarIds = [];

  // 동기화 대상 캘린더 목록
  List<String> _syncSourceCalendarIds = [];

  /// 현재 로그인한 사용자
  GoogleSignInAccount? get currentUser => _currentUser;

  /// 캘린더 API 인스턴스
  calendar.CalendarApi? get calendarApi => _calendarApi;

  /// 캘린더 연결 여부
  bool get isCalendarConnected => _isCalendarConnected;

  /// Heafit 캘린더 ID
  String? get heafitCalendarId => _heafitCalendarId;

  /// 사용자의 캘린더 목록
  List<calendar.CalendarListEntry> get userCalendars => _userCalendars;

  /// 표시할 캘린더 ID 목록
  List<String> get visibleCalendarIds => _visibleCalendarIds;

  /// 동기화 대상 캘린더 ID 목록
  List<String> get syncSourceCalendarIds => _syncSourceCalendarIds;

  /// 초기화 함수
  Future<void> init() async {
    // 저장된 로그인 정보 확인
    _currentUser = await _googleSignIn.signInSilently();
    if (_currentUser != null) {
      await _checkCalendarConnection();
      if (_isCalendarConnected) {
        await _setupCalendarAccess();
        await _loadCalendarSettings();
        await _loadCalendarList();
      }
    }
  }

  /// 구글 로그인
  Future<bool> signIn() async {
    try {
      final user = await _googleSignIn.signIn();
      if (user == null) return false;

      _currentUser = user;
      final success = await _setupCalendarAccess();

      if (success) {
        await _loadCalendarList();
        await _ensureHeafitCalendarExists();
      }

      return success;
    } catch (error) {
      debugPrint('Google sign in error: $error');
      return false;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _calendarApi = null;
    _isCalendarConnected = false;
    _userCalendars = [];
    _visibleCalendarIds = [];
    _syncSourceCalendarIds = [];

    // 저장된 설정 초기화
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_calendar_connected', false);
    await prefs.setStringList('visible_calendar_ids', []);
    await prefs.setStringList('sync_source_calendar_ids', []);
  }

  /// 캘린더 접근 설정
  Future<bool> _setupCalendarAccess() async {
    try {
      final auth = await _currentUser!.authentication;
      final credentials = AccessCredentials(
        AccessToken(
          'Bearer',
          auth.accessToken!,
          DateTime.now().toUtc().add(const Duration(hours: 1)),
        ),
        auth.idToken,
        [
          'https://www.googleapis.com/auth/calendar',
          'https://www.googleapis.com/auth/calendar.events',
        ],
      );

      // 시크릿 파일에서 클라이언트 ID 가져오기
      final clientId = Secrets.googleClientId;

      // googleapis_auth의 authenticatedClient 메서드 사용
      final client = authenticatedClient(Client(), credentials);

      _calendarApi = calendar.CalendarApi(client);

      // 캘린더 연결 성공 시 설정 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_calendar_connected', true);
      _isCalendarConnected = true;

      return true;
    } catch (e) {
      debugPrint('Calendar setup error: $e');
      return false;
    }
  }

  /// 캘린더 연결 여부 확인
  Future<bool> _checkCalendarConnection() async {
    final prefs = await SharedPreferences.getInstance();
    _isCalendarConnected = prefs.getBool('is_calendar_connected') ?? false;
    return _isCalendarConnected;
  }

  /// 사용자의 캘린더 목록 로드
  Future<void> _loadCalendarList() async {
    if (_calendarApi == null || !_isCalendarConnected) {
      return;
    }

    try {
      final calendarList = await _calendarApi!.calendarList.list();
      _userCalendars = calendarList.items ?? [];

      // Heafit 캘린더가 있는지 확인
      final heafitCalendar = _userCalendars.firstWhere(
        (calendar) =>
            calendar.summary != null && calendar.summary!.startsWith('Heafit'),
        orElse: () => calendar.CalendarListEntry(),
      );

      if (heafitCalendar.id != null) {
        _heafitCalendarId = heafitCalendar.id;
      }

      debugPrint('로드된 캘린더 수: ${_userCalendars.length}');
    } catch (e) {
      debugPrint('캘린더 목록 로드 오류: $e');
    }
  }

  /// Heafit 캘린더 생성 (없는 경우)
  Future<String?> _ensureHeafitCalendarExists() async {
    if (_calendarApi == null || !_isCalendarConnected) {
      return null;
    }

    // 이미 Heafit 캘린더가 있는 경우
    if (_heafitCalendarId != null) {
      return _heafitCalendarId;
    }

    try {
      // 사용자 정보 가져오기
      final userName = _currentUser?.displayName ?? '사용자';

      // Heafit 캘린더 생성
      final newCalendar = calendar.Calendar();
      newCalendar.summary = 'Heafit - ${userName}의 캘린더';
      newCalendar.description =
          '${userName}의 Heafit 앱 전용 개인 캘린더입니다. 혜택 정보 및 일정을 관리합니다.';
      newCalendar.timeZone = 'Asia/Seoul';

      debugPrint('Heafit 캘린더 생성 중: ${newCalendar.summary}');
      final createdCalendar = await _calendarApi!.calendars.insert(newCalendar);
      _heafitCalendarId = createdCalendar.id;
      debugPrint('Heafit 캘린더 생성 완료: $_heafitCalendarId');

      // 새로 생성된 캘린더도 표시할 캘린더 목록에 추가
      if (_heafitCalendarId != null) {
        await addVisibleCalendar(_heafitCalendarId!);
      }

      // 캘린더 목록 다시 로드
      await _loadCalendarList();

      return _heafitCalendarId;
    } catch (e) {
      debugPrint('Heafit 캘린더 생성 오류: $e');
      return null;
    }
  }

  /// 표시할 캘린더 설정 불러오기
  Future<void> _loadCalendarSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _visibleCalendarIds = prefs.getStringList('visible_calendar_ids') ?? [];
    _syncSourceCalendarIds =
        prefs.getStringList('sync_source_calendar_ids') ?? [];

    // 아무것도 선택되지 않았다면 기본적으로 primary 캘린더는 표시
    if (_visibleCalendarIds.isEmpty) {
      _visibleCalendarIds.add('primary');
    }
  }

  /// 표시할 캘린더 추가
  Future<void> addVisibleCalendar(String calendarId) async {
    if (!_visibleCalendarIds.contains(calendarId)) {
      _visibleCalendarIds.add(calendarId);
      await _saveVisibleCalendars();
    }
  }

  /// 표시할 캘린더에서 제거
  Future<void> removeVisibleCalendar(String calendarId) async {
    if (_visibleCalendarIds.contains(calendarId)) {
      _visibleCalendarIds.remove(calendarId);
      await _saveVisibleCalendars();
    }
  }

  /// 표시할 캘린더 목록 설정
  Future<void> setVisibleCalendars(List<String> calendarIds) async {
    _visibleCalendarIds = List.from(calendarIds);
    await _saveVisibleCalendars();
  }

  /// 표시할 캘린더 목록 저장
  Future<void> _saveVisibleCalendars() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('visible_calendar_ids', _visibleCalendarIds);
  }

  /// 특정 캘린더가 표시되는지 확인
  bool isCalendarVisible(String calendarId) {
    return _visibleCalendarIds.contains(calendarId);
  }

  /// 이벤트를 구글 캘린더에 추가
  Future<bool> addEventToCalendar({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    String? location,
    String? calendarId,
  }) async {
    if (_calendarApi == null || !_isCalendarConnected) {
      return false;
    }

    try {
      // 이벤트 생성
      final event = calendar.Event();
      event.summary = title;
      event.description = description;

      // 시작 시간 설정
      final start = calendar.EventDateTime();
      start.dateTime = startTime;
      start.timeZone = 'Asia/Seoul';
      event.start = start;

      // 종료 시간 설정
      final end = calendar.EventDateTime();
      end.dateTime = endTime;
      end.timeZone = 'Asia/Seoul';
      event.end = end;

      // 위치 설정 (선택적)
      if (location != null && location.isNotEmpty) {
        event.location = location;
      }

      // Heafit 캘린더가 없으면 생성
      if (_heafitCalendarId == null) {
        await _ensureHeafitCalendarExists();
      }

      // 캘린더에 이벤트 추가
      final targetCalendarId = calendarId ?? _heafitCalendarId ?? 'primary';
      await _calendarApi!.events.insert(event, targetCalendarId);
      return true;
    } catch (e) {
      debugPrint('Add event error: $e');
      return false;
    }
  }

  /// 캘린더 이벤트 가져오기
  Future<List<calendar.Event>> getEvents({
    required DateTime startTime,
    required DateTime endTime,
    String? calendarId,
  }) async {
    if (_calendarApi == null || !_isCalendarConnected) {
      return [];
    }

    try {
      final List<calendar.Event> allEvents = [];

      // 표시할 캘린더가 없는 경우 기본 캘린더만 조회
      final calendarsToFetch =
          _visibleCalendarIds.isEmpty ? ['primary'] : _visibleCalendarIds;

      // 특정 캘린더만 조회하는 경우
      if (calendarId != null) {
        final events = await _calendarApi!.events.list(
          calendarId,
          timeMin: startTime.toUtc(),
          timeMax: endTime.toUtc(),
          singleEvents: true,
          orderBy: 'startTime',
        );
        return events.items ?? [];
      }

      // 모든 표시 대상 캘린더의 일정 조회
      for (final id in calendarsToFetch) {
        final events = await _calendarApi!.events.list(
          id,
          timeMin: startTime.toUtc(),
          timeMax: endTime.toUtc(),
          singleEvents: true,
          orderBy: 'startTime',
        );

        if (events.items != null) {
          allEvents.addAll(events.items!);
        }
      }

      // 시간순으로 정렬
      allEvents.sort((a, b) {
        final aStart = a.start?.dateTime;
        final bStart = b.start?.dateTime;

        // 날짜만 있는 경우와 시간까지 있는 경우 처리
        if (aStart == null && bStart == null) {
          final aDate = a.start?.date;
          final bDate = b.start?.date;
          if (aDate == null || bDate == null) return 0;
          return aDate.compareTo(bDate);
        } else if (aStart == null) {
          return 1; // 날짜만 있는 일정은 뒤로
        } else if (bStart == null) {
          return -1; // 날짜만 있는 일정은 뒤로
        }

        return aStart.compareTo(bStart);
      });

      return allEvents;
    } catch (e) {
      debugPrint('Get events error: $e');
      return [];
    }
  }

  /// 선택한 캘린더의 일정을 Heafit 캘린더로 동기화
  Future<int> syncCalendarToHeafit({
    required List<String> sourceCalendarIds,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    if (_calendarApi == null ||
        !_isCalendarConnected ||
        _heafitCalendarId == null) {
      debugPrint(
        '동기화 전제 조건 미충족: calendarApi=${_calendarApi != null}, isConnected=$_isCalendarConnected, heafitId=$_heafitCalendarId',
      );
      return 0;
    }

    try {
      debugPrint('============ 캘린더 동기화 시작 ============');
      debugPrint(
        '동기화 기간: ${startTime.toIso8601String()} ~ ${endTime.toIso8601String()}',
      );

      // Heafit 캘린더가 없으면 생성
      if (_heafitCalendarId == null) {
        await _ensureHeafitCalendarExists();
        if (_heafitCalendarId == null) {
          debugPrint('Heafit 캘린더 생성 실패');
          return 0; // 캘린더 생성 실패
        }
      }

      // 동기화 설정 저장
      _syncSourceCalendarIds = List.from(sourceCalendarIds);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'sync_source_calendar_ids',
        _syncSourceCalendarIds,
      );

      int addedCount = 0;
      int updatedCount = 0;
      int deletedCount = 0;
      int skippedCount = 0;

      // 작업 내역 기록을 위한 맵
      final Map<String, Set<String>> sourceCalendarEventIds = {};
      final Map<String, Map<String, String>> heafitEventIdMap =
          {}; // 소스 ID -> Heafit ID 매핑

      // 기존 Heafit 캘린더의 이벤트 로드
      debugPrint('기존 Heafit 캘린더 이벤트 로드 중...');
      final existingEvents = await _calendarApi!.events.list(
        _heafitCalendarId!,
        timeMin: startTime.toUtc(),
        timeMax: endTime.toUtc(),
        singleEvents: true,
        maxResults: 2500, // 최대 이벤트 수 지정
      );

      final existingHeafitEvents = existingEvents.items ?? [];
      debugPrint('Heafit 캘린더에서 ${existingHeafitEvents.length}개의 이벤트 로드됨');

      // 소스 ID별 Heafit 이벤트 ID 매핑 구성
      for (final event in existingHeafitEvents) {
        if (event.description == null || event.id == null) continue;

        // 소스 캘린더 ID 추출
        final calendarIdRegex = RegExp(r'소스 캘린더: (.*?)\n');
        final calendarIdMatch = calendarIdRegex.firstMatch(event.description!);

        // 소스 이벤트 ID 추출
        final sourceIdRegex = RegExp(r'소스 ID: (.*?)\n');
        final sourceIdMatch = sourceIdRegex.firstMatch(event.description!);

        if (calendarIdMatch != null &&
            sourceIdMatch != null &&
            calendarIdMatch.groupCount >= 1 &&
            sourceIdMatch.groupCount >= 1) {
          final calendarId = calendarIdMatch.group(1);
          final sourceId = sourceIdMatch.group(1);

          if (calendarId != null && sourceId != null) {
            if (heafitEventIdMap[calendarId] == null) {
              heafitEventIdMap[calendarId] = {};
            }
            heafitEventIdMap[calendarId]![sourceId] = event.id!;
          }
        }
      }

      // 소스 캘린더별 처리
      for (final calendarId in sourceCalendarIds) {
        debugPrint('$calendarId 캘린더 동기화 중...');
        sourceCalendarEventIds[calendarId] = <String>{};

        // 소스 캘린더에서 이벤트 가져오기
        final sourceEvents = await _calendarApi!.events.list(
          calendarId,
          timeMin: startTime.toUtc(),
          timeMax: endTime.toUtc(),
          singleEvents: true,
          maxResults: 2500,
        );

        final sourceEventsList = sourceEvents.items ?? [];
        debugPrint('소스 캘린더 $calendarId에서 ${sourceEventsList.length}개의 이벤트 로드됨');

        // 이 캘린더로부터 동기화된 기존 이벤트 찾기
        final syncedFromThisCalendar =
            existingHeafitEvents.where((event) {
              return event.description != null &&
                  event.description!.contains('소스 캘린더: $calendarId');
            }).toList();

        debugPrint('이미 동기화된 이벤트 수: ${syncedFromThisCalendar.length}');

        // 각 소스 이벤트의 ID 저장 (삭제 확인용)
        for (final sourceEvent in sourceEventsList) {
          if (sourceEvent.id != null) {
            sourceCalendarEventIds[calendarId]!.add(sourceEvent.id!);
          }
        }

        // 1. 이벤트 추가 또는 업데이트
        for (final sourceEvent in sourceEventsList) {
          if (sourceEvent.summary == null) {
            skippedCount++;
            continue; // 제목 없는 이벤트는 건너뜀
          }

          final sourceEventId = sourceEvent.id;
          if (sourceEventId == null) {
            skippedCount++;
            continue;
          }

          // 소스 ID에 해당하는 Heafit 이벤트 ID 찾기
          String? heafitEventId;
          if (heafitEventIdMap.containsKey(calendarId) &&
              heafitEventIdMap[calendarId]!.containsKey(sourceEventId)) {
            heafitEventId = heafitEventIdMap[calendarId]![sourceEventId];

            // 업데이트 로직
            if (heafitEventId != null) {
              try {
                final newEvent = calendar.Event();
                newEvent.summary = sourceEvent.summary;

                // 소스 캘린더 정보 추가
                final sourceCal = userCalendars.firstWhere(
                  (cal) => cal.id == calendarId,
                  orElse: () => calendar.CalendarListEntry(summary: '기타 캘린더'),
                );

                final sourceCalName = sourceCal.summary ?? '기타 캘린더';
                // 추적을 위한 메타데이터 포함
                newEvent.description =
                    '${sourceEvent.description ?? ''}\n\n'
                    '[${sourceCalName}에서 동기화된 일정]\n'
                    '소스 캘린더: $calendarId\n'
                    '소스 ID: $sourceEventId\n'
                    '동기화 시간: ${DateTime.now()}';

                // 시작 및 종료 시간 복사
                if (sourceEvent.start != null) {
                  newEvent.start = sourceEvent.start;
                }

                if (sourceEvent.end != null) {
                  newEvent.end = sourceEvent.end;
                }

                // 위치 정보 복사
                if (sourceEvent.location != null) {
                  newEvent.location = sourceEvent.location;
                }

                // 반복 일정 정보 복사
                if (sourceEvent.recurrence != null) {
                  newEvent.recurrence = sourceEvent.recurrence;
                }

                // 기타 추가 정보 복사
                if (sourceEvent.colorId != null) {
                  newEvent.colorId = sourceEvent.colorId;
                }

                // Heafit 캘린더에 업데이트
                debugPrint('이벤트 업데이트: ${newEvent.summary}');
                await _calendarApi!.events.update(
                  newEvent,
                  _heafitCalendarId!,
                  heafitEventId,
                );
                updatedCount++;
              } catch (e) {
                debugPrint('이벤트 업데이트 실패: $e');
                skippedCount++;
              }
              continue;
            }
          }

          // 새 이벤트 생성 및 추가
          try {
            final newEvent = calendar.Event();
            newEvent.summary = sourceEvent.summary;

            // 소스 캘린더 정보 추가
            final sourceCal = userCalendars.firstWhere(
              (cal) => cal.id == calendarId,
              orElse: () => calendar.CalendarListEntry(summary: '기타 캘린더'),
            );

            final sourceCalName = sourceCal.summary ?? '기타 캘린더';
            // 추적을 위한 메타데이터 포함
            newEvent.description =
                '${sourceEvent.description ?? ''}\n\n'
                '[${sourceCalName}에서 동기화된 일정]\n'
                '소스 캘린더: $calendarId\n'
                '소스 ID: $sourceEventId\n'
                '동기화 시간: ${DateTime.now()}';

            // 시작 및 종료 시간 복사
            if (sourceEvent.start != null) {
              newEvent.start = sourceEvent.start;
            }

            if (sourceEvent.end != null) {
              newEvent.end = sourceEvent.end;
            }

            // 위치 정보 복사
            if (sourceEvent.location != null) {
              newEvent.location = sourceEvent.location;
            }

            // 반복 일정 정보 복사
            if (sourceEvent.recurrence != null) {
              newEvent.recurrence = sourceEvent.recurrence;
            }

            // 기타 추가 정보 복사
            if (sourceEvent.colorId != null) {
              newEvent.colorId = sourceEvent.colorId;
            }

            // Heafit 캘린더에 추가
            debugPrint('새 이벤트 추가: ${newEvent.summary}');
            final createdEvent = await _calendarApi!.events.insert(
              newEvent,
              _heafitCalendarId!,
            );

            // 매핑 저장
            if (createdEvent.id != null) {
              if (heafitEventIdMap[calendarId] == null) {
                heafitEventIdMap[calendarId] = {};
              }
              heafitEventIdMap[calendarId]![sourceEventId] = createdEvent.id!;
            }

            addedCount++;
          } catch (e) {
            debugPrint('새 이벤트 추가 실패: $e');
            skippedCount++;
          }
        }

        // 2. 소스 캘린더에서 삭제된 이벤트 찾아 제거
        for (final existingEvent in syncedFromThisCalendar) {
          if (existingEvent.id == null || existingEvent.description == null)
            continue;

          // 소스 ID 추출
          bool shouldDelete = false;
          final sourceIdRegex = RegExp(r'소스 ID: (.*?)\n');
          final sourceIdMatch = sourceIdRegex.firstMatch(
            existingEvent.description!,
          );

          if (sourceIdMatch != null && sourceIdMatch.groupCount >= 1) {
            final sourceEventId = sourceIdMatch.group(1);
            if (sourceEventId != null &&
                !sourceCalendarEventIds[calendarId]!.contains(sourceEventId)) {
              shouldDelete = true;
              debugPrint('소스 캘린더에서 삭제된 이벤트 감지: $sourceEventId');
            }
          }

          if (shouldDelete) {
            try {
              debugPrint('이벤트 삭제: ${existingEvent.summary}');
              await _calendarApi!.events.delete(
                _heafitCalendarId!,
                existingEvent.id!,
              );
              deletedCount++;
            } catch (e) {
              debugPrint('이벤트 삭제 실패: $e');
            }
          }
        }
      }

      final totalProcessed = addedCount + updatedCount + deletedCount;
      debugPrint(
        '동기화 완료: $addedCount개 추가, $updatedCount개 업데이트, $deletedCount개 삭제, $skippedCount개 건너뜀, 총 $totalProcessed개 처리',
      );
      debugPrint('============ 캘린더 동기화 종료 ============');
      return totalProcessed;
    } catch (e) {
      debugPrint('캘린더 동기화 오류: $e');
      return 0;
    }
  }
}

/// 인증된 HTTP 클라이언트
class AuthClient extends BaseClient {
  final String clientId;
  final String clientSecret;
  final AccessCredentials credentials;
  final Client _client = Client();

  AuthClient(this.clientId, this.clientSecret, this.credentials);

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    request.headers['Authorization'] = 'Bearer ${credentials.accessToken.data}';
    return _client.send(request);
  }

  @override
  void close() {
    _client.close();
  }
}
