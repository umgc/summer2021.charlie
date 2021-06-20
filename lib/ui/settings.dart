import 'package:flutter/material.dart';

import 'menudrawer.dart';

class Settings extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(
          Icons.settings_outlined,
          size: 40,
        ),
        title: Text("Settings"),
      ),
      endDrawer: MenuDrawer(),
      body: Text("Settings Screen"),
    );
  }
}
