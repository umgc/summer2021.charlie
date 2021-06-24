import 'package:encrypt/encrypt.dart';

class EncryptionService {
  final key = Key.fromUtf8('IAmTestingEncryptionForUmgcSwen1');
  final iv = IV.fromLength(16);
  String encrypt(String plainText) {
    final encrypter = Encrypter(AES(key));
    return encrypter.encrypt(plainText, iv: iv).base64;
  }

  String decrypt(String encryptedBase64) {
    final encrypter = Encrypter(AES(key));
    return encrypter.decrypt(Encrypted.from64(encryptedBase64), iv: iv);
  }
}
