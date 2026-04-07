import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WidgetLauncher {
  static const _channel = MethodChannel('app.bdcoe.upmark/widget');

  static Future<void> showWidgetPicker(BuildContext context, String widgetName) async {
    try {
      final bool supported = await _channel.invokeMethod('showWidgetPicker', {'widget': widgetName});
      if (!supported) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please add the widget manually.')),
        );
      }
    } on PlatformException catch (e) {
      debugPrint('Error: ${e.message}');
    }
  }
}