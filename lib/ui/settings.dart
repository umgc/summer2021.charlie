import 'package:flutter/material.dart';

import 'menudrawer.dart';
import 'settingsform.dart';

///Settings page
class MySettingsScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      endDrawer: MenuDrawer(),
      body: SettingsForm(),
    );
  }
}
