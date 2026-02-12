import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum StatCardColor { primary, purple, emerald, rose, amber }

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  /// If set, this widget is shown instead of [value] text (e.g. for animated counter).
  final Widget? valueWidget;
  final String? subValue;
  final IconData icon;
  final StatCardColor color;
  final String? trendValue;
  final bool? trendIsUp;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.valueWidget,
    this.subValue,
    required this.icon,
    this.color = StatCardColor.primary,
    this.trendValue,
    this.trendIsUp,
  });

  Color get _colorValue {
    switch (color) {
      case StatCardColor.primary: return primaryIndigo;
      case StatCardColor.purple: return accentPurple;
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
        // Tablet/mid size: mas malaki padding para hindi mukhang lubog ang text
        final isTabletSize = constraints.maxWidth >= 160 && constraints.maxWidth <= 320;
        final padding = isCompact ? 8.0 : (isTabletSize ? 16.0 : 14.0);
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
            mainAxisAlignment: MainAxisAlignment.center,
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
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
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
              ),
              const SizedBox(height: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: DefaultTextStyle(
                      style: TextStyle(
                        fontSize: valueFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      child: valueWidget ??
                          Text(
                            value,
                            maxLines: 1,
                          ),
                    ),
                  ),
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
