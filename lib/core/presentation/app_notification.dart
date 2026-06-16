enum NotificationType { error, success, info }

class AppNotification {
  final String message;
  final NotificationType type;

  const AppNotification(
    this.message, {
    this.type = NotificationType.error,
  });

  bool get isError => type == NotificationType.error;
  bool get isSuccess => type == NotificationType.success;
}
