import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '/model/user_note.dart';
import '/service/local_auth_api.dart';
import '/util/settingsloader.dart';
import '/util/textmap.dart';
import '/util/util.dart';
import 'save.dart';
import 'script.dart';
import 'view_notes.dart';

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
  bool onSearch = false;
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

  void _backButton() {
    setState(() {
      onDates = true;

      curMenu = topMenu;
    });
  }

  void _onSlideRightToDelete(BuildContext context, var curTime) async {
    /*
    if (onDates) {
      await logs.deleteLog(curDate, null);
      await _resetMapValues(true);
    } else {
      await logs.deleteLog(curDate, curTime);
      await _resetMapValues(false);

      curMenu = topMenu[curTime];
    }
    (context as Element).markNeedsBuild();
    */

    if (!onDates) {
      await logs.deleteLog(curDate, curTime);

      Timer.run(() async {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => ViewNotes(filterFavorite: false)),
            (route) => false);
      });
    }
  }

  void _searchButton() {
    setState(() {
      //Check whether or not the app is performing a search or clearing one
      if (onSearch) {
        //Clear the search and reset curMenu/topMenu
        onSearch = false;
        curMenu = _decryptedJson;
        topMenu = _decryptedJson;
      } else {
        //Perform the search.
        onSearch = true;
        //Save serach term, trim it, and lower case it to avoid case issues
        var searchTerm = textController.text.trim().toLowerCase();
        textController.text = "";

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

        //Set curMenu/topMenu to this created map
        topMenu = toReturn;
        curMenu = topMenu;
      }
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
      MaterialPageRoute(builder: (context) => Save()),
    );
  }

  Widget build(BuildContext context) {
    //Generating list of Dates/Times for initial buttons
    var dateTimes =
        curMenu == null || curMenu.keys == null ? [] : curMenu.keys.toList();
    var listSize = dateTimes.length + 1;

    if (onDates && !onSearch) {
      listSize++;
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Container(
          child: Icon(Icons.add),
        ),
        onPressed: () {
          _addButtonPressed(context);
        },
      ),
      body: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: listSize,
          itemBuilder: (context, i) {
            //Last items on dates list are the serach field and button
            //Search field for dates list
            if (onDates && i == listSize - 2 && !onSearch) {
              return TextField(
                style: settingsLoader.getStyle(textSize),
                controller: textController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Search",
                ),
              );
            }

            //Search button for dates list
            if (onDates && i == listSize - 1) {
              var searchText = "Search";

              if (onSearch) {
                searchText = "Clear Search";
              }

              return ElevatedButton(
                onPressed: () {
                  _searchButton();
                },
                child:
                    Text(searchText, style: settingsLoader.getStyle(textSize)),
              );
            }

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

            //Create appropriate label for upcoming button
            String buttonName = dateTimes[i];
            String subTitle = dateTimes[i];
            var isFavorite = false;

            //If this is a time, the button text needs a preview
            if (!onDates) {
              buttonName = "${buttonName.substring(0, 5)}: ";

              var mapVal = curMenu[dateTimes[i]];
              var fullNote = mapVal is String
                  ? mapVal
                  : (mapVal is UserNote ? mapVal.note : mapVal["note"]);
              //Check that the note is not shorter than 20 characters
              subTitle =
                  fullNote.length < 20 ? fullNote : fullNote.substring(0, 20);
              subTitle += '...';

              isFavorite = mapVal is String
                  ? false
                  : (mapVal is UserNote
                      ? mapVal.isFavorite
                      : mapVal["isFavorite"]);
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
          }),
    );
  }

  Widget _noteCard(var dateTime, String subTitle, bool isFavorite) {
    var buttonName =
        dateTime != subTitle ? "${dateTime.substring(0, 8)}" : dateTime;
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
