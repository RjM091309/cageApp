import 'types.dart';

/// Response from GET /api/realtime and Socket.IO 'realtime' event.
class RealtimeData {
  final bool success;
  final int totalChips;
  final int cashBalance;
  final int guestBalance;
  final int netJunketMoney;
  final int netJunketCash;
  final List<OngoingGame> ongoingGames;

  const RealtimeData({
    required this.success,
    required this.totalChips,
    required this.cashBalance,
    required this.guestBalance,
    required this.netJunketMoney,
    required this.netJunketCash,
    required this.ongoingGames,
  });

  /// Parse numeric value from API (may be int, double, or string e.g. "12345.00" from MySQL DECIMAL).
  static int _num(Map<String, dynamic> json, String key) {
    final v = json[key];
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.round();
    final s = v.toString().trim();
    if (s.isEmpty) return 0;
    final d = double.tryParse(s);
    return d?.round() ?? 0;
  }

  factory RealtimeData.fromJson(Map<String, dynamic> json) {
    final raw = json['ongoing_games'] as List<dynamic>? ?? [];
    final ongoingGames = raw.map((e) {
      final m = e as Map<String, dynamic>;
      final agentName = (m['agent_name'] ?? '').toString().trim();
      final agentCode = (m['agent_code'] ?? '').toString().trim();
      final accountLabel = agentName.isNotEmpty && agentCode.isNotEmpty
          ? '$agentName ($agentCode)'
          : (agentCode.isNotEmpty ? agentCode : agentName);
      return OngoingGame(
        id: (m['game_id'] ?? '').toString(),
        account: accountLabel,
        buyIn: _num(m, 'buyin'),
        cashOut: _num(m, 'cashout'),
        table: (m['encoded_dt'] ?? '').toString(),
        gameType: (m['game_type'] ?? '').toString(),
        status: 'Active',
      );
    }).toList();

    return RealtimeData(
      success: json['success'] as bool? ?? false,
      totalChips: _num(json, 'total_chips'),
      cashBalance: _num(json, 'cash_balance'),
      guestBalance: _num(json, 'guest_balance'),
      netJunketMoney: _num(json, 'net_junket_money'),
      netJunketCash: _num(json, 'net_junket_cash'),
      ongoingGames: ongoingGames,
    );
  }

  /// Empty placeholder for loading/error states.
  factory RealtimeData.empty() => RealtimeData(
        success: false,
        totalChips: 0,
        cashBalance: 0,
        guestBalance: 0,
        netJunketMoney: 0,
        netJunketCash: 0,
        ongoingGames: const [],
      );
}
