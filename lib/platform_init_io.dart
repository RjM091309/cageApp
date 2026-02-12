// Android init when dart:io is available (mobile/desktop).

import 'dart:io' show Platform;

import 'package:flutter/material.dart' show Colors;
import 'package:flutter/services.dart';
import 'package:workmanager/workmanager.dart';

import 'background_notification_task.dart';
import 'services/local_notification_service.dart';

bool get isAndroid => Platform.isAndroid;

Future<void> initAndroidIfNeeded() async {
  if (!Platform.isAndroid) return;
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  await LocalNotificationService.instance.initialize();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  await Workmanager().registerPeriodicTask(
    'cage-notification-check',
    'checkNotifications',
    frequency: const Duration(minutes: 15),
    initialDelay: const Duration(minutes: 1),
  );
}
