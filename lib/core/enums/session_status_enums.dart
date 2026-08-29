/// Represents the status of an active audio/video call session
enum CallStatus {
  none,
  initiated,
  ringing,
  dialing,
  waiting,
  ongoing,
  completed,
  rejected,
  cancelled,
  missed,
  timeout,
  failed,
  idle,
}

/// Represents the status of a chat session
enum ChatStatus {
  none,
  pending,
  initiated,
  ongoing,
  completed,
  rejected,
  cancelled,
  missed,
  failed,
  idle,
}

/// Represents the high-level state of a prepaid package session
enum PackageSessionState { none, inProgress, paused, terminated }

/// Extensions to help with string conversions if needed
extension CallStatusExtension on CallStatus {
  String get value {
    return toString().split('.').last;
  }
}

extension ChatStatusExtension on ChatStatus {
  String get value {
    return toString().split('.').last;
  }
}
