import 'package:mnemosyne/ui/textmap.dart';

class ScheduledDeleteText {
  TextMap logs = new TextMap();
  void deleteText (int numberDays) async {

    String fileText = await logs.getDecryptedContent();
    Map dateTimeText = logs.readJson(fileText);

    //dateTimeText.removeWhere((key, value) => false)
    dateTimeText.removeWhere((key, value) {
      //Date dt = convertStringToDate(key);
      Date dt = DateTime.parse(key);
      //return dt < now() - numberOfDays;
      return dt < DateTime.now().subtract(new Duration(days: 7));
    });

  }

  var encryptedBase64 = _encryptionService.encrypt(toJson(dateTimeText));
  file.writeAsString(encryptedBase64);
  
}


///workmanager tasks