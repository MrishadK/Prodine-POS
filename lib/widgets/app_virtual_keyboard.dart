import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';

class AppVirtualKeyboard extends StatefulWidget {
  final VoidCallback onClose;

  const AppVirtualKeyboard({super.key, required this.onClose});

  @override
  State<AppVirtualKeyboard> createState() => _AppVirtualKeyboardState();
}

class _AppVirtualKeyboardState extends State<AppVirtualKeyboard> {
  // Toggle between generic (text) and numeric
  VirtualKeyboardType _type = VirtualKeyboardType.Alphanumeric;
  bool _isShiftEnabled = false;

  void _onKeyPress(VirtualKeyboardKey key) {
    if (key.keyType == VirtualKeyboardKeyType.String) {
      // 📝 Insert Text into Active Field
      SystemChannels.textInput.invokeMethod('TextInput.commitText', key.text);
    } else if (key.action == VirtualKeyboardKeyAction.Backspace) {
      // ⌫ Delete Character
      // Delete 1 character before cursor, 0 after
      SystemChannels.textInput
          .invokeMethod('TextInput.deleteSurroundingText', [1, 0]);
    } else if (key.action == VirtualKeyboardKeyAction.Return) {
      // ⏎ Enter Key
      SystemChannels.textInput
          .invokeMethod('TextInput.performAction', 'TextInputAction.done');
    } else if (key.action == VirtualKeyboardKeyAction.Shift) {
      setState(() {
        _isShiftEnabled = !_isShiftEnabled;
      });
    } else if (key.action == VirtualKeyboardKeyAction.Space) {
      SystemChannels.textInput.invokeMethod('TextInput.commitText', ' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 20,
      child: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A4C), // Dark Sidebar Color
          border:
              const Border(top: BorderSide(color: Color(0xFF2C5F7C), width: 2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- HEADER (Close & Type Toggle) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Virtual Keyboard",
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      // Toggle Layout Button
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _type = _type == VirtualKeyboardType.Numeric
                                ? VirtualKeyboardType.Alphanumeric
                                : VirtualKeyboardType.Numeric;
                          });
                        },
                        icon: Icon(
                          _type == VirtualKeyboardType.Numeric
                              ? Icons.abc
                              : Icons.onetwothree,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: Text(
                          _type == VirtualKeyboardType.Numeric ? "ABC" : "123",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Close Button
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.redAccent),
                        onPressed: widget.onClose,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- KEYBOARD ---
            // ✅ FIXED: Removed 'keyDecoration' and 'keyRowDecoration'
            // ✅ FIXED: Changed 'preKeyPress' to 'onKeyPress'
            Container(
              color: Colors.black12, // Slight background for keys
              child: VirtualKeyboard(
                height: 300,
                textColor: Colors.white,
                fontSize: 20,
                type: _type,
                alwaysCaps: _isShiftEnabled,
                preKeyPress: _onKeyPress,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
