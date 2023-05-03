import 'package:flutter_test/flutter_test.dart';
import 'package:simple_work_manager/simple_work_manager.dart';
import 'package:simple_work_manager/simple_work_manager_platform_interface.dart';
import 'package:simple_work_manager/simple_work_manager_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSimpleWorkManagerPlatform
    with MockPlatformInterfaceMixin
    implements SimpleWorkManagerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SimpleWorkManagerPlatform initialPlatform = SimpleWorkManagerPlatform.instance;

  test('$MethodChannelSimpleWorkManager is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSimpleWorkManager>());
  });

  test('getPlatformVersion', () async {
    SimpleWorkManager simpleWorkManagerPlugin = SimpleWorkManager();
    MockSimpleWorkManagerPlatform fakePlatform = MockSimpleWorkManagerPlatform();
    SimpleWorkManagerPlatform.instance = fakePlatform;

    expect(await simpleWorkManagerPlugin.getPlatformVersion(), '42');
  });
}
