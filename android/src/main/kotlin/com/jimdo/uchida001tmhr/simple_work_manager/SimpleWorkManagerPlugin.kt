package com.jimdo.uchida001tmhr.simple_work_manager

import android.app.Activity
import android.content.Context
import androidx.work.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.concurrent.TimeUnit

/** SimpleWorkManagerPlugin */

private lateinit var channelToPlugin: MethodChannel
private lateinit var channelToMain: MethodChannel
private lateinit var gCall: MethodCall

class SimpleWorker(appContext: Context, workerParams: WorkerParameters) :
    Worker(appContext, workerParams) {

    override fun doWork(): Result {
        val callbackIdentifier: String? = gCall.argument<String?>("callbackIdentifier")
        if (callbackIdentifier != null) {
            CoroutineScope(Dispatchers.Main).launch {
                channelToMain.invokeMethod(callbackIdentifier, null)
            }
        }
        // Indicate whether the work finished successfully with the Result
        return Result.success()
    }
}

class SimpleWorkManagerPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var activity: Activity
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channelToPlugin = MethodChannel(
            flutterPluginBinding.binaryMessenger,
            "simple_work_manager/to_plugin"
        )
        channelToMain = MethodChannel(
            flutterPluginBinding.binaryMessenger,
            "simple_work_manager/to_main"
        )
        channelToPlugin.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {

        gCall = call

        when (call.method) {
            "schedule" -> {
                val constraints =
                    if (call.argument<Boolean>("androidRequiresNetworkConnectivity") == null) {
                        if (call.argument<Boolean>("androidRequiresExternalPower") == null) {
                            Constraints.Builder()
                                .build()
                        } else if (call.argument<Boolean>("androidRequiresExternalPower") == false) {
                            Constraints.Builder()
                                .setRequiresCharging(false)
                                .build()
                        } else {
                            Constraints.Builder()
                                .setRequiresCharging(true)
                                .build()
                        }
                    } else if (call.argument<Boolean>("androidRequiresNetworkConnectivity") == false) {
                        if (call.argument<Boolean>("androidRequiresExternalPower") == null) {
                            Constraints.Builder()
                                .setRequiredNetworkType(NetworkType.NOT_REQUIRED)
                                .build()
                        } else if (call.argument<Boolean>("androidRequiresExternalPower") == false) {
                            Constraints.Builder()
                                .setRequiredNetworkType(NetworkType.NOT_REQUIRED)
                                .setRequiresCharging(false)
                                .build()
                        } else {
                            Constraints.Builder()
                                .setRequiredNetworkType(NetworkType.NOT_REQUIRED)
                                .setRequiresCharging(true)
                                .build()
                        }
                    } else {
                        if (call.argument<Boolean>("androidRequiresExternalPower") == null) {
                            Constraints.Builder()
                                .setRequiredNetworkType(NetworkType.CONNECTED)
                                .build()
                        } else if (call.argument<Boolean>("androidRequiresExternalPower") == false) {
                            Constraints.Builder()
                                .setRequiredNetworkType(NetworkType.CONNECTED)
                                .setRequiresCharging(false)
                                .build()
                        } else {
                            Constraints.Builder()
                                .setRequiredNetworkType(NetworkType.CONNECTED)
                                .setRequiresCharging(true)
                                .build()
                        }
                    }
                val workRequest: PeriodicWorkRequest? =
                    call.argument<Int?>("androidTargetPeriodInMinutes")?.toLong()?.let {
                        PeriodicWorkRequestBuilder<SimpleWorker>(it, TimeUnit.MINUTES)
                            .setConstraints(constraints)
                            .build()
                    }
                if (workRequest != null) {
                    WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                        "Work",
                        ExistingPeriodicWorkPolicy.KEEP,
                        workRequest
                    )
                }
                result.success("Success")
            }
            "cancel" -> {
                WorkManager.getInstance(context).cancelAllWork()
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channelToPlugin.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
    }
}
