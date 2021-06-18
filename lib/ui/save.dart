import 'package:flutter/material.dart';

import 'menudrawer.dart';
import 'saveform.dart';

class Save extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Save"),
      ),
      drawer: MenuDrawer(),
      body: SaveForm(),
    );
  }
}
