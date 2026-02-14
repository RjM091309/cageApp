import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../generated/app_localizations.dart';
import '../services/daily_settlement_service.dart';
import '../theme/app_theme.dart';
import '../widgets/skeleton_box.dart';

String _fmt(num v) {
  return NumberFormat.compact(locale: 'en_PH').format(v);
}

String _fmtWL(int v) {
  final s = NumberFormat.compact(locale: 'en_PH').format(v.abs());
  return v >= 0 ? '+$s' : '-$s';
}

class _VerticalGamesWlBar extends StatelessWidget {
  final String date;
  final int numGames;
  final int winLoss;
  final int maxGames;
  final int minWL;
  final int maxWL;
  final bool animate;
  final bool isExpanded;

  const _VerticalGamesWlBar({
    required this.date,
    required this.numGames,
    required this.winLoss,
    required this.maxGames,
    required this.minWL,
    required this.maxWL,
    required this.animate,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final isCompact = media.width < 360;
    final isSmall = media.width < 400;
    final labelFontSize = isExpanded ? 16.0 : (isCompact ? 10.0 : (isSmall ? 11.0 : 13.0));
    final wlFontSize = isExpanded ? 15.0 : (isCompact ? 9.0 : (isSmall ? 10.0 : 12.0));
    final dateFontSize = isExpanded ? 14.0 : (isCompact ? 9.0 : (isSmall ? 10.0 : 12.0));
    final labelAreaHeight = isCompact ? 44.0 : (isSmall ? 50.0 : 56.0);
    final barMaxWidth = isCompact ? 32.0 : (isSmall ? 40.0 : 48.0);
    final sidePadding = isCompact ? 2.0 : 3.0;
    final barGap = isCompact ? 2.0 : 3.0;
    final labelBarGap = isCompact ? 4.0 : 6.0;
    final dateTopGap = isCompact ? 6.0 : 10.0;

    final maxY = (maxGames * 1.15).toDouble();
    double wlBarRatio() {
      if (winLoss >= 0) {
        if (maxWL <= 0) return 0;
        return (winLoss / maxWL).clamp(0.0, 1.0);
      }
      if (minWL >= 0) return 0;
      return (winLoss.abs() / minWL.abs()).clamp(0.0, 1.0);
    }

    return LayoutBuilder(
      builder: (context, c) {
        final barMaxHeight = ((c.maxHeight - labelAreaHeight) * 0.92).clamp(20.0, 200.0);
        final gamesHeight = (numGames / maxY * barMaxHeight).clamp(0.0, barMaxHeight);
        final wlHeight = (wlBarRatio() * barMaxHeight).clamp(2.0, barMaxHeight);
        final rawWidth = c.maxWidth.isFinite ? c.maxWidth : 80.0;
        final maxContentWidth = (rawWidth - sidePadding * 2).clamp(40.0, 500.0);
        final barWidth = ((maxContentWidth - barGap) / 2).clamp(10.0, barMaxWidth);

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sidePadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$numGames', style: TextStyle(fontSize: labelFontSize, fontWeight: FontWeight.w700, color: primaryIndigo)),
                          SizedBox(height: labelBarGap),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            height: animate ? gamesHeight : 0,
                            width: barWidth,
                            decoration: BoxDecoration(
                              color: primaryIndigo,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: barGap),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_fmtWL(winLoss), style: TextStyle(fontSize: wlFontSize, fontWeight: FontWeight.w700, color: winLoss >= 0 ? emeraldAccent : roseAccent)),
                          SizedBox(height: labelBarGap),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            height: animate ? wlHeight : 0,
                            width: barWidth,
                            decoration: BoxDecoration(
                              color: winLoss >= 0 ? emeraldAccent : roseAccent,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: dateTopGap),
            Text(
              date,
              style: TextStyle(fontSize: dateFontSize, fontWeight: FontWeight.w500, color: const Color(0xFFBDBDBD)),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        );
      },
    );
  }
}

class _HorizontalCommissionBar extends StatelessWidget {
  final String date;
  final int commission;
  final double maxCommission;
  final double barHeight;
  final bool animate;
  final bool isExpanded;

  const _HorizontalCommissionBar({
    required this.date,
    required this.commission,
    required this.maxCommission,
    required this.barHeight,
    required this.animate,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = maxCommission > 0 ? (commission / maxCommission) : 0.0;
    final fontSize = isExpanded ? 16.0 : 10.0;
    final dateWidth = isExpanded ? 48.0 : 32.0;
    final valueWidth = isExpanded ? 72.0 : 48.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: dateWidth,
          child: Text(date, style: TextStyle(fontSize: fontSize, color: const Color(0xFFBDBDBD))),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) {
              final maxW = c.maxWidth;
              final w = (animate ? maxW * ratio : 0.0).clamp(0.0, maxW);
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    width: w,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: amberAccent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: valueWidth,
          child: Text(
            _fmt(commission),
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600, color: amberAccent),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class DailySettlementView extends StatefulWidget {
  const DailySettlementView({super.key});

  @override
  State<DailySettlementView> createState() => _DailySettlementViewState();
}

class _DailySettlementViewState extends State<DailySettlementView> {
  bool _chartAnimate = false;
  bool _loading = true;
  String? _error;
  DailySettlementResult _result = DailySettlementResult.empty();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _chartAnimate = false;
    });
    try {
      final result = await DailySettlementService.instance.fetch();
      if (!mounted) return;
      setState(() {
        _result = result;
        _loading = false;
      });
      // Trigger chart animation after first build with data (initial spots → final spots)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _chartAnimate = true);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load settlement data';
      });
    }
  }

  Widget _buildSkeletonContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final count = constraints.maxWidth > 600 ? 4 : 2;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: count,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.85,
              children: List.generate(4, (_) => _skeletonMetricTile()),
            );
          },
        ),
        SizedBox(height: MediaQuery.sizeOf(context).height > 600 ? 24 : 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final isPortrait = constraints.maxWidth < 600;
            final spacing = isPortrait ? 28.0 : 20.0;
            final h = (isPortrait ? 360.0 : 320.0) * (MediaQuery.sizeOf(context).height / 700).clamp(0.85, 1.15);
            if (isPortrait) {
              return Column(
                children: [
                  SizedBox(height: h, child: _skeletonChartCard()),
                  SizedBox(height: spacing),
                  SizedBox(height: h, child: _skeletonChartCard()),
                  SizedBox(height: spacing),
                  SizedBox(height: h, child: _skeletonChartCard()),
                  SizedBox(height: spacing),
                  SizedBox(height: h, child: _skeletonChartCard()),
                ],
              );
            }
            return Column(
              children: [
                SizedBox(
                  height: h,
                  child: Row(
                    children: [
                      Expanded(child: _skeletonChartCard()),
                      SizedBox(width: spacing),
                      Expanded(child: _skeletonChartCard()),
                    ],
                  ),
                ),
                SizedBox(height: spacing),
                SizedBox(
                  height: h,
                  child: Row(
                    children: [
                      Expanded(child: _skeletonChartCard()),
                      SizedBox(width: spacing),
                      Expanded(child: _skeletonChartCard()),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _skeletonMetricTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SkeletonBox(height: 10, width: 80, borderRadius: 4),
          SizedBox(height: 8),
          SkeletonBox(height: 18, width: 60, borderRadius: 4),
        ],
      ),
    );
  }

  Widget _skeletonChartCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonBox(width: 20, height: 20, borderRadius: 6),
              SizedBox(width: 8),
              SkeletonBox(width: 140, height: 16, borderRadius: 4),
            ],
          ),
          SizedBox(height: 16),
          Expanded(child: SkeletonBox(height: double.infinity, borderRadius: 8)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_loading && _result.days.isEmpty) {
      return _buildSkeletonContent(context);
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, style: TextStyle(color: Colors.grey[400])),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _load,
                style: FilledButton.styleFrom(backgroundColor: primaryIndigo),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    final r = _result;
    final fmtCurr = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 0);
    final totalBuyInStr = fmtCurr.format(r.totalBuyIn);
    final dailyRollingStr = fmtCurr.format(r.totalRolling);
    final dailyWlStr = r.totalWinLoss >= 0
        ? '+${fmtCurr.format(r.totalWinLoss)}'
        : '-${fmtCurr.format(r.totalWinLoss.abs())}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = constraints.maxWidth;
            final count = contentWidth > 600 ? 4 : 2;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: count,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.85,
              children: [
                _metricTile(l10n.totalBuyIn, totalBuyInStr),
                _metricTile(l10n.avgRolling, dailyRollingStr),
                _metricTile(l10n.winRate, dailyWlStr, isGreen: r.totalWinLoss >= 0),
                _metricTile(l10n.totalGames, '${r.totalGames}'),
              ],
            );
          },
        ),
        SizedBox(height: MediaQuery.sizeOf(context).height > 600 ? 24 : 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final media = MediaQuery.sizeOf(context);
            final contentWidth = constraints.maxWidth;
            final isPortrait = contentWidth < 600;
            final spacing = isPortrait ? 28.0 : 20.0;
            final heightScale = (media.height / 700).clamp(0.85, 1.15);
            final topRowHeight = (isPortrait ? 360.0 : 320.0) * heightScale;
            final bottomRowHeight = (isPortrait ? 380.0 : 340.0) * heightScale;
            if (isPortrait) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: topRowHeight, child: _wrapChartTap(context, AppLocalizations.of(context).numberOfGamesWinLoss, _gamesChartCard)),
                  SizedBox(height: spacing),
                  SizedBox(height: topRowHeight, child: _wrapChartTap(context, AppLocalizations.of(context).winLossTrend, _winLossTrendCard)),
                  SizedBox(height: spacing),
                  SizedBox(height: bottomRowHeight, child: _wrapChartTap(context, AppLocalizations.of(context).dailyCommission, _commissionChartCard)),
                  SizedBox(height: spacing),
                  SizedBox(height: bottomRowHeight, child: _wrapChartTap(context, AppLocalizations.of(context).junketExpenses, _expensesChartCard)),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: topRowHeight,
                  child: Row(
                    children: [
                      Expanded(child: _wrapChartTap(context, AppLocalizations.of(context).numberOfGamesWinLoss, _gamesChartCard)),
                      SizedBox(width: spacing),
                      Expanded(child: _wrapChartTap(context, AppLocalizations.of(context).winLossTrend, _winLossTrendCard)),
                    ],
                  ),
                ),
                SizedBox(height: spacing),
                SizedBox(
                  height: bottomRowHeight,
                  child: Row(
                    children: [
                      Expanded(child: _wrapChartTap(context, AppLocalizations.of(context).dailyCommission, _commissionChartCard)),
                      SizedBox(width: spacing),
                      Expanded(child: _wrapChartTap(context, AppLocalizations.of(context).junketExpenses, _expensesChartCard)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _metricTile(String label, String value, {bool isGreen = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label.toUpperCase(), textAlign: TextAlign.center, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.0)),
          const SizedBox(height: 4),
          Text(value, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isGreen ? emeraldAccent : Colors.white)),
        ],
      ),
    );
  }

  void _showExpandedChart(
    BuildContext context,
    String title,
    Widget Function(BuildContext, {bool isExpanded, VoidCallback? onClose}) buildChart,
  ) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (BuildContext fullContext) {
          return Scaffold(
            backgroundColor: surfaceColor,
            body: SafeArea(
              child: buildChart(
                fullContext,
                isExpanded: true,
                onClose: () => Navigator.of(fullContext).pop(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _wrapChartTap(
    BuildContext context,
    String title,
    Widget Function(BuildContext, {bool isExpanded, VoidCallback? onClose}) buildChart,
  ) {
    return GestureDetector(
      onTap: () => _showExpandedChart(context, title, buildChart),
      child: buildChart(context),
    );
  }

  Widget _gamesChartCard(BuildContext context, {bool isExpanded = false, VoidCallback? onClose}) {
    final media = MediaQuery.sizeOf(context);
    final isCompact = media.width < 360;
    final gapBetweenDays = isCompact ? 4.0 : 6.0;
    final minWidthPerDay = isCompact ? 20.0 : 24.0;
    final titleSize = isExpanded ? 18.0 : (isCompact ? 13.0 : (media.width < 400 ? 14.0 : 16.0));
    final padding = isCompact ? 12.0 : 16.0;

    final days = _result.days;
    final maxGames = days.isEmpty ? 0 : days.map((e) => e.numGames).reduce((a, b) => a > b ? a : b);
    final minWL = days.isEmpty ? 0 : days.map((e) => e.winLoss).reduce((a, b) => a < b ? a : b);
    final maxWL = days.isEmpty ? 0 : days.map((e) => e.winLoss).reduce((a, b) => a > b ? a : b);
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.grid_view, size: isCompact ? 16 : 20, color: accentPurple),
              SizedBox(width: isCompact ? 6 : 8),
              Expanded(child: Text(AppLocalizations.of(context).numberOfGamesWinLoss, style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w600, color: Colors.white))),
              if (isExpanded && onClose != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  iconSize: isCompact ? 20 : 24,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  color: Colors.grey[400],
                )
              else
                Icon(Icons.open_in_full, size: isCompact ? 14 : 18, color: Colors.grey[500]),
            ],
          ),
          SizedBox(height: isCompact ? 12 : 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemCount = days.length;
                final totalGap = itemCount <= 1 ? 0.0 : gapBetweenDays * (itemCount - 1);
                final availableWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : 400.0;
                final widthPerDay = itemCount == 0 ? minWidthPerDay : ((availableWidth - totalGap) / itemCount).clamp(minWidthPerDay, double.infinity);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (int i = 0; i < days.length; i++) ...[
                      if (i > 0) SizedBox(width: gapBetweenDays),
                      SizedBox(
                        width: widthPerDay,
                        child:                       _VerticalGamesWlBar(
                          date: days[i].date,
                          numGames: days[i].numGames,
                          winLoss: days[i].winLoss,
                          maxGames: maxGames,
                          minWL: minWL,
                          maxWL: maxWL,
                          animate: _chartAnimate,
                          isExpanded: isExpanded,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _winLossTrendCard(BuildContext context, {bool isExpanded = false, VoidCallback? onClose}) {
    final media = MediaQuery.sizeOf(context);
    final isCompact = media.width < 360;
    final titleSize = isExpanded ? 18.0 : (isCompact ? 12.0 : (media.width < 400 ? 13.0 : 14.0));
    final padding = isCompact ? 12.0 : 16.0;
    final labelFontSize = isExpanded ? 14.0 : (isCompact ? 8.0 : 10.0);
    final valueFontSize = isExpanded ? 18.0 : (isCompact ? 8.0 : 9.0);

    final days = _result.days;
    final maxPos = days.isEmpty ? 1.0 : days.map((e) => e.winLoss).where((v) => v > 0).fold<double>(0, (a, b) => b > a ? b.toDouble() : a);
    final maxNeg = days.isEmpty ? 1.0 : days.map((e) => e.winLoss).where((v) => v < 0).fold<double>(0, (a, b) => b.abs() > a ? b.abs().toDouble() : a);
    final scalePos = maxPos <= 0 ? 1.0 : maxPos * 1.1;
    final scaleNeg = maxNeg <= 0 ? 1.0 : maxNeg * 1.1;
    const centerLabelHeight = 40.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, size: isCompact ? 16 : 18, color: emeraldAccent),
              SizedBox(width: isCompact ? 6 : 8),
              Expanded(child: Text(AppLocalizations.of(context).winLossTrend, style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w600, color: Colors.white))),
              if (isExpanded && onClose != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  iconSize: isCompact ? 20 : 24,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  color: Colors.grey[400],
                )
              else
                Icon(Icons.open_in_full, size: isCompact ? 14 : 18, color: Colors.grey[500]),
            ],
          ),
          SizedBox(height: isCompact ? 12 : 16),
          Expanded(
            child: days.isEmpty
                ? const SizedBox.shrink()
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final h = constraints.maxHeight;
                      final halfExtra = (h - centerLabelHeight) / 2;
                      const maxTopBottomHeight = 80.0;
                      final labelGap = 4.0;
                      final labelHeight = valueFontSize * 1.35;
                      final topBottomHeight = min(maxTopBottomHeight, halfExtra - labelGap);
                      final barMax = max(4.0, topBottomHeight - labelHeight - labelGap - 4);
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              for (int i = 0; i < days.length; i++) ...[
                                if (i > 0) SizedBox(width: isCompact ? 4 : 6),
                                Expanded(
                                  child: SizedBox(
                                    height: topBottomHeight,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (days[i].winLoss > 0) ...[
                                          Text(
                                            _fmtWL(days[i].winLoss),
                                            style: TextStyle(fontSize: valueFontSize, fontWeight: FontWeight.w600, color: emeraldAccent),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: labelGap),
                                          AnimatedContainer(
                                            duration: const Duration(milliseconds: 500),
                                            curve: Curves.easeOutCubic,
                                            height: _chartAnimate ? (days[i].winLoss / scalePos * barMax).clamp(4.0, barMax) : 0,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: emeraldAccent.withValues(alpha: 0.6),
                                              borderRadius: const BorderRadius.vertical(bottom: Radius.zero),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Row(
                            children: [
                              for (int i = 0; i < days.length; i++) ...[
                                if (i > 0) SizedBox(width: isCompact ? 4 : 6),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: days[i].winLoss > 0
                                          ? emeraldAccent.withValues(alpha: 0.25)
                                          : (days[i].winLoss < 0 ? roseAccent.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.06)),
                                      borderRadius: const BorderRadius.vertical(top: Radius.zero, bottom: Radius.zero),
                                    ),
                                    child: Text(
                                      days[i].date,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: labelFontSize, color: Colors.grey[400]),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (int i = 0; i < days.length; i++) ...[
                                if (i > 0) SizedBox(width: isCompact ? 4 : 6),
                                Expanded(
                                  child: SizedBox(
                                    height: topBottomHeight,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (days[i].winLoss < 0) ...[
                                          AnimatedContainer(
                                            duration: const Duration(milliseconds: 500),
                                            curve: Curves.easeOutCubic,
                                            height: _chartAnimate ? (days[i].winLoss.abs() / scaleNeg * barMax).clamp(4.0, barMax) : 0,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: roseAccent.withValues(alpha: 0.6),
                                              borderRadius: const BorderRadius.vertical(top: Radius.zero),
                                            ),
                                          ),
                                          SizedBox(height: labelGap),
                                          Text(
                                            _fmtWL(days[i].winLoss),
                                            style: TextStyle(fontSize: valueFontSize, fontWeight: FontWeight.w600, color: roseAccent),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ] else if (days[i].winLoss == 0)
                                          Text(_fmtWL(0), style: TextStyle(fontSize: valueFontSize, fontWeight: FontWeight.w600, color: Colors.grey[500])),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
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

  Widget _commissionChartCard(BuildContext context, {bool isExpanded = false, VoidCallback? onClose}) {
    final media = MediaQuery.sizeOf(context);
    final isCompact = media.width < 360;
    final padding = isCompact ? 12.0 : 16.0;
    final titleSize = isExpanded ? 18.0 : (isCompact ? 12.0 : (media.width < 400 ? 13.0 : 14.0));
    final maxBarHeight = isExpanded ? 56.0 : (isCompact ? 36.0 : 44.0);
    final minBarHeight = isExpanded ? 28.0 : (isCompact ? 18.0 : 24.0);

    final days = _result.days;
    final maxCommission = days.isEmpty ? 1.0 : days.map((e) => e.commission).reduce((a, b) => a > b ? a : b).toDouble();
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.handshake, size: isCompact ? 16 : 18, color: amberAccent),
              SizedBox(width: isCompact ? 6 : 8),
              Expanded(child: Text(AppLocalizations.of(context).dailyCommission, style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w600, color: Colors.white))),
              if (isExpanded && onClose != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  iconSize: isCompact ? 20 : 24,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  color: Colors.grey[400],
                )
              else
                Icon(Icons.open_in_full, size: isCompact ? 14 : 18, color: Colors.grey[500]),
            ],
          ),
          SizedBox(height: isCompact ? 12 : 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final barHeight = days.isEmpty ? minBarHeight : (constraints.maxHeight / days.length).clamp(minBarHeight, maxBarHeight) - 4;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (int i = 0; i < days.length; i++)
                      _HorizontalCommissionBar(
                        date: days[i].date,
                        commission: days[i].commission,
                        maxCommission: maxCommission,
                        barHeight: barHeight,
                        animate: _chartAnimate,
                        isExpanded: isExpanded,
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

  static double _logExpense(int value) {
    return value <= 0 ? 0.0 : log(value.toDouble() + 1);
  }

  Widget _expensesChartCard(BuildContext context, {bool isExpanded = false, VoidCallback? onClose}) {
    final media = MediaQuery.sizeOf(context);
    final isCompact = media.width < 360;
    final padding = isCompact ? 12.0 : 16.0;
    final titleSize = isExpanded ? 18.0 : (isCompact ? 12.0 : (media.width < 400 ? 13.0 : 14.0));
    final labelFontSize = isExpanded ? 14.0 : (isCompact ? 8.0 : 10.0);
    final valueFontSize = isExpanded ? 18.0 : (isCompact ? 8.0 : 9.0);

    final days = _result.days;
    // Use log scale so small values (e.g. 3K) are visible vs 0 when max is huge (e.g. 3.03M)
    final maxLogY = days.isEmpty
        ? 1.0
        : days.map((e) => _logExpense(e.expenses)).reduce((a, b) => a > b ? a : b) * 1.15;
    final minLogY = 0.0;
    final spots = _chartAnimate
        ? days.asMap().entries.map((e) => FlSpot(e.key.toDouble(), _logExpense(e.value.expenses))).toList()
        : List.generate(days.length, (i) => FlSpot(i.toDouble(), minLogY));
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, size: isCompact ? 16 : 18, color: roseAccent),
              SizedBox(width: isCompact ? 6 : 8),
              Expanded(child: Text(AppLocalizations.of(context).junketExpenses, style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w600, color: Colors.white))),
              if (isExpanded && onClose != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  iconSize: isCompact ? 20 : 24,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  color: Colors.grey[400],
                )
              else
                Icon(Icons.open_in_full, size: isCompact ? 14 : 18, color: Colors.grey[500]),
            ],
          ),
          SizedBox(height: isCompact ? 12 : 16),
          Expanded(
            child: ClipRect(
              child: LineChart(
                LineChartData(
                  lineTouchData: const LineTouchData(enabled: false),
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (days.isEmpty ? 0 : days.length - 1).toDouble(),
                  minY: minLogY,
                  maxY: maxLogY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: false,
                      color: roseAccent,
                      barWidth: 3,
                      belowBarData: BarAreaData(show: true, color: roseAccent.withValues(alpha: 0.1)),
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
              ),
            ),
          ),
          SizedBox(height: isCompact ? 6 : 8),
          Row(
            children: [
              for (int i = 0; i < days.length; i++)
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(days[i].date, style: TextStyle(fontSize: labelFontSize, color: Colors.grey[400])),
                      const SizedBox(height: 2),
                      Text(
                        _fmt(days[i].expenses),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: valueFontSize, fontWeight: FontWeight.w600, color: roseAccent),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
