import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:simple_work_manager/simple_work_manager.dart';

import 'simple_work_manager_method_channel.dart';

abstract class SimpleWorkManagerPlatform extends PlatformInterface {
  /// Constructs a SimpleWorkManagerPlatform.
  SimpleWorkManagerPlatform() : super(token: _token);

  static final Object _token = Object();

  static SimpleWorkManagerPlatform _instance = MethodChannelSimpleWorkManager();

  /// The default instance of [SimpleWorkManagerPlatform] to use.
  ///
  /// Defaults to [MethodChannelSimpleWorkManager].
  static SimpleWorkManagerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SimpleWorkManagerPlatform] when
  /// they register themselves.
  static set instance(SimpleWorkManagerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> schedule(String callbackIdentifier,
      AndroidOptions androidOptions,
      IOSOptions iosOptions) {
    throw UnimplementedError("schedule() has not been implemented.");
  }

  Future<void> cancel() {
    throw UnimplementedError("cancel() has not been implemented.");
  }

}
