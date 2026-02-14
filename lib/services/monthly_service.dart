import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_config.dart';

/// One month's casino rolling for the chart.
class MonthlyCasinoRolling {
  final String monthKey; // e.g. "January"
  final int value;

  const MonthlyCasinoRolling({required this.monthKey, required this.value});
}

/// Result of GET /api/monthly-accumulated for the Monthly view.
class MonthlyResult {
  final int year;
  final int month;
  final int winLoss;
  final int commissionTotal;
  final int topCommissionAmount; // first in by_rank (per guest/agent)
  final String topCommissionAgentLabel; // e.g. "Agent Dragon" or "AGENT01"
  final int junketExpenses;
  final int rollingGames;
  final int rollingCasino; // current month only
  final List<MonthlyCasinoRolling> casinoRollingByMonth; // 12 months Jan–Dec for chart

  const MonthlyResult({
    required this.year,
    required this.month,
    required this.winLoss,
    required this.commissionTotal,
    required this.topCommissionAmount,
    required this.topCommissionAgentLabel,
    required this.junketExpenses,
    required this.rollingGames,
    required this.rollingCasino,
    required this.casinoRollingByMonth,
  });

  static MonthlyResult empty() {
    return MonthlyResult(
      year: DateTime.now().year,
      month: DateTime.now().month,
      winLoss: 0,
      commissionTotal: 0,
      topCommissionAmount: 0,
      topCommissionAgentLabel: '',
      junketExpenses: 0,
      rollingGames: 0,
      rollingCasino: 0,
      casinoRollingByMonth: const [],
    );
  }
}

class MonthlyService {
  MonthlyService._();
  static final MonthlyService instance = MonthlyService._();

  static const _monthKeys = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  /// Fetches monthly accumulated for current month and 12 months (Jan–Dec) for casino chart.
  Future<MonthlyResult> fetch({int? year, int? month}) async {
    final now = DateTime.now();
    final y = year ?? now.year;
    final m = month ?? now.month;
    try {
      // Fetch main data and 12-month chart in parallel (2 requests instead of 13)
      final results = await Future.wait([
        http.get(Uri.parse(monthlyAccumulatedApiUrl(year: y, month: m))),
        http.get(Uri.parse(monthlyRollingCasinoByYearApiUrl(y))),
      ]);
      final res = results[0];
      final chartRes = results[1];
      if (res.statusCode != 200) return MonthlyResult.empty();
      final json = _parseJson(res.body);
      if (json == null || json['success'] != true) return MonthlyResult.empty();

      final winLoss = _int(json['monthly_accumulated_win_loss']);
      final comm = json['monthly_accumulated_commission'];
      int commissionTotal = 0;
      int topCommissionAmount = 0;
      String topCommissionAgentLabel = '';
      if (comm is Map) {
        commissionTotal = _int(comm['total']);
        final byRank = comm['by_rank'] as List<dynamic>?;
        if (byRank != null && byRank.isNotEmpty) {
          final first = byRank.first;
          if (first is Map) {
            topCommissionAmount = _int(first['amount']);
            final name = first['agent_name']?.toString().trim();
            final code = first['agent_code']?.toString().trim();
            topCommissionAgentLabel = (name != null && name.isNotEmpty) ? name : (code ?? '');
          }
        }
      }
      final junketExpenses = _int(json['monthly_accumulated_junket_expenses']);
      final rollingGames = _int(json['monthly_accumulated_rolling_games']);
      final rollingCasino = _int(json['monthly_accumulated_rolling_casino']);

      // Parse 12 months (Jan–Dec) from single chart response
      final List<MonthlyCasinoRolling> casinoByMonth = [];
      if (chartRes.statusCode == 200) {
        final chartJson = _parseJson(chartRes.body);
        if (chartJson != null && chartJson['success'] == true) {
          final byMonth = chartJson['by_month'] as List<dynamic>?;
          if (byMonth != null && byMonth.length >= 12) {
            for (int i = 0; i < 12; i++) {
              final entry = byMonth[i];
              final val = entry is Map ? _int(entry['value']) : 0;
              casinoByMonth.add(MonthlyCasinoRolling(monthKey: _monthKeys[i], value: val));
            }
          }
        }
      }
      if (casinoByMonth.length != 12) {
        for (int i = casinoByMonth.length; i < 12; i++) {
          casinoByMonth.add(MonthlyCasinoRolling(monthKey: _monthKeys[i], value: 0));
        }
      }

      return MonthlyResult(
        year: y,
        month: m,
        winLoss: winLoss,
        commissionTotal: commissionTotal,
        topCommissionAmount: topCommissionAmount,
        topCommissionAgentLabel: topCommissionAgentLabel,
        junketExpenses: junketExpenses,
        rollingGames: rollingGames,
        rollingCasino: rollingCasino,
        casinoRollingByMonth: casinoByMonth,
      );
    } catch (_) {
      return MonthlyResult.empty();
    }
  }

  int _int(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
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
