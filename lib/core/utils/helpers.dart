/// General-purpose helper functions used across the app.
///
/// Keep this file lean. If a helper becomes domain-specific,
/// move it to the relevant feature folder.

/// Formats a [DateTime] into a human-readable string.
/// Example: "Mar 15, 2025"
String formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

/// Formats a [DateTime] into a time string.
/// Example: "09:30 AM"
String formatTime(DateTime date) {
  final hour = date.hour > 12 ? date.hour - 12 : date.hour;
  final period = date.hour >= 12 ? 'PM' : 'AM';
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute $period';
}

/// Truncates [text] to [maxLength] characters, appending "..." if truncated.
String truncate(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength)}...';
}
