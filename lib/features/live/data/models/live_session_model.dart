class LiveSessionModel {
  final int id;
  final String title;
  final String? description;
  final DateTime scheduledAt;
  final String sessionType;
  final int durationMinutes;
  final int maxParticipants;
  final String? status;
  final DateTime? createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? streamKey;
  final int viewerCount;
  final int currentParticipants;

  LiveSessionModel({
    required this.id,
    required this.title,
    this.description,
    required this.scheduledAt,
    required this.sessionType,
    required this.durationMinutes,
    required this.maxParticipants,
    this.status,
    this.createdAt,
    this.startedAt,
    this.endedAt,
    this.streamKey,
    this.viewerCount = 0,
    this.currentParticipants = 0,
  });

  factory LiveSessionModel.fromJson(Map<String, dynamic> json) {
    return LiveSessionModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      scheduledAt: DateTime.parse(json['scheduled_at']),
      sessionType: json['session_type'] ?? 'public',
      durationMinutes: json['duration_minutes'] ?? 0,
      maxParticipants: json['max_participants'] ?? 0,
      status: json['status'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at']) : null,
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at']) : null,
      streamKey: json['stream_key'],
      viewerCount: json['viewer_count'] ?? 0,
      currentParticipants: json['current_participants'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'scheduled_at': scheduledAt.toIso8601String(),
      'session_type': sessionType,
      'duration_minutes': durationMinutes,
      'max_participants': maxParticipants,
      'status': status,
      'started_at': startedAt?.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'stream_key': streamKey,
      'viewer_count': viewerCount,
      'current_participants': currentParticipants,
    };
  }
}
