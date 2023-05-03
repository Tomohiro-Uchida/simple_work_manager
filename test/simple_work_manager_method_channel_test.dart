import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_work_manager/simple_work_manager_method_channel.dart';

void main() {
  MethodChannelSimpleWorkManager platform = MethodChannelSimpleWorkManager();
  const MethodChannel channel = MethodChannel('simple_work_manager');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
