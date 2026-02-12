import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../generated/app_localizations.dart';
import '../services/monthly_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/skeleton_box.dart';
import '../theme/app_theme.dart';

final _fmt = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 0);
final _fmtCompact = NumberFormat.compact(locale: 'en_PH');

class MonthlyView extends StatefulWidget {
  const MonthlyView({super.key});

  @override
  State<MonthlyView> createState() => _MonthlyViewState();
}

class _MonthlyViewState extends State<MonthlyView> {
  bool _chartAnimate = false;
  bool _loading = true;
  String? _error;
  MonthlyResult _result = MonthlyResult.empty();

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
      final result = await MonthlyService.instance.fetch();
      if (!mounted) return;
      setState(() {
        _result = result;
        _loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _chartAnimate = true);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load monthly data';
      });
    }
  }

  String _monthLabel(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'January': return l10n.monthJanuary;
      case 'February': return l10n.monthFebruary;
      case 'March': return l10n.monthMarch;
      case 'April': return l10n.monthApril;
      case 'May': return key;
      case 'June': return key;
      case 'July': return key;
      case 'August': return key;
      case 'September': return key;
      case 'October': return key;
      case 'November': return key;
      case 'December': return key;
      default: return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_loading && _result.casinoRollingByMonth.isEmpty) {
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
    final winLossStr = r.winLoss >= 0 ? _fmt.format(r.winLoss) : '-${_fmt.format(r.winLoss.abs())}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatCard(
          label: l10n.monthlyAccumulatedWinLoss,
          value: winLossStr,
          icon: Icons.gps_fixed,
          color: r.winLoss >= 0 ? StatCardColor.emerald : StatCardColor.rose,
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
                  _metricCard(l10n.topMonthlyCommission, r.topCommissionAgentLabel.isNotEmpty ? 'Rank #1 – ${r.topCommissionAgentLabel}' : l10n.rankAgentDragon, _fmt.format(r.topCommissionAmount), Icons.star, amberAccent),
                  _metricCard(l10n.accumulatedExpenses, l10n.mtdExpenditure, _fmt.format(r.junketExpenses), Icons.verified_user, roseAccent),
                  _metricCard(l10n.gamesRolling, l10n.totalRolling, _fmt.format(r.rollingGames), Icons.sports_esports, primaryIndigo),
                ],
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _metricCard(l10n.topMonthlyCommission, r.topCommissionAgentLabel.isNotEmpty ? 'Rank #1 – ${r.topCommissionAgentLabel}' : l10n.rankAgentDragon, _fmt.format(r.topCommissionAmount), Icons.star, amberAccent),
                const SizedBox(height: 12),
                _metricCard(l10n.accumulatedExpenses, l10n.mtdExpenditure, _fmt.format(r.junketExpenses), Icons.verified_user, roseAccent),
                const SizedBox(height: 12),
                _metricCard(l10n.gamesRolling, l10n.totalRolling, _fmt.format(r.rollingGames), Icons.sports_esports, primaryIndigo),
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
                primaryIndigo.withValues(alpha: 0.2),
                primaryIndigo.withValues(alpha: 0.1),
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
                    decoration: BoxDecoration(color: primaryIndigo.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.business, color: primaryIndigo, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.casinoIntegration, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(l10n.monthlyAccumulatedRollingCasino, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final list = r.casinoRollingByMonth;
                  if (list.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('No data', style: TextStyle(fontSize: 14, color: Colors.grey[500]))),
                    );
                  }
                  final maxRolling = list.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();
                  final barHeight = 28.0;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < list.length; i++) ...[
                        if (i > 0) const SizedBox(height: 12),
                        _HorizontalCasinoBar(
                          label: _monthLabel(context, list[i].monthKey),
                          value: list[i].value,
                          maxValue: maxRolling > 0 ? maxRolling : 1,
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

  Widget _buildSkeletonContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 21),
          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
          child: Row(
            children: [
              SkeletonBox(width: 28, height: 28, borderRadius: 10),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SkeletonBox(height: 12, width: 180, borderRadius: 4),
                    const SizedBox(height: 6),
                    SkeletonBox(height: 18, width: 100, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            final card = Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 21),
              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
              child: Row(
                children: [
                  SkeletonBox(width: 24, height: 24, borderRadius: 8),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SkeletonBox(height: 10, width: 120, borderRadius: 4),
                        const SizedBox(height: 6),
                        SkeletonBox(height: 16, width: 80, borderRadius: 4),
                      ],
                    ),
                  ),
                ],
              ),
            );
            if (isWide) {
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.9,
                children: List.generate(3, (_) => card),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (_) => Padding(padding: const EdgeInsets.only(bottom: 12), child: card)),
            );
          },
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SkeletonBox(width: 40, height: 40, borderRadius: 12),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(height: 18, width: 160, borderRadius: 4),
                      const SizedBox(height: 4),
                      SkeletonBox(height: 12, width: 200, borderRadius: 4),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              for (int i = 0; i < 4; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                Row(
                  children: [
                    SkeletonBox(width: 72, height: 22, borderRadius: 4),
                    const SizedBox(width: 12),
                    Expanded(child: SkeletonBox(height: 28, borderRadius: 4)),
                    const SizedBox(width: 12),
                    SkeletonBox(width: 56, height: 22, borderRadius: 4),
                  ],
                ),
              ],
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
                        color: primaryIndigo,
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
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: primaryIndigo),
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
