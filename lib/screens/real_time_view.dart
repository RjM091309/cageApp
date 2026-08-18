import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../generated/app_localizations.dart';
import '../main.dart';
import '../models/dashboard_summary.dart';
import '../models/monthly_statistics.dart';
import '../services/dashboard_summary_service.dart';
import '../services/monthly_statistics_service.dart';
import '../theme/app_theme.dart';
import '../utils/fold_layout.dart';
import '../widgets/skeleton_box.dart';

final _fmt = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 0);

const _monthNamesEn = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _monthLabel(String monthKey, Locale? locale) {
  final parts = monthKey.split('-');
  if (parts.length < 2) return monthKey;
  final m = int.tryParse(parts[1]);
  if (m == null || m < 1 || m > 12) return monthKey;
  if (locale?.languageCode == 'en') return _monthNamesEn[m - 1];
  return '$m월';
}

class RealTimeView extends StatefulWidget {
  const RealTimeView({super.key, this.onPollTick});

  /// Called every 3s so other polled data (e.g. notifications) stays in sync while this tab is active.
  final VoidCallback? onPollTick;

  @override
  State<RealTimeView> createState() => _RealTimeViewState();
}

class _RealTimeViewState extends State<RealTimeView> {
  Timer? _pollTimer;
  Timer? _summaryTimer;
  DashboardSummary? _summary;
  bool _loadingSummary = true;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      widget.onPollTick?.call();
    });
    _loadSummary();
    _summaryTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _loadSummary();
    });
  }

  Future<void> _loadSummary() async {
    final summary = await DashboardSummaryService.instance.fetchSummary();
    if (!mounted) return;
    setState(() {
      _summary = summary;
      _loadingSummary = false;
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _summaryTimer?.cancel();
    super.dispose();
  }

  void _showStatisticsDialog() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => const _StatisticsDialog(),
    );
  }

  Widget _buildHighlightCard(_DashboardFit fit) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.fromLTRB(fit.highlightPad, fit.highlightPad * 0.7, fit.highlightPad, fit.highlightPad),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: emeraldAccent.withValues(alpha: 0.35)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            emeraldAccent.withValues(alpha: 0.22),
            emeraldAccent.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: fit.highlightIcon,
                height: fit.highlightIcon,
                decoration: BoxDecoration(color: emeraldAccent.withValues(alpha: 0.25), shape: BoxShape.circle),
                child: Icon(Icons.trending_up, size: fit.highlightIcon * 0.5, color: emeraldAccent),
              ),
              const Spacer(),
              Material(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: _showStatisticsDialog,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: fit.statBtnPadH, vertical: fit.statBtnPadV),
                    child: Text(
                      l10n.statisticsLabel,
                      style: TextStyle(color: Colors.white, fontSize: fit.statBtnFont, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: fit.highlightGap),
          Expanded(
            child: LayoutBuilder(
              builder: (context, metricsBox) {
                final dividerH = (metricsBox.maxHeight * 0.55).clamp(18.0, fit.dividerHeight);
                return Row(
                  children: [
                    Expanded(
                      child: _highlightMetric(
                        label: l10n.winLossLabel,
                        value: _summary?.winLoss,
                        fit: fit,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: dividerH,
                      margin: EdgeInsets.symmetric(horizontal: fit.dividerMargin),
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    Expanded(
                      child: _highlightMetric(
                        label: l10n.ngrLabel,
                        value: _summary?.ngr,
                        fit: fit,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _signedAmountColor(int? value) {
    if (value == null || value == 0) return Colors.white;
    return value > 0 ? emeraldAccent : roseAccent;
  }

  Widget _highlightMetric({required String label, required int? value, required _DashboardFit fit}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: fit.highlightLabel, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: fit.compact ? 4 : 6),
        Flexible(
          child: _amountText(
            value,
            fontSize: fit.highlightAmount,
            color: _signedAmountColor(value),
            align: Alignment.center,
          ),
        ),
      ],
    );
  }

  Widget _amountText(int? value, {required double fontSize, required Color color, Alignment align = Alignment.centerLeft}) {
    if (_loadingSummary || value == null) {
      return SkeletonBox(width: fontSize * 4, height: fontSize * 1.1);
    }
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: align,
      child: Text(
        _fmt.format(value),
        maxLines: 1,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _wideStatCard({
    required IconData icon,
    required Color color,
    required String label,
    required int? value,
    required _DashboardFit fit,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: fit.cardPadH, vertical: fit.cardPadV),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final iconBox = box.maxHeight.clamp(22.0, fit.cardIcon);
          return Row(
            children: [
              Container(
                width: iconBox,
                height: iconBox,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, size: iconBox * 0.48, color: color),
              ),
              SizedBox(width: fit.cardGap),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: fit.cardLabel, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: fit.compact ? 2 : 4),
                    Flexible(
                      child: _amountText(value, fontSize: fit.cardAmount, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statSlot({required Widget child}) {
    return Expanded(child: child);
  }

  List<Widget> _secondaryCards(AppLocalizations l10n, _DashboardFit fit) {
    return [
      _wideStatCard(icon: Icons.account_balance_wallet, color: amberAccent, label: l10n.totalCommissionLabel, value: _summary?.totalCommission, fit: fit),
      _wideStatCard(icon: Icons.shield, color: roseAccent, label: l10n.accumulatedExpenses, value: _summary?.expenses, fit: fit),
      _wideStatCard(icon: Icons.videogame_asset, color: primaryIndigo, label: l10n.cageRollingLabel, value: _summary?.cageRolling, fit: fit),
      _wideStatCard(icon: Icons.casino, color: primaryIndigo, label: l10n.casinoRollingLabel, value: _summary?.casinoRolling, fit: fit),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final fit = _DashboardFit.from(constraints);
        final cards = _secondaryCards(l10n, fit);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: fit.useGrid ? 5 : 4,
              child: _buildHighlightCard(fit),
            ),
            SizedBox(height: fit.gap),
            if (fit.useGrid)
              Expanded(
                flex: 8,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _statSlot(child: cards[0]),
                          SizedBox(width: fit.gap),
                          _statSlot(child: cards[1]),
                        ],
                      ),
                    ),
                    SizedBox(height: fit.gap),
                    Expanded(
                      child: Row(
                        children: [
                          _statSlot(child: cards[2]),
                          SizedBox(width: fit.gap),
                          _statSlot(child: cards[3]),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) SizedBox(height: fit.gap),
                Expanded(flex: 3, child: cards[i]),
              ],
          ],
        );
      },
    );
  }
}

/// Viewport-based sizes so the 5 dashboard cards always fit without scrolling.
class _DashboardFit {
  final bool compact;
  final bool useGrid;
  final double gap;
  final double highlightPad;
  final double highlightGap;
  final double highlightIcon;
  final double highlightLabel;
  final double highlightAmount;
  final double dividerHeight;
  final double dividerMargin;
  final double statBtnPadH;
  final double statBtnPadV;
  final double statBtnFont;
  final double cardPadH;
  final double cardPadV;
  final double cardIcon;
  final double cardGap;
  final double cardLabel;
  final double cardAmount;

  const _DashboardFit({
    required this.compact,
    required this.useGrid,
    required this.gap,
    required this.highlightPad,
    required this.highlightGap,
    required this.highlightIcon,
    required this.highlightLabel,
    required this.highlightAmount,
    required this.dividerHeight,
    required this.dividerMargin,
    required this.statBtnPadH,
    required this.statBtnPadV,
    required this.statBtnFont,
    required this.cardPadH,
    required this.cardPadV,
    required this.cardIcon,
    required this.cardGap,
    required this.cardLabel,
    required this.cardAmount,
  });

  factory _DashboardFit.from(BoxConstraints constraints) {
    final w = constraints.maxWidth;
    final h = constraints.maxHeight;
    final compact = h < 620;
    // Tablet/desktop, or short landscape phones: 2×2 grid so cards use width instead of overflowing vertically.
    final useGrid = w >= 640 || h < 500;
    final t = (h / 720).clamp(0.72, 1.15);
    return _DashboardFit(
      compact: compact,
      useGrid: useGrid,
      gap: (compact ? 8.0 : 12.0) * t.clamp(0.85, 1.1),
      highlightPad: compact ? 14.0 : 22.0,
      highlightGap: compact ? 8.0 : 14.0,
      highlightIcon: compact ? 28.0 : 36.0,
      highlightLabel: compact ? 15.0 : 20.0,
      highlightAmount: compact ? 20.0 : 24.0,
      dividerHeight: compact ? 32.0 : 44.0,
      dividerMargin: w < 400 ? 10.0 : (w < 700 ? 16.0 : 28.0),
      statBtnPadH: compact ? 12.0 : 18.0,
      statBtnPadV: compact ? 6.0 : 10.0,
      statBtnFont: compact ? 11.0 : 13.0,
      cardPadH: compact ? 12.0 : 18.0,
      cardPadV: compact ? 8.0 : 14.0,
      cardIcon: compact ? 36.0 : 46.0,
      cardGap: compact ? 10.0 : 14.0,
      cardLabel: compact ? 13.0 : 16.0,
      cardAmount: compact ? 16.0 : 19.0,
    );
  }
}

class _StatisticsDialog extends StatefulWidget {
  const _StatisticsDialog();

  @override
  State<_StatisticsDialog> createState() => _StatisticsDialogState();
}

class _StatisticsDialogState extends State<_StatisticsDialog> {
  MonthlyStatistics? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stats = await MonthlyStatisticsService.instance.fetchStatistics();
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _loading = false;
    });
  }

  static const _monthColumnWidth = 32.0;

  String _compactAmount(int value) {
    if (value == 0) return '0';
    final sign = value < 0 ? '-' : '';
    final abs = value.abs();
    if (abs >= 1000000) {
      final m = abs / 1000000;
      final body = m >= 10 ? m.round().toString() : m.toStringAsFixed(1);
      return '$sign${body}M';
    }
    if (abs >= 1000) {
      final k = abs / 1000;
      final body = k >= 10 ? k.round().toString() : k.toStringAsFixed(1);
      return '$sign${body}K';
    }
    return NumberFormat.decimalPattern().format(value);
  }

  Widget _headerCell(String text, {required bool compact}) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              text,
              maxLines: 1,
              softWrap: false,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: compact ? 9 : 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey[400],
              ),
            ),
          ),
        ),
      );

  Widget _monthCell(String month, {required bool compact}) => SizedBox(
        width: _monthColumnWidth,
        child: Text(
          month,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: compact ? 11 : 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );

  Widget _valueCell(int value, Color color, {required bool compact}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Text(
            _compactAmount(value),
            maxLines: 1,
            softWrap: false,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = AppLocaleScope.of(context).locale;
    final compact = FoldLayout.isFoldedCover(context);
    final year = locale?.languageCode == 'en' ? '${DateTime.now().year}' : '${DateTime.now().year}년';
    final months = _stats?.months ?? const [];
    final rowGap = compact ? 8.0 : 14.0;
    return Dialog(
      backgroundColor: surfaceDarkMid,
      insetPadding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 16,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(compact ? 10 : 20, 16, compact ? 10 : 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(year, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                IconButton(
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white70, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(width: _monthColumnWidth),
                _headerCell(compact && locale?.languageCode == 'en' ? 'W/L' : l10n.winLossLabel, compact: compact),
                _headerCell(l10n.shareLabel, compact: compact),
                _headerCell(compact && locale?.languageCode == 'en' ? 'Comm' : l10n.commissionLabel, compact: compact),
                _headerCell(compact && locale?.languageCode == 'en' ? 'Exp' : l10n.expensesLabel, compact: compact),
                _headerCell(l10n.ngrLabel, compact: compact),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: Colors.white12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (months.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text(l10n.noDataYet, style: TextStyle(color: Colors.grey[500]))),
              )
            else
              for (final s in months) ...[
                SizedBox(height: rowGap),
                Row(
                  children: [
                    _monthCell(_monthLabel(s.monthKey, locale), compact: compact),
                    _valueCell(s.winLoss, amberAccent, compact: compact),
                    _valueCell(s.share, roseAccent, compact: compact),
                    _valueCell(s.commission, roseAccent, compact: compact),
                    _valueCell(s.expenses, amberAccent, compact: compact),
                    _valueCell(s.ngr, Colors.white, compact: compact),
                  ],
                ),
                SizedBox(height: rowGap),
                const Divider(height: 1, color: Colors.white12),
              ],
            const SizedBox(height: 4),
            Center(
              child: Icon(Icons.keyboard_double_arrow_down, color: primaryIndigo, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}
