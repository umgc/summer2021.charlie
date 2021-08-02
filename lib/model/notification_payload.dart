import 'package:flutter/cupertino.dart';

///Notification payload model
class NotificationPayload {
  /// Constructor
  NotificationPayload({
    @required this.dateText,
    @required this.timeText,
    @required this.note,
  });

  ///payload dateText
  final String dateText;

  ///payload timeText
  final String timeText;

  ///payload note
  final String note;

  ///FromJSON method to handle json decoding
  NotificationPayload.fromJson(Map<String, dynamic> json)
      : dateText = json['dateText'],
        timeText = json['timeText'],
        note = json['note'];

  ///ToJSON method to handle json encoding
  Map<String, dynamic> toJson() {
    return {
      'dateText': dateText,
      'timeText': timeText,
      'note': note,
    };
  }
}
