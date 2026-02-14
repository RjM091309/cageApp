import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import '../models/types.dart';

class MarkerService {
  MarkerService._();
  static final MarkerService instance = MarkerService._();

  /// Fetches marker/credit list (guests/agents with non-zero balance).
  Future<List<MarkerEntry>> fetch() async {
    try {
      final res = await http.get(Uri.parse(markerApiUrl));
      if (res.statusCode != 200) return [];
      final json = _parseJson(res.body);
      if (json == null || json['success'] != true) return [];
      final list = json['marker'] as List<dynamic>?;
      if (list == null) return [];
      return list.map((e) {
        if (e is! Map) return null;
        final name = e['agent_name']?.toString().trim() ?? '';
        final code = e['agent_code']?.toString().trim() ?? '';
        final agencyName = e['agency_name']?.toString().trim() ?? '';
        // Right side: agency name (fallback to name/code if no agency)
        final guest = agencyName.isNotEmpty ? agencyName : (name.isNotEmpty ? name : (code.isNotEmpty ? code : '—'));
        // Left side: "NAME (AGENT CODE)"
        final agent = name.isNotEmpty && code.isNotEmpty
            ? '$name ($code)'
            : (name.isNotEmpty ? name : (code.isNotEmpty ? code : ''));
        final balance = _int(e['balance']);
        final lastUpdate = _formatLastActivity(e['last_activity']);
        return MarkerEntry(
          guest: guest,
          agent: agent,
          balance: balance,
          limit: 0, // API does not return limit; hide utilization when 0
          lastUpdate: lastUpdate,
        );
      }).whereType<MarkerEntry>().toList();
    } catch (_) {
      return [];
    }
  }

  int _int(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  /// Format last_activity (ISO string) to "MMM d, yyyy h:mm a" for card display.
  String _formatLastActivity(dynamic v) {
    if (v == null || v.toString().trim().isEmpty) return '';
    try {
      final dt = DateTime.tryParse(v.toString());
      if (dt == null) return '';
      const months = 'JanFebMarAprMayJunJulAugSepOctNovDec';
      final m = months.substring((dt.month - 1) * 3, dt.month * 3);
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final ampm = dt.hour < 12 ? 'AM' : 'PM';
      final min = dt.minute.toString().padLeft(2, '0');
      return '$m ${dt.day}, ${dt.year} $hour:$min $ampm';
    } catch (_) {
      return '';
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
}
