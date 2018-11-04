import 'dart:ui' show window;
import 'package:flutter/widgets.dart';
import 'venetian_image_view/widget.dart';

void main() {
  final initialUri = window.defaultRouteName;
  final widget = (initialUri == null) ? Text("No images found") : VenetianImageView(
    duration: Duration(milliseconds: 1500),
    initialUri: initialUri,
    numberOfBlinds: 10,
    backgroundColor: Color(0xff0a0a0a),
  );
  runApp(widget);
}
