import 'dart:async';
import 'package:flutter/widgets.dart';
import '../common/colors.dart' show waterfall;

void main() {
  runApp(ExplicitAnimationExample());
}

class ExplicitAnimationExample extends StatefulWidget {
  final Duration duration;
  final Duration period;
  final double size;

  ExplicitAnimationExample({
    this.duration = const Duration(milliseconds: 400),
    this.period = const Duration(seconds: 2),
    this.size = 160.0,
  });

  _ExplicitlyAnimatedState createState() => _ExplicitlyAnimatedState();
}

class _ExplicitlyAnimatedState extends State<ExplicitAnimationExample>
with SingleTickerProviderStateMixin {
  static const _kGrowthFactor = 0.25;
  double _currentSize;
  AnimationController _controller;
  Timer _timer;

  void _changeSize() {
    final sizeDelta = widget.size * _controller.value * _kGrowthFactor;

    setState(() {
      _currentSize = widget.size + sizeDelta;
    });
  }

  void _onAnimationComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _controller.reverse();
    }
  }

  @override
  void initState() {
    super.initState();

    _currentSize = widget.size;

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..addListener(_changeSize)
     ..addStatusListener(_onAnimationComplete);

    _timer = Timer.periodic(widget.period, (_) { _controller.forward(); });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: waterfall,
        height: _currentSize,
        width: _currentSize,
      ),
    );
  }
}
