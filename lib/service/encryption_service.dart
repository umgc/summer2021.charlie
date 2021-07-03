import 'package:encrypt/encrypt.dart';
import '/util/util.dart';

///Encryption service
class EncryptionService {
  ///This is the key for the encryption
  final key = Key.fromUtf8('IAmTestingEncryptionForUmgcSwen1');

  ///Initialization vector
  final iv = IV.fromLength(16);

  ///Encrypt
  String encrypt(String plainText) {
    final encryptor = Encrypter(AES(key));
    return encryptor.encrypt(plainText, iv: iv).base64;
  }

  ///Decrypt
  String decrypt(String encryptedBase64) {
    final encryptor = Encrypter(AES(key));
    return encryptedBase64.isNullOrEmpty()
        ? '{}'
        : encryptor.decrypt(Encrypted.from64(encryptedBase64), iv: iv);
  }
}
