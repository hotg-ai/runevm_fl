import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runevm_fl/runevm_fl.dart';

void main() {
  const MethodChannel channel = MethodChannel('runevm_fl');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
