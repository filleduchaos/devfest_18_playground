import 'dart:async';
import 'package:flutter/widgets.dart';
import '../common/colors.dart' show waterfall;

void main() {
  runApp(EncapsulatingAnimationsExample());
}

class EncapsulatingAnimationsExample extends StatefulWidget {
  final Duration duration;
  final Duration period;
  final double size;

  EncapsulatingAnimationsExample({
    this.duration = const Duration(milliseconds: 400),
    this.period = const Duration(seconds: 2),
    this.size = 160.0,
  });

  _EncapsulatingAnimationsState createState() => _EncapsulatingAnimationsState();
}

class _EncapsulatingAnimationsState extends State<EncapsulatingAnimationsExample>
with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Timer _timer;

  void _onAnimationComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _controller.reverse();
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..addStatusListener(_onAnimationComplete);

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
      child: ExpandingBoxWidget(animation: _controller, size: widget.size),
    );
  }
}

const _kGrowthFactor = 0.25;

class ExpandingBoxWidget extends AnimatedWidget {
  final Animation<double> animation;
  final double size;

  ExpandingBoxWidget({ this.animation, this.size }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final sizeDelta = size * animation.value * _kGrowthFactor;

    return Container(
      color: waterfall,
      height: size + sizeDelta,
      width: size + sizeDelta,
    );
  }
}

class ExpandingBoxBuilder extends StatelessWidget {
  final Animation<double> animation;
  final double size;

  ExpandingBoxBuilder({ this.animation, this.size });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget child) {
        final sizeDelta = size * animation.value * _kGrowthFactor;

        return Container(
          color: waterfall,
          height: size + sizeDelta,
          width: size + sizeDelta,
        );
      },
    );
  }
}
