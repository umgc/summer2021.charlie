import 'dart:convert';

import '/util/textmap.dart';

///schedule delete
class ScheduledDeleteText {
  /// logs
  final TextMap logs = TextMap();

  /// delete
  void deleteText(int numberDays) async {
    var fileText = await logs.getDecryptedContent();
    var dateTimeText = logs.readJson(input: fileText, filterFavorite: false);

    dateTimeText.removeWhere((key, value) {
      var dt = DateTime.parse(key);
      var data = json.decode(value);
      return dt.isBefore(DateTime.now().subtract(Duration(days: numberDays))) &&
          data['isFavorites'] == false;
    });
    //Write to file after adding log
    logs.writeFile(dateTimeText);
  }
}
