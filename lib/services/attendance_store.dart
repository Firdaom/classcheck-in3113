import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/attendance_session.dart';

class AttendanceStore extends ChangeNotifier {
  AttendanceStore({SharedPreferences? preferences}) : _preferences = preferences;

  static const String _storageKey = 'attendance_sessions_v1';
  static String _studentId = 'STU-240031';

  static String get studentId => _studentId;

  static Future<void> setStudentId(String id) async {
    _studentId = id;
  }

  static Future<String> getStudentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('attendance_student_id') ?? 'STU-240031';
  }

  SharedPreferences? _preferences;
  final List<AttendanceSession> _sessions = <AttendanceSession>[];

  List<AttendanceSession> get sessions {
    final items = List<AttendanceSession>.from(_sessions);
    items.sort((a, b) => b.latestActivity.compareTo(a.latestActivity));
    return List<AttendanceSession>.unmodifiable(items);
  }

  Future<void> initialize() async {
    _preferences ??= await SharedPreferences.getInstance();
    
    // Load student ID if exists
    final savedStudentId = _preferences!.getString('attendance_student_id');
    if (savedStudentId != null) {
      _studentId = savedStudentId;
    }
    
    final rawSessions = _preferences!.getStringList(_storageKey) ?? <String>[];

    _sessions
      ..clear()
      ..addAll(
        rawSessions.map(
          (item) => AttendanceSession.fromJson(
            jsonDecode(item) as Map<String, dynamic>,
          ),
        ),
      );
    notifyListeners();
  }

  Future<bool> isUserLoggedIn() async {
    _preferences ??= await SharedPreferences.getInstance();
    return _preferences!.containsKey('user_email') &&
        _preferences!.containsKey('user_password');
  }

  AttendanceSession? sessionForDate({
    required String classId,
    required DateTime date,
  }) {
    final key = sessionKeyFor(classId: classId, date: date);
    for (final session in _sessions) {
      if (session.sessionKey == key) {
        return session;
      }
    }
    return null;
  }

  Future<void> saveCheckIn({
    required String classId,
    required String className,
    required DateTime sessionDate,
    required AttendanceSubmission submission,
  }) async {
    _upsertSession(
      classId: classId,
      className: className,
      sessionDate: sessionDate,
      update: (current) => current.copyWith(
        checkIn: submission,
        syncState: SyncState.localOnly,
      ),
    );

    await _persist();
  }

  Future<void> saveFinish({
    required String classId,
    required String className,
    required DateTime sessionDate,
    required AttendanceSubmission submission,
  }) async {
    _upsertSession(
      classId: classId,
      className: className,
      sessionDate: sessionDate,
      update: (current) => current.copyWith(
        finish: submission,
        syncState: SyncState.localOnly,
      ),
    );

    await _persist();
  }

  String sessionKeyFor({required String classId, required DateTime date}) {
    final normalized = DateTime(date.year, date.month, date.day);
    final dateValue = normalized.toIso8601String().split('T').first;
    return '$dateValue-$classId';
  }

  void _upsertSession({
    required String classId,
    required String className,
    required DateTime sessionDate,
    required AttendanceSession Function(AttendanceSession current) update,
  }) {
    final key = sessionKeyFor(classId: classId, date: sessionDate);
    final index = _sessions.indexWhere((session) => session.sessionKey == key);
    final normalizedDate = DateTime(
      sessionDate.year,
      sessionDate.month,
      sessionDate.day,
    );

    final current = index >= 0
        ? _sessions[index]
        : AttendanceSession(
            sessionKey: key,
            studentId: studentId,
            classId: classId,
            className: className,
            sessionDate: normalizedDate,
            syncState: SyncState.localOnly,
          );

    final updated = update(current);

    if (index >= 0) {
      _sessions[index] = updated;
    } else {
      _sessions.add(updated);
    }
  }

  Future<void> _persist() async {
    await _preferences!.setStringList(
      _storageKey,
      _sessions.map((session) => jsonEncode(session.toJson())).toList(),
    );
    notifyListeners();
  }
}