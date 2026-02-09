import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../widgets/sidebar_menu.dart';
import '../providers/order_provider.dart';
import '../services/license_service.dart';

import 'pos_screen.dart';
import 'add_food_screen.dart';
import 'history_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    POSScreen(),
    AddFoodScreen(),
    HistoryScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLicenseExpiry();
    });
  }

  Future<void> _checkLicenseExpiry() async {
    final expiry = await LicenseService.getLicenseExpiry();
    if (expiry != null) {
      final daysLeft = expiry.difference(DateTime.now()).inDays;
      if (daysLeft >= 0 && daysLeft <= 3) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("⚠️ License Expiring Soon"),
            content: Text(
                "Your license expires in $daysLeft days. Please contact admin to renew."),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"))
            ],
          ),
        );
      }
    }
  }

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  void _onNewOrder() {
    // Just switch to POS screen; don't reset order automatically
    setState(() => _selectedIndex = 0);
  }

  Future<void> _toggleFullScreen() async {
    bool isFullScreen = await windowManager.isFullScreen();
    await windowManager.setFullScreen(!isFullScreen);
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f11): _toggleFullScreen,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: const Color(0xFFE8EAF0),
          body: Row(
            children: [
              // ✅ FIX: Removed onHistory and onSettings
              SidebarMenu(
                selectedIndex: _selectedIndex,
                onItemSelected: _onTabSelected,
                onNewOrder: _onNewOrder,
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeOutQuart,
                  switchOutCurve: Curves.easeInQuart,
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    final offsetAnimation = Tween<Offset>(
                      begin: const Offset(0.0, 0.05),
                      end: Offset.zero,
                    ).animate(animation);

                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                          position: offsetAnimation, child: child),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey<int>(_selectedIndex),
                    child: Container(
                      color: const Color(0xFFE8EAF0),
                      child: _pages[_selectedIndex],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
