import 'package:flutter/material.dart';

import 'menudrawer.dart';

class Settings extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      drawer: MenuDrawer(),
      body: Text("Settings Screen"),
    );
  }
}
