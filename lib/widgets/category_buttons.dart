import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/menu_provider.dart';

class CategoryButtons extends ConsumerWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryButtons({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbCategories = ref.watch(categoriesProvider);
    final categories = ['All', ...dbCategories];

    final scrollController = ScrollController();

    return SizedBox(
      height: 90,
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            // Handle mouse wheel scrolling
            const scrollSensitivity = 40.0;
            final newOffset = scrollController.offset +
                (event.scrollDelta.dy * scrollSensitivity);

            if (newOffset < 0) {
              scrollController.jumpTo(0);
            } else if (newOffset > scrollController.position.maxScrollExtent) {
              scrollController
                  .jumpTo(scrollController.position.maxScrollExtent);
            } else {
              scrollController.jumpTo(newOffset);
            }
          }
        },
        child: RawScrollbar(
          controller: scrollController,
          thumbVisibility: true,
          trackVisibility: true,
          thumbColor: Colors.grey[600],
          trackColor: Colors.grey[200],
          thickness: 8,
          radius: const Radius.circular(4),
          minThumbLength: 50,
          scrollbarOrientation: ScrollbarOrientation.bottom,
          // ✅ Important: This makes the scrollbar work properly
          notificationPredicate: (notification) => notification.depth == 0,
          child: SingleChildScrollView(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                const SizedBox(width: 8),
                ...List.generate(categories.length, (index) {
                  final category = categories[index];
                  final isSelected = category == selectedCategory;

                  Color bgColor;
                  if (category == 'All') {
                    bgColor = const Color(0xFF2C5F7C);
                  } else {
                    switch (index % 3) {
                      case 0:
                        bgColor = const Color(0xFFE67E22);
                        break;
                      case 1:
                        bgColor = const Color(0xFFF39C12);
                        break;
                      default:
                        bgColor = const Color(0xFFD35400);
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => onCategorySelected(category),
                      child: Container(
                        width: 140,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected ? Colors.green.shade600 : bgColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 2)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            category,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
