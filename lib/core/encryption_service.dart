import 'package:encrypt/encrypt.dart';

class EncryptionService {
  // A 32 byte static key for AES encryption (MVP placeholder)
  // In a real production app, this should be derived from the user's PIN + a secure salt or PKDF2,
  // or stored securely in the local keychain, but here it serves as a basic layer of obscuration on Firestore.
  static final Key _key = Key.fromUtf8('my32charfamilyosstoragekey123456');
  static final IV _iv = IV.fromLength(16);

  static final Encrypter _encrypter = Encrypter(AES(_key));

  /// Encrypts plain text into a base64 string
  static String encrypt(String plainText) {
    try {
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      return plainText; // Fallback if encryption fails
    }
  }

  /// Decrypts a base64 string into plain text
  static String decrypt(String base64Text) {
    try {
      final encrypted = Encrypted.fromBase64(base64Text);
      final decrypted = _encrypter.decrypt(encrypted, iv: _iv);
      return decrypted;
    } catch (e) {
      return base64Text; // Fallback if it's already plain text or decryption fails
    }
  }
}
