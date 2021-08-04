import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '/util/util.dart';

///Local auth api service
class LocalAuthApi {
  static final _auth = LocalAuthentication();

  ///Check if the device has biometrics
  static Future<bool> hasBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print('Error in hasBiometrics `$e');
      return false;
    }
  }

  ///Get biometrics
  Future<List<BiometricType>> getBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print('Error in getBiometrics `$e');
      return <BiometricType>[];
    }
  }

  ///Authenticate
  static Future<bool> authenticate(BuildContext context) async {
    final isAvailable = await hasBiometrics();
    if (!isAvailable) return false;

    try {
      return await _auth.authenticate(
        localizedReason: 'Scan Fingerprint to Authenticate',
        useErrorDialogs: true,
        stickyAuth: true,
        biometricOnly: true,
      );
    } on PlatformException catch (e) {
      print('Error in authenticate `$e');
      showDialogOnPlatformException(context);
      return false;
    }
  }
}
