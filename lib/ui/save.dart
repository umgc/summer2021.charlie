import 'package:flutter/material.dart';

import 'menudrawer.dart';
import 'saveform.dart';

///Save page
class Save extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(
          Icons.new_label_outlined,
          size: 40,
        ),
        title: Text("New Notes"),
      ),
      endDrawer: MenuDrawer(),
      body: SaveForm(),
    );
  }
}
