import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum StatCardColor { primary, purple, emerald, rose, amber, teal, brown }

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

  /// When true, enlarges icon/text and centers content in the card instead of anchoring
  /// top-left. Use for cards much taller than their content (e.g. a 3-column grid with a
  /// tall aspect ratio).
  final bool centered;

  /// Icon + label/value in one row. Use for a full-width spanning card.
  final bool horizontal;

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
    this.centered = false,
    this.horizontal = false,
  });

  Color get _colorValue {
    switch (color) {
      case StatCardColor.primary: return primaryIndigo;
      case StatCardColor.purple: return accentPurple;
      case StatCardColor.emerald: return emeraldAccent;
      case StatCardColor.rose: return roseAccent;
      case StatCardColor.amber: return amberAccent;
      case StatCardColor.teal: return tealAccent;
      case StatCardColor.brown: return brownAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final short = constraints.maxHeight > 0 && constraints.maxHeight < 130;
        final isCompact = constraints.maxHeight < 90 || constraints.maxWidth < 140;
        final padding = isCompact || short ? 10.0 : 12.0;
        final spacing = isCompact ? 4.0 : 6.0;
        final valueFontSize = isCompact ? 16.0 : (short ? 18.0 : 20.0);
        final labelFontSize = isCompact ? 9.0 : 10.0;
        final iconBoxSize = isCompact || short ? 6.0 : 8.0;
        final iconSize = isCompact || short ? 16.0 : 18.0;
        final decoration = BoxDecoration(
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
        );
        if (horizontal) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: padding + 4, vertical: 8),
            decoration: decoration,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: (constraints.maxWidth - (padding + 4) * 2).clamp(0.0, double.infinity),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(iconBoxSize),
                      decoration: BoxDecoration(
                        color: _colorValue.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, size: iconSize, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.8,
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          value,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return Container(
          padding: EdgeInsets.all(padding),
          alignment: centered ? Alignment.center : Alignment.topLeft,
          decoration: decoration,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: centered ? Alignment.center : Alignment.topLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: (constraints.maxWidth - padding * 2).clamp(0.0, double.infinity),
              ),
              child: Column(
            crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(iconBoxSize),
                decoration: BoxDecoration(
                  color: _colorValue.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: iconSize, color: Colors.white),
              ),
              SizedBox(height: spacing),
              Text(
                label.toUpperCase(),
                textAlign: centered ? TextAlign.center : TextAlign.start,
                style: TextStyle(
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: Colors.white.withValues(alpha: 0.78),
                  height: 1.15,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              SizedBox(height: spacing),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: centered ? Alignment.center : Alignment.centerLeft,
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontSize: valueFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                  child: valueWidget ??
                      Text(
                        value,
                        maxLines: 1,
                      ),
                ),
              ),
              if (subValue != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    subValue!,
                    textAlign: centered ? TextAlign.center : TextAlign.start,
                    style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
            ],
              ),
            ),
          ),
        );
      },
    );
  }
}
