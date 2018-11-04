import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'service.dart';

final _perspectiveMatrix = Matrix4(
    1.0, 0.0, 0.0, 0.0,
    0.0, 1.0, 0.0, 0.0,
    0.0, 0.0, 1.0, 0.0001,
    0.0, 0.0, 0.0, 1.0
);

class VenetianImageView extends StatefulWidget {
  final Color backgroundColor;
  final Duration duration;
  final String initialUri;
  final int numberOfBlinds;

  VenetianImageView({ this.backgroundColor, this.duration, this.initialUri, this.numberOfBlinds });

  _VIVState createState() => _VIVState();
}

class _VIVState extends State<VenetianImageView>
    with SingleTickerProviderStateMixin {
  File _imageFile;
  AnimationController _controller;
  void Function(AnimationStatus) _statusListener;
  List<Animation<double>> _animations;

  bool get _isChanging => _controller.status != AnimationStatus.dismissed;
  double get blindFactor => 1 / widget.numberOfBlinds;

  @override
  void initState() {
    super.initState();
    _imageFile = File(widget.initialUri);
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animations = List.generate(widget.numberOfBlinds, (index) {
      return Tween<double>(begin: 0.0, end: math.pi / 2).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(index * blindFactor, (index + 1) * blindFactor, curve: Curves.ease),
        ),
      );
    });
  }

  void Function(AnimationStatus) _reverseTo(String uri) {
    return (AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _imageFile = File(uri);
        });
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        if (_statusListener != null) _controller.removeStatusListener(_statusListener);
      }
    };
  }

  void _onTap() {
    if (!_isChanging) {
      VenetianImageService.fetchImage()
          .then((uri) {
        _statusListener = _reverseTo(uri);
        _controller..addStatusListener(_statusListener)
          ..forward();
      });
    }
  }

  Widget _getChild(BuildContext context, Widget child) {
    if (!_isChanging) return child;

    final blinds = List.generate(widget.numberOfBlinds, (index) {
      final currentValue = _animations[index].value;
      final topEdge = -1.0 + (2 * index * blindFactor);
      final alignment = Alignment(0.0, topEdge);
      final matrix = _perspectiveMatrix.clone();
      final transform = matrix..rotateX(currentValue);

      return Transform(
        alignment: FractionalOffset.center,
        transform: transform,
        child: ClipRect(
          clipBehavior: Clip.antiAlias,
          child: Align(alignment: alignment, heightFactor: blindFactor, child: child),
        ),
      );
    });

    return Column(children: blinds, mainAxisAlignment: MainAxisAlignment.center);
  }

  @override
  Widget build(BuildContext context) {
    final image = Image.file(_imageFile, fit: BoxFit.contain);

    return Container(
      alignment: Alignment.center,
      color: widget.backgroundColor,
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: _getChild,
          child: image,
        ),
      ),
    );
  }
}
