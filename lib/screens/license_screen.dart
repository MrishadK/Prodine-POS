import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';

import '../services/license_service.dart';
import 'main_screen.dart';

class LicenseScreen extends StatefulWidget {
  const LicenseScreen({super.key});

  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  String deviceId = "Loading...";
  final TextEditingController controller = TextEditingController();

  // UI State
  String? errorMessage;
  bool isLoading = false;
  bool isDeviceLoaded = false;

  // 🚀 NEW: Tracks if we are here because of expiration
  bool isExpired = false;

  @override
  void initState() {
    super.initState();
    loadDeviceId();
    _checkExpiryStatus();
  }

  // 🚀 NEW: Check if the license is specifically expired
  Future<void> _checkExpiryStatus() async {
    final expired = await LicenseService.isLicenseExpired();
    if (mounted) {
      setState(() {
        isExpired = expired;
      });
    }
  }

  Future<void> loadDeviceId() async {
    try {
      final id = await LicenseService.getDeviceId();
      if (mounted) {
        setState(() {
          deviceId = id;
          isDeviceLoaded = true;
        });
      }
    } catch (e) {
      setState(() => deviceId = "Error loading ID");
    }
  }

  // --- ACTIONS ---

  Future<void> _handleActivation() async {
    final key = controller.text.trim();
    if (key.isEmpty) {
      _showError("Please enter a license key or upload a file.");
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final success = await LicenseService.updateLicense(key);

    if (success) {
      if (!mounted) return;
      _navigateToMain();
    } else {
      _showError("Invalid License Key or Expired Date.");
    }
  }

  Future<void> _handleFileUpload() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['lic', 'txt'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();

        setState(() {
          controller.text = content.trim();
          errorMessage = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "License file loaded! Click 'ACTIVATE LICENSE' to finish."),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _showError("Error reading file: $e");
    }
  }

  void _copyDeviceId() {
    Clipboard.setData(ClipboardData(text: deviceId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Device ID copied to clipboard"),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      errorMessage = message;
      isLoading = false;
    });
  }

  // --- UI BUILDERS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildWelcomePanel(),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 3,
                  child: _buildActivationCard(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePanel() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isExpired
                ? Colors.red.withOpacity(0.1) // 🔴 Red background if expired
                : const Color(0xFF2C5F7C).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
              isExpired
                  ? Icons.timer_off
                  : Icons.verified_user_outlined, // 🔴 Icon change
              size: 48,
              color: isExpired
                  ? Colors.red
                  : const Color(0xFF2C5F7C) // 🔴 Red icon
              ),
        ),
        const SizedBox(height: 24),

        // 🚀 NEW: Dynamic Title
        Text(
          isExpired ? "License Expired" : "Activate Your\nPOS System",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color:
                isExpired ? Colors.red : const Color(0xFF2C5F7C), // 🔴 Red text
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),

        // 🚀 NEW: Dynamic Description
        Text(
          isExpired
              ? "Your license validity period has ended. Please upload a new license file to restore access to the system."
              : "This software requires a valid license to operate. Please contact your administrator to obtain your activation key or license file.",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),

        const SizedBox(height: 32),
        _buildStep(1, "Share your Device ID/QR with\nAdmin"),
        const SizedBox(height: 16),
        _buildStep(2, "Receive New License File"),
        const SizedBox(height: 16),
        _buildStep(3, "Upload to Reactivate"),
      ],
    );
  }

  Widget _buildStep(int num, String text) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            shape: BoxShape.circle,
          ),
          child: Text("$num",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        const SizedBox(width: 12),
        Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w500, color: Colors.black87)),
      ],
    );
  }

  Widget _buildActivationCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C5F7C).withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                const Text("SCAN FOR DEVICE ID",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.grey)),
                const SizedBox(height: 16),
                Container(
                  height: 240,
                  width: 240,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: !isDeviceLoaded
                      ? const Center(child: CircularProgressIndicator())
                      : PdfPreview(
                          build: (format) => _buildQr(deviceId),
                          useActions: false,
                          loadingWidget: const SizedBox(),
                          scrollViewDecoration:
                              const BoxDecoration(color: Colors.white),
                        ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _copyDeviceId,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy, size: 16, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Text(
                          isDeviceLoaded
                              ? "${deviceId.substring(0, 8)}..."
                              : "Loading...",
                          style: TextStyle(
                              fontFamily: 'monospace', color: Colors.grey[800]),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 32),
          const Text("Enter New License Key",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 2,
            minLines: 1,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            decoration: InputDecoration(
              hintText: "Paste key starting with eyJ... or upload .lic file",
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF2C5F7C), width: 2),
              ),
            ),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[100]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(errorMessage!,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 13))),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : _handleFileUpload,
                  icon: const Icon(Icons.folder_open),
                  label: const Text("Upload File"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    side: const BorderSide(color: Color(0xFF2C5F7C)),
                    foregroundColor: const Color(0xFF2C5F7C),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleActivation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C5F7C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text("ACTIVATE LICENSE",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<Uint8List> _buildQr(String data) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: const PdfPageFormat(160, 160),
      margin: pw.EdgeInsets.zero,
      build: (context) => pw.Center(
        child: pw.BarcodeWidget(
          data: data,
          barcode: pw.Barcode.qrCode(),
          width: 160,
          height: 160,
          drawText: false,
        ),
      ),
    ));
    return pdf.save();
  }
}
