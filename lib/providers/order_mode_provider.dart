import 'package:flutter_riverpod/flutter_riverpod.dart';

// Default to 'Dine-in'
final orderModeProvider = StateProvider<String>((ref) => 'Dine-in');
