import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';

final historyProvider = StateNotifierProvider<HistoryNotifier, List<Order>>((
  ref,
) {
  return HistoryNotifier();
});

class HistoryNotifier extends StateNotifier<List<Order>> {
  HistoryNotifier() : super([]) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? historyJson = prefs.getStringList('order_history');
    if (historyJson != null) {
      state = historyJson.map((str) => Order.fromJson(jsonDecode(str))).toList()
        // Sort by date descending (newest first)
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    }
  }

  Future<void> addOrder(Order order) async {
    final newState = [order, ...state];
    state = newState;
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList =
        state.map((o) => jsonEncode(o.toJson())).toList();
    await prefs.setStringList('order_history', jsonList);
  }
}
