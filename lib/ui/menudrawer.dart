import 'package:flutter/material.dart';

import 'save.dart';
import 'load.dart';
import 'settings.dart';

class MenuDrawer extends StatelessWidget {
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              "Menu",
              textAlign: TextAlign.center,
            ),
          ),
          //Save Screen
          ListTile(
              title: Text("Save"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  new MaterialPageRoute(builder: (context) => new Save()),
                );
              }),
          //Load Screen
          ListTile(
              title: Text("Load"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  new MaterialPageRoute(builder: (context) => new Load()),
                );
              }),
          //Settings Screen
          ListTile(
              title: Text("Settings"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  new MaterialPageRoute(builder: (context) => new Settings()),
                );
              }),
        ],
      ),
    );
  }
}
