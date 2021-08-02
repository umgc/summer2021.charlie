import 'package:flutter/cupertino.dart';

///ReceivedNotification model
class ReceivedNotification {
  /// Constructor
  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });

  ///An id for the notification
  final int id;

  ///Title for notification
  final String title;

  /// notification body
  final String body;

  ///payload json
  final String payload;
}
