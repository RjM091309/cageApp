import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../constants/api_config.dart';
import '../models/realtime_data.dart';

class RealtimeService {
  RealtimeService._();
  static final RealtimeService instance = RealtimeService._();

  io.Socket? _socket;
  final StreamController<RealtimeData> _realtimeController = StreamController<RealtimeData>.broadcast();

  Stream<RealtimeData> get realtimeStream => _realtimeController.stream;

  Future<RealtimeData> fetchRealtime() async {
    try {
      final res = await http.get(Uri.parse(realtimeApiUrl));
      if (res.statusCode != 200) return const RealtimeData.empty();
      final json = _parseJson(res.body);
      if (json == null) return const RealtimeData.empty();
      return RealtimeData.fromJson(json);
    } catch (_) {
      return const RealtimeData.empty();
    }
  }

  Map<String, dynamic>? _parseJson(String body) {
    try {
      if (body.isEmpty) return null;
      return Map<String, dynamic>.from(jsonDecode(body) as Map);
    } catch (_) {
      return null;
    }
  }

  /// Connect to Socket.IO and push each 'realtime' payload to [realtimeStream].
  void connectSocket() {
    if (_socket != null && _socket!.connected) return;
    _socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .build(),
    );
    _socket!.on('realtime', (data) {
      try {
        final map = data is Map ? Map<String, dynamic>.from(data) : _parseJson(data is String ? data : '{}');
        if (map != null) _realtimeController.add(RealtimeData.fromJson(map));
      } catch (_) {}
    });
    _socket!.onConnect((_) {});
    _socket!.onDisconnect((_) {});
    _socket!.onError((err) {});
  }

  void disconnectSocket() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {
    disconnectSocket();
    _realtimeController.close();
  }
}
