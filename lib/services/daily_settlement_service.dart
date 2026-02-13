import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import '../models/types.dart';

/// Result of daily settlement chart + summary for the Flutter UI.
class DailySettlementResult {
  final List<SettlementData> days;
  final int totalBuyIn;
  final int totalGames;
  final int totalRolling;
  final double avgRolling;
  final int totalWinLoss;
  final double winRatePercent;

  DailySettlementResult({
    required this.days,
    required this.totalBuyIn,
    required this.totalGames,
    required this.totalRolling,
    required this.avgRolling,
    required this.totalWinLoss,
    required this.winRatePercent,
  });

  static DailySettlementResult empty() {
    return DailySettlementResult(
      days: [],
      totalBuyIn: 0,
      totalGames: 0,
      totalRolling: 0,
      avgRolling: 0,
      totalWinLoss: 0,
      winRatePercent: 0,
    );
  }
}

class DailySettlementService {
  DailySettlementService._();
  static final DailySettlementService instance = DailySettlementService._();

  static String _shortDate(String yyyyMmDd) {
    try {
      final parts = yyyyMmDd.split('-');
      if (parts.length != 3) return yyyyMmDd;
      final y = int.tryParse(parts[0]) ?? 0;
      final m = (int.tryParse(parts[1]) ?? 1) - 1;
      final d = int.tryParse(parts[2]) ?? 1;
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final day = DateTime(y, m, d).weekday;
      return weekdays[day - 1];
    } catch (_) {
      return yyyyMmDd;
    }
  }

  static String _dateLabel(String yyyyMmDd, DateTime today, List<String> weekdays) {
    try {
      final parts = yyyyMmDd.split('-');
      if (parts.length != 3) return yyyyMmDd;
      final y = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 1; // Dart DateTime month 1-12
      final d = int.tryParse(parts[2]) ?? 1;
      final dt = DateTime(y, m, d);
      if (dt.year == today.year && dt.month == today.month && dt.day == today.day) return 'Today';
      return weekdays[dt.weekday - 1];
    } catch (_) {
      return yyyyMmDd;
    }
  }

  static List<String> _toStringList(dynamic list) {
    if (list == null || list is! List) return [];
    return list.map((e) => e?.toString() ?? '').toList();
  }

  /// Fetches chart data for the last 7 days (rolling window ending today).
  /// So Sat/Sun shown are previous weekend with real data; "Today" stays last.
  /// Optional [start]/[end] override the range.
  Future<DailySettlementResult> fetch({
    DateTime? start,
    DateTime? end,
    int weekOffset = 0,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime startDate;
    DateTime endDate;
    if (start != null && end != null) {
      startDate = start;
      endDate = end;
    } else {
      // Last 7 days (rolling): today-6 .. today. So previous Sat/Sun have real data.
      endDate = today.add(Duration(days: weekOffset * 7));
      startDate = endDate.subtract(const Duration(days: 6));
    }
    final startStr = _toYYYYMMDD(startDate);
    final endStr = _toYYYYMMDD(endDate);
    try {
      final res = await http.get(
        Uri.parse(dailySettlementApiUrl(startDate: startStr, endDate: endStr)),
      );
      if (res.statusCode != 200) return DailySettlementResult.empty();
      final json = _parseJson(res.body);
      if (json == null || json['success'] != true) return DailySettlementResult.empty();
      final chart = json['chart'];
      if (chart == null || chart is! Map) return DailySettlementResult.empty();

      final labels = _toStringList(chart['labels']);
      final numGames = _toIntList(chart['number_of_games']);
      final buyIn = _toIntList(chart['buy_in']);
      final gameRolling = _toIntList(chart['game_rolling']);
      final winLoss = _toIntList(chart['win_loss']);
      final commission = _toIntList(chart['commission']);
      final junketExpenses = _toIntList(chart['junket_expenses']);

      // API returns one entry per day in range (oldest first). Label each by weekday or "Today".
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final days = <SettlementData>[];
      final count = numGames.length;
      for (int i = 0; i < count; i++) {
        final dateLabel = i < labels.length
            ? _dateLabel(labels[i], today, weekdays)
            : (i == count - 1 ? 'Today' : weekdays[i % 7]);
        days.add(SettlementData(
          date: dateLabel,
          numGames: numGames[i],
          buyIn: i < buyIn.length ? buyIn[i] : 0,
          rolling: i < gameRolling.length ? gameRolling[i] : 0,
          winLoss: i < winLoss.length ? winLoss[i] : 0,
          commission: i < commission.length ? commission[i] : 0,
          expenses: i < junketExpenses.length ? junketExpenses[i] : 0,
        ));
      }

      // Card metrics: last day in range is "today" when range ends today
      final lastIdx = days.isEmpty ? -1 : days.length - 1;
      final hasToday = lastIdx >= 0 && endDate == today;
      final int totalBuyIn = hasToday ? days[lastIdx].buyIn : 0;
      final int totalGames = hasToday ? days[lastIdx].numGames : 0;
      final int totalRolling = hasToday ? days[lastIdx].rolling : 0;
      final int totalWL = hasToday ? days[lastIdx].winLoss : 0;
      final double avgRolling = totalGames > 0 ? totalRolling / totalGames : 0.0;
      final double winRatePercent = totalBuyIn > 0 ? (totalWL / totalBuyIn) * 100 : 0.0;

      return DailySettlementResult(
        days: days,
        totalBuyIn: totalBuyIn,
        totalGames: totalGames,
        totalRolling: totalRolling,
        avgRolling: avgRolling,
        totalWinLoss: totalWL,
        winRatePercent: winRatePercent,
      );
    } catch (_) {
      return DailySettlementResult.empty();
    }
  }

  String _toYYYYMMDD(DateTime d) {
    final y = d.year;
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  List<int> _toIntList(dynamic list) {
    if (list == null || list is! List) return [];
    return list.map((e) => (e is int) ? e : (e is num) ? e.toInt() : int.tryParse(e?.toString() ?? '0') ?? 0).toList();
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
