import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '/ui/audio_recorder.dart';
import '/util/constant.dart';
import '/util/util.dart';

/// A Flutter application demonstrating the functionality of this plugin
class PermissionHandlerWidget extends StatefulWidget {
  @override
  _PermissionHandlerWidgetState createState() =>
      _PermissionHandlerWidgetState();
}

class _PermissionHandlerWidgetState extends State<PermissionHandlerWidget> {
  bool _hasPermissions = true;

  @override
  void initState() {
    super.initState();

    _listenForAllPermissionStatus();
  }

  void _listenForAllPermissionStatus() async {
    const tick = Duration(milliseconds: 5);
    Timer.periodic(tick, (t) async {
      final status = await hasPermissions();
      setState(() {
        _hasPermissions = status;
      });
      if (_hasPermissions) {
        t.cancel();
      }
    });
  }

  ///On continue
  void _onContinue() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AudioRecorder()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(
          Icons.memory_outlined,
          size: 40,
        ),
        title: Text(
          'Mnemosyne',
          style: TextStyle(fontSize: 25),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          SizedBox(
            height: 40,
          ),
          Text(
            'Permissions required ...',
            style:
                TextStyle(color: Theme.of(context).primaryColor, fontSize: 25),
            softWrap: true,
          ),
          SizedBox(
            height: 80,
          ),
          Column(
              children: Permission.values
                  .where(isListedPermissions)
                  .map((permission) => PermissionWidget(permission))
                  .toList()),
          SizedBox(height: 180),
          Container(
            constraints: BoxConstraints(maxWidth: 375.0, minHeight: 50.0),
            margin: EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: _hasPermissions ? _onContinue : null,
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  )
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

///Widget to handle permissions
class PermissionWidget extends StatefulWidget {
  /// Constructs a [PermissionWidget] for the supplied [Permission].
  const PermissionWidget(this._permission);

  final Permission _permission;

  @override
  _PermissionState createState() => _PermissionState(_permission);
}

class _PermissionState extends State<PermissionWidget> {
  _PermissionState(this._permission);

  final Permission _permission;
  PermissionStatus _permissionStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();

    _listenForPermissionStatus();
  }

  void _listenForPermissionStatus() async {
    final status = await _permission.status;
    setState(() => _permissionStatus = status);
  }

  Color getPermissionColor() {
    switch (_permissionStatus) {
      case PermissionStatus.denied:
        return Colors.red;
      case PermissionStatus.granted:
        return Colors.green;
      case PermissionStatus.limited:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      ListTile(
        title: Text(
          Constant.mapPermissionName[_permission],
          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20),
        ),
        subtitle: Text(
          Constant.mapPermissionStatus[_permissionStatus],
          style: TextStyle(color: getPermissionColor(), fontSize: 15),
        ),
        trailing: (_permission is PermissionWithService)
            ? IconButton(
                icon: const Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                onPressed: () {
                  checkServiceStatus(
                      context, _permission as PermissionWithService);
                })
            : null,
        onTap: () {
          requestPermission(_permission);
        },
      ),
      Divider(),
    ]);
  }

  void checkServiceStatus(
      BuildContext context, PermissionWithService permission) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text((await permission.serviceStatus).toString()),
    ));
  }

  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();

    setState(() {
      print(status);
      _permissionStatus = status;
      print(_permissionStatus);
    });
  }
}
