import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import '../common/colors.dart' show melonMelody, yueGuangLanBlue;

void main() {
  runApp(MultipleAnimationExample());
}

class MultipleAnimationExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: melonMelody,
      child: Center(
        child: RotatingBox(),
      ),
    );
  }
}

class RotatingBox extends StatefulWidget {
  final Duration spinDuration;
  final Duration shrinkDuration;

  RotatingBox({
    this.spinDuration = const Duration(seconds: 1),
    this.shrinkDuration = const Duration(milliseconds: 600),
  });

  @override
  _RotatingBoxState createState() => _RotatingBoxState();
}

const _kMaxSize = 160.0;
const _kMinSize = 120.0;

class _RotatingBoxState extends State<RotatingBox>
with TickerProviderStateMixin {
  AnimationController _spinController;
  AnimationController _shrinkController;
  Animation<double> _spin;
  Animation<double> _size;

  void _onTapDown(TapDownDetails _) {
    _spinController..addStatusListener(_spinListener)..forward();
    _shrinkController.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _spinController.removeStatusListener(_spinListener);
    _shrinkController.reverse();
  }

  void _spinListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _spinController..reset()..forward();
    }
  }

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: widget.spinDuration,
      vsync: this,
    );
    _spin = Tween<double>(begin: 0.0, end: math.pi * 2).animate(
      CurvedAnimation(
        parent: _spinController,
        curve: Curves.decelerate,
      ),
    );

    _shrinkController = AnimationController(
      duration: widget.shrinkDuration,
      vsync: this,
    );
    _size = Tween<double>(begin: _kMaxSize, end: _kMinSize).animate(
      CurvedAnimation(
        parent: _shrinkController,
        curve: Curves.bounceOut,
        reverseCurve: Curves.bounceOut.flipped,
      ),
    );
  }

  @override
  void dispose() {
    _spinController?.dispose();
    _shrinkController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      child: AnimatedBuilder(
        animation: _spin,
        builder: (_, child) {
          return Transform.rotate(
            angle: _spin.value,
            child: child,
          );
        },
        child: AnimatedBuilder(
          animation: _size,
          builder: (_, __) {
            return Container(
              color: yueGuangLanBlue,
              height: _size.value,
              width: _size.value,
            );
          },
        ),
      ),
    );
  }
}
