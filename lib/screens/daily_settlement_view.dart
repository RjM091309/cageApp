import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../generated/app_localizations.dart';
import '../models/expense_breakdown.dart';
import '../models/realtime_data.dart';
import '../services/realtime_service.dart';
import '../theme/app_theme.dart';
import '../widgets/skeleton_box.dart';
import '../widgets/stat_card.dart';

final _fmt = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 0);

/// Text tokens for the expense breakdown panel, matching the app's dark theme
/// (no separate light card — everything sits on the same dark surface as other cards).
const _breakdownInkPrimary = Colors.white;
final _breakdownInkSecondary = Colors.grey[400]!;
final _breakdownInkMuted = Colors.grey[500]!;
final _breakdownTrack = Colors.white.withValues(alpha: 0.08);

/// Fixed-order categorical palette, dark-surface steps (validated: dataviz skill
/// `references/palette.md`, dark column).
const _categoryColors = [
  Color(0xFF3987E5), // blue
  Color(0xFFD95926), // orange
  Color(0xFF199E70), // aqua
  Color(0xFFC98500), // yellow
  Color(0xFFD55181), // magenta
  Color(0xFF008300), // green
  Color(0xFF9085E9), // violet
  Color(0xFFE66767), // red
];

Widget _skeletonExpenseCategoryRow() {
  return const Padding(
    padding: EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        SkeletonBox(width: 8, height: 8, borderRadius: 4),
        SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 90, height: 11, borderRadius: 4),
              SizedBox(height: 6),
              SkeletonBox(width: double.infinity, height: 6, borderRadius: 3),
            ],
          ),
        ),
        SizedBox(width: 12),
        SkeletonBox(width: 60, height: 12, borderRadius: 4),
      ],
    ),
  );
}

class DailySettlementView extends StatefulWidget {
  const DailySettlementView({super.key});

  @override
  State<DailySettlementView> createState() => _DailySettlementViewState();
}

class _DailySettlementViewState extends State<DailySettlementView> {
  final RealtimeService _service = RealtimeService.instance;
  RealtimeData _data = const RealtimeData.empty();
  ExpenseBreakdown _expenseBreakdown = const ExpenseBreakdown.empty();
  bool _loading = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _load();
    // HTTP polling: refresh realtime data for UI. Notifications are created by server-side job only; app just fetches (GET).
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      _service.fetchRealtime().then((data) {
        if (!mounted) return;
        setState(() => _data = data);
      });
      _service.fetchExpenseBreakdown().then((data) {
        if (!mounted) return;
        setState(() => _expenseBreakdown = data);
      });
    });
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      _service.fetchRealtime(),
      _service.fetchExpenseBreakdown(),
    ]);
    if (!mounted) return;
    setState(() {
      _data = results[0] as RealtimeData;
      _expenseBreakdown = results[1] as ExpenseBreakdown;
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
            final aspectRatio = isTabletWidth ? 1.65 : (crossAxisCount == 2 ? 1.3 : 1.95);
            const spacing = 16.0;
            final cardWidth = (constraints.maxWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;
            final cardHeight = cardWidth / aspectRatio;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              alignment: WrapAlignment.center,
              children: List.generate(
                5,
                (_) => SizedBox(width: cardWidth, height: cardHeight, child: _skeletonStatCard()),
              ),
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
                  children: List.generate(6, (_) => _skeletonExpenseCategoryRow()),
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

  String _pct(double v) => v.toStringAsFixed(1);

  Widget _buildExpenseCategoryRow(String name, int amount, double percent, Color color) {
    final barFraction = (percent / 100).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _breakdownInkPrimary),
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: barFraction == 0 ? 0.015 : barFraction,
                    minHeight: 5,
                    backgroundColor: _breakdownTrack,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_fmt.format(amount), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _breakdownInkPrimary)),
              const SizedBox(height: 2),
              Text('(${_pct(percent)}%)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _breakdownInkSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseBreakdownBody(AppLocalizations l10n) {
    final categories = _expenseBreakdown.categories;
    if (categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Center(
          child: Text(
            l10n.noExpensesToday,
            style: TextStyle(fontSize: 15, color: Colors.grey[500], fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    final selectedTotalBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: amberAccent.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.filter_alt, color: amberAccent, size: 20),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.selectedTotal.toUpperCase(),
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: _breakdownInkMuted, letterSpacing: 0.6),
        ),
        const SizedBox(height: 4),
        Text(_fmt.format(_expenseBreakdown.total), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _breakdownInkPrimary)),
        const SizedBox(height: 4),
        Text(l10n.ofGrandTotal('100.0'), style: TextStyle(fontSize: 11, color: _breakdownInkSecondary, fontWeight: FontWeight.w500)),
      ],
    );

    final list = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(categories.length, (i) {
        final c = categories[i];
        final color = _categoryColors[i % _categoryColors.length];
        return _buildExpenseCategoryRow(c.name, c.amount, c.percent, color);
      }),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 480) {
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(width: 150, child: selectedTotalBlock),
                  Container(width: 1, color: _breakdownTrack, margin: const EdgeInsets.symmetric(horizontal: 16)),
                  Expanded(child: list),
                ],
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              selectedTotalBlock,
              const SizedBox(height: 16),
              Divider(color: _breakdownTrack, height: 1),
              const SizedBox(height: 16),
              list,
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_loading) {
      return _buildSkeletonContent(context);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 900 ? 6 : (constraints.maxWidth > 600 ? 3 : 2);
            final isTabletWidth = constraints.maxWidth > 600 && constraints.maxWidth <= 1400;
            final aspectRatio = isTabletWidth ? 1.65 : (crossAxisCount == 2 ? 1.3 : 1.95);
            final houseBalance = _data.totalChips + _data.cashBalance;
            const spacing = 16.0;
            final cardWidth = (constraints.maxWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;
            final cardHeight = cardWidth / aspectRatio;
            Widget sizedCard(Widget child) => SizedBox(width: cardWidth, height: cardHeight, child: child);
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              alignment: WrapAlignment.center,
              children: [
                sizedCard(StatCard(
                  label: l10n.houseBalance,
                  value: _fmt.format(houseBalance),
                  icon: Icons.home_work,
                  color: StatCardColor.brown,
                  centered: true,
                )),
                sizedCard(StatCard(
                  label: l10n.cashBalance,
                  value: _fmt.format(_data.cashBalance),
                  icon: Icons.payments,
                  color: StatCardColor.emerald,
                  centered: true,
                )),
                sizedCard(StatCard(
                  label: l10n.guestBalance,
                  value: _fmt.format(_data.guestBalance),
                  icon: Icons.people,
                  color: StatCardColor.purple,
                  centered: true,
                )),
                sizedCard(StatCard(
                  label: l10n.netJunketMoney,
                  value: _fmt.format(_data.netJunketMoney),
                  icon: Icons.account_balance,
                  color: StatCardColor.amber,
                  centered: true,
                )),
                sizedCard(StatCard(
                  label: l10n.netJunketCash,
                  value: _fmt.format(_data.netJunketCash),
                  icon: Icons.account_balance_wallet,
                  color: StatCardColor.rose,
                  centered: true,
                )),
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
                        Icon(Icons.donut_large, size: 18, color: primaryIndigo),
                        const SizedBox(width: 8),
                        Text(l10n.expenseBreakdown, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: primaryIndigo.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                      child: Text(l10n.thisMonth, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryIndigo)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.white12),
              _buildExpenseBreakdownBody(l10n),
            ],
          ),
        ),
      ],
    );
  }
}
