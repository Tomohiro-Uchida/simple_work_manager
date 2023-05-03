import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:simple_work_manager/simple_work_manager.dart';

import 'simple_work_manager_platform_interface.dart';

/// An implementation of [SimpleWorkManagerPlatform] that uses method channels.
class MethodChannelSimpleWorkManager extends SimpleWorkManagerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel("simple_work_manager/to_plugin");

  @override
  Future<void> schedule(String callbackIdentifier,
      AndroidOptions androidOptions,
      IOSOptions iosOptions) async {
    final Map arguments = <String, dynamic>{
      "callbackIdentifier": callbackIdentifier,
      "androidRequiresNetworkConnectivity": androidOptions.requiresNetworkConnectivity,
      "androidRequiresExternalPower": androidOptions.requiresExternalPower,
      "androidTargetPeriodInMinutes": androidOptions.targetPeriodInMinutes,
      "iosRequiresNetworkConnectivity": iosOptions.requiresNetworkConnectivity,
      "iosRequiresExternalPower": iosOptions.requiresExternalPower,
      "iosTaskIdentifier": iosOptions.taskIdentifier};
    await methodChannel.invokeMethod<void>("schedule", arguments);
  }

  @override
  Future<void> cancel() async {
    await methodChannel.invokeMethod<void>("cancel", null);
  }
}
