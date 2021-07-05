import 'package:workmanager/workmanager.dart';

import '../ui/textmap.dart';

///schedule delete
class ScheduledDeleteText {
  /// logs
  final TextMap logs = TextMap();

  void _deleteText(int numberDays) async {
    var fileText = await logs.getDecryptedContent();
    var dateTimeText = logs.readJson(fileText);

    dateTimeText.removeWhere((key, value) {
      var dt = DateTime.parse(key);
      //todo add isFavorites exception for deletes
      return dt.isBefore(DateTime.now().subtract(Duration(days: numberDays)));
    });
    //Write to file after adding log
    logs.writeFile(dateTimeText);
  }
}

/// callback dispatcher
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    var scheduledDeleteText = ScheduledDeleteText();
    scheduledDeleteText._deleteText(7);
    return Future.value(true);
  });
}

/// initialising work manager
void initialize() {
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  Workmanager().registerPeriodicTask(
    "6",
    "Periodic1hourTask",
    initialDelay: Duration(seconds: 10),
    frequency: Duration(minutes: 15),
  );
}