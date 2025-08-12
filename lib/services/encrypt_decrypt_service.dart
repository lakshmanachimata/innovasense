import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

/// Flutter/Dart equivalent of the Angular TypeScript EncryptDecryptService
/// Provides AES encryption and decryption functionality using CBC mode with PKCS7 padding
class EncryptDecryptService {
  static const String _defaultKey = 'innovosens2022ma';
  static const String _defaultIV = 'smashapp01012022';

  final String _key;
  final String _iv;

  /// Constructor with default key and IV
  EncryptDecryptService({String? key, String? iv})
    : _key = key ?? _defaultKey,
      _iv = iv ?? _defaultIV;

  /// Factory constructor for creating service with custom key and IV
  factory EncryptDecryptService.withCustomKeys(String key, String iv) {
    return EncryptDecryptService(key: key, iv: iv);
  }

  /// Private method to encrypt data (equivalent to TypeScript 'set' method)
  String _set(String keys, dynamic value) {
    try {
      // Parse key and IV, ensuring they are 16 bytes (128-bit)
      final keyBytes = _padKeyTo16Bytes(keys);
      final ivBytes = _padKeyTo16Bytes(_iv);

      // Create the key and IV objects
      final key = Key(keyBytes);
      final iv = IV(ivBytes);

      // Create the encrypter with AES algorithm
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

      // Convert value to string and encrypt
      final encrypted = encrypter.encrypt(value.toString(), iv: iv);

      // Return the encrypted string
      return encrypted.base64;
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  /// Private method to decrypt data (equivalent to TypeScript 'get' method)
  String _get(String keys, dynamic value) {
    try {
      // Parse key and IV, ensuring they are 16 bytes (128-bit)
      final keyBytes = _padKeyTo16Bytes(keys);
      final ivBytes = _padKeyTo16Bytes(_iv);

      // Create the key and IV objects
      final key = Key(keyBytes);
      final iv = IV(ivBytes);

      // Create the encrypter with AES algorithm
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

      // Decrypt the value
      final decrypted = encrypter.decrypt64(value.toString(), iv: iv);

      return decrypted;
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  /// Public method to encrypt data using default key (equivalent to TypeScript 'getencriptData')
  String getEncryptData(dynamic data) {
    return _set(_key, data);
  }

  /// Public method to decrypt data using default key (equivalent to TypeScript 'getdecriptData')
  String getDecryptData(dynamic data) {
    return _get(_key, data);
  }

  /// Encrypt data using a custom key
  String encryptWithKey(String customKey, dynamic data) {
    return _set(customKey, data);
  }

  /// Decrypt data using a custom key
  String decryptWithKey(String customKey, dynamic data) {
    return _get(customKey, data);
  }

  /// Helper method to pad key/IV to 16 bytes for AES-128
  Uint8List _padKeyTo16Bytes(String input) {
    final bytes = utf8.encode(input);
    final result = Uint8List(16);

    if (bytes.length < 16) {
      // Pad with zeros if shorter than 16 bytes
      result.setRange(0, bytes.length, bytes);
      result.fillRange(bytes.length, 16, 0);
    } else if (bytes.length > 16) {
      // Truncate if longer than 16 bytes
      result.setRange(0, 16, bytes.take(16));
    } else {
      // Exactly 16 bytes
      result.setRange(0, 16, bytes);
    }

    return result;
  }

  /// Get the current key being used
  String get key => _key;

  /// Get the current IV being used
  String get iv => _iv;
}

/// Extension methods for easier usage
extension EncryptDecryptServiceExtension on EncryptDecryptService {
  /// Encrypt a string value
  String encryptString(String value) => getEncryptData(value);

  /// Decrypt a string value
  String decryptString(String value) => getDecryptData(value);

  /// Encrypt a map/JSON object
  String encryptMap(Map<String, dynamic> map) =>
      getEncryptData(jsonEncode(map));

  /// Decrypt and parse a map/JSON object
  Map<String, dynamic> decryptMap(String encryptedData) {
    final decrypted = getDecryptData(encryptedData);
    return jsonDecode(decrypted) as Map<String, dynamic>;
  }
}
