import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../services/license_service.dart';
import 'main_screen.dart';

class LicenseScreen extends StatefulWidget {
  const LicenseScreen({super.key});

  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  final TextEditingController _keyController = TextEditingController();

  String _deviceId = "Loading...";
  bool _isDeviceLoaded = false;
  bool _isLoading = false;
  bool _isCopied = false;
  bool _isExpired = false;
  DateTime? _existingExpiry;

  String? _errorMessage;
  String? _successMessage;
  String? _selectedFileName;
  int? _selectedFileSize;
  bool _showManualInput = false;

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialState() async {
    try {
      final id = await LicenseService.getDeviceId();
      final expired = await LicenseService.isLicenseExpired();
      final expiry = await LicenseService.getLicenseExpiry();

      if (mounted) {
        setState(() {
          _deviceId = id;
          _isDeviceLoaded = true;
          _isExpired = expired;
          _existingExpiry = expiry;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _deviceId = "Error loading ID");
      }
    }
  }

  // --- ACTIONS ---

  void _copyDeviceId() {
    if (!_isDeviceLoaded) return;
    Clipboard.setData(ClipboardData(text: _deviceId));
    setState(() => _isCopied = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text("Device ID copied to clipboard!"),
          ],
        ),
        backgroundColor: Color(0xFF1E3A4C),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  Future<void> _exportDeviceId() async {
    if (!_isDeviceLoaded) return;
    try {
      final user = Platform.environment['USERNAME'] ?? 'user';
      final pc = Platform.environment['COMPUTERNAME'] ?? 'pc';
      final nowFormatted =
          DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

      final content = """
==================================================
ProDine POS - Workstation Activation Details
==================================================
Date & Time    : $nowFormatted
Workstation PC : $pc
Windows User   : $user
Operating Sys  : Windows Desktop

DEVICE ID (Machine Fingerprint):
$_deviceId
==================================================
Send this file or copy the Device ID to your
system administrator to generate your license key.
==================================================
""";

      final String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Workstation Details',
        fileName: 'prodine_workstation_id.txt',
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (outputPath != null) {
        final file = File(outputPath);
        await file.writeAsString(content);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Workstation details saved successfully!"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save file: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleFilePick() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['lic', 'txt', 'dat'],
        dialogTitle: 'Select ProDine License File',
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final file = File(filePath);
        final content = await file.readAsString();

        setState(() {
          _keyController.text = content.trim();
          _selectedFileName = result.files.single.name;
          _selectedFileSize = result.files.single.size;
          _errorMessage = null;
          _successMessage = null;
        });

        // Automatically trigger verification on upload for convenience
        await _handleActivation();
      }
    } catch (e) {
      setState(() => _errorMessage = "Error opening file: $e");
    }
  }

  void _clearSelectedFile() {
    setState(() {
      _selectedFileName = null;
      _selectedFileSize = null;
      _keyController.clear();
      _errorMessage = null;
      _successMessage = null;
    });
  }

  Future<void> _handleActivation() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      setState(() {
        _errorMessage =
            "Please upload a license file (.lic) or paste a license key.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 350));

    final result = await LicenseService.updateLicenseDetailed(key);

    if (!mounted) return;

    if (result.isValid) {
      final expiryStr = result.expiryDate != null
          ? DateFormat('dd MMM yyyy').format(result.expiryDate!)
          : "Permanent";

      setState(() {
        _isLoading = false;
        _errorMessage = null;
        _successMessage =
            "License Verified! Tier: ${result.type ?? 'PRO'} • Valid until: $expiryStr";
      });

      // Brief visual confirmation before transitioning
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      _navigateToMain();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result.message;
        _successMessage = null;
      });
    }
  }

  Future<void> _recheckExistingLicense() async {
    setState(() => _isLoading = true);
    final isValid = await LicenseService.isAppLicensed();
    if (!mounted) return;

    if (isValid) {
      _navigateToMain();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = "No active valid license found on this workstation.";
      });
    }
  }

  void _navigateToMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  // --- UI BUILDING BLOCKS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EAF0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120, minHeight: 560),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // LEFT COLUMN: Modern Branded Sidebar
                      Expanded(
                        flex: 4,
                        child: _buildBrandedSidebar(),
                      ),
                      // RIGHT COLUMN: Activation Workspace
                      Expanded(
                        flex: 6,
                        child: _buildActivationPanel(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- LEFT BRANDED SIDEBAR ---
  Widget _buildBrandedSidebar() {
    final pcName = Platform.environment['COMPUTERNAME'] ?? 'Windows PC';
    final userName = Platform.environment['USERNAME'] ?? 'Cashier';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A4C),
            Color(0xFF142734),
          ],
        ),
      ),
      padding: const EdgeInsets.all(36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Header & Logo
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Image.asset(
                      'assets/logo.png',
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.restaurant_menu,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ProDine POS",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        "Enterprise Restaurant Terminal",
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Status Pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isExpired
                      ? const Color(0xFFD32F2F).withValues(alpha: 0.2)
                      : const Color(0xFF0288D1).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isExpired
                        ? const Color(0xFFFF5252).withValues(alpha: 0.4)
                        : const Color(0xFF4FC3F7).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isExpired
                          ? Icons.warning_amber_rounded
                          : Icons.verified_user_outlined,
                      size: 16,
                      color: _isExpired
                          ? const Color(0xFFFF8A80)
                          : const Color(0xFF81D4FA),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isExpired
                          ? "SUBSCRIPTION EXPIRED"
                          : "WORKSTATION UNLICENSED",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                        color: _isExpired
                            ? const Color(0xFFFF8A80)
                            : const Color(0xFF81D4FA),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              Text(
                _isExpired
                    ? "Renew Your License"
                    : "Activate This\nTerminal",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _isExpired
                    ? "Your terminal's operating license ended${_existingExpiry != null ? ' on ${DateFormat('dd MMM yyyy').format(_existingExpiry!)}' : ''}. Upload a renewed license file (.lic) to continue taking orders."
                    : "This POS workstation requires a digitally signed license file from your system administrator before taking orders.",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              // Step Workflow
              _buildStepItem(
                step: 1,
                title: "Copy Workstation ID",
                subtitle: "Use the QR code or click Copy ID",
              ),
              const SizedBox(height: 14),
              _buildStepItem(
                step: 2,
                title: "Request License File",
                subtitle: "Send ID to your admin or vendor",
              ),
              const SizedBox(height: 14),
              _buildStepItem(
                step: 3,
                title: "Upload & Activate",
                subtitle: "Select your signed .lic file to unlock",
              ),
            ],
          ),

          // Workstation Info Footer
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                const Icon(Icons.desktop_windows_outlined,
                    color: Colors.white70, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pcName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        "User: $userName • Windows Native",
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required int step,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Text(
            "$step",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- RIGHT ACTIVATION WORKSPACE ---
  Widget _buildActivationPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Workstation Activation",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A4C),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Match your hardware ID and upload your license",
                    style: TextStyle(fontSize: 12.5, color: Colors.black54),
                  ),
                ],
              ),
              IconButton(
                tooltip: "Re-check Current License",
                onPressed: _isLoading ? null : _recheckExistingLicense,
                icon: const Icon(Icons.refresh_rounded, color: Color(0xFF2C5F7C)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 1. Hardware Fingerprint Card (QR + ID + Copy)
          _buildHardwareIdCard(),

          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 20),

          // 2. Upload / Input Area
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "License File or Key",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1E3A4C),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() => _showManualInput = !_showManualInput);
                },
                child: Text(
                  _showManualInput
                      ? "← Back to File Upload"
                      : "Paste key manually",
                  style: const TextStyle(
                    color: Color(0xFF2C5F7C),
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (!_showManualInput)
            _buildFileUploadDropzone()
          else
            _buildManualKeyTextField(),

          // 3. Alerts (Error or Success)
          if (_errorMessage != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFCDD2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: Color(0xFFD32F2F), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFC62828),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (_successMessage != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFC8E6C9)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF2E7D32), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _successMessage!,
                      style: const TextStyle(
                        color: Color(0xFF1B5E20),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // 4. Action Row (Activate Button)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleActivation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C5F7C),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      disabledBackgroundColor:
                          const Color(0xFF2C5F7C).withValues(alpha: 0.6),
                    ),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.lock_open_rounded, size: 20),
                    label: Text(
                      _isLoading ? "VERIFYING..." : "ACTIVATE WORKSTATION",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- HARDWARE ID & QR CODE CARD ---
  Widget _buildHardwareIdCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // QR Preview
          Container(
            width: 108,
            height: 108,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: !_isDeviceLoaded
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: IgnorePointer(
                      child: PdfPreview(
                        build: (format) => _buildQrPdf(_deviceId),
                        useActions: false,
                        canChangePageFormat: false,
                        canChangeOrientation: false,
                        canDebug: false,
                        maxPageWidth: 100,
                        loadingWidget: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        scrollViewDecoration:
                            const BoxDecoration(color: Colors.white),
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 18),

          // ID Info & Buttons
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "UNIQUE HARDWARE ID",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _isDeviceLoaded ? _deviceId : "Generating fingerprint...",
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey.shade800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        tooltip: "Copy full ID",
                        icon: Icon(
                          _isCopied ? Icons.check : Icons.copy_rounded,
                          size: 16,
                          color: _isCopied ? Colors.green : const Color(0xFF2C5F7C),
                        ),
                        onPressed: _copyDeviceId,
                        splashRadius: 18,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _copyDeviceId,
                      icon: Icon(
                        _isCopied ? Icons.check : Icons.content_copy_rounded,
                        size: 14,
                        color: _isCopied ? Colors.green : const Color(0xFF2C5F7C),
                      ),
                      label: Text(
                        _isCopied ? "Copied!" : "Copy Full ID",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              _isCopied ? Colors.green : const Color(0xFF2C5F7C),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        side: BorderSide(
                          color: _isCopied
                              ? Colors.green
                              : const Color(0xFF2C5F7C).withValues(alpha: 0.4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: _exportDeviceId,
                      icon: const Icon(Icons.download_rounded,
                          size: 14, color: Color(0xFF2C5F7C)),
                      label: const Text(
                        "Save Info (.txt)",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C5F7C),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        side: BorderSide(
                          color: const Color(0xFF2C5F7C).withValues(alpha: 0.4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- FILE UPLOAD DROPZONE ---
  Widget _buildFileUploadDropzone() {
    final bool hasFile = _selectedFileName != null;

    return InkWell(
      onTap: _isLoading ? null : _handleFilePick,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: hasFile
              ? const Color(0xFFE8F5E9).withValues(alpha: 0.5)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasFile ? const Color(0xFF81C784) : Colors.grey.shade300,
            style: hasFile ? BorderStyle.solid : BorderStyle.solid,
            width: hasFile ? 1.5 : 1.2,
          ),
        ),
        child: hasFile
            ? Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.insert_drive_file_rounded,
                        color: Color(0xFF2E7D32), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedFileName!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            color: Color(0xFF1B5E20),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${(_selectedFileSize! / 1024).toStringAsFixed(1)} KB • Ready to activate",
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF388E3C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _clearSelectedFile,
                    icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                    label: const Text(
                      "Remove",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C5F7C).withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cloud_upload_outlined,
                        color: Color(0xFF2C5F7C), size: 24),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Click to select your .lic or .txt license file",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: Color(0xFF1E3A4C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Provided by your administrator after registering your Device ID",
                    style: TextStyle(fontSize: 11.5, color: Colors.black45),
                  ),
                ],
              ),
      ),
    );
  }

  // --- MANUAL KEY TEXTFIELD ---
  Widget _buildManualKeyTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _keyController,
          maxLines: 3,
          minLines: 2,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          decoration: InputDecoration(
            hintText: "Paste encrypted license token (starts with gAAAAAB...)",
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2C5F7C), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // --- QR GENERATION ---
  Future<Uint8List> _buildQrPdf(String data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
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
      ),
    );
    return pdf.save();
  }
}
