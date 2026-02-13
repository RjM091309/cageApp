import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import '../models/types.dart';

/// Result of a paginated ranking fetch.
class RankingPageResult {
  final List<RankingItem> list;
  final int total;

  const RankingPageResult({required this.list, required this.total});
}

class RankingService {
  RankingService._();
  static final RankingService instance = RankingService._();

  static const int _pageSize = 20;

  /// Fetches one page of guest/agent ranking.
  /// [limit] default 20, [offset] for pagination. Returns list and total count.
  Future<RankingPageResult> fetch({int? year, int? month, int limit = _pageSize, int offset = 0}) async {
    try {
      final url = rankingApiUrl(year: year, month: month, limit: limit, offset: offset);
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) return const RankingPageResult(list: [], total: 0);
      final json = _parseJson(res.body);
      if (json == null || json['success'] != true) return const RankingPageResult(list: [], total: 0);
      final list = json['ranking'] as List<dynamic>?;
      final total = _int(json['total']);
      if (list == null) return RankingPageResult(list: [], total: total);
      final items = list.map((e) {
        if (e is! Map) return null;
        final name = e['agent_name']?.toString()?.trim() ?? '';
        final code = e['agent_code']?.toString()?.trim() ?? '';
        final displayName = code.isNotEmpty && name.isNotEmpty
            ? '$name ($code)'
            : (name.isNotEmpty ? name : (code.isNotEmpty ? code : '—'));
        final rolling = _int(e['monthly_accumulated_rolling']);
        final winnings = _int(e['monthly_accumulated_winning']);
        final losses = _int(e['monthly_accumulated_losing']);
        final rank = _int(e['rank_rolling']);
        return RankingItem(
          name: displayName,
          rolling: rolling,
          winnings: winnings,
          losses: losses,
          rank: rank > 0 ? rank : 0,
        );
      }).whereType<RankingItem>().toList()
        ..sort((a, b) => a.rank.compareTo(b.rank));
      return RankingPageResult(list: items, total: total);
    } catch (_) {
      return const RankingPageResult(list: [], total: 0);
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
