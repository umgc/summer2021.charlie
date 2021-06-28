import 'package:flutter/material.dart';
import 'package:mnemosyne/ui/audio_recognize.dart';

import 'save.dart';
import 'load.dart';
import 'settings.dart';

class MenuDrawer extends StatelessWidget {
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
          ListTile(
              leading: Icon(
                Icons.new_label_outlined,
                size: 40,
              ),
              title: Text(
                "New Note",
                style: TextStyle(fontSize: 20),
              ),
              subtitle: Text('Type your notes to save along with other texts'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  new MaterialPageRoute(builder: (context) => new Save()),
                );
              }),
          //Load Screen
          ListTile(
            leading: Icon(
              Icons.view_headline_outlined,
              size: 40,
            ),
            title: Text(
              "View Notes",
              style: TextStyle(fontSize: 20),
            ),
            subtitle: Text('View all the saved notes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                new MaterialPageRoute(builder: (context) => new Load()),
              );
            },
          ),
          //Settings Screen
          ListTile(
              leading: Icon(
                Icons.settings_outlined,
                size: 40,
              ),
              title: Text(
                "Settings",
                style: TextStyle(fontSize: 20),
              ),
              subtitle: Text('My settings to set the days and other ones'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  new MaterialPageRoute(builder: (context) => new Settings()),
                );
              }),
          const Divider(
            height: 50,
            thickness: 5,
            indent: 20,
            endIndent: 20,
          ),
          //Home Screen
          ListTile(
              leading: Icon(
                Icons.home_outlined,
                size: 40,
              ),
              title: Text(
                "Home",
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
              subtitle: Text('Back to home screen',
                  style: TextStyle(color: Colors.grey)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new AudioRecognize()),
                );
              }),
          //Previous Screen
          ListTile(
              leading: Icon(
                Icons.arrow_back_outlined,
                size: 40,
              ),
              title: Text(
                "Back",
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
              subtitle: Text('Back to previous screen',
                  style: TextStyle(color: Colors.grey)),
              onTap: () {
                Navigator.of(context).pop();
              }),
        ],
      ),
    );
  }
}