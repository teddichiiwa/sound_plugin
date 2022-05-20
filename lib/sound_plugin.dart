
import 'dart:async';

import 'package:flutter/services.dart';

class SoundPlugin {
  static const MethodChannel _channel =
      const MethodChannel('sound_plugin');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
