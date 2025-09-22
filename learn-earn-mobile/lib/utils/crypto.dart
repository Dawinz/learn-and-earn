import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';

class DeviceIdentity {
  final String deviceId;
  final String publicKey;
  final String privateKey;

  DeviceIdentity({
    required this.deviceId,
    required this.publicKey,
    required this.privateKey,
  });
}

class CryptoUtils {
  static const String _appPepper =
      'learn_earn_app_pepper_2024'; // Should match backend

  /// Generate RSA keypair and derive device ID
  static DeviceIdentity generateDeviceIdentity() {
    final keyPair = RSAKeyGenerator();
    final secureRandom = FortunaRandom();
    secureRandom.seed(KeyParameter(Uint8List(32)));
    keyPair.init(
      ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
        secureRandom,
      ),
    );

    final pair = keyPair.generateKeyPair();
    final privateKey = pair.privateKey as RSAPrivateKey;
    final publicKey = pair.publicKey as RSAPublicKey;

    // Convert to PEM format
    final privateKeyPem = _encodePrivateKeyToPem(privateKey);
    final publicKeyPem = _encodePublicKeyToPem(publicKey);

    // Derive device ID using app pepper + public key
    final deviceId = sha256
        .convert(utf8.encode(_appPepper + publicKeyPem))
        .toString();

    return DeviceIdentity(
      deviceId: deviceId,
      publicKey: publicKeyPem,
      privateKey: privateKeyPem,
    );
  }

  /// Create signature for a message using private key
  static String createSignature(String message, String privateKeyPem) {
    // Simplified implementation - in production, use proper RSA signing
    final messageBytes = utf8.encode(message);
    final hash = sha256.convert(messageBytes);
    return base64Encode(hash.bytes);
  }

  /// Verify signature using RSA public key
  static bool verifySignature(
    String message,
    String signature,
    String publicKeyPem,
  ) {
    try {
      // Simplified implementation - in production, use proper RSA verification
      final messageBytes = utf8.encode(message);
      final hash = sha256.convert(messageBytes);
      final expectedSignature = base64Encode(hash.bytes);
      return signature == expectedSignature;
    } catch (e) {
      print('Signature verification error: $e');
      return false;
    }
  }

  /// Generate a secure nonce for anti-replay protection
  static String generateNonce() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Encode(bytes);
  }

  /// Hash mobile money number for privacy
  static String hashMobileMoneyNumber(String number) {
    return sha256.convert(utf8.encode(_appPepper + number)).toString();
  }

  /// Generate 12-word recovery phrase (simplified version)
  static List<String> generateRecoveryPhrase() {
    // In a real implementation, use BIP39 wordlist
    final words = [
      'abandon',
      'ability',
      'able',
      'about',
      'above',
      'absent',
      'absorb',
      'abstract',
      'absurd',
      'abuse',
      'access',
      'accident',
      'account',
      'accuse',
      'achieve',
      'acid',
      'acoustic',
      'acquire',
      'across',
      'act',
      'action',
      'actor',
      'actress',
      'actual',
      'adapt',
      'add',
      'addict',
      'address',
      'adjust',
      'admit',
      'adult',
      'advance',
    ];

    final random = Random.secure();
    return List.generate(12, (i) => words[random.nextInt(words.length)]);
  }

  // Helper methods for PEM encoding/decoding
  static String _encodePrivateKeyToPem(RSAPrivateKey privateKey) {
    final keyBytes = _bigIntToBytes(privateKey.privateExponent!);
    final base64Key = base64Encode(keyBytes);
    return '-----BEGIN PRIVATE KEY-----\n$base64Key\n-----END PRIVATE KEY-----';
  }

  static String _encodePublicKeyToPem(RSAPublicKey publicKey) {
    final keyBytes = _bigIntToBytes(publicKey.modulus!);
    final base64Key = base64Encode(keyBytes);
    return '-----BEGIN PUBLIC KEY-----\n$base64Key\n-----END PUBLIC KEY-----';
  }

  static RSAPrivateKey _parsePrivateKeyFromPem(String pem) {
    // This is a simplified implementation - in production, use proper ASN.1 parsing
    return RSAPrivateKey(
      BigInt.zero,
      BigInt.zero,
      BigInt.zero,
      BigInt.zero,
      BigInt.zero,
    );
  }

  static RSAPublicKey _parsePublicKeyFromPem(String pem) {
    final base64Key = pem
        .replaceAll('-----BEGIN PUBLIC KEY-----', '')
        .replaceAll('-----END PUBLIC KEY-----', '')
        .replaceAll('\n', '');
    // This is a simplified implementation - in production, use proper ASN.1 parsing
    return RSAPublicKey(BigInt.zero, BigInt.zero);
  }

  // Helper method to convert BigInt to bytes
  static Uint8List _bigIntToBytes(BigInt value) {
    if (value == BigInt.zero) return Uint8List(1);

    final bitLength = value.bitLength;
    final byteLength = (bitLength + 7) ~/ 8;
    final bytes = Uint8List(byteLength);

    for (int i = 0; i < byteLength; i++) {
      bytes[byteLength - 1 - i] = (value >> (i * 8)).toInt() & 0xFF;
    }

    return bytes;
  }
}
