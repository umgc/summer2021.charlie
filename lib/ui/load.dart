import 'package:flutter/material.dart';

import 'loadform.dart';
import 'menudrawer.dart';

///Load the notes
class Load extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Notes"),
      ),
      endDrawer: MenuDrawer(),
      body: LoadForm(),
    );
  }
}
