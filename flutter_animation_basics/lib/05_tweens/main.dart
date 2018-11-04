import 'package:flutter/widgets.dart';
import '../common/randomizer.dart' show generateColor, generateGradient;

void main() {
  runApp(TweenAnimationExample());
}

class TweenAnimationExample extends StatefulWidget {
  final Duration duration;

  const TweenAnimationExample({ this.duration = const Duration(seconds: 1) });

  _TweenAnimationState createState() => _TweenAnimationState();
}

class _TweenAnimationState extends State<TweenAnimationExample>
with SingleTickerProviderStateMixin {
  AnimationController _controller;
  ColorTween _colorTween;
  LinearGradientTween _gradientTween;
  Animation<Color> _colorAnimation;
  Animation<LinearGradient> _gradientAnimation;

  void _changeState() {
    _colorTween.begin = _colorTween.end;
    _gradientTween.begin = _gradientTween.end;

    _colorTween.end = generateColor(_colorTween.begin);
    _gradientTween.end = generateGradient(_gradientTween.begin);

    _controller..reset()..forward();
  }

  void _onAnimationEnd(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(_changeState);
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..addStatusListener(_onAnimationEnd);

    final animation = CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);

    final color = generateColor();
    final gradient = generateGradient();

    _colorTween = ColorTween(begin: color, end: generateColor(color));
    _gradientTween = LinearGradientTween(begin: gradient, end: generateGradient(gradient));

    _colorAnimation = _colorTween.animate(animation);
    _gradientAnimation = _gradientTween.animate(animation);

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
      AnimatedColorBox(animation: _colorAnimation),
      AnimatedGradientBox(animation: _gradientAnimation),
    ].map((child) => Expanded(child: child)).toList();

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: boxes,
    );
  }
}

class AnimatedColorBox extends AnimatedWidget {
  final Animation<Color> animation;

  AnimatedColorBox({ this.animation }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 2.0),
        color: animation.value,
      ),
    );
  }
}

class AnimatedGradientBox extends AnimatedWidget {
  final Animation<LinearGradient> animation;

  AnimatedGradientBox({ this.animation }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 2.0),
        gradient: animation.value,
      ),
    );
  }
}

class LinearGradientTween extends Tween<LinearGradient> {
  LinearGradientTween({
    LinearGradient begin,
    LinearGradient end,
  }) : super(begin: begin, end: end);

  @override
  LinearGradient lerp(double t) => LinearGradient.lerp(begin, end, t);
}
