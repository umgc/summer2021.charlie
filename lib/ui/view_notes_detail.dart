import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '/util/textmap.dart';
import '/util/util.dart';
import 'save.dart';
import 'script.dart';

///LoadForm
class ViewNotesDetail extends StatefulWidget {
  _ViewNotesDetailState createState() => _ViewNotesDetailState();
}

class _ViewNotesDetailState extends State<ViewNotesDetail> {
  TextMap logs = TextMap();
  String rawText = "";
  String outputText = "";
  String curDate = "";
  Map _decryptedJson;
  Map topMenu;
  Map curMenu;
  bool onDates = true;
  bool onSearch = false;
  final textController = TextEditingController();

  //Attempt to load file as this screen opens
  void initState() {
    super.initState();

    Timer.run(() async {
      await _resetMapValues(true);
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
      _decryptedJson = logs.readJson(fileText);
      topMenu = _decryptedJson;
      if (resetCurMenu) {
        curMenu = _decryptedJson;
      }
    });
  }

  void _buttonPressed(String dateTime) {
    setState(() {
      if (onDates) {
        onDates = false;
        curMenu = topMenu[dateTime];
        curDate = dateTime;
      } else {
        var userNote = getUserNote(curMenu[dateTime]);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  Script(userNote: userNote, time: dateTime, date: curDate),
            ));
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
    if (onDates) {
      logs.deleteLog(curDate, null);
      await _resetMapValues(true);
    } else {
      logs.deleteLog(curDate, curTime);
      await _resetMapValues(false);
      curMenu = topMenu[curTime];
    }
    (context as Element).markNeedsBuild();
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
            String curLog = curDate[times[t]].trim().toLowerCase();

            //Check if this log has the search term
            if (curLog.contains(searchTerm)) {
              //Search term found, add this date/time/log to toReturn
              toReturn =
                  _addLog(dates[d], times[t], curDate[times[t]], toReturn);
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
  Map _addLog(String date, String time, String log, Map toAdd) {
    var toReturn = toAdd;
    //Check if current date exists in map
    if (toReturn.containsKey(date)) {
      //Existing date
      var times = toReturn[date];
      times[time] = log;
      toReturn[date] = times;
    } else {
      //New date
      var times = {};
      times[time] = log;
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
                child: Text(searchText),
              );
            }

            //Last button on the times list should be a back button
            if (!onDates && i == listSize - 1) {
              //back button for list of times
              return ElevatedButton(
                onPressed: () {
                  _backButton();
                },
                child: Text("Back"),
              );
            }

            //Create appropriate label for upcoming button
            String buttonName = dateTimes[i];

            //If this is a time, the button text needs a preview
            if (!onDates) {
              buttonName = "${buttonName.substring(0, 5)}: ";

              var mapVal = curMenu[dateTimes[i]];
              var buttonNameVal = mapVal is String ? mapVal : mapVal["note"];
              //Check that the note is not shorter than 20 characters
              if (mapVal.length < 20) {
                buttonName += buttonNameVal;
              } else {
                buttonName += buttonNameVal.substring(0, 20);
              }
            }

            //Normal button for date or time listing
            // return ElevatedButton(
            //   onPressed: () {
            //     _buttonPressed(dateTimes[i]);
            //   },
            //   child: Text(buttonName),
            // );

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
              child: _noteCard(dateTimes[i]),
              key: UniqueKey(),
              direction: DismissDirection.endToStart,
            );
          }),
    );
  }

  Widget _noteCard(var dateTime) {
    return Card(
      child: InkWell(
        onTap: () {
          _buttonPressed(dateTime);
        },
        child: Column(
          children: <Widget>[
            ListTile(
              // leading: CircleAvatar(
              //   backgroundImage: NetworkImage(movie.imageUrl),
              // ),
              title: Text(dateTime),
              subtitle: Text(dateTime),
              trailing: Text(dateTime),
            )
          ],
        ),
      ),
    );
  }
}