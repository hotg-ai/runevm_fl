import 'dart:async';
import 'dart:convert';
import 'dart:html' as html show window;
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:inject_js/inject_js.dart' as JS;
import 'package:runevm_fl/rune.dart';
import 'dart:js_util';

/// A web implementation of the RunevmFl plugin.
class RunevmFlWeb {
  static bool bridgeLoaded = false;

  static loadWebBindings() async {
    if (bridgeLoaded == false) {
      try {
        String script =
            await rootBundle.loadString('packages/runevm_fl/assets/bridge.js');
        JS.injectScript(script);
        bridgeLoaded = true;
        print("Bridge is loaded");
      } catch (e) {
        print("Exception $e while loading bridge");
        bridgeLoaded = false;
      }
    }
  }

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

  /// Returning dummy values for now
  dynamic manifest = [];

  Future<dynamic> handleMethodCall(MethodCall dCall) async {
    await loadWebBindings();

    switch (dCall.method) {
      case 'load':
        manifest = await promiseToFuture(load(dCall.arguments));
        return true;
      case 'getManifest':
        return manifest;
      case 'runRune':
        print("dcall ${dCall.arguments["lengths"]}");
        return await promiseToFuture(
            call(dCall.arguments["bytes"], dCall.arguments["lengths"]));
      case 'getLogs':
        return await promiseToFuture(getLogs());
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'runevm_fl for web doesn\'t implement \'${dCall.method}\'',
        );
    }
  }
}
