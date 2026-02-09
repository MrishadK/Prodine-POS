import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:file_picker/file_picker.dart'; // ✅ Required for extension

import '../providers/settings_provider.dart';
import '../models/restaurant_settings.dart';
import '../services/license_service.dart';
import '../screens/license_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _vatNumController;
  late TextEditingController _vatRateController;
  late TextEditingController _cashierController;

  DateTime? _expiryDate;
  bool _isLicensed = false;
  bool _isSaving = false;
  bool _showAdvancedSettings = false;
  String _appVersion = '1.0.0';
  String _appBuildNumber = '1';

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);

    _nameController = TextEditingController(text: settings.name);
    _addressController = TextEditingController(text: settings.address);
    _phoneController = TextEditingController(text: settings.phone);
    _vatNumController = TextEditingController(text: settings.vatNumber);
    _vatRateController = TextEditingController(
        text: (settings.vatRate * 100).toStringAsFixed(2));
    _cashierController = TextEditingController(text: settings.cashierName);

    _loadLicenseInfo();
    _loadPackageInfo();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _vatNumController.dispose();
    _vatRateController.dispose();
    _cashierController.dispose();
    super.dispose();
  }

  Future<void> _loadLicenseInfo() async {
    final date = await LicenseService.getLicenseExpiry();
    final licensed = await LicenseService.isAppLicensed();

    if (mounted) {
      setState(() {
        _expiryDate = date;
        _isLicensed = licensed;
      });
    }
  }

  Future<void> _loadPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = packageInfo.version;
          _appBuildNumber = packageInfo.buildNumber;
        });
      }
    } catch (e) {
      // Fallback
    }
  }

  // --- 🚀 NEW: EXTENSION LOGIC ---
  Future<void> _extendLicense() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['lic'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _isSaving = true);

        final file = File(result.files.single.path!);
        final content = await file.readAsString();

        final success = await LicenseService.updateLicense(content);

        setState(() => _isSaving = false);

        if (success) {
          await _loadLicenseInfo();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Subscription extended successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid License File.'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() => _isSaving = false);
    }
  }

  // --- LOGO LOGIC ---
  Future<void> _pickImage({bool fromCamera = false}) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );

    if (image != null) {
      ref.read(settingsProvider.notifier).updateLogo(image.path);
      setState(() {});
    }
  }

  void _removeLogo() {
    ref.read(settingsProvider.notifier).updateLogo("");
    setState(() {});
  }

  // --- SAVE SETTINGS ---
  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final newSettings = ref.read(settingsProvider).copyWith(
            name: _nameController.text.trim(),
            address: _addressController.text.trim(),
            phone: _phoneController.text.trim(),
            vatNumber: _vatNumController.text.trim(),
            vatRate: double.tryParse(_vatRateController.text) != null
                ? double.parse(_vatRateController.text) / 100
                : 0.0,
            cashierName: _cashierController.text.trim(),
          );

      await ref.read(settingsProvider.notifier).updateSettings(newSettings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Settings saved successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: const Text('Choose where to pick the logo from'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(fromCamera: true);
            },
            child: const Row(children: [
              Icon(Icons.camera_alt),
              SizedBox(width: 8),
              Text('Camera')
            ]),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(fromCamera: false);
            },
            child: const Row(children: [
              Icon(Icons.photo_library),
              SizedBox(width: 8),
              Text('Gallery')
            ]),
          ),
        ],
      ),
    );
  }

  // --- RESET LOGIC ---
  Future<void> _showStrictResetDialog() async {
    final confirmController = TextEditingController();
    bool canReset = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Text("Factory Reset License"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                      "This action will remove the license and restart the app.",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text("Type 'CONFIRM' below to proceed:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: confirmController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), hintText: "CONFIRM"),
                    onChanged: (value) =>
                        setDialogState(() => canReset = value == "CONFIRM"),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: canReset
                      ? () async {
                          Navigator.pop(context);
                          await _performLicenseReset();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white),
                  child: const Text("RESET LICENSE"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _performLicenseReset() async {
    await LicenseService.clearLicenseData();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LicenseScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('System Settings'),
        backgroundColor: const Color(0xFF2C5F7C),
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- [REMOVED STATUS CARD FROM HERE] ---

                  // Main Settings Card
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.settings,
                                  color: Color(0xFF2C5F7C)),
                              const SizedBox(width: 12),
                              const Text('Restaurant Configuration',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C5F7C))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 24),

                          // Logo
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: settings.logoPath != null &&
                                          settings.logoPath!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.file(
                                              File(settings.logoPath!),
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                      Icons.broken_image)),
                                        )
                                      : const Icon(Icons.store,
                                          size: 32, color: Colors.grey),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Receipt Logo',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          ElevatedButton.icon(
                                              onPressed: _showImageSourceDialog,
                                              icon: const Icon(Icons.upload,
                                                  size: 16),
                                              label: const Text('Upload'),
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFF2C5F7C),
                                                  foregroundColor:
                                                      Colors.white)),
                                          const SizedBox(width: 8),
                                          if (settings.logoPath != null &&
                                              settings.logoPath!.isNotEmpty)
                                            OutlinedButton.icon(
                                              onPressed: _removeLogo,
                                              icon: const Icon(Icons.delete,
                                                  size: 16),
                                              label: const Text('Remove'),
                                              style: OutlinedButton.styleFrom(
                                                  foregroundColor: Colors.red),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Fields
                          _buildField('Restaurant Name *', _nameController,
                              prefixIcon: Icons.business),
                          _buildField('Address *', _addressController,
                              maxLines: 2, prefixIcon: Icons.location_on),
                          _buildField('Phone Number *', _phoneController,
                              prefixIcon: Icons.phone),
                          _buildField('Cashier Name *', _cashierController,
                              prefixIcon: Icons.person),
                          Row(children: [
                            Expanded(
                                child: _buildField(
                                    'VAT Number *', _vatNumController,
                                    prefixIcon: Icons.numbers)),
                            const SizedBox(width: 16),
                            Expanded(
                                child: _buildField(
                                    'VAT Rate (%) *', _vatRateController,
                                    isNumber: true, prefixIcon: Icons.percent)),
                          ]),

                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveSettings,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2C5F7C),
                                  foregroundColor: Colors.white),
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : const Text('SAVE SETTINGS',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Advanced Settings Card
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Row(
                                  children: [
                                    Icon(Icons.security,
                                        color: Color(0xFF2C5F7C)),
                                    SizedBox(width: 12),
                                    Text('Advanced Settings',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2C5F7C))),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(_showAdvancedSettings
                                    ? Icons.expand_less
                                    : Icons.expand_more),
                                onPressed: () => setState(() =>
                                    _showAdvancedSettings =
                                        !_showAdvancedSettings),
                              ),
                            ],
                          ),
                          if (_showAdvancedSettings) ...[
                            const Divider(),
                            const SizedBox(height: 16),

                            // --- 🟢 EXTENSION SECTION ---
                            const Text('Subscription',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.blue.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.timer, color: Colors.blue),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _expiryDate != null
                                              ? "Valid until: ${DateFormat('yyyy-MM-dd').format(_expiryDate!)}"
                                              : "License Active",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const Text(
                                            "Upload a new file to extend.",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: _extendLicense,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white),
                                    child: const Text("Extend"),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // --- 🔴 RESET SECTION ---
                            const Text('Danger Zone',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.red)),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon:
                                    const Icon(Icons.delete_forever, size: 20),
                                label: const Text("Remove License & Reset App",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red)),
                                onPressed: _showStrictResetDialog,
                              ),
                            ),

                            const SizedBox(height: 16),
                            const Divider(),

                            // App Information
                            _buildInfoRow('App Version',
                                '$_appVersion (build $_appBuildNumber)'),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {bool isNumber = false, int maxLines = 1, IconData? prefixIcon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          SizedBox(
              width: 150,
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.grey))),
          const SizedBox(width: 8),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
        ]));
  }
}
