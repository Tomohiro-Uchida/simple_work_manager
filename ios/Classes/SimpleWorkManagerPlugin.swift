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

class backgroundOperation: Operation {
  
  override func main() {
    channelToMain!.invokeMethod(callbackIdentifier!, arguments: nil)
  }
  
}

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
      let simpleWorkManagerPlugin = SimpleWorkManagerPlugin()
      simpleWorkManagerPlugin.schedule(
        taskIdentifier: taskIdentifier!,
        requiresNetworkConnectivity: gRequiresNetworkConnectivity,
        requiresExternalPower: gRequiresExternalPower
      )
      // タスクが実行された時の処理を記述する
      let queue = OperationQueue()
      queue.maxConcurrentOperationCount = 1
      
      // 時間内に実行完了しなかった場合は、処理を解放します
      // バックグラウンドで実行する処理は、次回に回しても問題ない処理のはずなので、これでOK
      task.expirationHandler = {
        queue.cancelAllOperations()
      }
      
      // サンプルの処理をキューに詰めます
      let operation = backgroundOperation()
      operation.completionBlock = {
        // 最後の処理が完了したら、必ず完了したことを伝える必要があります
        task.setTaskCompleted(success: operation.isFinished)
      }
      queue.addOperation(operation)
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
          let formatter = DateFormatter()
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
