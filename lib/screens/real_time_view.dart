import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../generated/app_localizations.dart';
import '../models/realtime_data.dart';
import '../services/realtime_service.dart';
import '../services/notification_service.dart';
import '../models/types.dart';
import '../theme/app_theme.dart';
import '../widgets/active_view_scope.dart';
import '../widgets/skeleton_box.dart';
import '../widgets/stat_card.dart';

final _fmt = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 0);
final _dateTimeFmt = DateFormat('MMM d, yyyy h:mm a');

/// Formats encoded_dt for display in device local time, e.g. "Feb 12, 2026 2:14 PM".
/// Backend may send UTC without "Z"; we treat that as UTC so it displays correctly in Philippines/local.
String _formatTableDateTime(String raw) {
  if (raw.isEmpty) return raw;
  final dt = _parseDateTimeAsUtcOrLocal(raw);
  if (dt == null) return raw;
  return _dateTimeFmt.format(dt);
}

/// Parses API datetime. If string has no timezone (no Z, no offset), treats it as UTC (server/DB convention).
DateTime? _parseDateTimeAsUtcOrLocal(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return null;
  final withZ = DateTime.tryParse(s);
  if (withZ != null && (s.endsWith('Z') || s.contains('+') || s.contains('-'))) return withZ.toLocal();
  final noTz = DateTime.tryParse(s);
  if (noTz != null) {
    if (noTz.isUtc) return noTz.toLocal();
    return DateTime.utc(noTz.year, noTz.month, noTz.day, noTz.hour, noTz.minute, noTz.second, noTz.millisecond).toLocal();
  }
  return null;
}

TableCell _tableCell(Widget child) => TableCell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: child,
      ),
    );

class RealTimeView extends StatefulWidget {
  const RealTimeView({super.key});

  @override
  State<RealTimeView> createState() => _RealTimeViewState();
}

class _RealTimeViewState extends State<RealTimeView> {
  final RealtimeService _service = RealtimeService.instance;
  RealtimeData _data = RealtimeData.empty();
  bool _loading = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _load();
    // HTTP polling on all platforms (backend has REST /api/realtime only; no Socket.IO emit)
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      _service.fetchRealtime().then((data) {
        if (!mounted) return;
        if (ActiveViewScope.find(context)?.activeView != ViewType.realTime) return;
        _notifyNewOngoingGamesIfAny(data);
        setState(() => _data = data);
      });
    });
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _service.fetchRealtime();
    if (!mounted) return;
    if (ActiveViewScope.find(context)?.activeView != ViewType.realTime) return;
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  /// When new games or buy-in changes appear in realtime data, create notifications for the executive.
  void _notifyNewOngoingGamesIfAny(RealtimeData data) {
    final previousById = {for (final g in _data.ongoingGames) g.id: g};
    final previousIds = previousById.keys.toSet();

    // New game started
    final newGames = data.ongoingGames.where((g) => !previousIds.contains(g.id)).toList();
    for (final g in newGames) {
      NotificationService.instance.createNotification(
        title: 'New game started',
        message: '${g.account} – Buy-in ${_fmt.format(g.buyIn)} at ${_formatTableDateTime(g.table)} (${g.gameType})',
        type: 'info',
      );
    }

    // Buy-in added to current game (show time when we detected it, not game start time)
    for (final g in data.ongoingGames) {
      final prev = previousById[g.id];
      if (prev == null || g.buyIn <= prev.buyIn) continue;
      final added = g.buyIn - prev.buyIn;
      final nowStr = _dateTimeFmt.format(DateTime.now());
      NotificationService.instance.createNotification(
        title: 'Buy-in added',
        message: '${g.account} added ${_fmt.format(added)} at $nowStr – total ${_fmt.format(g.buyIn)} (${g.gameType})',
        type: 'info',
      );
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Widget _buildSkeletonContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 900 ? 5 : (constraints.maxWidth > 600 ? 3 : 2);
            final isTabletWidth = constraints.maxWidth > 600 && constraints.maxWidth <= 1400;
            final aspectRatio = isTabletWidth ? 1.65 : 1.95;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: aspectRatio,
              children: List.generate(5, (_) => _skeletonStatCard()),
            );
          },
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SkeletonBox(width: 18, height: 18, borderRadius: 6),
                        const SizedBox(width: 8),
                        SkeletonBox(width: 120, height: 16, borderRadius: 4),
                      ],
                    ),
                    SkeletonBox(width: 36, height: 22, borderRadius: 20),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.white12),
              LayoutBuilder(
                builder: (context, c) {
                  final isMobile = c.maxWidth < 600;
                  final table = Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1.5),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1.2),
                      3: FlexColumnWidth(0.8),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05)),
                        children: [
                          _tableCell(SkeletonBox(height: 12, borderRadius: 4)),
                          _tableCell(SkeletonBox(height: 12, borderRadius: 4)),
                          _tableCell(SkeletonBox(height: 12, borderRadius: 4)),
                          _tableCell(SkeletonBox(height: 12, borderRadius: 4)),
                        ],
                      ),
                      ...List.generate(6, (_) => TableRow(
                        children: [
                          _tableCell(SkeletonBox(height: 14, borderRadius: 4)),
                          _tableCell(SkeletonBox(height: 14, borderRadius: 4)),
                          _tableCell(SkeletonBox(height: 14, borderRadius: 4)),
                          _tableCell(SkeletonBox(width: 60, height: 20, borderRadius: 12)),
                        ],
                      )),
                    ],
                  );
                  if (isMobile) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(width: 420, child: table),
                    );
                  }
                  return table;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _skeletonStatCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        color: Colors.white.withValues(alpha: 0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(width: 28, height: 28, borderRadius: 10),
              const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 8),
          SkeletonBox(width: 70, height: 10, borderRadius: 4),
          const SizedBox(height: 8),
          SkeletonBox(width: 90, height: 18, borderRadius: 4),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_loading && _data.ongoingGames.isEmpty) {
      return _buildSkeletonContent(context);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 900 ? 5 : (constraints.maxWidth > 600 ? 3 : 2);
            final isTabletWidth = constraints.maxWidth > 600 && constraints.maxWidth <= 1400;
            final aspectRatio = isTabletWidth ? 1.65 : 1.95;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: aspectRatio,
              children: [
                StatCard(
                  label: l10n.totalChips,
                  value: _fmt.format(_data.totalChips),
                  icon: Icons.monetization_on,
                  color: StatCardColor.primary,
                ),
                StatCard(
                  label: l10n.cashBalance,
                  value: _fmt.format(_data.cashBalance),
                  icon: Icons.payments,
                  color: StatCardColor.emerald,
                ),
                StatCard(
                  label: l10n.guestBalance,
                  value: _fmt.format(_data.guestBalance),
                  icon: Icons.people,
                  color: StatCardColor.purple,
                ),
                StatCard(
                  label: l10n.netJunketMoney,
                  value: _fmt.format(_data.netJunketMoney),
                  icon: Icons.account_balance,
                  color: StatCardColor.amber,
                ),
                StatCard(
                  label: l10n.netJunketCash,
                  value: _fmt.format(_data.netJunketCash),
                  icon: Icons.account_balance_wallet,
                  color: StatCardColor.rose,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.show_chart, size: 18, color: primaryIndigo),
                        const SizedBox(width: 8),
                        Text(l10n.ongoingGames, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: primaryIndigo.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                      child: Text(l10n.live, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryIndigo)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.white12),
              LayoutBuilder(
                builder: (context, c) {
                  final isMobile = c.maxWidth < 600;
                  final games = _data.ongoingGames;
                  final table = Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1.5),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1.2),
                      3: FlexColumnWidth(0.8),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05)),
                        children: [
                          _tableCell(Text(l10n.account, style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold))),
                          _tableCell(Text(l10n.gameType, style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold))),
                          _tableCell(Text(l10n.buyIn, style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold))),
                          _tableCell(Text(l10n.status, style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold))),
                        ],
                      ),
                      ...games.map((g) {
                        final statusLabel = g.status == 'Active' ? l10n.statusActive : l10n.statusSettling;
                        return TableRow(
                          children: [
                            _tableCell(Text(g.account, style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500))),
                            _tableCell(Text(g.gameType, style: TextStyle(fontSize: 13, color: Colors.grey[400]))),
                            _tableCell(Text(_fmt.format(g.buyIn), style: TextStyle(fontSize: 13, color: primaryIndigo, fontFamily: 'monospace'))),
                            _tableCell(
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: g.status == 'Active' ? emeraldAccent.withValues(alpha: 0.2) : amberAccent.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(statusLabel, style: TextStyle(fontSize: 10, color: g.status == 'Active' ? emeraldAccent : amberAccent, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  );
                  if (games.isEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        table,
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                          child: Center(
                            child: Text(
                              l10n.noGamesToday,
                              style: TextStyle(fontSize: 15, color: Colors.grey[500], fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  if (isMobile) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: 420,
                        child: table,
                      ),
                    );
                  }
                  return table;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
