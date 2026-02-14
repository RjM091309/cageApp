import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../generated/app_localizations.dart';
import '../models/realtime_data.dart';
import '../services/realtime_service.dart';
import '../models/types.dart';
import '../theme/app_theme.dart';
import '../widgets/active_view_scope.dart';
import '../widgets/skeleton_box.dart';
import '../widgets/stat_card.dart';

final _fmt = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 0);

Widget _skeletonGameCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 38, height: 38, borderRadius: 10),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBox(width: 100, height: 14, borderRadius: 4),
                    SkeletonBox(width: 50, height: 18, borderRadius: 10),
                  ],
                ),
                SizedBox(height: 6),
                SkeletonBox(width: 80, height: 10, borderRadius: 4),
                SizedBox(height: 10),
                Row(
                  children: [
                    SkeletonBox(width: 70, height: 14, borderRadius: 4),
                    SizedBox(width: 12),
                    SkeletonBox(width: 70, height: 14, borderRadius: 4),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

class RealTimeView extends StatefulWidget {
  const RealTimeView({super.key, this.onPollTick});

  /// Called every time the realtime poll runs (same 3s). Use to sync e.g. notification fetch so toast/red dot update with ongoing games.
  final VoidCallback? onPollTick;

  @override
  State<RealTimeView> createState() => _RealTimeViewState();
}

class _RealTimeViewState extends State<RealTimeView> {
  final RealtimeService _service = RealtimeService.instance;
  RealtimeData _data = const RealtimeData.empty();
  bool _loading = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _load();
    // HTTP polling: refresh realtime data for UI. Notifications are created by server-side job only; app just fetches (GET).
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      widget.onPollTick?.call();
      _service.fetchRealtime().then((data) {
        if (!mounted) return;
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
            final crossAxisCount = constraints.maxWidth > 900 ? 6 : (constraints.maxWidth > 600 ? 3 : 2);
            final isTabletWidth = constraints.maxWidth > 600 && constraints.maxWidth <= 1400;
            final aspectRatio = isTabletWidth ? 1.65 : 1.95;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: aspectRatio,
              children: List.generate(6, (_) => _skeletonStatCard()),
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
              const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SkeletonBox(width: 18, height: 18, borderRadius: 6),
                        SizedBox(width: 8),
                        SkeletonBox(width: 120, height: 16, borderRadius: 4),
                      ],
                    ),
                    SkeletonBox(width: 36, height: 22, borderRadius: 20),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.white12),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: List.generate(6, (_) => _skeletonGameCard()),
                ),
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(width: 28, height: 28, borderRadius: 10),
              SizedBox.shrink(),
            ],
          ),
          SizedBox(height: 8),
          SkeletonBox(width: 70, height: 10, borderRadius: 4),
          SizedBox(height: 8),
          SkeletonBox(width: 90, height: 18, borderRadius: 4),
        ],
      ),
    );
  }

  Widget _buildMobileGameCard(AppLocalizations l10n, OngoingGame game) {
    final statusLabel = game.status == 'Active' ? l10n.statusActive : l10n.statusSettling;
    final nameMatch = RegExp(r'^(.+?)\s*\(([^)]+)\)\s*$').firstMatch(game.account);
    final displayName = nameMatch != null ? nameMatch.group(1)!.trim() : game.account;
    final codeSubtitle = nameMatch?.group(2)!.trim();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trophy/Status Icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: game.status == 'Active' ? emeraldAccent.withValues(alpha: 0.2) : amberAccent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              game.status == 'Active' ? Icons.emoji_events : Icons.pending,
              color: game.status == 'Active' ? emeraldAccent : amberAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          // Name and stats column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Status row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(displayName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: game.status == 'Active' ? emeraldAccent.withValues(alpha: 0.2) : amberAccent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 9,
                          color: game.status == 'Active' ? emeraldAccent : amberAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                // Code and Game Type
                Row(
                  children: [
                    if (codeSubtitle != null) ...[
                      Text(codeSubtitle, style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                      const SizedBox(width: 6),
                      Text('•', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                      const SizedBox(width: 6),
                    ],
                    Text(game.gameType, style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 10),
                // Buy In and Cash Out row
                Row(
                  children: [
                    // Buy In
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.buyIn.toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey[500], letterSpacing: 0.5)),
                          const SizedBox(height: 3),
                          Text(_fmt.format(game.buyIn), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryIndigo)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Cash Out
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(l10n.cashOut.toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey[500], letterSpacing: 0.5)),
                          const SizedBox(height: 3),
                          Text(_fmt.format(game.cashOut), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: amberAccent)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
            final crossAxisCount = constraints.maxWidth > 900 ? 6 : (constraints.maxWidth > 600 ? 3 : 2);
            final isTabletWidth = constraints.maxWidth > 600 && constraints.maxWidth <= 1400;
            final aspectRatio = isTabletWidth ? 1.65 : 1.95;
            final houseBalance = _data.totalChips + _data.cashBalance;
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
                  label: l10n.houseBalance,
                  value: _fmt.format(houseBalance),
                  icon: Icons.home_work,
                  color: StatCardColor.brown,
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
              Builder(
                builder: (context) {
                  // Newest first: sort by table (encoded_dt) descending so new games appear at top
                  final games = List<OngoingGame>.from(_data.ongoingGames)
                    ..sort((a, b) => b.table.compareTo(a.table));
                  if (games.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                      child: Center(
                        child: Text(
                          l10n.noGamesToday,
                          style: TextStyle(fontSize: 15, color: Colors.grey[500], fontWeight: FontWeight.w500),
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: games.map((g) => _buildMobileGameCard(l10n, g)).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
