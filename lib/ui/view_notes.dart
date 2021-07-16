import 'package:flutter/material.dart';

import 'menudrawer.dart';
import 'view_notes_detail.dart';

///Load the notes
class ViewNotes extends StatelessWidget {
  ///is favorite flag
  final bool filterFavorite;

  ///Constructor
  ViewNotes({Key key, @required this.filterFavorite}) : super(key: key);

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Notes"),
      ),
      endDrawer: MenuDrawer(),
      body: ViewNotesDetail(filterFavorite: filterFavorite),
    );
  }
}
