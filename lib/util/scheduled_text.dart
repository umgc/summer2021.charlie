import 'package:timezone/data/latest.dart' as latest;
import 'package:timezone/timezone.dart' as tz;

import '/model/notification_payload.dart';
import '/service/notification_service.dart';
import '/util/util.dart';

Future<void> _configureLocalTimeZone() async {
  latest.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Detroit'));
  isTzLocalInitialized = true;
}

///Is Tz local initialized
bool isTzLocalInitialized;

///ScheduledText for notification
class ScheduledText {
  final List<String> schedKeywords = [
    'tonight',
    ', o clock',
    'a.m.',
    'p.m.',
    'hour',
    'minute',
    'second'
  ];
  int _keywordIndex = -1;
  String _keywordFound = '';
  List _allWords = [];
  int _hourValue = 0;
  final NotificationService _notificationService = NotificationService();

  ///Check if it is a schedule text
  void checkScheduleKeyWords(String date, String time, String log) async {
    if (log.isNullOrEmpty()) {
      print('---> Null or empty');
      return;
    }

    if (!_keywordExists(log)) {
      print('---> $log ---> Not a scheduled text');
      return;
    }

    if (isTzLocalInitialized == null || !isTzLocalInitialized) {
      await _configureLocalTimeZone();
    }
    _setKeywordFound(log);

    var scheduledValue = _getSanitizedDateTimeValue;

    print('---> scheduledValue = $scheduledValue');
    //TODO notify that you ll remind the user at this time (_allWords[_keywordIndex - 1] + _keywordFound)

    var scheduledDateTime = _getScheduledDateTime(scheduledValue);
    await _notificationService.zonedScheduleNotification(scheduledDateTime,
        NotificationPayload(dateText: date, timeText: time, note: log));
  }

  get _getSanitizedDateTimeValue {
    var scheduledValue = _allWords[_keywordIndex - 1];
    scheduledValue =
        scheduledValue == 'a' || scheduledValue == 'an' ? 1 : scheduledValue;

    scheduledValue = scheduledValue.contains(',')
        ? scheduledValue.split(',')[0]
        : scheduledValue;
    return scheduledValue;
  }

  DateTime _getScheduledDateTime(scheduledValue) {
    DateTime now = tz.TZDateTime.now(tz.local);
    DateTime scheduledDateTime = tz.TZDateTime.now(tz.local);
    switch (_keywordFound) {
      case 'tonight':
        scheduledDateTime = _getScheduledTime(20, 0, 0);
        break;
      case ', o clock':
        scheduledDateTime = _getScheduledTime(int.parse(scheduledValue), 0, 0);
        break;
      case 'a.m.':
        var dateTimeValAm =
            _getDateTimeForAm(scheduledValue, scheduledDateTime);
        scheduledDateTime = _hourValue == 12
            ? dateTimeValAm.subtract(const Duration(hours: 12))
            : dateTimeValAm;
        break;
      case 'p.m.':
        var dateTimeValAm =
            _getDateTimeForAm(scheduledValue, scheduledDateTime);
        scheduledDateTime = _hourValue == 12
            ? dateTimeValAm
            : dateTimeValAm.add(const Duration(hours: 12));
        break;
      case 'hour':
        scheduledDateTime = now.add(Duration(hours: int.parse(scheduledValue)));
        break;
      case 'minute':
        scheduledDateTime =
            now.add(Duration(minutes: int.parse(scheduledValue)));
        break;
      case 'second':
        scheduledDateTime =
            now.add(Duration(seconds: int.parse(scheduledValue)));
        break;
    }
    scheduledDateTime = scheduledDateTime.isBefore(now)
        ? scheduledDateTime.add(const Duration(hours: 12))
        : scheduledDateTime;
    print('---> scheduledDateTime = $scheduledDateTime');
    return scheduledDateTime;
  }

  DateTime _getDateTimeForAm(scheduledValue, DateTime scheduledDateTime) {
    _hourValue = scheduledValue.contains(':')
        ? int.parse(scheduledValue.split(':')[0])
        : scheduledValue;
    var minuteValue = scheduledValue.contains(':')
        ? int.parse(scheduledValue.split(':')[1])
        : 0;
    var secondValue =
        scheduledValue.contains(':') && scheduledValue.split(':').length > 2
            ? int.parse(scheduledValue.split(':')[2])
            : 0;
    scheduledDateTime = _getScheduledTime(_hourValue, minuteValue, secondValue);
    return scheduledDateTime;
  }

  void _setKeywordFound(String log) {
    _keywordIndex = -1;
    _keywordFound = '';
    _allWords = log.toLowerCase().split(' ');
    for (var keyword in schedKeywords) {
      if (_keywordFound.isNotNullOrEmpty()) {
        break;
      }
      for (var i = 0; i < _allWords.length; i++) {
        var word = _allWords[i];
        if (word.contains(keyword)) {
          _keywordIndex = i;
          _keywordFound = keyword;
          break;
        }

        if (keyword == ', o clock' &&
            word == 'clock' &&
            i > 0 &&
            _allWords[i - 1] == 'o') {
          _keywordIndex = i - 1;
          _keywordFound = keyword;
          break;
        }
      }
    }
  }

  DateTime _getScheduledTime(int hourInt, int minuteInt, int secondInt) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hourInt, minuteInt, secondInt);
    return scheduledDate;
  }

  bool _keywordExists(String log) {
    var _keywordIndex = -1;
    for (var k in schedKeywords) {
      if (log.toLowerCase().contains(k)) {
        _keywordIndex = log.toLowerCase().indexOf(k);
        break;
      }
    }
    return _keywordIndex > -1;
  }
}
