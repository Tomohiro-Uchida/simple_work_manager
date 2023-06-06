import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'simple_work_manager_platform_interface.dart';

class AndroidOptions {
  bool? requiresNetworkConnectivity;
  bool? requiresExternalPower;
  int targetPeriodInMinutes = 15;

  AndroidOptions(
      {required this.requiresNetworkConnectivity,
      required this.requiresExternalPower,
      required this.targetPeriodInMinutes});
}

class IOSOptions {
  bool? requiresNetworkConnectivity;
  bool? requiresExternalPower;
  String taskIdentifier = "";

  IOSOptions(
      {required this.requiresNetworkConnectivity,
      required this.requiresExternalPower,
      required this.taskIdentifier});
}

class SimpleWorkManager {

  void Function() callbackFunction;
  String callbackFunctionIdentifier;

  SimpleWorkManager({required this.callbackFunction, required this.callbackFunctionIdentifier}) {
    const methodChannel = MethodChannel("simple_work_manager/to_main");
    methodChannel.setMethodCallHandler(_platformCallHandler);
  }

  Future<void> schedule(AndroidOptions androidOptions, IOSOptions iosOptions) {
    return SimpleWorkManagerPlatform.instance
        .schedule(callbackFunctionIdentifier, androidOptions, iosOptions);
  }

  Future<void> cancel() {
    return SimpleWorkManagerPlatform.instance.cancel();
  }

  Future<dynamic> _platformCallHandler(MethodCall call) async {
    if (call.method == callbackFunctionIdentifier) {
      callbackFunction();
    } else {
      debugPrint('Unknown method ${call.method}');
      throw MissingPluginException();
    }
  }
}
