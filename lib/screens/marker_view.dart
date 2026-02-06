import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/mock_data.dart';
import '../theme/app_theme.dart';

final _fmt = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 0);

class MarkerView extends StatelessWidget {
  const MarkerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.description, color: cyanAccent, size: 20),
            const SizedBox(width: 8),
            const Text('Real-Time Marker', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.95,
              ),
              itemCount: mockMarkers.length,
              itemBuilder: (context, i) {
                final marker = mockMarkers[i];
                final usagePercent = (marker.balance / marker.limit) * 100;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                            child: Icon(Icons.credit_card, color: Colors.blue[300], size: 20),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.access_time, size: 10, color: Colors.grey[500]),
                                  const SizedBox(width: 4),
                                  Text(marker.lastUpdate, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                                ],
                              ),
                              Text('ID: #${1000 + i}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[400])),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(marker.guest, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ACTIVE BALANCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                              Text(_fmt.format(marker.balance), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('LIMIT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                              Text(_fmt.format(marker.limit), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[300])),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('UTILIZATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                          Text('${usagePercent.toStringAsFixed(1)}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: usagePercent > 80 ? roseAccent : cyanAccent)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: usagePercent / 100,
                          minHeight: 6,
                          backgroundColor: cardBg,
                          valueColor: AlwaysStoppedAnimation(usagePercent > 80 ? roseAccent : cyanAccent),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
