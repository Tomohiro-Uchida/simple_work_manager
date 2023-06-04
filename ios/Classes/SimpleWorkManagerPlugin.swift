import Flutter
import UIKit
import BackgroundTasks

var channelToPlugin: FlutterMethodChannel? = nil
var channelToMain: FlutterMethodChannel? = nil
var instance: SimpleWorkManagerPlugin? = nil
var callbackIdentifier: String? = nil
var taskIdentifier: String? = nil
var gRequiresNetworkConnectivity: Bool?
var gRequiresExternalPower: Bool?
var simpleWorkManagerPlugin = SimpleWorkManagerPlugin()

public class SimpleWorkManagerPlugin: NSObject, FlutterPlugin {

  public static func register(with registrar: FlutterPluginRegistrar) {
    channelToPlugin = FlutterMethodChannel(name: "simple_work_manager/to_plugin",
                                   binaryMessenger: registrar.messenger())
    channelToMain = FlutterMethodChannel(name: "simple_work_manager/to_main",
                                       binaryMessenger: registrar.messenger())
    instance = SimpleWorkManagerPlugin()
    registrar.addMethodCallDelegate(instance!, channel: channelToPlugin!)
    BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.jimdo.uchida001tmhr.simple_work_manager.process",
                                    using: nil,
                                    launchHandler: { task in
      simpleWorkManagerPlugin.schedule(
        taskIdentifier: taskIdentifier!,
        requiresNetworkConnectivity: gRequiresNetworkConnectivity,
        requiresExternalPower: gRequiresExternalPower
      )
      // let dispatchQueue = DispatchQueue(label :"SimpleWorkManagerQueue", qos : .userInitiated, attributes : .concurrent )
      // dispatchQueue.async {
        channelToMain!.invokeMethod(callbackIdentifier!, arguments: nil)
      // }
      task.setTaskCompleted(success: true)
      task.expirationHandler = {
      }
    })
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "schedule" :
        if let args = call.arguments as? Dictionary<String, Any>,
           let taskIdentifierLocal = args["iosTaskIdentifier"] as? String {
          let requiresNetworkConnectivity = args["iosRequiresNetworkConnectivity"] as? Bool
          let requiresExternalPower = args["requiresExternalPower"] as? Bool
          taskIdentifier = taskIdentifierLocal
          callbackIdentifier = args["callbackIdentifier"] as? String
          schedule(
              taskIdentifier: taskIdentifier!,
              requiresNetworkConnectivity: requiresNetworkConnectivity,
              requiresExternalPower: requiresExternalPower
          )
        }
        result("Success")
      case "cancel" :
        cancel()
      default :
        result(FlutterMethodNotImplemented)
    }
  }

  public func schedule(taskIdentifier: String, requiresNetworkConnectivity: Bool?, requiresExternalPower: Bool?) {
    gRequiresNetworkConnectivity = requiresNetworkConnectivity
    gRequiresExternalPower = requiresExternalPower
    let request = BGProcessingTaskRequest(identifier: taskIdentifier)
    // 通信が必要な場合はtrueにする（デフォルトはfalseで、この場合通信がない時間にも起動される)
    if (requiresNetworkConnectivity != nil) {
      request.requiresNetworkConnectivity = requiresNetworkConnectivity!
    }
    // 充電中に実行したい処理の場合はtrueにする
    // これがtrueの時にCPU Monitorが無効になる
    if (requiresExternalPower != nil) {
      request.requiresExternalPower = requiresExternalPower!
    }
    do {
      try BGTaskScheduler.shared.submit(request)
    } catch {
      print("Could not schedule.")
    }
  }
    
  public func cancel() {
    BGTaskScheduler.shared.cancelAllTaskRequests()
  }
}
