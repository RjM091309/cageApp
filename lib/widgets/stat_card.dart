import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum StatCardColor { cyan, blue, emerald, rose, amber }

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subValue;
  final IconData icon;
  final StatCardColor color;
  final String? trendValue;
  final bool? trendIsUp;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.subValue,
    required this.icon,
    this.color = StatCardColor.cyan,
    this.trendValue,
    this.trendIsUp,
  });

  Color get _colorValue {
    switch (color) {
      case StatCardColor.cyan: return cyanAccent;
      case StatCardColor.blue: return Colors.blue;
      case StatCardColor.emerald: return emeraldAccent;
      case StatCardColor.rose: return roseAccent;
      case StatCardColor.amber: return amberAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 90 || constraints.maxWidth < 140;
        final padding = isCompact ? 8.0 : 12.0;
        final spacing = isCompact ? 4.0 : 8.0;
        final valueFontSize = isCompact ? 14.0 : 18.0;
        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _colorValue.withValues(alpha: 0.3)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _colorValue.withValues(alpha: 0.2),
                _colorValue.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(isCompact ? 4 : 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: isCompact ? 14 : 16, color: _colorValue),
                  ),
                  if (trendValue != null)
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: (trendIsUp ?? true) ? emeraldAccent.withValues(alpha: 0.2) : roseAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${(trendIsUp ?? true) ? '+' : '-'}$trendValue',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: (trendIsUp ?? true) ? emeraldAccent : roseAccent,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: spacing),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.grey[400],
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: valueFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (subValue != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    subValue!,
                    style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
