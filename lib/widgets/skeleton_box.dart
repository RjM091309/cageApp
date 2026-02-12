import 'package:flutter/material.dart';

/// Skeleton placeholder with shimmer effect. Use for loading states.
class SkeletonBox extends StatefulWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.white.withValues(alpha: 0.06);
    final shimmerColor = Colors.white.withValues(alpha: 0.16);

    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        final t = _shimmerAnimation.value;
        // Shimmer band sweeps left to right (alignment -1 to 1)
        const bandWidth = 0.5;
        final start = -1.2 + t * (1 + 1.2);
        final end = start + bandWidth;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(start, 0),
              end: Alignment(end, 0),
              colors: [
                baseColor,
                shimmerColor,
                shimmerColor,
                baseColor,
              ],
              stops: const [0.0, 0.35, 0.65, 1.0],
            ),
          ),
        );
      },
    );
  }
}
