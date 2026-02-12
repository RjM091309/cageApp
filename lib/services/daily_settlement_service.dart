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

  /// Fetches chart data for the week (Monday–Sunday), same as dashboard win/loss.
  /// Default: this week (Mon–Sun). Optional [weekOffset]: 0 = this week, -1 = last week, etc.
  Future<DailySettlementResult> fetch({
    DateTime? start,
    DateTime? end,
    int weekOffset = 0,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime startDate;
    DateTime endDate;
    if (start != null && end != null) {
      startDate = start;
      endDate = end;
    } else {
      // Week = Monday to Sunday (same as dashboard getDateRange)
      // today.weekday: 1=Mon .. 7=Sun → Monday of this week = today - (weekday - 1)
      final mondayOfThisWeek = today.subtract(Duration(days: today.weekday - 1));
      startDate = mondayOfThisWeek.add(Duration(days: weekOffset * 7));
      endDate = startDate.add(const Duration(days: 6));
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

      final numGames = _toIntList(chart['number_of_games']);
      final buyIn = _toIntList(chart['buy_in']);
      final gameRolling = _toIntList(chart['game_rolling']);
      final winLoss = _toIntList(chart['win_loss']);
      final commission = _toIntList(chart['commission']);
      final junketExpenses = _toIntList(chart['junket_expenses']);

      // Fixed order: Mon, Tue, Wed, Thu, Fri, Sat, Sun (same as dashboard). API returns [Mon..Sun] by index.
      // Map API[i] to weekday (i+1); show "Today" when (i+1) == today.weekday.
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      const dayCount = 7;
      final days = <SettlementData>[];
      for (int i = 0; i < dayCount; i++) {
        final weekday = i + 1; // 1=Mon .. 7=Sun
        final dateLabel = (weekday == today.weekday) ? 'Today' : weekdays[i];
        days.add(SettlementData(
          date: dateLabel,
          numGames: i < numGames.length ? numGames[i] : 0,
          buyIn: i < buyIn.length ? buyIn[i] : 0,
          rolling: i < gameRolling.length ? gameRolling[i] : 0,
          winLoss: i < winLoss.length ? winLoss[i] : 0,
          commission: i < commission.length ? commission[i] : 0,
          expenses: i < junketExpenses.length ? junketExpenses[i] : 0,
        ));
      }

      // Card metrics: today only (index = today's offset in range; if not in range, use 0)
      final todayInRange = !today.isBefore(startDate) && !today.isAfter(endDate);
      final todayIdx = todayInRange ? today.difference(startDate).inDays : -1;
      final hasToday = todayIdx >= 0 && todayIdx < days.length;
      final int totalBuyIn = hasToday ? days[todayIdx].buyIn : 0;
      final int totalGames = hasToday ? days[todayIdx].numGames : 0;
      final int totalRolling = hasToday ? days[todayIdx].rolling : 0;
      final int totalWL = hasToday ? days[todayIdx].winLoss : 0;
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
