import 'dart:async' show Timer;
import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import '../common/colors.dart' show tomatoRed, darkSapphire, auroraGreen, flatFlesh;

void main() {
  runApp(CurvedAnimationExample());
}

class CurvedAnimationExample extends StatefulWidget {
  final Duration duration;

  const CurvedAnimationExample({ this.duration = const Duration(milliseconds: 1500) });

  _CurvedAnimationState createState() => _CurvedAnimationState();
}

class _CurvedAnimationState extends State<CurvedAnimationExample>
with SingleTickerProviderStateMixin {
  AnimationController _controller;
  CurvedAnimation _animation;

  void _onAnimationComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _controller.reverse();
    } else if (status == AnimationStatus.dismissed) {
      _controller.forward();
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      lowerBound: -1.0,
      upperBound: 1.0,
      duration: widget.duration,
      vsync: this,
    )..addStatusListener(_onAnimationComplete);

    _animation = CurvedAnimation(parent: _controller, curve: SineCurve());

    _controller.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boxes = [
      ExplicitlyOscillatingBox(animation: _animation, color: tomatoRed),
      ImplicitlyOscillatingBox(period: widget.duration, color: darkSapphire),
      ExplicitlyOscillatingBox(animation: _controller, color: auroraGreen),
    ].map((child) => Expanded(child: child)).toList();

    return Container(
      color: flatFlesh,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: boxes,
      ),
    );
  }
}

const _kBoxSize = 80.0;

class ImplicitlyOscillatingBox extends StatefulWidget {
  final Duration period;
  final Color color;

  ImplicitlyOscillatingBox({ this.period, this.color });

  _ImplicitOscillatingState createState() => _ImplicitOscillatingState();
}

class _ImplicitOscillatingState extends State<ImplicitlyOscillatingBox> {
  Alignment _alignment = Alignment.centerRight;
  Timer _timer;
  bool get _isLeft => _alignment == Alignment.centerLeft;

  void _changeAlignment(_) {
    setState(() {
      _alignment = _isLeft ? Alignment.centerRight : Alignment.centerLeft;
    });
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.period, _changeAlignment);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedAlign(
      alignment: _alignment,
      curve: Curves.bounceOut,
      duration: widget.period,
      child: Container(
        color: widget.color,
        height: _kBoxSize,
        width: _kBoxSize,
      ),
    );
  }
}

class ExplicitlyOscillatingBox extends AnimatedWidget {
  final Animation<double> animation;
  final Color color;

  ExplicitlyOscillatingBox({ this.animation, this.color })
      : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(animation.value, 0.0),
      child: Container(
        color: color,
        height: _kBoxSize,
        width: _kBoxSize,
      ),
    );
  }
}

class SineCurve extends Curve {
  @override
  double transform(double time) {
    assert(time >= -1.0 && time <= 1.0, 'Time must be a value between -1 and 1');
    final angle = time * (math.pi / 2); // pi / 2 radians is 90 degrees
    return math.sin(angle);
  }
}

