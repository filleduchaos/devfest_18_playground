import 'dart:math' as math;
import 'package:flutter/painting.dart';
import 'colors.dart' show palette;

final _generator = math.Random();

const _kMinSize = 60.0;
const _kMaxSize = 150.0;

typedef ValueGenerator<T> = T Function([T seed]);

ValueGenerator<S> generatorFactory<S>(List<S> original) {
  final allValues = List.from(original)..shuffle();

  return ([S seed ]) {
    if (seed == null) {
      return allValues.first;
    }

    final otherValues = allValues.where((value) => value != seed).toList()..shuffle(_generator);

    return otherValues.first;
  };
}

const _alignments = [
  Alignment.topLeft,
  Alignment.topCenter,
  Alignment.topRight,
  Alignment.centerRight,
  Alignment.bottomRight,
  Alignment.bottomCenter,
  Alignment.bottomLeft,
  Alignment.centerLeft,
];

final generateAlignment = generatorFactory<Alignment>(_alignments);

final generateColor = generatorFactory<Color>(palette);

LinearGradient generateGradient([LinearGradient seed]) {
  final startColor = seed?.colors?.last ?? generateColor();

  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [startColor, generateColor(startColor)],
  );
}

double _generateDouble(double max, double min) {
  final range = max - min;
  return min + (_generator.nextDouble() * range);
}

double generateSize([double _]) {
  return _generateDouble(_kMaxSize, _kMinSize);
}

double generateBorderRadius([double _]) {
  return _generateDouble(_kMaxSize / 2, 0.0);
}

ContainerSettings generateContainerSettings([ContainerSettings seed]) {
  return ContainerSettings._(
    alignment: generateAlignment(seed?.alignment),
    borderRadius: BorderRadius.circular(generateBorderRadius()),
    color: generateColor(seed?.color),
    height: generateSize(),
    width: generateSize(),
  );
}

class ContainerSettings {
  final Alignment alignment;
  final BorderRadius borderRadius;
  final Color color;
  final double height;
  final double width;

  const ContainerSettings._({
    this.alignment,
    this.borderRadius,
    this.color,
    this.height,
    this.width
  });
}

