import 'package:flutter/material.dart';

import 'menudrawer.dart';
import 'loadform.dart';

class Load extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Load"),
      ),
      drawer: MenuDrawer(),
      body: LoadForm(),
    );
  }
}
