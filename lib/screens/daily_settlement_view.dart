import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/mock_data.dart';
import '../theme/app_theme.dart';

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

  const _VerticalGamesWlBar({
    required this.date,
    required this.numGames,
    required this.winLoss,
    required this.maxGames,
    required this.minWL,
    required this.maxWL,
    required this.animate,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final isCompact = media.width < 360;
    final isSmall = media.width < 400;
    final labelFontSize = isCompact ? 10.0 : (isSmall ? 11.0 : 13.0);
    final wlFontSize = isCompact ? 9.0 : (isSmall ? 10.0 : 12.0);
    final dateFontSize = isCompact ? 9.0 : (isSmall ? 10.0 : 12.0);
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
                          Text('$numGames', style: TextStyle(fontSize: labelFontSize, fontWeight: FontWeight.w700, color: const Color(0xFF0ea5e9))),
                          SizedBox(height: labelBarGap),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            height: animate ? gamesHeight : 0,
                            width: barWidth,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0ea5e9),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
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
                              color: winLoss >= 0 ? const Color(0xFF14b8a6) : roseAccent,
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

  const _HorizontalCommissionBar({
    required this.date,
    required this.commission,
    required this.maxCommission,
    required this.barHeight,
    required this.animate,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = maxCommission > 0 ? (commission / maxCommission) : 0.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 32,
          child: Text(date, style: const TextStyle(fontSize: 10, color: Color(0xFFBDBDBD))),
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
          width: 48,
          child: Text(
            _fmt(commission),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: amberAccent),
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _chartAnimate = true);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                _metricTile('Total Buy-In', '₱24.5M'),
                _metricTile('Avg Rolling', '₱10.2M'),
                _metricTile('Win Rate', '+14.2%', isGreen: true),
                _metricTile('Total Games', '174'),
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
                  SizedBox(height: topRowHeight, child: _gamesChartCard(context)),
                  SizedBox(height: spacing),
                  SizedBox(height: topRowHeight, child: _winLossTrendCard(context)),
                  SizedBox(height: spacing),
                  SizedBox(height: bottomRowHeight, child: _commissionChartCard(context)),
                  SizedBox(height: spacing),
                  SizedBox(height: bottomRowHeight, child: _expensesChartCard(context)),
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
                      Expanded(child: _gamesChartCard(context)),
                      SizedBox(width: spacing),
                      Expanded(child: _winLossTrendCard(context)),
                    ],
                  ),
                ),
                SizedBox(height: spacing),
                SizedBox(
                  height: bottomRowHeight,
                  child: Row(
                    children: [
                      Expanded(child: _commissionChartCard(context)),
                      SizedBox(width: spacing),
                      Expanded(child: _expensesChartCard(context)),
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

  Widget _gamesChartCard(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final isCompact = media.width < 360;
    final gapBetweenDays = isCompact ? 4.0 : 6.0;
    final minWidthPerDay = isCompact ? 20.0 : 24.0;
    final titleSize = isCompact ? 13.0 : (media.width < 400 ? 14.0 : 16.0);
    final padding = isCompact ? 12.0 : 16.0;

    final maxGames = mockDailySettlement.map((e) => e.numGames).reduce((a, b) => a > b ? a : b);
    final minWL = mockDailySettlement.map((e) => e.winLoss).reduce((a, b) => a < b ? a : b);
    final maxWL = mockDailySettlement.map((e) => e.winLoss).reduce((a, b) => a > b ? a : b);
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.grid_view, size: isCompact ? 16 : 20, color: Colors.blue[300]),
              SizedBox(width: isCompact ? 6 : 8),
              Text('Number of Games & Win/Loss', style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
          SizedBox(height: isCompact ? 12 : 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemCount = mockDailySettlement.length;
                final totalGap = gapBetweenDays * (itemCount - 1);
                final availableWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : 400.0;
                final widthPerDay = ((availableWidth - totalGap) / itemCount).clamp(minWidthPerDay, double.infinity);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (int i = 0; i < mockDailySettlement.length; i++) ...[
                      if (i > 0) SizedBox(width: gapBetweenDays),
                      SizedBox(
                        width: widthPerDay,
                        child: _VerticalGamesWlBar(
                          date: mockDailySettlement[i].date,
                          numGames: mockDailySettlement[i].numGames,
                          winLoss: mockDailySettlement[i].winLoss,
                          maxGames: maxGames,
                          minWL: minWL,
                          maxWL: maxWL,
                          animate: _chartAnimate,
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

  Widget _winLossTrendCard(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final isCompact = media.width < 360;
    final titleSize = isCompact ? 12.0 : (media.width < 400 ? 13.0 : 14.0);
    final padding = isCompact ? 12.0 : 16.0;
    final labelFontSize = isCompact ? 8.0 : 10.0;
    final valueFontSize = isCompact ? 8.0 : 9.0;

    final minY = mockDailySettlement.map((e) => e.winLoss).reduce((a, b) => a < b ? a : b) * 1.1;
    final maxY = mockDailySettlement.map((e) => e.winLoss).reduce((a, b) => a > b ? a : b) * 1.1;
    final spots = _chartAnimate
        ? mockDailySettlement.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.winLoss.toDouble())).toList()
        : List.generate(mockDailySettlement.length, (i) => FlSpot(i.toDouble(), minY));
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
              Text('Win / Loss Trend', style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
          SizedBox(height: isCompact ? 12 : 16),
          Expanded(
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
                maxX: (mockDailySettlement.length - 1).toDouble(),
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: emeraldAccent,
                    barWidth: 3,
                    belowBarData: BarAreaData(show: true, color: emeraldAccent.withValues(alpha: 0.2)),
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
            ),
          ),
          SizedBox(height: isCompact ? 6 : 8),
          Row(
            children: [
              for (int i = 0; i < mockDailySettlement.length; i++)
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(mockDailySettlement[i].date, style: TextStyle(fontSize: labelFontSize, color: Colors.grey[400])),
                      const SizedBox(height: 2),
                      Text(
                        _fmtWL(mockDailySettlement[i].winLoss),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: valueFontSize, fontWeight: FontWeight.w600, color: mockDailySettlement[i].winLoss >= 0 ? emeraldAccent : roseAccent),
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

  Widget _commissionChartCard(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final isCompact = media.width < 360;
    final padding = isCompact ? 12.0 : 16.0;
    final titleSize = isCompact ? 12.0 : (media.width < 400 ? 13.0 : 14.0);
    final maxBarHeight = isCompact ? 36.0 : 44.0;
    final minBarHeight = isCompact ? 18.0 : 24.0;

    final maxCommission = mockDailySettlement.map((e) => e.commission).reduce((a, b) => a > b ? a : b).toDouble();
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
              Text('Daily Commission', style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
          SizedBox(height: isCompact ? 12 : 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final barHeight = (constraints.maxHeight / mockDailySettlement.length).clamp(minBarHeight, maxBarHeight) - 4;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (int i = 0; i < mockDailySettlement.length; i++)
                      _HorizontalCommissionBar(
                        date: mockDailySettlement[i].date,
                        commission: mockDailySettlement[i].commission,
                        maxCommission: maxCommission,
                        barHeight: barHeight,
                        animate: _chartAnimate,
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

  Widget _expensesChartCard(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final isCompact = media.width < 360;
    final padding = isCompact ? 12.0 : 16.0;
    final titleSize = isCompact ? 12.0 : (media.width < 400 ? 13.0 : 14.0);
    final labelFontSize = isCompact ? 8.0 : 10.0;
    final valueFontSize = isCompact ? 8.0 : 9.0;

    final maxY = mockDailySettlement.map((e) => e.expenses).reduce((a, b) => a > b ? a : b) * 1.2;
    final spots = _chartAnimate
        ? mockDailySettlement.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.expenses.toDouble())).toList()
        : List.generate(mockDailySettlement.length, (i) => FlSpot(i.toDouble(), 0.0));
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
              Text('Junket Expenses', style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
          SizedBox(height: isCompact ? 12 : 16),
          Expanded(
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
                maxX: (mockDailySettlement.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
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
          SizedBox(height: isCompact ? 6 : 8),
          Row(
            children: [
              for (int i = 0; i < mockDailySettlement.length; i++)
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(mockDailySettlement[i].date, style: TextStyle(fontSize: labelFontSize, color: Colors.grey[400])),
                      const SizedBox(height: 2),
                      Text(
                        _fmt(mockDailySettlement[i].expenses),
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
