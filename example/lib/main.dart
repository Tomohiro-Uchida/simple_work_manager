import 'package:flutter/material.dart';
import 'package:simple_work_manager/simple_work_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma("vm:entry-point")
Future<void> callbackDispatcher() async {
  debugPrint("simple_work_manager: callbackDispatcher() is called at ${DateTime.now()}");
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin
      .initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings()
        )
      )
      .then((_) => flutterLocalNotificationsPlugin.show(
          0,
          'simple_work_manager',
          'debug notification',
          const NotificationDetails(
              android: AndroidNotificationDetails('simple_work_manager debug notification',
                  'simple_work_manager debug notification'))));
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late SimpleWorkManager _simpleWorkManagerPlugin;
  int iRequiresNetworkConnectivity = 0;
  int iRequiresExternalPower = 0;

  @override
  void initState() {
    super.initState();
    _simpleWorkManagerPlugin =
        SimpleWorkManager(callbackFunction: callbackDispatcher, callbackFunctionIdentifier: "callbackDispatcher");
  }

  bool? dropDownToBool(int dropDownValue) {
    switch (dropDownValue) {
      case 1:
        return false;
      case 2:
        return true;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<int, String> dropDownMap = {0: "NULL", 1: "FALSE", 2: "TRUE"};
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text("Plugin example app"),
            ),
            body: Column(children: [
              Row(children: [
                TextButton(
                    onPressed: () {
                      debugPrint("simple_work_manager: scheduled at ${DateTime.now()}");
                      _simpleWorkManagerPlugin.schedule(
                          AndroidOptions(
                              requiresNetworkConnectivity: dropDownToBool(iRequiresNetworkConnectivity),
                              requiresExternalPower: dropDownToBool(iRequiresExternalPower),
                              targetPeriodInMinutes: 15),
                          IOSOptions(
                              requiresNetworkConnectivity: dropDownToBool(iRequiresNetworkConnectivity),
                              requiresExternalPower: dropDownToBool(iRequiresExternalPower),
                              taskIdentifier: "com.jimdo.uchida001tmhr.simple_work_manager.process"));
                    },
                    child: const Text("Schedule")),
                const Spacer(),
                TextButton(
                    onPressed: () {
                      debugPrint("simple_work_manager: cancel");
                      _simpleWorkManagerPlugin.cancel();
                    },
                    child: const Text("Cancel"))
              ]),
              Row(children: [
                const Text("requiresNetworkConnectivity"),
                const Spacer(),
                DropdownButton(
                    value: iRequiresNetworkConnectivity,
                    items: [
                      for (var element in dropDownMap.entries) ...{
                        DropdownMenuItem(value: element.key, child: Text(element.value))
                      }
                    ],
                    onChanged: (value) {
                      setState(() {
                        iRequiresNetworkConnectivity = value as int;
                      });
                    })
              ]),
              Row(children: [
                const Text("requiresExternalPower"),
                const Spacer(),
                DropdownButton(
                    value: iRequiresExternalPower,
                    items: [
                      for (var element in dropDownMap.entries) ...{
                        DropdownMenuItem(value: element.key, child: Text(element.value))
                      }
                    ],
                    onChanged: (value) {
                      setState(() {
                        iRequiresExternalPower = value as int;
                      });
                    })
              ])
            ])));
  }
}
