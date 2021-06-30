import 'package:flutter/material.dart';

import 'menudrawer.dart';
import 'load.dart';

class Script extends StatelessWidget {
  final String log;

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
                new MaterialPageRoute(builder: (context) => new Load()),
              );
            },
            child: Text("Back"),
          ),
        ],
      ),
    );
  }
}
