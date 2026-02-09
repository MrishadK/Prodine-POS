import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:window_manager/window_manager.dart';

import 'screens/main_screen.dart';
import 'screens/license_screen.dart';
import 'database/database.dart';
import 'services/license_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 720),
    minimumSize: Size(1280, 700),
    center: true,
    backgroundColor: Color(0xFFE8EAF0),
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  final bool isLicensed = await LicenseService.isAppLicensed();

  runApp(
    ProviderScope(
      child: RestaurantPOSApp(isLicensed: isLicensed),
    ),
  );
}

class RestaurantPOSApp extends StatelessWidget {
  final bool isLicensed;

  const RestaurantPOSApp({super.key, required this.isLicensed});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProDine POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor:
            const Color(0xFFE8EAF0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C5F7C),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      builder: (context, child) => Material(
        type: MaterialType.transparency,
        child: child!,
      ),
      home: isLicensed ? const MainScreen() : const LicenseScreen(),
    );
  }
}
