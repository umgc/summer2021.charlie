import 'package:mnemosyne/ui/textmap.dart';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'encryption_service.dart';
import 'package:workmanager/workmanager.dart';

class ScheduledDeleteText {
  final EncryptionService _encryptionService = EncryptionService();
  final String mainFileName = "memory.txt";
  final TextMap logs = new TextMap();

  void deleteText(int numberDays) async {
    String fileText = await logs.getDecryptedContent();
    Map dateTimeText = logs.readJson(fileText);

    //dateTimeText.removeWhere((key, value) => false)
    dateTimeText.removeWhere((key, value) {
//Date dt = convertStringToDate(key);
      DateTime dt = DateTime.parse(key);
//return dt < now() - numberOfDays;
      return dt.isBefore(DateTime.now().subtract(new Duration(days: 7)));
    });

    /*
    //dateTimeText.removeWhere((key, value) => false)
    dateTimeText.removeWhere((key, value) {
      //Date dt = convertStringToDate(key);
      var dt = DateTime.parse(key);
      //return dt < now() - numberOfDays;
      return dt < DateTime.now().subtract(new Duration(days: 7));
    });
    */
    var file = await getFile(mainFileName);
    var encryptedBase64 = _encryptionService.encrypt(toJson(dateTimeText));
    file.writeAsString(encryptedBase64);
  }

  String toJson(Map dateTimeText) {
    return json.encode(dateTimeText);
  }

  ///Get file from path

  Future<File> getFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${'${directory.path}/'}$fileName');
  }
}

/// integrate workmanager scheduler

const simplePeriodic1HourTask = "simplePeriodic1HourTask";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case simplePeriodic1HourTask:
        var scheduledDeleteText = ScheduledDeleteText();
        scheduledDeleteText.deleteText(7);
        print("$simplePeriodic1HourTask was executed");
        break;
    }
    return Future.value(true);
  });
}

void initialize() {
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


/*
class ScheduledDeleteText {
  TextMap logs = new TextMap();
  void deleteText (int numberDays) async {

    String fileText = await logs.getDecryptedContent();
    Map dateTimeText = logs.readJson(fileText);



    //dateTimeText.removeWhere((key, value) => false)
    dateTimeText.removeWhere((key, value) {
//Date dt = convertStringToDate(key);
      DateTime dt = DateTime.parse(key);
//return dt < now() - numberOfDays;
      return dt.isBefore(DateTime.now().subtract(new Duration(days: 7)));
    });


    /*
    //dateTimeText.removeWhere((key, value) => false)
    dateTimeText.removeWhere((key, value) {
      //Date dt = convertStringToDate(key);
      var dt = DateTime.parse(key);
      //return dt < now() - numberOfDays;
      return dt < DateTime.now().subtract(new Duration(days: 7));
    });
    */

  }


  var encryptedBase64 = _encryptionService.encrypt(toJson(dateTimeText));
  file.writeAsString(encryptedBase64);


}


*/
