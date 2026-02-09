import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/menu_item.dart';

// --- 1. MENU ITEMS PROVIDER ---
final menuProvider = StateNotifierProvider<MenuNotifier, List<MenuItem>>((ref) {
  return MenuNotifier();
});

class MenuNotifier extends StateNotifier<List<MenuItem>> {
  MenuNotifier() : super([]) {
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    final prefs = await SharedPreferences.getInstance();
    final String? menuJson = prefs.getString('saved_menu');
    if (menuJson != null) {
      final List<dynamic> decoded = jsonDecode(menuJson);
      state = decoded.map((item) => MenuItem.fromJson(item)).toList();
    }
  }

  Future<void> addMenuItem(MenuItem item) async {
    state = [...state, item];
    await _saveMenu();
  }

  Future<void> deleteItem(String id) async {
    state = state.where((item) => item.id != id).toList();
    await _saveMenu();
  }

  // Delete all items belonging to a specific category
  Future<void> deleteItemsInCategory(String category) async {
    state = state.where((item) => item.category != category).toList();
    await _saveMenu();
  }

  Future<void> _saveMenu() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(state.map((i) => i.toJson()).toList());
    await prefs.setString('saved_menu', encoded);
  }
}

// --- 2. CATEGORIES PROVIDER (FIXED) ---
// This ensures categories exist even without items!
final categoriesProvider =
    StateNotifierProvider<CategoryNotifier, List<String>>((ref) {
  return CategoryNotifier();
});

class CategoryNotifier extends StateNotifier<List<String>> {
  CategoryNotifier() : super([]) {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? saved = prefs.getStringList('saved_categories');

    // Start empty so user must add their own. No defaults.
    if (saved != null) {
      state = saved;
    } else {
      state = [];
    }
  }

  Future<void> addCategory(String category) async {
    if (!state.contains(category)) {
      state = [...state, category];
      await _saveCategories();
    }
  }

  Future<void> removeCategory(String category) async {
    state = state.where((c) => c != category).toList();
    await _saveCategories();
  }

  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saved_categories', state);
  }
}
