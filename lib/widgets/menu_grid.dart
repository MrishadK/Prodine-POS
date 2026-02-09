import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/menu_provider.dart';
import '../providers/order_provider.dart';
import '../models/menu_item.dart';

class MenuGrid extends ConsumerWidget {
  final String category;
  final String searchQuery; // ✅ NEW PARAMETER

  const MenuGrid({
    super.key,
    required this.category,
    required this.searchQuery, // ✅ REQUIRE IT
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allItems = ref.watch(menuProvider);

    // 🔥 FILTER LOGIC
    final items = allItems.where((item) {
      // 1. Check Category (Ignore if "All")
      final matchesCategory = category == 'All' || item.category == category;

      // 2. Check Search Text (Case insensitive)
      final matchesSearch =
          item.name.toLowerCase().contains(searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text("No items found", style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildMenuCard(context, ref, item);
      },
    );
  }

  Widget _buildMenuCard(BuildContext context, WidgetRef ref, MenuItem item) {
    // Generate a consistent color based on item name hash
    final colorIndex = item.name.codeUnitAt(0) % Colors.primaries.length;
    final accentColor = Colors.primaries[colorIndex].withOpacity(0.1);
    final iconColor = Colors.primaries[colorIndex];

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          ref.read(orderProvider.notifier).addItem(item);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Center(
                  child: Icon(Icons.lunch_dining, size: 40, color: iconColor),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.price.toStringAsFixed(2)} SAR',
                      style: const TextStyle(
                          color: Color(0xFF2C5F7C),
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
