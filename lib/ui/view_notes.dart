import 'package:flutter/material.dart';

import 'menudrawer.dart';
import 'view_notes_detail.dart';

///Load the notes
class ViewNotes extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Notes"),
      ),
      endDrawer: MenuDrawer(),
      body: ViewNotesDetail(),
    );
  }
}
