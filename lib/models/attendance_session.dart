enum SyncState {
  localOnly,
}

class AttendanceSubmission {
  AttendanceSubmission({
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.qrCode,
    this.previousTopic,
    this.expectedTopic,
    this.moodScore,
    this.learnedToday,
    this.feedback,
  });

  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String qrCode;
  final String? previousTopic;
  final String? expectedTopic;
  final int? moodScore;
  final String? learnedToday;
  final String? feedback;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'qrCode': qrCode,
      'previousTopic': previousTopic,
      'expectedTopic': expectedTopic,
      'moodScore': moodScore,
      'learnedToday': learnedToday,
      'feedback': feedback,
    };
  }

  factory AttendanceSubmission.fromJson(Map<String, dynamic> json) {
    return AttendanceSubmission(
      timestamp: DateTime.parse(json['timestamp'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      qrCode: json['qrCode'] as String,
      previousTopic: json['previousTopic'] as String?,
      expectedTopic: json['expectedTopic'] as String?,
      moodScore: json['moodScore'] as int?,
      learnedToday: json['learnedToday'] as String?,
      feedback: json['feedback'] as String?,
    );
  }
}

class AttendanceSession {
  AttendanceSession({
    required this.sessionKey,
    required this.studentId,
    required this.classId,
    required this.className,
    required this.sessionDate,
    required this.syncState,
    this.checkIn,
    this.finish,
  });

  final String sessionKey;
  final String studentId;
  final String classId;
  final String className;
  final DateTime sessionDate;
  final SyncState syncState;
  final AttendanceSubmission? checkIn;
  final AttendanceSubmission? finish;

  DateTime get latestActivity => finish?.timestamp ?? checkIn?.timestamp ?? sessionDate;

  AttendanceSession copyWith({
    AttendanceSubmission? checkIn,
    AttendanceSubmission? finish,
    SyncState? syncState,
  }) {
    return AttendanceSession(
      sessionKey: sessionKey,
      studentId: studentId,
      classId: classId,
      className: className,
      sessionDate: sessionDate,
      syncState: syncState ?? this.syncState,
      checkIn: checkIn ?? this.checkIn,
      finish: finish ?? this.finish,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'sessionKey': sessionKey,
      'studentId': studentId,
      'classId': classId,
      'className': className,
      'sessionDate': sessionDate.toIso8601String(),
      'syncState': syncState.name,
      'checkIn': checkIn?.toJson(),
      'finish': finish?.toJson(),
    };
  }

  factory AttendanceSession.fromJson(Map<String, dynamic> json) {
    return AttendanceSession(
      sessionKey: json['sessionKey'] as String,
      studentId: json['studentId'] as String,
      classId: json['classId'] as String,
      className: json['className'] as String,
      sessionDate: DateTime.parse(json['sessionDate'] as String),
      syncState: SyncState.values.firstWhere(
        (value) => value.name == json['syncState'],
        orElse: () => SyncState.localOnly,
      ),
      checkIn: json['checkIn'] == null
          ? null
          : AttendanceSubmission.fromJson(
              Map<String, dynamic>.from(json['checkIn'] as Map),
            ),
      finish: json['finish'] == null
          ? null
          : AttendanceSubmission.fromJson(
              Map<String, dynamic>.from(json['finish'] as Map),
            ),
    );
  }
}