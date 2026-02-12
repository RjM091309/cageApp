import 'dart:async';

import 'package:http/http.dart' as http;

import '../constants/api_config.dart';

/// Checks server connectivity periodically and exposes [isOnlineStream].
/// Used by the layout header to show Live vs Offline.
class ServerStatusService {
  ServerStatusService._();
  static final ServerStatusService instance = ServerStatusService._();

  /// 15s = light load; leaves room for Notifications polling without piling up requests.
  static const _checkInterval = Duration(seconds: 15);
  static const _requestTimeout = Duration(seconds: 3);

  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  Timer? _timer;
  bool _lastKnown = true;

  /// Stream of server online state. true = server reachable, false = offline/unreachable.
  Stream<bool> get isOnlineStream => _controller.stream;

  /// Current value (last emitted). Default true to avoid flashing "Offline" before first check.
  bool get isOnline => _lastKnown;

  void start() {
    if (_timer?.isActive == true) return;
    _runCheck();
    _timer = Timer.periodic(_checkInterval, (_) => _runCheck());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _runCheck() async {
    try {
      final uri = Uri.parse(realtimeApiUrl);
      final res = await http.get(uri).timeout(_requestTimeout);
      final online = res.statusCode >= 200 && res.statusCode < 500;
      _emit(online);
    } catch (_) {
      _emit(false);
    }
  }

  void _emit(bool online) {
    if (online == _lastKnown) return;
    _lastKnown = online;
    if (!_controller.isClosed) _controller.add(online);
  }

  void dispose() {
    stop();
    _controller.close();
  }
}
