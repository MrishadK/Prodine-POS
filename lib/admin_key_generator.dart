import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() {
  // ============================================================
  // 🔐 ADMIN CONFIGURATION
  // ============================================================

  // 1. Paste the Client's Machine ID here (The one they send you)
  String clientMachineId = "{8C8BAC50-2D56-40DB-A1CB-4AA242A7C981}";

  // 2. MUST match the salt in your App Code EXACTLY!
  const String appSecretSalt = "MySecureSalt_2024_@#";

  // ============================================================
  // ⚡ GENERATION LOGIC
  // ============================================================

  var bytes = utf8.encode(clientMachineId + appSecretSalt);
  var digest = sha256.convert(bytes);

  // This extracts the first 16 characters as the key
  String licenseKey = digest.toString().substring(0, 16).toUpperCase();

  print("---------------------------------------------");
  print("🔑 LICENSE KEY FOR CLIENT:");
  print(licenseKey);
  print("---------------------------------------------");
}
