import 'package:flutter/material.dart';

import 'load.dart';
import 'menudrawer.dart';

class Script extends StatelessWidget {
  final String log;

  ///Script to read
  Script({Key key, @required this.log}) : super(key: key);

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(
          Icons.view_headline_outlined,
          size: 40,
        ),
        title: Text("Read a Note"),
      ),
      endDrawer: MenuDrawer(),
      body: Column(
        children: [
          Text(log),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Load()),
              );
            },
            child: Text("Back"),
          ),
        ],
      ),
    );
  }
}
