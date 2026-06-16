import 'dart:async';
import 'app_notification.dart';

class NotificationService {
  static final StreamController<AppNotification> _controller = StreamController<AppNotification>.broadcast();

  static Stream<AppNotification> get stream => _controller.stream;

  static void error(String message) {
    _controller.add(AppNotification(message, type: NotificationType.error));
  }

  static void success(String message) {
    _controller.add(AppNotification(message, type: NotificationType.success));
  }

  static void info(String message) {
    _controller.add(AppNotification(message, type: NotificationType.info));
  }

  static void dispose() {
    _controller.close();
  }
}
