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

  Widget _buildHighlightCard() {
    final l10n = AppLocalizations.of(context);
    final folded = FoldLayout.isFoldedCover(context);
    return Container(
      padding: EdgeInsets.fromLTRB(folded ? 12 : 16, folded ? 12 : 14, folded ? 12 : 16, folded ? 12 : 16),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: emeraldAccent.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.trending_up, size: 18, color: emeraldAccent),
              ),
              const Spacer(),
              Material(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: _showStatisticsDialog,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      l10n.statisticsLabel,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: folded ? 10 : 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _metricBlock(l10n.winLossLabel, _summary?.winLoss)),
              Container(
                width: 1,
                height: folded ? 44 : 52,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: Colors.white.withValues(alpha: 0.12),
              ),
              Expanded(child: _metricBlock(l10n.ngrLabel, _summary?.ngr)),
            ],
          ),
        ],
      ),
    );
  }

  Color _signedAmountColor(int? value) {
    if (value == null || value == 0) return Colors.white;
    return value > 0 ? emeraldAccent : roseAccent;
  }

  Widget _metricBlock(String label, int? value) {
    final folded = FoldLayout.isFoldedCover(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        _amountText(
          _summary == null ? null : value,
          fontSize: folded ? 16 : 20,
          color: _signedAmountColor(value),
        ),
      ],
    );
  }

  Widget _amountText(int? value, {required double fontSize, required Color color}) {
    if (_loadingSummary || value == null) {
      return SkeletonBox(width: fontSize * 4, height: fontSize * 1.1);
    }
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        _fmt.format(value),
        maxLines: 1,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _wideStatCard({required IconData icon, required Color color, required String label, required int? value}) {
    final folded = FoldLayout.isFoldedCover(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: folded ? 12 : 18, vertical: folded ? 16 : 22),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: folded ? 40 : 46,
            height: folded ? 40 : 46,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: folded ? 20 : 22, color: color),
          ),
          SizedBox(width: folded ? 10 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: folded ? 16 : 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _amountText(value, fontSize: folded ? 16 : 19, color: Colors.white),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHighlightCard(),
        const SizedBox(height: 18),
        _wideStatCard(icon: Icons.account_balance_wallet, color: amberAccent, label: l10n.totalCommissionLabel, value: _summary?.totalCommission),
        const SizedBox(height: 14),
        _wideStatCard(icon: Icons.shield, color: roseAccent, label: l10n.accumulatedExpenses, value: _summary?.expenses),
        const SizedBox(height: 14),
        _wideStatCard(icon: Icons.videogame_asset, color: primaryIndigo, label: l10n.cageRollingLabel, value: _summary?.cageRolling),
        const SizedBox(height: 14),
        _wideStatCard(icon: Icons.casino, color: primaryIndigo, label: l10n.casinoRollingLabel, value: _summary?.casinoRolling),
      ],
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
                fontSize: compact ? 10 : 12,
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
          style: TextStyle(fontSize: compact ? 12 : 13, fontWeight: FontWeight.bold, color: Colors.white),
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
