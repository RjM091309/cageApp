import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../generated/app_localizations.dart';
import '../models/types.dart';
import '../services/ranking_service.dart';
import '../theme/app_theme.dart';
import '../widgets/skeleton_box.dart';

final _fmt = NumberFormat.compact(locale: 'en_PH');

class RankingView extends StatefulWidget {
  const RankingView({super.key});

  @override
  State<RankingView> createState() => _RankingViewState();
}

class _RankingViewState extends State<RankingView> {
  final RankingService _service = RankingService.instance;
  final ScrollController _scrollController = ScrollController();
  static const int _pageSize = 20;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  List<RankingItem> _ranking = [];
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _load();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loadingMore || _ranking.isEmpty || _ranking.length >= _total) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) _loadMore();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _ranking = [];
      _total = 0;
    });
    try {
      final result = await _service.fetch(limit: _pageSize, offset: 0);
      if (!mounted) return;
      setState(() {
        _ranking = result.list;
        _total = result.total;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load ranking';
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _ranking.length >= _total) return;
    setState(() => _loadingMore = true);
    try {
      final result = await _service.fetch(limit: _pageSize, offset: _ranking.length);
      if (!mounted) return;
      setState(() {
        _ranking = [..._ranking, ...result.list];
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_loading && _ranking.isEmpty) {
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
    if (_ranking.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, l10n),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Text('No ranking data', style: TextStyle(fontSize: 15, color: Colors.grey[500])),
            ),
          ),
        ],
      );
    }
    final hasMore = _ranking.length < _total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context, l10n),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: _ranking.length + (hasMore ? 1 : 0),
            itemBuilder: (context, i) {
              if (i >= _ranking.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: primaryIndigo),
                    ),
                  ),
                );
              }
              return _buildRankCard(context, l10n, _ranking[i]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: amberAccent.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: amberAccent.withValues(alpha: 0.2), blurRadius: 12)],
          ),
          child: Icon(Icons.emoji_events, color: amberAccent, size: 28),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.guestAgentRanking, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5, fontStyle: FontStyle.italic)),
            Text(l10n.monthlyPerformanceReport, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
          ],
        ),
      ],
    );
  }

  Widget _buildRankCard(BuildContext context, AppLocalizations l10n, RankingItem item) {
    final total = item.winnings + item.losses;
    final winRatio = total > 0 ? (item.winnings / total) * 100 : 0.0;
    final nameMatch = RegExp(r'^(.+?)\s*\(([^)]+)\)\s*$').firstMatch(item.name);
    final displayName = nameMatch != null ? nameMatch.group(1)!.trim() : item.name;
    final codeSubtitle = nameMatch != null ? nameMatch.group(2)!.trim() : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
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
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (item.rank == 1) Icon(Icons.emoji_events, size: 36, color: amberAccent),
                      if (item.rank == 2) Icon(Icons.emoji_events, size: 36, color: Colors.grey[400]),
                      if (item.rank == 3) Icon(Icons.emoji_events, size: 36, color: Colors.amber[800]),
                      if (item.rank > 3) Icon(Icons.military_tech, size: 36, color: primaryIndigo.withValues(alpha: 0.5)),
                      Positioned(
                        bottom: 2,
                        child: Text(
                          '${item.rank}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: item.rank <= 3 ? Colors.black87 : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      if (codeSubtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(codeSubtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                      ],
                    ],
                  ),
                ),
                Builder(
                  builder: (_) {
                    final net = item.winnings - item.losses;
                    final isZero = net == 0;
                    final isNegative = net < 0;
                    final text = isZero ? '0' : (isNegative ? '-₱${_fmt.format(net.abs())}' : '₱${_fmt.format(net)}');
                    final color = isZero ? Colors.white : (isNegative ? roseAccent : emeraldAccent);
                    return Column(
                      children: [
                        Text(l10n.winLoss, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey[500], letterSpacing: 1)),
                        const SizedBox(height: 4),
                        Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                      ],
                    );
                  },
                ),
                const SizedBox(width: 24),
                Column(
                  children: [
                    Text(l10n.rollingVolume, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey[500], letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text('₱${_fmt.format(item.rolling)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                if (MediaQuery.sizeOf(context).width > 600) ...[
                  const SizedBox(width: 24),
                  Container(
                    width: 80,
                    height: 48,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(8)),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: winRatio <= 0 ? 0.0 : (48 * (winRatio / 100).clamp(0.2, 1.0)),
                            width: 80,
                            decoration: BoxDecoration(
                              color: primaryIndigo.withValues(alpha: 0.2),
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(l10n.winRatio, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: primaryIndigo)),
                              const SizedBox(height: 2),
                              Text('${winRatio.toStringAsFixed(0)}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryIndigo)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonContent(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context, l10n),
        const SizedBox(height: 24),
        ...List.generate(5, (_) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  SkeletonBox(width: 48, height: 48, borderRadius: 12),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(height: 18, width: 160, borderRadius: 4),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            SkeletonBox(height: 12, width: 60, borderRadius: 4),
                            const SizedBox(width: 16),
                            SkeletonBox(height: 12, width: 60, borderRadius: 4),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SkeletonBox(height: 20, width: 80, borderRadius: 4),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
