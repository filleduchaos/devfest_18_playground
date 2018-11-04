import 'package:flutter/services.dart';

abstract class VenetianImageService {
  static const channel = const MethodChannel('me.filleduchaos/images');

  static Future<String> fetchImage() async {
    final imageUrl = await channel.invokeMethod('getImage');
    return imageUrl;
  }
}
