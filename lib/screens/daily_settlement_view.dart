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
        final barMaxHeight = ((c.maxHeight - 48) * 0.92).clamp(24.0, 200.0);
        final gamesHeight = (numGames / maxY * barMaxHeight).clamp(0.0, barMaxHeight);
        final wlHeight = (wlBarRatio() * barMaxHeight).clamp(2.0, barMaxHeight);
        const barWidth = 30.0;
        const barGap = 2.0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$numGames', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF0ea5e9))),
                    const SizedBox(height: 2),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      height: animate ? gamesHeight : 0,
                      width: barWidth,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0ea5e9),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: barGap),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_fmtWL(winLoss), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: winLoss >= 0 ? emeraldAccent : roseAccent)),
                    const SizedBox(height: 2),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      height: animate ? wlHeight : 0,
                      width: barWidth,
                      decoration: BoxDecoration(
                        color: winLoss >= 0 ? const Color(0xFF14b8a6) : roseAccent,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(date, style: const TextStyle(fontSize: 10, color: Color(0xFFBDBDBD))),
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
            final count = constraints.maxWidth > 600 ? 4 : 2;
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
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 1,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              childAspectRatio: 2.0,
              children: [
                _gamesChartCard(),
                _winLossTrendCard(),
                _commissionChartCard(),
                _expensesChartCard(),
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

  Widget _gamesChartCard() {
    final maxGames = mockDailySettlement.map((e) => e.numGames).reduce((a, b) => a > b ? a : b);
    final minWL = mockDailySettlement.map((e) => e.winLoss).reduce((a, b) => a < b ? a : b);
    final maxWL = mockDailySettlement.map((e) => e.winLoss).reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.grid_view, size: 18, color: Colors.blue[300]),
              const SizedBox(width: 8),
              const Text('Number of Games & Win/Loss', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (int i = 0; i < mockDailySettlement.length; i++)
                  Expanded(
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _winLossTrendCard() {
    final minY = mockDailySettlement.map((e) => e.winLoss).reduce((a, b) => a < b ? a : b) * 1.1;
    final maxY = mockDailySettlement.map((e) => e.winLoss).reduce((a, b) => a > b ? a : b) * 1.1;
    final spots = _chartAnimate
        ? mockDailySettlement.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.winLoss.toDouble())).toList()
        : List.generate(mockDailySettlement.length, (i) => FlSpot(i.toDouble(), minY));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, size: 18, color: emeraldAccent),
              const SizedBox(width: 8),
              const Text('Win / Loss Trend', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
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
                    barWidth: 2,
                    belowBarData: BarAreaData(show: true, color: emeraldAccent.withValues(alpha: 0.2)),
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (int i = 0; i < mockDailySettlement.length; i++)
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(mockDailySettlement[i].date, style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                      const SizedBox(height: 2),
                      Text(
                        _fmtWL(mockDailySettlement[i].winLoss),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: mockDailySettlement[i].winLoss >= 0 ? emeraldAccent : roseAccent),
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

  Widget _commissionChartCard() {
    final maxCommission = mockDailySettlement.map((e) => e.commission).reduce((a, b) => a > b ? a : b).toDouble();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.handshake, size: 18, color: amberAccent),
              const SizedBox(width: 8),
              const Text('Daily Commission', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final barHeight = (constraints.maxHeight / mockDailySettlement.length).clamp(20.0, 36.0) - 4;
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

  Widget _expensesChartCard() {
    final maxY = mockDailySettlement.map((e) => e.expenses).reduce((a, b) => a > b ? a : b) * 1.2;
    final spots = _chartAnimate
        ? mockDailySettlement.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.expenses.toDouble())).toList()
        : List.generate(mockDailySettlement.length, (i) => FlSpot(i.toDouble(), 0.0));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, size: 18, color: roseAccent),
              const SizedBox(width: 8),
              const Text('Junket Expenses', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
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
                    barWidth: 2,
                    belowBarData: BarAreaData(show: true, color: roseAccent.withValues(alpha: 0.1)),
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (int i = 0; i < mockDailySettlement.length; i++)
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(mockDailySettlement[i].date, style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                      const SizedBox(height: 2),
                      Text(
                        _fmt(mockDailySettlement[i].expenses),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: roseAccent),
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
