import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/mock_data.dart';
import '../theme/app_theme.dart';

final _fmt = NumberFormat.compact(locale: 'en_PH');

class RankingView extends StatelessWidget {
  const RankingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
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
                const Text('GUEST & AGENT RANKING', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5, fontStyle: FontStyle.italic)),
                Text('Monthly Accumulated Performance Report', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        ...mockRanking.map((item) {
          final winRatio = item.winnings + item.losses > 0 ? (item.winnings / (item.winnings + item.losses)) * 100 : 20.0;
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
                            if (item.rank > 3) Icon(Icons.military_tech, size: 36, color: Colors.blue.withValues(alpha: 0.5)),
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
                            Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.trending_up, size: 12, color: emeraldAccent),
                                const SizedBox(width: 4),
                                Text('Wins: ', style: TextStyle(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.bold)),
                                Text('₱${_fmt.format(item.winnings)}', style: TextStyle(fontSize: 10, color: emeraldAccent, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 16),
                                Icon(Icons.trending_down, size: 12, color: roseAccent),
                                const SizedBox(width: 4),
                                Text('Losses: ', style: TextStyle(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.bold)),
                                Text('₱${_fmt.format(item.losses)}', style: TextStyle(fontSize: 10, color: roseAccent, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Column(
                        children: [
                          Text('ROLLING VOLUME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey[500], letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text('₱${_fmt.format(item.rolling)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                      if (MediaQuery.sizeOf(context).width > 600) ...[
                        const SizedBox(width: 24),
                        Container(
                          width: 80,
                          height: 40,
                          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(8)),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  height: (40 * (winRatio / 100).clamp(0.2, 1.0)),
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: cyanAccent.withValues(alpha: 0.2),
                                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                                  ),
                                ),
                              ),
                              const Center(child: Text('WIN RATIO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.cyan))),
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
        }),
      ],
    );
  }
}
