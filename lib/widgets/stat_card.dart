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

  /// Icon + label/value in one row, label and value spread across the full width.
  /// Use for a full-width spanning card.
  final bool horizontal;

  /// Icon chip on the left, label and value stacked to its right (left-aligned).
  /// Use for a compact, non-spanning card (e.g. inside a 2-column grid).
  final bool leadingIcon;

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
    this.leadingIcon = false,
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
        final padding = isCompact || short ? 8.0 : 16.0;
        final spacing = isCompact ? 4.0 : 12.0;
        final valueFontSize = isCompact ? 14.0 : (short ? 19.0 : 21.0);
        final labelFontSize = isCompact ? 11.0 : 16.0;
        final iconBoxSize = isCompact || short ? 7.0 : 10.0;
        final iconSize = isCompact || short ? 18.0 : 20.0;
        final horizNarrow = horizontal && constraints.maxWidth < 250;
        final horizLabelFontSize = horizNarrow ? 12.0 : 16.0;
        final horizValueFontSize = horizNarrow ? 17.0 : 20.0;
        final horizGap = horizNarrow ? 8.0 : 14.0;
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
            padding: EdgeInsets.symmetric(horizontal: padding + 4, vertical: 12),
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
                    SizedBox(width: horizGap),
                    Expanded(
                      child: Text(
                        label.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: horizLabelFontSize,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4,
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                    SizedBox(width: horizGap),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          value,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: horizValueFontSize,
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
        if (leadingIcon) {
          // A card can be tall (short/isCompact both false, e.g. a phone whose viewport
          // is >=720 tall) while still sitting in a narrow 2-column grid — go by width
          // here, not just height, or the "big" sizing below overflows the label.
          final leadCompact = isCompact || constraints.maxWidth < 260;
          final iconBoxWH = leadCompact ? 36.0 : 46.0;
          final leadIconSize = leadCompact ? 18.0 : 22.0;
          final leadLabelFontSize = leadCompact ? 13.0 : 18.0;
          final leadValueFontSize = leadCompact ? 16.0 : 19.0;
          return Container(
            padding: EdgeInsets.symmetric(horizontal: leadCompact ? 10.0 : 18.0, vertical: leadCompact ? 10.0 : 22.0),
            decoration: decoration,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: (constraints.maxWidth - (leadCompact ? 20.0 : 36.0)).clamp(0.0, double.infinity),
                child: Row(
                  children: [
                    Container(
                      width: iconBoxWH,
                      height: iconBoxWH,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: _colorValue.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                      child: Icon(icon, size: leadIconSize, color: _colorValue),
                    ),
                    SizedBox(width: leadCompact ? 10.0 : 14.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: leadLabelFontSize, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: leadValueFontSize, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
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
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
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
