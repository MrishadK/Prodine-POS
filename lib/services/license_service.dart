import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/signers/rsa_signer.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class LicenseValidationResult {
  final bool isValid;
  final String message;
  final String? deviceId;
  final DateTime? expiryDate;
  final String? type;

  const LicenseValidationResult({
    required this.isValid,
    required this.message,
    this.deviceId,
    this.expiryDate,
    this.type,
  });
}

class LicenseService {
  // Production AES Fernet Key
  static const String _aesKeyStr =
      '7T_w9y0M2X8q1N4v5E6r7T8y9U0i1O2p3A4s5D6f7G8=';

  // Production RSA Public Key
  static const String publicKeyPem = """-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAv653YqGLZzOv+AOzzjE4
LHY7hrTnpBYhthuEe010yoUf4Ar3Sh4xiyKioWa7MklBs3p35glTHAZXpCu5AWq2
8wmv25jr+dq0UKHU8qlc9PopUWA4KgctcWwth9IVaL0Cm4tUVZ9HyYAm03xioiH7
d2zDaj7GnbL411jJr7ts+oa1xiQpgfNCSxwA4NzDPrMChoJFw+GHGyYSQvh4UYFZ
dj5OSs51UZjnRQ2/iOQkBzMMk3gwVKyldMC/YCRaIct7sJdJ1IFu/xVkNnIPyG56
nA3TCNUrE0kPVYh1aLbUhVdeO0vC8fVkEiSCxuS00XYowDp/NMrOq2N2sc5Gr4oy
7wIDAQAB
-----END PUBLIC KEY-----""";

  static const String _licenseExpiryCacheKey = 'license_expiry_cache';
  static const String _licenseTypeCacheKey = 'license_type_cache';

  static Future<File> _licenseFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/license.dat');
  }

  // --- 1. DECRYPT (Fernet AES) ---
  static String _decryptLicenseBlob(String encrypted) {
    try {
      final sanitized = encrypted.replaceAll(RegExp(r'\s+'), '').trim();
      final key = encrypt.Key.fromBase64(_aesKeyStr);
      final encrypter = encrypt.Encrypter(encrypt.Fernet(key));
      return encrypter.decrypt64(sanitized);
    } catch (e) {
      return encrypted; // Fallback to raw if already decrypted
    }
  }

  // --- 2. DETAILED VALIDATION ---
  static Future<LicenseValidationResult> validateLicenseDetailed(
      String licenseContent) async {
    try {
      // 1. Sanitize text (remove BOM, surrounding quotes, whitespace)
      String rawData = licenseContent.replaceAll('\uFEFF', '').trim();
      if ((rawData.startsWith('"') && rawData.endsWith('"')) ||
          (rawData.startsWith("'") && rawData.endsWith("'"))) {
        rawData = rawData.substring(1, rawData.length - 1).trim();
      }

      if (rawData.isEmpty) {
        return const LicenseValidationResult(
          isValid: false,
          message: "License key is empty. Please upload a file or paste a key.",
        );
      }

      // 2. Decrypt if needed
      if (!rawData.contains("::")) {
        final decrypted = _decryptLicenseBlob(rawData);
        if (decrypted.contains("::")) {
          rawData = decrypted;
        } else {
          return const LicenseValidationResult(
            isValid: false,
            message:
                "Could not decrypt license key. Format is invalid or corrupted.",
          );
        }
      }

      final parts = rawData.split('::');
      if (parts.length != 2) {
        return const LicenseValidationResult(
          isValid: false,
          message:
              "Invalid license format. Expected data payload and signature.",
        );
      }

      final licenseJson = parts[0].trim();
      final signature = parts[1].trim();

      // 3. Verify RSA Signature
      if (!_verifySignature(licenseJson, signature)) {
        return const LicenseValidationResult(
          isValid: false,
          message:
              "Cryptographic signature check failed! The license may be modified or forged.",
        );
      }

      // 4. Parse Payload
      final dynamic decoded = jsonDecode(licenseJson);
      if (decoded is! Map<String, dynamic>) {
        return const LicenseValidationResult(
          isValid: false,
          message: "License payload structure is invalid.",
        );
      }
      final data = decoded;

      // 5. Device ID Check
      final currentDeviceId = await getDeviceId();
      final licDevice = data['device']?.toString();
      if (licDevice != currentDeviceId) {
        final targetShort = (licDevice != null && licDevice.length > 8)
            ? '${licDevice.substring(0, 8)}...'
            : (licDevice ?? 'Unknown');
        final currentShort = '${currentDeviceId.substring(0, 8)}...';
        return LicenseValidationResult(
          isValid: false,
          message:
              'Device ID mismatch! This license is for another computer.\nTarget: $targetShort\nThis PC: $currentShort',
          deviceId: licDevice,
        );
      }

      // 6. Expiry Check
      DateTime? expiryDate;
      if (data.containsKey('expiry')) {
        expiryDate = DateTime.tryParse(data['expiry'].toString());
        if (expiryDate != null && DateTime.now().isAfter(expiryDate)) {
          final formatted =
              "${expiryDate.year}-${expiryDate.month.toString().padLeft(2, '0')}-${expiryDate.day.toString().padLeft(2, '0')}";
          return LicenseValidationResult(
            isValid: false,
            message: "License expired on $formatted. Please request renewal.",
            deviceId: licDevice,
            expiryDate: expiryDate,
            type: data['type']?.toString(),
          );
        }
      }

      return LicenseValidationResult(
        isValid: true,
        message: "License verified successfully!",
        deviceId: licDevice,
        expiryDate: expiryDate,
        type: data['type']?.toString() ?? 'Standard',
      );
    } catch (e) {
      return LicenseValidationResult(
        isValid: false,
        message: "Validation error: $e",
      );
    }
  }

  // Backwards compatible boolean validation
  static Future<bool> validateLicense(String licenseContent) async {
    final result = await validateLicenseDetailed(licenseContent);
    return result.isValid;
  }

  // --- UPDATE LICENSE ---
  static Future<LicenseValidationResult> updateLicenseDetailed(
      String newLicenseContent) async {
    final result = await validateLicenseDetailed(newLicenseContent);
    if (!result.isValid) return result;

    final file = await _licenseFile();
    await file.writeAsString(newLicenseContent.trim(), flush: true);

    // Update UI Cache
    try {
      final prefs = await SharedPreferences.getInstance();
      if (result.expiryDate != null) {
        await prefs.setString(
            _licenseExpiryCacheKey, result.expiryDate!.toIso8601String());
      }
      if (result.type != null) {
        await prefs.setString(_licenseTypeCacheKey, result.type!);
      }
    } catch (e) {
      // ignore
    }

    return result;
  }

  static Future<bool> updateLicense(String newLicenseContent) async {
    final result = await updateLicenseDetailed(newLicenseContent);
    return result.isValid;
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
    return cached != null ? DateTime.tryParse(cached) : null;
  }

  static Future<String?> getLicenseType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_licenseTypeCacheKey);
  }

  static Future<void> clearLicenseData() async {
    final file = await _licenseFile();
    if (await file.exists()) await file.delete();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_licenseExpiryCacheKey);
    await prefs.remove(_licenseTypeCacheKey);
  }

  // Returns true only if the license file is legitimately found AND expired
  static Future<bool> isLicenseExpired() async {
    try {
      final file = await _licenseFile();
      if (!file.existsSync()) return false;

      final rawData = await file.readAsString();
      final result = await validateLicenseDetailed(rawData);
      if (!result.isValid) {
        if (result.expiryDate != null &&
            DateTime.now().isAfter(result.expiryDate!)) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
