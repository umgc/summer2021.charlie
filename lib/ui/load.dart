import 'package:flutter/material.dart';

import 'loadform.dart';
import 'menudrawer.dart';

///Load the notes
class Load extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(
          Icons.view_headline_outlined,
          size: 40,
        ),
        title: Text("View Notes"),
      ),
      endDrawer: MenuDrawer(),
      body: LoadForm(),
    );
  }
}
