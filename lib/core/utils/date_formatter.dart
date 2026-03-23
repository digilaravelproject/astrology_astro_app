import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  static String timeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);

    if (duration.inDays > 365) {
      return '${(duration.inDays / 365).floor()} years ago';
    } else if (duration.inDays > 30) {
      return '${(duration.inDays / 30).floor()} months ago';
    } else if (duration.inDays > 0) {
      return '${duration.inDays} days ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hours ago';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minutes ago';
    } else {
      return 'just now';
    }
  }
}
