import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/signers/rsa_signer.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class LicenseService {
  static const String _aesKeyStr =
      '<aeskey>';

  static const String publicKeyPem = """-----BEGIN PUBLIC KEY-----
<Key Here>
  
-----END PUBLIC KEY-----""";

  static const String _licenseExpiryCacheKey = 'license_expiry_cache';

  static Future<File> _licenseFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/license.dat');
  }

  // --- 1. DECRYPT (AES) ---
  static String _decryptLicenseBlob(String encrypted) {
    try {
      final key = encrypt.Key.fromBase64(_aesKeyStr);
      final encrypter = encrypt.Encrypter(encrypt.Fernet(key));
      return encrypter.decrypt64(encrypted);
    } catch (e) {
      return encrypted; // Fallback
    }
  }

  // --- 2. VALIDATE (RSA + DATE CHECK) ---
  static Future<bool> validateLicense(String licenseContent) async {
    try {
      String rawData = licenseContent.trim();

      if (!rawData.contains("::")) {
        rawData = _decryptLicenseBlob(rawData);
      }

      final parts = rawData.split('::');
      if (parts.length != 2) return false;

      final licenseJson = parts[0];
      final signature = parts[1];

      // 1. Verify RSA Signature
      if (!_verifySignature(licenseJson, signature)) {
        print("RSA Signature Invalid!");
        return false;
      }

      // 2. Parse Data
      final data = jsonDecode(licenseJson);

      // 3. Device ID Check
      final currentDeviceId = await getDeviceId();
      if (data['device'] != currentDeviceId) {
        print("Device ID mismatch");
        return false;
      }

      // 4. Expiry Check
      if (data.containsKey('expiry')) {
        final expiryDate = DateTime.parse(data['expiry']);
        final now = DateTime.now();
        if (now.isAfter(expiryDate)) {
          print("License Expired");
          return false;
        }
      }

      return true;
    } catch (e) {
      print("Validation Error: $e");
      return false;
    }
  }

  // --- UPDATE LICENSE ---
  static Future<bool> updateLicense(String newLicenseContent) async {
    final isValid = await validateLicense(newLicenseContent);
    if (!isValid) return false;

    final file = await _licenseFile();
    await file.writeAsString(newLicenseContent.trim(), flush: true);

    // Update UI Cache
    try {
      final rawDecrypted = _decryptLicenseBlob(newLicenseContent.trim());
      final data = jsonDecode(rawDecrypted.split('::')[0]);

      if (data.containsKey('expiry')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_licenseExpiryCacheKey, data['expiry']);
      }
    } catch (e) {
      print("Error updating cache: $e");
    }

    return true;
  }

  static bool _verifySignature(String data, String signatureBase64) {
    try {
      final publicKey = CryptoUtils.rsaPublicKeyFromPem(publicKeyPem);
      final signer = RSASigner(SHA256Digest(), '0609608648016503040201');
      signer.init(false, PublicKeyParameter<RSAPublicKey>(publicKey));
      final sig = RSASignature(base64.decode(signatureBase64));
      return signer.verifySignature(Uint8List.fromList(utf8.encode(data)), sig);
    } catch (e) {
      return false;
    }
  }


  static Future<String> getDeviceId() async {
    if (Platform.isWindows) {
      final user = Platform.environment['USERNAME'] ?? 'user';
      final pc = Platform.environment['COMPUTERNAME'] ?? 'pc';
      return sha256.convert(utf8.encode("$user-$pc")).toString();
    }
    return "unknown_device";
  }

  static Future<bool> isAppLicensed() async {
    final file = await _licenseFile();
    if (!file.existsSync()) return false;
    final content = await file.readAsString();
    return validateLicense(content);
  }

  static Future<DateTime?> getLicenseExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_licenseExpiryCacheKey);
    return cached != null ? DateTime.parse(cached) : null;
  }

  static Future<void> clearLicenseData() async {
    final file = await _licenseFile();
    if (await file.exists()) await file.delete();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_licenseExpiryCacheKey);
  }

  // 🚀 NEW: Check specifically if the license exists but is expired
  static Future<bool> isLicenseExpired() async {
    try {
      final file = await _licenseFile();
      if (!file.existsSync()) return false; // No license = New Install

      String rawData = await file.readAsString();
      if (!rawData.contains("::")) {
        rawData = _decryptLicenseBlob(rawData);
      }

      final parts = rawData.split('::');
      if (parts.length != 2)
        return true; // Invalid format = treat as expired/invalid

      final licenseJson = parts[0];
      final data = jsonDecode(licenseJson);

      if (data.containsKey('expiry')) {
        final expiryDate = DateTime.parse(data['expiry']);
        if (DateTime.now().isAfter(expiryDate)) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
