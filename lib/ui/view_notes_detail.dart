import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/model/user_note.dart';
import '/service/local_auth_api.dart';
import '/util/settingsloader.dart';
import '/util/textmap.dart';
import '/util/util.dart';
import 'menudrawer.dart';
import 'saveform.dart';
import 'script.dart';

///LoadForm
class ViewNotesDetail extends StatefulWidget {
  ///is favorite flag
  final bool filterFavorite;

  ///Constructor
  ViewNotesDetail({Key key, @required this.filterFavorite}) : super(key: key);

  _ViewNotesDetailState createState() =>
      _ViewNotesDetailState(filterFavorite: filterFavorite);
}

class _ViewNotesDetailState extends State<ViewNotesDetail> {
  ///is favorite flag
  final bool filterFavorite;

  _ViewNotesDetailState({@required this.filterFavorite});

  TextMap logs = TextMap();
  SettingsLoader settingsLoader = SettingsLoader();
  String rawText = "";
  String outputText = "";
  String curDate = "";
  Map _decryptedJson;
  Map topMenu;
  Map curMenu;
  bool onDates = true;
  double textSize = 12.0;
  final textController = TextEditingController();

  //Attempt to load files as this screen opens
  void initState() {
    super.initState();

    //Prepare locally stored data and settings
    Timer.run(() async {
      await _resetMapValues(true);
      var settingsList = await settingsLoader.readFile();

      setState(() {
        textSize = settingsList[0];
      });
    });

    Timer.run(() async {
      var rawContent = await logs.readFile();
      setState(() {
        rawText = json.encode(rawContent);
        outputText = logs.toJson(_decryptedJson);
      });
    });
  }

  void _resetMapValues(bool resetCurMenu) async {
    var fileText = await logs.getDecryptedContent();
    setState(() {
      _decryptedJson =
          logs.readJson(input: fileText, filterFavorite: filterFavorite);
      topMenu = _decryptedJson;
      if (resetCurMenu) {
        curMenu = _decryptedJson;
      }
    });
  }

  void _buttonPressed(String dateTime) async {
    var userNote = UserNote();
    var isFavorite = false;
    var isAuthenticated = true;

    await _closeKeyboard();

    if (!onDates) {
      userNote = getUserNote(curMenu[dateTime]);
      isFavorite = userNote != null && userNote.isFavorite;
      isAuthenticated = isFavorite ? await LocalAuthApi.authenticate() : true;
    }

    setState(() {
      if (onDates) {
        onDates = false;
        curMenu = topMenu[dateTime];
        curDate = dateTime;
      } else {
        if (isAuthenticated) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Script(
                    userNote: userNote,
                    time: dateTime,
                    date: curDate,
                    textSize: textSize * 2),
              ));
        }
      }
    });
  }

  void _backButton() async {
    await _closeKeyboard();
    setState(() {
      onDates = true;

      curMenu = topMenu;
    });
  }

  void _onSlideRightToDelete(BuildContext context, var curTime) async {
    await _closeKeyboard();

    if (!onDates) {
      await logs.deleteLog(curDate, curTime);

      Timer.run(() async {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => ViewNotesDetail(filterFavorite: false)),
            (route) => false);
      });
    }
  }

  void _clearSearch() {
    setState(() {
      topMenu = _decryptedJson;
      curMenu = topMenu;
      onDates = true;
    });
  }

  void _searchX() async {
    textController.text = "";
    await _clearSearch();
    await _closeKeyboard();
  }

  void _closeKeyboard() async {
    await FocusScope.of(context).requestFocus(FocusNode());
  }

  void _searchButton(String searchTerm) async {
    await setState(() async {
      //If search box is empty, the search needs to be cleared
      if (searchTerm.isEmpty) {
        await _clearSearch();
      }

      //Save search term, trim it, and lower case it to avoid case issues
      searchTerm = searchTerm.trim().toLowerCase();

      //Generate a new map that only contains logs with the search term
      var toReturn = {};
      var curDate = {};

      //Loop through each date.
      var dates = _decryptedJson.keys.toList();

      for (var d = 0; d < dates.length; d++) {
        curDate = _decryptedJson[dates[d]];
        var times = curDate.keys.toList();

        //Loop through each time for this date.
        for (var t = 0; t < times.length; t++) {
          var uNote = getUserNote(curDate[times[t]]);
          var curLog = uNote != null ? uNote.note.trim().toLowerCase() : null;

          //Check if this log has the search term
          if (curLog.contains(searchTerm)) {
            //Search term found, add this date/time/note to toReturn
            toReturn = _addLog(dates[d], times[t], uNote, toReturn);
          }
        }
      }

      //Change the current view based on search results
      onDates = true;
      topMenu = toReturn;
      curMenu = topMenu;
    });
  }

  //Helper method: Adds a log for the passed date/time to the passed Map
  Map _addLog(String date, String time, UserNote note, Map toAdd) {
    var toReturn = toAdd;
    //Check if current date exists in map
    if (toReturn.containsKey(date)) {
      //Existing date
      var times = toReturn[date];
      times[time] = note;
      toReturn[date] = times;
    } else {
      //New date
      var times = {};
      times[time] = note;
      toReturn[date] = times;
    }

    return toReturn;
  }

  void _addButtonPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SaveForm()),
    );
  }

  //Returns a user-friendly label for the passed date or time String
  String _generateButtonName(String dateTime) {
    var toReturn = dateTime;

    //First determine if the String is a date or a time
    if (dateTime.contains(':')) {
      //Time
      toReturn = toReturn.substring(0, 5);

      var hour = int.parse(toReturn.substring(0, 2));
      var minutes = int.parse(toReturn.substring(3, 5));
      var suffix = "";

      if (hour >= 12) {
        suffix = "P.M.";

        if (hour > 12) {
          hour -= 12;
        }
      } else {
        suffix = "A.M.";

        if (hour == 0) {
          hour = 12;
        }
      }

      toReturn = "$hour:$minutes $suffix";
    } else {
      //Date
      var noteDate = DateTime.parse(toReturn);
      var currentDate = DateTime.now();
      var between = _daysBetween(noteDate, currentDate);

      if (between == 0) {
        toReturn = "Today";
      } else if (between == 1) {
        toReturn = "Yesterday";
      } else if (between > 2 && between <= 7) {
        toReturn = "Last ${DateFormat('EEEE').format(noteDate)}";
      } else if (between > 7 && between <= 14) {
        toReturn = "Last week";
      } else if (between > 14 && between <= 21) {
        toReturn = "Two weeks ago";
      } else if (between > 21 && between <= 28) {
        toReturn = "Three weeks ago";
      } else {
        toReturn = "Over three weeks ago";
      }
    }

    return toReturn;
  }

  //Returns a user-friendly subtitle based on the based date
  String _generateSubtitle(String dateTime) {
    var toReturn = dateTime;

    var year = toReturn.substring(0, 4);
    var month = toReturn.substring(5, 7);
    var day = toReturn.substring(8, 10);

    switch (month) {
      case "01":
        {
          month = "January";
        }
        break;
      case "02":
        {
          month = "February";
        }
        break;
      case "03":
        {
          month = "March";
        }
        break;
      case "04":
        {
          month = "April";
        }
        break;
      case "05":
        {
          month = "May";
        }
        break;
      case "06":
        {
          month = "June";
        }
        break;
      case "07":
        {
          month = "July";
        }
        break;
      case "08":
        {
          month = "August";
        }
        break;
      case "09":
        {
          month = "September";
        }
        break;
      case "10":
        {
          month = "October";
        }
        break;
      case "11":
        {
          month = "November";
        }
        break;
      case "12":
        {
          month = "December";
        }
        break;
    }

    day = int.parse(day).toString();
    toReturn = "$month $day, $year";

    return toReturn;
  }

  ///Returns the number of calendar days between the two passed dates
  int _daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  Widget build(BuildContext context) {
    //Generating list of Dates/Times for initial buttons
    var dateTimes =
        curMenu == null || curMenu.keys == null ? [] : curMenu.keys.toList();
    var listSize = dateTimes.length;

    if (!onDates) {
      listSize++;
    }

    return GestureDetector(
        onTap: _closeKeyboard,
        child: Scaffold(
            appBar: AppBar(
              leading: BackButton(color: Colors.white),
              title: _buildSearchBox(),
            ),
            endDrawer: MenuDrawer(),
            body: Scaffold(
              floatingActionButton: FloatingActionButton(
                child: Container(
                  child: Icon(Icons.add),
                ),
                onPressed: () {
                  _addButtonPressed(context);
                },
              ),
              body: listSize > 0 ? _getListView(dateTimes, listSize) : null,
            )));

    /*return Scaffold(
        appBar: AppBar(
          leading: BackButton(color: Colors.white),
          title: _buildSearchBox(),
        ),
        endDrawer: MenuDrawer(),
        body: Scaffold(
          floatingActionButton: FloatingActionButton(
            child: Container(
              child: Icon(Icons.add),
            ),
            onPressed: () {
              _addButtonPressed(context);
            },
          ),
          body: listSize > 0 ? _getListView(dateTimes, listSize) : null,
        ));*/
  }

  SizedBox _buildSearchBox() {
    return SizedBox(
        height: 40,
        child: TextField(
          controller: textController,
          onSubmitted: _searchButton,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7.0),
              borderSide: BorderSide.none,
            ),
            hintText: 'Search',
            prefixIcon: Icon(Icons.search),
            suffixIcon: IconButton(
              onPressed: _searchX,
              icon: Icon(Icons.clear),
            ),
          ),
        ));
  }

  Widget _getListView(var dateTimes, var listSize) {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: listSize,
        itemBuilder: (context, i) {
          //Last button on the times list should be a back button
          return _getItemBuilder(i, listSize, dateTimes, context);
        });
  }

  StatefulWidget _getItemBuilder(
      int i, listSize, dateTimes, BuildContext context) {
    //Last button on the times list should be a back button
    if (!onDates && i == listSize - 1) {
      //back button for list of times
      return ElevatedButton(
        onPressed: () {
          _backButton();
        },
        child: Text("Back", style: settingsLoader.getStyle(textSize)),
      );
    }

    String subTitle = dateTimes[i];
    var isFavorite = false;

    //If this is a time, the button text needs a preview
    if (!onDates) {
      //buttonName = "${buttonName.substring(0, 5)}: ";
      var mapVal = curMenu[dateTimes[i]];
      var fullNote = mapVal is String
          ? mapVal
          : (mapVal is UserNote ? mapVal.note : mapVal["note"]);

      if (fullNote == null) {
        return null;
      }
      //Check that the note is not shorter than 20 characters
      subTitle = fullNote.length < 20 ? fullNote : fullNote.substring(0, 20);
      subTitle += '...';

      isFavorite = mapVal is String
          ? false
          : (mapVal is UserNote ? mapVal.isFavorite : mapVal["isFavorite"]);
    } else {
      //Button subtitle needs to be converted to a user-friendly date
      subTitle = _generateSubtitle(subTitle);
    }

    return Dismissible(
      onDismissed: (direction) {
        setState(() {
          _onSlideRightToDelete(context, dateTimes[i]);
        });
      },
      secondaryBackground: Container(
        child: Center(
          child: Text(
            'Delete',
            style: TextStyle(color: Colors.white),
          ),
        ),
        color: Colors.red,
      ),
      background: Container(),
      child: _noteCard(dateTimes[i], subTitle, isFavorite),
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
    );
  }

  Widget _noteCard(var dateTime, String subTitle, bool isFavorite) {
    var buttonName = _generateButtonName(dateTime);
    return Card(
      child: InkWell(
        onTap: () {
          _buttonPressed(dateTime);
        },
        child: Column(
          children: <Widget>[
            ListTile(
              tileColor: Theme.of(context).secondaryHeaderColor,
              title: Text(buttonName, style: settingsLoader.getStyle(textSize)),
              subtitle:
                  Text(subTitle, style: settingsLoader.getStyle(textSize)),
              trailing: isFavorite
                  ? Icon(Icons.favorite, color: Theme.of(context).primaryColor)
                  : null,
            )
          ],
        ),
      ),
    );
  }
}
