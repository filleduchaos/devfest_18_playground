import 'dart:async';
import 'package:flutter/widgets.dart';
import '../common/randomizer.dart';

void main() {
  runApp(StaggeredAnimationExample());
}

class StaggeredAnimationExample extends StatefulWidget {
  final Duration duration;
  final Duration period;

  const StaggeredAnimationExample({
    this.duration = const Duration(seconds: 2),
    this.period = const Duration(seconds: 5),
  });

  _StaggeredAnimationState createState() => _StaggeredAnimationState();
}

class _StaggeredAnimationState extends State<StaggeredAnimationExample>
with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Timer _timer;

  PerpetualAnimation<Alignment> _alignment;
  PerpetualAnimation<double> _radius;
  PerpetualAnimation<Color> _color;
  PerpetualAnimation<double> _height;
  PerpetualAnimation<double> _width;

  void _triggerChange(_) {
    final animations = [_color, _alignment, _height, _width, _radius];
    animations.forEach((animation) { animation.next(); });

    _controller..reset()..forward();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _color = PerpetualAnimation(begin: 0.0, end: 0.4, parent: _controller, generator: generateColor, tween: ColorTween());
    _alignment = PerpetualAnimation(begin: 0.2, end: 0.6, parent: _controller, generator: generateAlignment, tween: AlignmentTween());
    _height = PerpetualAnimation(begin: 0.6, end: 0.9, parent: _controller, generator: generateSize);
    _width = PerpetualAnimation(begin: 0.6, end: 0.9, parent: _controller, generator: generateSize);
    _radius = PerpetualAnimation(begin: 0.8, end: 1.0, parent: _controller, generator: generateBorderRadius);

    _timer = Timer.periodic(widget.period, _triggerChange);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Align(
          alignment: _alignment.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_radius.value),
              color: _color.value,
            ),
            height: _height.value,
            width: _width.value,
          ),
        );
      },
    );
  }
}

class PerpetualAnimation<T> {
  final Curve curve;
  final double begin;
  final double end;
  final ValueGenerator<T> generator;
  Tween<T> _tween;
  Animation<T> _animation;

  PerpetualAnimation({
    AnimationController parent,
    this.generator,
    this.curve = Curves.linear,
    this.begin,
    this.end,
    Tween<T> tween,
  }) {
    _tween = tween ?? Tween<T>();
    _tween.begin = generator();
    _tween.end = generator(_tween.begin);
    _animation = _tween.animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(begin, end, curve: curve),
      ),
    );
  }


  T get value => _animation.value;

  next() {
    _tween.begin = _tween.end;
    _tween.end = generator(_tween.begin);
  }
}
