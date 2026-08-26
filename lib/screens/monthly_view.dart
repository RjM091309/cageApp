import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../generated/app_localizations.dart';
import '../models/monthly_games.dart';
import '../services/monthly_games_service.dart';
import '../theme/app_theme.dart';

String _peso(int value) {
  final abs = value.abs();
  final String body;
  if (abs < 1000) {
    body = NumberFormat.decimalPattern().format(abs);
  } else if (abs < 1000000) {
    // Up to 2 decimals so e.g. 5,730 reads as "5.73K", not rounded away to "6K".
    body = '${NumberFormat('#,##0.##').format(abs / 1000)}K';
  } else {
    body = '${NumberFormat('#,##0.##').format(abs / 1000000)}M';
  }
  if (value < 0) return '-₱$body';
  return '₱$body';
}

String _rankOf(int index) => index.toString().padLeft(2, '0');

(String name, String? code) _splitAccount(String account) {
  final m = RegExp(r'^(.*)\s*\(([^)]+)\)\s*$').firstMatch(account.trim());
  if (m == null) return (account, null);
  return (m.group(1)!.trim(), m.group(2)!.trim());
}

class MonthlyView extends StatefulWidget {
  const MonthlyView({super.key});

  @override
  State<MonthlyView> createState() => _MonthlyViewState();
}

class _MonthlyViewState extends State<MonthlyView> {
  bool _todaySelected = true;
  bool _settledExpanded = false;
  MonthlyGames? _games;
  bool _loading = true;
  final ScrollController _scrollController = ScrollController();
  // Marks the end of the "On-Going Game" section, i.e. exactly the scroll offset at
  // which the pinned Settled Game header reaches the top of the viewport.
  final GlobalKey _ongoingSectionKey = GlobalKey();

  // On expand, scroll straight to where the pinned header sits at the top — computed
  // directly from the On-Going section's own height rather than via Scrollable.ensureVisible
  // (which, targeting a widget inside a pinned sliver, raced the sliver-list insertion
  // below it and produced a one-frame overlap glitch). This target doesn't depend on the
  // expanding rows at all, so there's nothing for it to race.
  void _toggleSettledExpanded() {
    final expanding = !_settledExpanded;
    setState(() => _settledExpanded = expanding);
    if (!expanding) return;
    final box = _ongoingSectionKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    _scrollController.animateTo(
      box.size.height,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final games = await MonthlyGamesService.instance.fetchMonthlyGames();
    if (!mounted) return;
    setState(() {
      _games = games;
      _loading = false;
    });
  }

  Widget _segmentTrack({required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(children: children),
      ),
    );
  }

  Widget _segment(
    String label, {
    required bool selected,
    VoidCallback? onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(isFirst ? 14 : 4),
            right: Radius.circular(isLast ? 14 : 4),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? primaryIndigo.withValues(alpha: 0.4) : Colors.transparent,
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(isFirst ? 14 : 4),
                right: Radius.circular(isLast ? 14 : 4),
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: primaryIndigo.withValues(alpha: 0.4),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.white : Colors.white.withValues(alpha: 0.75),
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _rankBadge(String rank, {bool gold = false}) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: gold ? amberAccent.withValues(alpha: 0.18) : primaryIndigo.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: gold ? amberAccent.withValues(alpha: 0.4) : primaryIndigo.withValues(alpha: 0.28)),
      ),
      child: Text(
        rank,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: gold ? amberAccent : accentPurple,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _metric(String label, String value, Color valueColor, {Color? labelColor}) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: labelColor ?? accentPurple,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: valueColor,
                height: 1.1,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricsRow({
    required String buyIn,
    required String cashOut,
    required String commission,
    required String winLoss,
    required Color winLossColor,
    Color? labelColor,
  }) {
    final l10n = AppLocalizations.of(context);
    Widget sep() => Container(
          width: 1,
          height: 22,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          color: Colors.white.withValues(alpha: 0.06),
        );
    return Row(
      children: [
        _metric(l10n.buyIn, buyIn, Colors.white.withValues(alpha: 0.92), labelColor: labelColor),
        sep(),
        _metric(l10n.cashOut, cashOut, Colors.white.withValues(alpha: 0.92), labelColor: labelColor),
        sep(),
        _metric(l10n.commissionLabel, commission, Colors.white.withValues(alpha: 0.92), labelColor: labelColor),
        sep(),
        _metric(l10n.winLossLabel, winLoss, winLossColor, labelColor: labelColor),
      ],
    );
  }

  Widget _gameCard({
    required String rank,
    required String title,
    String? code,
    required OngoingGameRow? row,
    SettledGameTotals? totals,
    VoidCallback? onTap,
    bool? expanded,
  }) {
    final buyIn = row?.buyIn ?? totals!.buyIn;
    final cashOut = row?.cashOut ?? totals!.cashOut;
    final commission = row?.commission ?? totals!.commission;
    final winLoss = row?.winLoss ?? totals!.winLoss;
    final winLossColor = winLoss == 0
        ? Colors.white.withValues(alpha: 0.92)
        : (winLoss < 0 ? roseAccent : emeraldAccent);
    // The totals card (row == null) is the pinned "N Settled Game" summary, not one of the
    // per-game rows underneath it — give it a distinct gold/gradient look so it doesn't
    // read as just another plain data row.
    final isSummary = row == null && totals != null;

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      constraints: const BoxConstraints(maxHeight: 118),
      decoration: isSummary
          ? BoxDecoration(
              // Same "highlight card" pattern the rest of the app already uses for
              // total/summary cards (see _buildHighlightCard in real_time_view.dart):
              // a single accent color fading to near-zero, plus a matching border —
              // not a bespoke two-color blend.
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  amberAccent.withValues(alpha: 0.22),
                  amberAccent.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: amberAccent.withValues(alpha: 0.35)),
            )
          : BoxDecoration(
              color: const Color(0xFF12121F).withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _rankBadge(rank, gold: isSummary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: isSummary ? FontWeight.w800 : FontWeight.w600,
                                color: isSummary ? amberAccent : Colors.white,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          if (code != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: primaryIndigo.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                code,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: accentPurple,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (row != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'GAME #${row.gameId}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.6),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                    if (expanded != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        expanded ? Icons.expand_less : Icons.expand_more,
                        size: 20,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
                const SizedBox(height: 8),
                _metricsRow(
                  buyIn: _peso(buyIn),
                  cashOut: _peso(cashOut),
                  commission: _peso(commission),
                  winLoss: _peso(winLoss),
                  winLossColor: winLossColor,
                  labelColor: isSummary ? amberAccent : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Plain, unbounded column — no nested scrollable here. A ListView with a fixed max
  // height inside the page's outer SingleChildScrollView fights it for drag gestures
  // (scrolling the inner list could instead scroll the whole page, moving cards above
  // it). Letting every card be part of the single outer scroll avoids that entirely.
  Widget _scrollList({required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Column(children: children),
    );
  }

  /// The "SETTLED GAME" title + Today/Yesterday toggle + total-breakdown summary card.
  /// Pinned at the top of the scroll view (see build()) so it stays visible while the
  /// per-game rows below it scroll underneath.
  Widget _settledHeaderCard(AppLocalizations l10n, SettledGameTotals settled) {
    // Solid (opaque) background, not the translucent `cardBg` used by ordinary cards —
    // this card is pinned at the top of the scroll view, so rows scrolling underneath
    // it must be fully hidden rather than showing through a tinted-but-see-through card.
    return Container(
        decoration: BoxDecoration(
          color: appBarBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.settledGameLabel.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: emeraldAccent,
                  ),
                ),
              ),
            ),
            _segmentTrack(children: [
              _segment(
                l10n.todayLabel,
                selected: _todaySelected,
                isFirst: true,
                // Switching Today/Yesterday keeps the expanded/collapsed state as-is —
                // only tapping the summary card itself should open or close the detail
                // rows, so a user mid-detail-view on Today stays in detail view on Yesterday.
                onTap: () => setState(() => _todaySelected = true),
              ),
              _segment(
                l10n.yesterdayLabel,
                selected: !_todaySelected,
                isLast: true,
                onTap: () => setState(() => _todaySelected = false),
              ),
            ]),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              _gameCard(
                rank: _rankOf(settled.gameCount),
                title: '${settled.gameCount} ${l10n.settledGameLabel}',
                row: null,
                totals: settled,
                expanded: settled.games.isEmpty ? null : _settledExpanded,
                onTap: settled.games.isEmpty ? null : _toggleSettledExpanded,
              ),
          ],
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final games = _games ?? const MonthlyGames.empty();
    final ongoing = games.ongoing;
    final settled = _todaySelected ? games.settledToday : games.settledPrevious;

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: ConstrainedBox(
                key: _ongoingSectionKey,
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          _segmentTrack(children: [
                            _segment(l10n.ongoingGames, selected: true, isFirst: true, isLast: true),
                          ]),
                          if (_loading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (ongoing.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(l10n.noOngoingGames,
                                    style: TextStyle(color: Colors.grey[500])),
                              ),
                            )
                          else
                            _scrollList(
                              children: [
                                for (var i = 0; i < ongoing.length; i++)
                                  _gameCard(
                                    rank: _rankOf(i),
                                    title: _splitAccount(ongoing[i].account).$1,
                                    code: _splitAccount(ongoing[i].account).$2,
                                    row: ongoing[i],
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            PinnedHeaderSliver(
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: _settledHeaderCard(l10n, settled),
              ),
            ),
            SliverToBoxAdapter(
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: (!_loading && _settledExpanded && settled.games.isNotEmpty)
                    ? _scrollList(
                        children: [
                          for (var i = 0; i < settled.games.length; i++)
                            _gameCard(
                              rank: _rankOf(i + 1),
                              title: _splitAccount(settled.games[i].account).$1,
                              code: _splitAccount(settled.games[i].account).$2,
                              row: settled.games[i],
                            ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        );
      },
    );
  }
}
