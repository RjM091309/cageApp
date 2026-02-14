import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import '../models/types.dart';
import 'auth_service.dart';
import 'system_notification_stub.dart' if (dart.library.io) 'system_notification_io.dart' as system_notification;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.instance.getToken();
    final headers = <String, String>{};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Fetches notifications for the executive app. Read state is per user (requires auth).
  Future<List<NotificationItem>> fetchNotifications() async {
    try {
      final headers = await _authHeaders();
      final uri = Uri.parse(notificationsApiUrl).replace(queryParameters: {'_': DateTime.now().millisecondsSinceEpoch.toString()});
      final res = await http.get(uri, headers: headers);
      if (res.statusCode == 401) return [];
      if (res.statusCode != 200) return [];
      final json = _parseJson(res.body);
      if (json == null) return [];
      final list = json['notifications'] as List<dynamic>?;
      if (list == null) return [];
      return list.map((e) {
        if (e is! Map) return null;
        final id = _int(e['id']);
        final title = e['title']?.toString() ?? '';
        final message = e['message']?.toString() ?? '';
        final type = e['type']?.toString() ?? 'info';
        final time = _formatTimeAgo(e['created_at']);
        final isRead = e['read'] == true;
        return NotificationItem(
          id: id,
          title: title,
          message: message,
          time: time,
          type: type,
          isRead: isRead,
        );
      }).whereType<NotificationItem>().toList();
    } catch (_) {
      return [];
    }
  }

  /// Clears this user's read state (DELETE /api/notifications). Requires auth.
  Future<bool> clearAll() async {
    try {
      final headers = await _authHeaders();
      final res = await http.delete(Uri.parse(notificationsApiUrl), headers: headers);
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  /// Create one notification (POST /api/notifications). Calls [onNotificationsChanged] on success.
  Future<bool> createNotification({required String title, required String message, String type = 'info'}) async {
    try {
      final res = await http.post(
        Uri.parse(notificationsApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': title, 'message': message, 'type': type}),
      );
      final ok = res.statusCode >= 200 && res.statusCode < 300;
      if (ok) {
        onNotificationsChanged?.call();
        system_notification.showSystemNotification(title: title, body: message);
      }
      return ok;
    } catch (_) {
      return false;
    }
  }

  /// Mark one notification as read for this user (PATCH /api/notifications/:id). Requires auth.
  Future<bool> markAsRead(int id) async {
    try {
      final headers = await _authHeaders();
      headers['Content-Type'] = 'application/json';
      final res = await http.patch(
        Uri.parse(notificationMarkReadUrl(id)),
        headers: headers,
        body: jsonEncode({'read': true}),
      );
      final ok = res.statusCode >= 200 && res.statusCode < 300;
      if (ok) onNotificationsChanged?.call();
      return ok;
    } catch (_) {
      return false;
    }
  }

  /// Set by layout so it can refetch notifications when a new one is created (e.g. from realtime view).
  static void Function()? onNotificationsChanged;

  int _int(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  String _formatTimeAgo(dynamic v) {
    if (v == null || v.toString().trim().isEmpty) return '';
    final dt = DateTime.tryParse(v.toString());
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inDays < 7) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    return '${dt.month}/${dt.day}/${dt.year}';
  }

  Map<String, dynamic>? _parseJson(String body) {
    try {
      if (body.isEmpty) return null;
      return Map<String, dynamic>.from(jsonDecode(body) as Map);
    } catch (_) {
      return null;
    }
  }
}
