import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';
import 'package:workmanager/workmanager.dart';

import '/model/received_notification.dart';
import '/service/notification_service.dart';
import '/ui/script.dart';
import 'model/notification_payload.dart';
import 'model/received_notification.dart';
import 'model/user_note.dart';
import 'service/scheduled_delete_text.dart';
import 'ui/audio_recognize.dart';
import 'ui/audio_recorder.dart';
import 'ui/permission_handler_widget.dart';
import 'util/constant.dart';
import 'util/util.dart';

/// This task runs periodically
const simplePeriodic1HourTask = "Old Notes Deleted";

///Selected Notification payload
NotificationPayload selectedPayload;

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

///Select notification subject
final BehaviorSubject<NotificationPayload> selectNotificationSubject =
    BehaviorSubject<NotificationPayload>();

Future<void> main() async {
  ///Initializing work manager
  WidgetsFlutterBinding.ensureInitialized();

  //Initializing workmanager for note purge
  _initializeWorkmanager();

  final notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  var initialRoute = MyApp.routeName;
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    initialRoute = Script.routeName;
    selectedPayload = _getScriptPayload(notificationAppLaunchDetails.payload);
  }

  await flutterLocalNotificationsPlugin.initialize(
      _getNotificationInitializationSettings,
      onSelectNotification: _onSelectNotification);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: <String, WidgetBuilder>{
        MyApp.routeName: (_) => MyApp(),
        Script.routeName: (_) => Script(
            userNote: UserNote(note: selectedPayload.note, isFavorite: false),
            time: selectedPayload.timeText,
            date: selectedPayload.dateText,
            textSize: 24.0)
      },
    ),
  );
}

///MyApp a stateless widget
class MyApp extends StatelessWidget {
  ///Constructor
  const MyApp({
    Key key,
  }) : super(key: key);

  ///Default route name
  static const String routeName = '/';

  @override
  Widget build(BuildContext context) {
    _requestPermissions();
    _configureDidReceiveLocalNotificationSubject(context);
    _configureSelectNotificationSubject(context);
    return MaterialApp(
      title: 'Mnemosyne',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: _getHome(context),
    );
  }
}

Widget _getHome(context) {
  return FutureBuilder<Widget>(
      future: _getHomeWidget(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data;
        } else {
          return CircularProgressIndicator();
        }
      });
}

Future<Widget> _getHomeWidget() async {
  if (!await hasPermissions()) {
    return PermissionHandlerWidget();
  }
  if (await _audioFileExists) {
    return AudioRecognize();
  }
  return AudioRecorder();
}

void _requestPermissions() {
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
}

void _configureSelectNotificationSubject(BuildContext context) {
  selectNotificationSubject.stream.listen((payload) async {
    await Navigator.pushNamed(context, Script.routeName);
  });
}

NotificationPayload _getScriptPayload(String payloadStr) {
  Map<String, dynamic> payloadMap =
      payloadStr.isNotNullOrEmpty() ? jsonDecode(payloadStr) : null;
  selectedPayload =
      payloadMap != null ? NotificationPayload.fromJson(payloadMap) : null;
  return selectedPayload;
}

Future<dynamic> _onSelectNotification(payload) async {
  if (payload != null) {
    debugPrint('notification payload: $payload');
  }

  selectedPayload = _getScriptPayload(payload);
  selectNotificationSubject.add(selectedPayload);
}

InitializationSettings get _getNotificationInitializationSettings {
  return InitializationSettings(
    android: AndroidInitializationSettings('app_icon'),
    iOS: _getIosNotificationInitializer(),
  );
}

IOSInitializationSettings _getIosNotificationInitializer() {
  final initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (
        id,
        title,
        body,
        payload,
      ) async {
        didReceiveLocalNotificationSubject.add(
          ReceivedNotification(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ),
        );
      });
  return initializationSettingsIOS;
}

/// callback dispatcher
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    var scheduledDeleteText = ScheduledDeleteText();
    scheduledDeleteText.deleteText(7);

    ///Return true when the task executed successfully or not
    return Future.value(true);
  });
}

void _initializeWorkmanager() {
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  Workmanager().registerPeriodicTask(
    "6",
    simplePeriodic1HourTask,
    initialDelay: Duration(seconds: 10),
    frequency: Duration(minutes: 15),
  );
}

Future<bool> get _audioFileExists async {
  final audioFilePath = await Constant.getAudioRecordingFilePath();
  return Constant.getIfFileExists(audioFilePath);
}

void _configureDidReceiveLocalNotificationSubject(BuildContext context) {
  didReceiveLocalNotificationSubject.stream
      .listen((receivedNotification) async {
    var scriptPayload = _getScriptPayload(receivedNotification.payload);
    await showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: receivedNotification.title != null
            ? Text(receivedNotification.title)
            : null,
        content: receivedNotification.body != null
            ? Text(receivedNotification.body)
            : null,
        actions: <Widget>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => Script(
                      userNote:
                          UserNote(note: scriptPayload.note, isFavorite: false),
                      time: scriptPayload.timeText,
                      date: scriptPayload.dateText,
                      textSize: 20.0),
                ),
              );
            },
            child: const Text('Ok'),
          )
        ],
      ),
    );
  });
}
