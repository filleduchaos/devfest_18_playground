import 'dart:async';
import 'package:flutter/widgets.dart';
import '../common/randomizer.dart' show ContainerSettings, generateContainerSettings;

void main() {
  runApp(ImplicitAnimationExample());
}

class ImplicitAnimationExample extends StatefulWidget {
  final Duration duration;
  final Duration period;

  const ImplicitAnimationExample({
    this.duration = const Duration(milliseconds: 700),
    this.period = const Duration(seconds: 1),
  });

  _ImplicitAnimationState createState() => _ImplicitAnimationState();
}

class _ImplicitAnimationState extends State<ImplicitAnimationExample> {
  Timer _timer;
  ContainerSettings _settings;

  void _changeSettings(Timer timer) {
    setState(() {
      _settings = generateContainerSettings(_settings);
    });
  }

  @override
  void initState() {
    super.initState();
    _settings = generateContainerSettings();
    _timer = Timer.periodic(widget.period, _changeSettings);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedAlign(
      alignment: _settings.alignment,
      duration: widget.duration,
      child: AnimatedContainer(
        decoration: BoxDecoration(
          borderRadius: _settings.borderRadius,
          color: _settings.color,
        ),
        duration: widget.duration,
        height: _settings.height,
        width: _settings.width,
      ),
    );
  }
}
