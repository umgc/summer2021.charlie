import 'package:flutter_test/flutter_test.dart';
import 'package:mnemosyne/service/encryption_service.dart';

void main() {
  test('encryption_service - Encrypt', () {
    final _encryptionService = EncryptionService();
    final myString = 'i think bruce wayne is batman';
    final String encryptedBase64 = _encryptionService.encrypt(myString);
    final String decrypted = _encryptionService.decrypt(encryptedBase64);
    expect(myString, decrypted);
  });
}
