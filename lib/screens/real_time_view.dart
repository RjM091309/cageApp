import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/stat_card.dart';
import '../constants/mock_data.dart';
import '../theme/app_theme.dart';

final _fmt = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 0);

TableCell _tableCell(Widget child) => TableCell(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: child,
  ),
);

class RealTimeView extends StatelessWidget {
  const RealTimeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 900 ? 5 : (constraints.maxWidth > 600 ? 3 : 2);
            // Sa tablet (5 cols), mas mababa ratio = mas matangkad na card = hindi lubog ang text
            final isTabletWidth = constraints.maxWidth > 600 && constraints.maxWidth <= 1400;
            final aspectRatio = isTabletWidth ? 1.65 : 1.95;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: aspectRatio,
              children: [
                StatCard(
                  label: 'Total Chips',
                  value: _fmt.format(12500000),
                  icon: Icons.monetization_on,
                  color: StatCardColor.cyan,
                  trendValue: '2.5%',
                  trendIsUp: true,
                ),
                StatCard(
                  label: 'Cash Balance',
                  value: _fmt.format(4820000),
                  icon: Icons.payments,
                  color: StatCardColor.emerald,
                ),
                StatCard(
                  label: 'Guest Balance',
                  value: _fmt.format(2150000),
                  icon: Icons.people,
                  color: StatCardColor.blue,
                ),
                StatCard(
                  label: 'Net Junket Money',
                  value: _fmt.format(8900000),
                  icon: Icons.account_balance,
                  color: StatCardColor.amber,
                ),
                StatCard(
                  label: 'Net Junket Cash',
                  value: _fmt.format(3150000),
                  icon: Icons.account_balance_wallet,
                  color: StatCardColor.rose,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.show_chart, size: 18, color: cyanAccent),
                        const SizedBox(width: 8),
                        const Text('Ongoing Games', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: cyanAccent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                      child: Text('LIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: cyanAccent)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.white12),
              LayoutBuilder(
                builder: (context, c) {
                  final isMobile = c.maxWidth < 600;
                  final table = Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1.5),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1.2),
                      3: FlexColumnWidth(0.8),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05)),
                        children: [
                          _tableCell(Text('Account', style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold))),
                          _tableCell(Text('Table', style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold))),
                          _tableCell(Text('Buy-In', style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold))),
                          _tableCell(Text('Status', style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold))),
                        ],
                      ),
                      ...mockOngoingGames.map((g) => TableRow(
                        children: [
                          _tableCell(Text(g.account, style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500))),
                          _tableCell(Text(g.table, style: TextStyle(fontSize: 13, color: Colors.grey[400]))),
                          _tableCell(Text(_fmt.format(g.buyIn), style: TextStyle(fontSize: 13, color: cyanAccent, fontFamily: 'monospace'))),
                          _tableCell(
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: g.status == 'Active' ? emeraldAccent.withValues(alpha: 0.2) : amberAccent.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(g.status, style: TextStyle(fontSize: 10, color: g.status == 'Active' ? emeraldAccent : amberAccent, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )),
                    ],
                  );
                  if (isMobile) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: 420,
                        child: table,
                      ),
                    );
                  }
                  return table;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
