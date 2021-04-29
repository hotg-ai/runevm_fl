import 'dart:async';
// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// A web implementation of the RunevmFl plugin.
class RunevmFlWeb {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'runevm_fl',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = RunevmFlWeb();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  /// Handles method calls over the MethodChannel of this plugin.
  /// Note: Check the "federated" architecture for a new way of doing this:
  /// https://flutter.dev/go/federated-plugins
  ///
  /// Returning dummy values for now
  Future<dynamic> handleMethodCall(MethodCall call) async {
    print("calling ${call.method}");
    switch (call.method) {
      case 'loadWASM':
        return true;
      case 'manifest':
        return [2];
      case 'runRune':
        return '{"type_name":"&str","channel":0,"string":"yes"}';
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'runevm_fl for web doesn\'t implement \'${call.method}\'',
        );
    }
  }
}
