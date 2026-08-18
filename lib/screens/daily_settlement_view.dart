import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../generated/app_localizations.dart';
import '../models/expense_breakdown.dart';
import '../models/realtime_data.dart';
import '../services/realtime_service.dart';
import '../theme/app_theme.dart';
import '../utils/fold_layout.dart';
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
    padding: EdgeInsets.only(bottom: 8),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCardGrid(
              context,
              constraints,
              List.generate(
                5,
                (i) => _skeletonStatCard(horizontal: i == 4 && constraints.maxWidth < 900),
              ),
            ),
            SizedBox(height: _fitGap(constraints)),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                        child: Column(
                          children: List.generate(6, (_) => _skeletonExpenseCategoryRow()),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _fitTight(BoxConstraints c) =>
      c.maxHeight < 720 || FoldLayout.isFoldedCover(context);

  double _fitGap(BoxConstraints c) => _fitTight(c) ? 8.0 : 16.0;

  Widget _buildCardGrid(BuildContext context, BoxConstraints constraints, List<Widget> cards) {
    final w = constraints.maxWidth;
    final tight = _fitTight(constraints);
    final gap = w < 400 ? 6.0 : (tight ? 8.0 : 12.0);
    if (cards.length != 5) {
      return Wrap(spacing: gap, runSpacing: gap, children: cards);
    }

    Widget cell(Widget child, double width, double height) =>
        SizedBox(width: width, height: height, child: ClipRect(child: child));

    if (w >= 900) {
      final cardW = (w - gap * 4) / 5;
      final h = tight && constraints.maxHeight < 500 ? 88.0 : 112.0;
      return Row(
        children: [
          for (var i = 0; i < 5; i++) ...[
            if (i > 0) SizedBox(width: gap),
            cell(cards[i], cardW, h),
          ],
        ],
      );
    }

    final cardW = (w - gap) / 2;
    final cardH = tight ? 68.0 : 112.0;
    final spanH = tight ? 50.0 : 72.0;
    return Column(
      children: [
        Row(
          children: [
            cell(cards[0], cardW, cardH),
            SizedBox(width: gap),
            cell(cards[1], cardW, cardH),
          ],
        ),
        SizedBox(height: gap),
        Row(
          children: [
            cell(cards[2], cardW, cardH),
            SizedBox(width: gap),
            cell(cards[3], cardW, cardH),
          ],
        ),
        SizedBox(height: gap),
        cell(cards[4], w, spanH),
      ],
    );
  }

  Widget _skeletonStatCard({bool horizontal = false}) {
    final box = BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      color: Colors.white.withValues(alpha: 0.03),
    );
    if (horizontal) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: box,
        child: const Row(
          children: [
            SkeletonBox(width: 32, height: 32, borderRadius: 10),
            SizedBox(width: 12),
            Expanded(child: SkeletonBox(height: 12, borderRadius: 4)),
            SizedBox(width: 12),
            SkeletonBox(width: 72, height: 16, borderRadius: 4),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: box,
      child: const FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 26, height: 26, borderRadius: 10),
            SizedBox(height: 6),
            SkeletonBox(width: 70, height: 10, borderRadius: 4),
            SizedBox(height: 6),
            SkeletonBox(width: 90, height: 16, borderRadius: 4),
          ],
        ),
      ),
    );
  }

  String _pct(double v) => v.toStringAsFixed(1);

  Widget _buildExpenseCategoryRow(String name, int amount, double percent, Color color) {
    final barFraction = (percent / 100).clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final tall = constraints.maxHeight >= 44;
        final barH = tall ? 6.0 : 4.0;
        return Row(
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: tall ? 12 : 11,
                      fontWeight: FontWeight.w600,
                      color: _breakdownInkPrimary,
                    ),
                  ),
                  SizedBox(height: tall ? 6 : 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: barFraction == 0 ? 0.015 : barFraction,
                      minHeight: barH,
                      backgroundColor: _breakdownTrack,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _fmt.format(amount),
                  style: TextStyle(
                    fontSize: tall ? 13 : 12,
                    fontWeight: FontWeight.bold,
                    color: _breakdownInkPrimary,
                  ),
                ),
                Text(
                  '(${_pct(percent)}%)',
                  style: TextStyle(fontSize: tall ? 10 : 9, fontWeight: FontWeight.w700, color: _breakdownInkSecondary),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _categoryList(List<ExpenseCategoryBreakdown> categories) {
    if (categories.isEmpty) return const SizedBox.shrink();
    return Column(
      children: List.generate(categories.length, (i) {
        final c = categories[i];
        final color = _categoryColors[i % _categoryColors.length];
        return Expanded(
          child: _buildExpenseCategoryRow(c.name, c.amount, c.percent, color),
        );
      }),
    );
  }

  Widget _buildExpenseBreakdownBody(AppLocalizations l10n) {
    final categories = _expenseBreakdown.categories;
    if (categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        child: Center(
          child: Text(
            l10n.noExpensesToday,
            style: TextStyle(fontSize: 15, color: Colors.grey[500], fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    final totalBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.totalExpenses.toUpperCase(),
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: _breakdownInkMuted, letterSpacing: 0.6),
        ),
        const SizedBox(height: 4),
        Text(_fmt.format(_expenseBreakdown.total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _breakdownInkPrimary)),
      ],
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          totalBlock,
          const SizedBox(height: 8),
          Divider(color: _breakdownTrack, height: 1),
          const SizedBox(height: 6),
          Expanded(child: _categoryList(categories)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_loading) {
      return _buildSkeletonContent(context);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final houseBalance = _data.totalChips + _data.cashBalance;
        final wide = constraints.maxWidth >= 900;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCardGrid(context, constraints, [
              StatCard(
                label: l10n.houseBalance,
                value: _fmt.format(houseBalance),
                icon: Icons.home_work,
                color: StatCardColor.brown,
                centered: true,
              ),
              StatCard(
                label: l10n.cashBalance,
                value: _fmt.format(_data.cashBalance),
                icon: Icons.payments,
                color: StatCardColor.emerald,
                centered: true,
              ),
              StatCard(
                label: l10n.guestBalance,
                value: _fmt.format(_data.guestBalance),
                icon: Icons.people,
                color: StatCardColor.purple,
                centered: true,
              ),
              StatCard(
                label: l10n.netJunketMoney,
                value: _fmt.format(_data.netJunketMoney),
                icon: Icons.account_balance,
                color: StatCardColor.amber,
                centered: true,
              ),
              StatCard(
                label: l10n.netJunketCash,
                value: _fmt.format(_data.netJunketCash),
                icon: Icons.account_balance_wallet,
                color: StatCardColor.rose,
                centered: true,
                horizontal: !wide,
              ),
            ]),
            SizedBox(height: _fitGap(constraints)),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.donut_large, size: 16, color: primaryIndigo),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              l10n.expenseBreakdown,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: primaryIndigo.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                            child: Text(l10n.thisMonth, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryIndigo)),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Colors.white12),
                    Expanded(child: _buildExpenseBreakdownBody(l10n)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
