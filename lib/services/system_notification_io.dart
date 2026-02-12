// Mobile/desktop: show Android system notification with sound.

import 'dart:io' show Platform;

import 'local_notification_service.dart';

Future<void> showSystemNotification({required String title, required String body}) async {
  if (!Platform.isAndroid) return;
  await LocalNotificationService.instance.show(title: title, body: body);
}
