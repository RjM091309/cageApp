import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/stat_card.dart';
import '../theme/app_theme.dart';

final _fmt = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 0);
final _fmtCompact = NumberFormat.compact(locale: 'en_PH');

final _mockCasinoRolling = <MapEntry<String, int>>[
  const MapEntry('January', 250000000),
  const MapEntry('February', 180000000),
  const MapEntry('March', 142500000),
  const MapEntry('April', 270000000),
];

class MonthlyView extends StatefulWidget {
  const MonthlyView({super.key});

  @override
  State<MonthlyView> createState() => _MonthlyViewState();
}

class _MonthlyViewState extends State<MonthlyView> {
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
        StatCard(
          label: 'Monthly Accumulated Win Loss',
          value: _fmt.format(42800000),
          icon: Icons.gps_fixed,
          color: StatCardColor.emerald,
          trendValue: '18% vs Last Month',
          trendIsUp: true,
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            if (isWide) {
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.9,
                children: [
                  _metricCard('Top Monthly Commission', 'Rank #1 - Agent Dragon', _fmt.format(850000), Icons.star, amberAccent),
                  _metricCard('Accumulated Expenses', 'MTD Expenditure', _fmt.format(420000), Icons.verified_user, roseAccent),
                  _metricCard('Games (Rolling)', 'Total Rolling', _fmt.format(125000000), Icons.sports_esports, cyanAccent),
                ],
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _metricCard('Top Monthly Commission', 'Rank #1 - Agent Dragon', _fmt.format(850000), Icons.star, amberAccent),
                const SizedBox(height: 12),
                _metricCard('Accumulated Expenses', 'MTD Expenditure', _fmt.format(420000), Icons.verified_user, roseAccent),
                const SizedBox(height: 12),
                _metricCard('Games (Rolling)', 'Total Rolling', _fmt.format(125000000), Icons.sports_esports, cyanAccent),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.withValues(alpha: 0.2),
                cyanAccent.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: cyanAccent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.business, color: cyanAccent, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Casino Integration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('Monthly Accumulated Rolling (Casino)', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final maxRolling = _mockCasinoRolling.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();
                  final barHeight = 28.0;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < _mockCasinoRolling.length; i++) ...[
                        if (i > 0) const SizedBox(height: 12),
                        _HorizontalCasinoBar(
                          label: _mockCasinoRolling[i].key,
                          value: _mockCasinoRolling[i].value,
                          maxValue: maxRolling,
                          barHeight: barHeight,
                          animate: _chartAnimate,
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ignore: non_constant_identifier_names
  static Widget _HorizontalCasinoBar({required String label, required int value, required double maxValue, required double barHeight, bool animate = false}) {
    final ratio = maxValue > 0 ? (value / maxValue) : 0.0;
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[300])),
          ),
          const SizedBox(width: 12),
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
                        color: cyanAccent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 56,
            child: Text(
              '₱${_fmtCompact.format(value)}',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cyanAccent),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
    );
  }

  Widget _metricCard(String title, String sub, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 21),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: TextStyle(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
