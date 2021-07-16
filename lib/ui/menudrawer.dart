import 'package:flutter/material.dart';

import '/service/local_auth_api.dart';
import 'audio_recognize.dart';
import 'save.dart';
import 'settings.dart';
import 'view_notes.dart';

///MenuDrawer
class MenuDrawer extends StatelessWidget {
  _saveNewNote(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Save()),
    );
  }

  _loadNotes(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ViewNotes(filterFavorite: false)),
    );
  }

  _loadFavorites(BuildContext context) async {
    final isAuthenticated = await LocalAuthApi.authenticate();
    if (isAuthenticated) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ViewNotes(filterFavorite: true)),
      );
    }
  }

  _loadSettings(BuildContext context) async {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Settings()),
    );
  }

  _recordSpeech(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AudioRecognize()),
    );
  }

  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
              height: 100,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.indigo,
                ),
                child: Text(
                  "Menu",
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              )),
          //Save Screen
          _buildListTitle(
            icon: Icons.add_circle_outline,
            title: "New Note",
            subTitleText: 'Type your notes to save along with other notes',
            subTitleFontColor: Colors.grey,
            onTapped: () {
              _saveNewNote(context);
            },
          ),
          //Load notes screen
          _buildListTitle(
            icon: Icons.note_alt_outlined,
            title: "View Notes",
            subTitleText: 'View all the saved notes',
            subTitleFontColor: Colors.grey,
            onTapped: () {
              _loadNotes(context);
            },
          ),
          //Favorites notes screen
          _buildListTitle(
            icon: Icons.favorite,
            title: "Personal/Favorites",
            subTitleText: 'View all personal or favorite notes',
            subTitleFontColor: Colors.grey,
            onTapped: () async {
              _loadFavorites(context);
            },
          ),
          //Settings Screen
          _buildListTitle(
            icon: Icons.settings_outlined,
            title: "Settings",
            subTitleText: 'My settings to set the days and other ones',
            subTitleFontColor: Colors.grey,
            onTapped: () {
              _loadSettings(context);
            },
          ),
          const Divider(
            height: 50,
            thickness: 5,
            indent: 20,
            endIndent: 20,
          ),
          //Home Screen
          _buildListTitle(
            icon: Icons.mic_none_outlined,
            title: "New Recording",
            subTitleText: 'Tap here to start a new recording',
            subTitleFontColor: Colors.grey,
            onTapped: () {
              _recordSpeech(context);
            },
          ),
          //Previous Screen
          _buildListTitle(
            icon: Icons.arrow_back_outlined,
            title: "Back",
            titleFontColor: Colors.grey,
            subTitleText: 'Back to previous screen',
            subTitleFontColor: Colors.grey,
            onTapped: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTitle({
    IconData icon,
    String title,
    MaterialColor titleFontColor,
    String subTitleText,
    MaterialColor subTitleFontColor,
    @required VoidCallback onTapped,
  }) =>
      ListTile(
        leading: Icon(
          icon,
          size: 30,
        ),
        title: Text(
          title,
          style: titleFontColor != null
              ? TextStyle(fontSize: 17, color: titleFontColor)
              : TextStyle(fontSize: 17),
        ),
        subtitle:
            Text(subTitleText, style: TextStyle(color: subTitleFontColor)),
        onTap: onTapped,
      );
}
