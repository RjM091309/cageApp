import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Animates a numeric value: from 0 on first load, then from previous to current when [value] changes.
class AnimatedCounter extends StatefulWidget {
  final int value;
  final NumberFormat format;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;

  const AnimatedCounter({
    super.key,
    required this.value,
    required this.format,
    this.style,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOut,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _fromValue = 0;
  int _toValue = 0;

  void _buildAnimation() {
    _animation = Tween<double>(
      begin: _fromValue.toDouble(),
      end: _toValue.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }

  @override
  void initState() {
    super.initState();
    _toValue = widget.value;
    _fromValue = 0; // Count up from 0 on first load
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _buildAnimation();
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _fromValue = _toValue;
      _toValue = widget.value;
      _controller.reset();
      _buildAnimation();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final displayValue = _animation.value.round();
        return Text(
          widget.format.format(displayValue),
          style: widget.style,
          maxLines: 1,
        );
      },
    );
  }
}
