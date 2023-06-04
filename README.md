# simple_work_manager

Simple Work Manager for Android and iOS.

## Abstracts
Simple Work Manager is mapped to Android Work Manager and iOS BGTaskScheduler. 

## Getting Started
### pubspec.yaml
Add "simple_work_manager:" into pubspec.yaml.
```dart:pubspec.yaml
dependencies:
  simple_work_manager:
```

### iOS
1. Permitted background task scheduler identifier in info.plist in Xcode  
Set PermittedBackgroundTaskSchedulerIdentifier as unique string like <[com].[domain].simple_work_manager.process>.
2. Background modes in Xcode   
Check Background processing.  
3. Add code for registration into AppDelegate.swift.
``` AppDelegate.swift
GeneratedPluginRegistrant.register(with: self)
```

## Import
```
import 'package:simple_work_manager/simple_work_manager.dart';
```
## Preparing callback function
```dart:main.dart
@pragma("vm:entry-point")
Future<void> callbackDispatcher() async {
    sync_func();
    await async_func();
    // execute background jobs here.
    // Jobs can include async function call.
    // Async function must be called with 'await'.
}
```
Defines callback function as top level function. The callback function is called in repetition.

## Instantiate SimpleWorkManager()
```dart:main.dart
_simpleWorkManagerPlugin =
        SimpleWorkManager(callbackFunction: callbackDispatcher, callbackFunctionIdentifier: "callbackDispatcher");
```
Specifies callbackFunction defined above. Specifies callbackFunctionIdentifier as arbitrarily non-empty string, typically same as callbackFunction name. 

## Schedule
```dart:main.dart
_simpleWorkManagerPlugin.schedule(
    AndroidOptions(
        requiresNetworkConnectivity: true,
        requiresExternalPower: true,
        targetPeriodInMinutes: 15),
    IOSOptions(
        requiresNetworkConnectivity: true,
        requiresExternalPower: true,
        taskIdentifier: "com.jimdo.uchida001tmhr.simple_work_manager.process"));
```
requiresNetworkConnectivity and requiresExternalPower must be set as following section.
targetPeriodInMinutes specifies minimum interval of background process, minimum value is 15.
taskIdentifier must be same as "Permitted background task scheduler identifier" of Info of Xcode. taskIdentifier must be unique, then must contain your domain identifier.

## Options(Constraints(Experimental approach))
Simple Work Manager can specify the constraints such that requiresNetworkConnectivity and requiresExternalPower. The behaviors according to these constraints are as following tables:

### Android

<table>
  <tr>
    <td colspan='3' rowspan='3'>◯: callback function will be called in background<br>△: callback function will be called but its interval is long<br>×: callback function wil not be called in background</td> <td colspan='6'><div style="text-align: center">requiresExternalPower</div></td>
  </tr>
  <tr>
    <td colspan='2'><div style="text-align: center">NULL</div></td> <td colspan='2'><div style="text-align: center">FALSE</div></td> <td colspan='2'><div style="text-align: center">TRUE</div></td>
  <tr>
    <td><div style="text-align: center">Power Plug in</div></td> <td><div style="text-align: center">Power Plug off</div></td> <td><div style="text-align: center">Power Plug in</div></td> <td><div style="text-align: center">Power Plug off</div></td> <td><div style="text-align: center">Power Plug in</div></td> <td><div style="text-align: center">Power Plug off</div></td>
  </tr>
  <tr>
    <td rowspan='6'>requiresNetworkConnectivity</td> <td rowspan='2'>NULL</td> <td>WiFi ON</td> <td><div style="text-align: center">◯</div></td>　<td><div style="text-align: center">△</div></td>　<td><div style="text-align: center">◯</div></td>　<td><div style="text-align: center">△</div></td>　<td><div style="text-align: center">◯</div></td>　<td><div style="text-align: center">×</div></td>
  </tr>
  <tr>
    <td>WiFi OFF</td> <td><div style="text-align: center">◯</div></td>　<td><div style="text-align: center">△</div></td>　<td><div style="text-align: center">◯</div></td>　<td><div style="text-align: center">△</div></td>　<td><div style="text-align: center">◯</div></td>　<td><div style="text-align: center">×</div></td>
  </tr>
  <tr>
    <td rowspan='2'>FALSE</td> <td>WiFi ON</td> <td><div style="text-align: center">◯</div></td>　<td><div style="text-align: center">◯</div></td>　<td><div style="text-align: center">◯</div></td>　<td><div style="text-align: center">◯</div></td>　<td><div style="text-align: center">◯</div></td>　<td><div style="text-align: center">×</div></td>
  </tr>
  <tr>
    <td>WiFi OFF</td> <td><div style="text-align: center">◯</div></td>　<td><div style="text-align: center">△</div></td>　<td><div style="text-align: center">◯</div></td>　<td><div style="text-align: center">◯</div></td>　<td><div style="text-align: center">◯</div></td>　<td><div style="text-align: center">×</div></td>
  </tr>
  <tr>
    <td rowspan='2'>TRUE</td> <td>WiFi ON</td> <td><div style="text-align: center">◯</div></td>　<td><div style="text-align: center">△</div></td>　<td><div style="text-align: center">◯</div></td>　<td><div style="text-align: center">△</div></td>　<td><div style="text-align: center">◯</div></td>　<td><div style="text-align: center">×</div></td>
  </tr>
  <tr>
    <td>WiFi OFF</td> <td><div style="text-align: center">×</div></td>　<td><div style="text-align: center">×</div></td>　<td><div style="text-align: center">×</div></td>　<td><div style="text-align: center">×</div></td>　<td><div style="text-align: center">×</div></td>　<td><div style="text-align: center">×</div></td>
  </tr>
</table>

### iOS

<table>
  <tr>
    <td colspan='3' rowspan='3'>◯: callback function will be called in background<br>△: callback function will be called but its interval is long<br>×: callback function wil not be called in background</td> <td colspan='6'><div style="text-align: center">requiresExternalPower</div></td>
  </tr>
  <tr>
    <td colspan='2'><div style="text-align: center">NULL</div></td> <td colspan='2'><div style="text-align: center">FALSE</div></td> <td colspan='2'><div style="text-align: center">TRUE</div></td>
  <tr>
    <td><div style="text-align: center">Power Plug in</div></td> <td><div style="text-align: center">Power Plug off</div></td> <td><div style="text-align: center">Power Plug in</div></td> <td><div style="text-align: center">Power Plug off</div></td> <td><div style="text-align: center">Power Plug in</div></td> <td><div style="text-align: center">Power Plug off</div></td>
  <tr>
    <td rowspan='6'>requiresNetworkConnectivity</td> <td rowspan='2'>NULL</td> <td>WiFi ON</td> <td><div style="text-align: center">◯</div></td>　<td><div style="text-align: center">×</div></td>　<td><div style="text-align: center">◯</div></td>　<td><div style="text-align: center">×</div></td>　<td><div style="text-align: center">×</div></td>　<td><div style="text-align: center">×</div></td>
  </tr>
  <tr>
    <td>WiFi OFF</td> <td><div style="text-align: center">◯</div></td>　<td><div style="text-align: center">×</div></td>　<td><div style="text-align: center">◯</div></td>　<td><div style="text-align: center">×</div></td>　<td><div style="text-align: center">×</div></td>　<td><div style="text-align: center">×</div></td>
  </tr>
  <tr>
    <td rowspan='2'>FALSE</td> <td>WiFi ON</td> <td><div style="text-align: center">△</div></td>　<td><div style="text-align: center">×</div></td>　<td><div style="text-align: center">◯</div></td>　<td><div style="text-align: center">×</div></td>　<td><div style="text-align: center">×</div></td>　<td><div style="text-align: center">×</div></td>
  </tr>
  <tr>
    <td>WiFi OFF</td> <td><div style="text-align: center">◯</div></td>　<td><div style="text-align: center">×</div></td>　<td><div style="text-align: center">△</div></td>　<td><div style="text-align: center">×</div></td>　<td><div style="text-align: center">◯</div></td>　<td><div style="text-align: center">×</div></td>
  </tr>
  <tr>
    <td rowspan='2'>TRUE</td> <td>WiFi ON</td> <td><div style="text-align: center">◯</div></td>　<td><div style="text-align: center">×</div></td>　<td><div style="text-align: center">◯</div></td>　<td><div style="text-align: center">×</div></td>　<td><div style="text-align: center">◯</div></td>　<td><div style="text-align: center">×</div></td>
  </tr>
  <tr>
    <td>WiFi OFF</td> <td><div style="text-align: center">×</div></td>　<td><div style="text-align: center">×</div></td>　<td><div style="text-align: center">×</div></td>　<td><div style="text-align: center">×</div></td>　<td><div style="text-align: center">×</div></td>　<td><div style="text-align: center">×</div></td>
  </tr>
</table>

### SUGGESTION FOR CONSTRAINTS

Set requiresExternalPower and requiresNetworkConnectivity to TRUE and plug external power IN to execute background process continuously.

## Cancel the schedule
```
_simpleWorkManagerPlugin.cancel();
```

## CAUTION
<span style="color: red; ">App must not killed to invoke callback function.</span>  
<span style="color: red; ">In iOS, app must be in background to invoke callback function.</span>
