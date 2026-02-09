import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/menu_item.dart';
import 'history_provider.dart';
import 'settings_provider.dart';
import 'order_mode_provider.dart';

class OrderNotifier extends StateNotifier<Order?> {
  final Ref ref;

  OrderNotifier(this.ref) : super(null);

  // ✅ PREVIEW LOGIC: Calculates what the ticket number SHOULD be.
  // We do NOT save to SharedPreferences here. We only peek at the values.
  Future<void> createNewOrder() async {
    final settings = ref.read(settingsProvider);
    final prefs = await SharedPreferences.getInstance();

    // 1. Generate Invoice Number
    String randomInvoiceId = (10000000 + Random().nextInt(90000000)).toString();

    // 2. PREVIEW Ticket Number
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final savedDate = prefs.getString('daily_ticket_date') ?? '';
    final lastTicket = prefs.getInt('daily_ticket_seq') ?? 0;

    int nextTicket;

    if (savedDate != todayStr) {
      // 🟢 NEW DAY: The first ticket must be 1
      nextTicket = 1;
    } else {
      // 🔵 SAME DAY: Continue from last number
      nextTicket = lastTicket + 1;
    }

    final ticketStr = nextTicket.toString().padLeft(3, '0');

    // 3. Create Order State
    state = Order(
      id: const Uuid().v4(),
      invoiceNumber: randomInvoiceId,
      ticketNumber: ticketStr, // Shows "001" on UI
      items: [],
      dateTime: DateTime.now(),
      cashier: settings.cashierName,
      vatRate: settings.vatRate,
    );
  }

  // ... (Keep existing _calculateAdjustedPrice, addItem, updateQuantity, removeItem methods same as before) ...
  double _calculateAdjustedPrice(MenuItem item, double quantity) {
    if (quantity == 0.25 && item.priceQuarter != null)
      return item.priceQuarter! / 0.25;
    if (quantity == 0.5 && item.priceHalf != null) return item.priceHalf! / 0.5;
    if (quantity == 0.75 && item.priceThreeQuarter != null)
      return item.priceThreeQuarter! / 0.75;
    return item.price;
  }

  Future<void> addItem(MenuItem menuItem, {double quantity = 1.0}) async {
    if (state == null) {
      await createNewOrder();
    }
    // ... (rest of addItem logic remains exactly the same) ...
    final existingIndex =
        state!.items.indexWhere((item) => item.menuItem.id == menuItem.id);
    if (existingIndex != -1) {
      final existingItem = state!.items[existingIndex];
      updateQuantity(menuItem.id, existingItem.quantity + quantity);
    } else {
      String nameSuffix = "";
      if (quantity == 0.5)
        nameSuffix = " (Half)";
      else if (quantity == 0.25)
        nameSuffix = " (Quarter)";
      else if (quantity == 0.75) nameSuffix = " (3/4)";

      double finalPrice = _calculateAdjustedPrice(menuItem, quantity);

      state = state?.copyWith(
        items: [
          ...state!.items,
          OrderItem(
            id: const Uuid().v4(),
            menuItem: menuItem,
            quantity: quantity,
            nameOverride: "${menuItem.name}$nameSuffix",
            priceOverride: finalPrice,
          ),
        ],
      );
    }
  }

  void updateQuantity(String menuItemId, double quantity) {
    if (state == null) return;
    if (quantity <= 0) {
      removeItem(menuItemId);
      return;
    }
    final updatedItems = state!.items.map((item) {
      if (item.menuItem.id == menuItemId) {
        double newPrice = _calculateAdjustedPrice(item.menuItem, quantity);
        String baseName = item.menuItem.name;
        String newName = baseName;
        if (quantity == 0.5)
          newName = "$baseName (Half)";
        else if (quantity == 0.25)
          newName = "$baseName (Quarter)";
        else if (quantity == 0.75) newName = "$baseName (3/4)";

        return item.copyWith(
          quantity: quantity,
          priceOverride: newPrice,
          nameOverride: newName,
        );
      }
      return item;
    }).toList();
    state = state!.copyWith(items: updatedItems);
  }

  void removeItem(String menuItemId) {
    if (state == null) return;
    final updatedItems =
        state!.items.where((item) => item.menuItem.id != menuItemId).toList();
    state = state!.copyWith(items: updatedItems);
  }

  void clearOrder() {
    state = null;
  }

  // ✅ COMMIT LOGIC: This is where we strictly enforce "Start from 1"
  Future<Order?> completeOrder() async {
    if (state == null) return null;

    final prefs = await SharedPreferences.getInstance();
    final currentMode = ref.read(orderModeProvider);

    // 1. Calculate the FINAL ticket number again to be safe
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final savedDate = prefs.getString('daily_ticket_date') ?? '';
    final lastTicket = prefs.getInt('daily_ticket_seq') ?? 0;

    int finalTicketNumber;

    if (savedDate != todayStr) {
      // 🟢 NEW DAY: FORCE RESET TO 1
      finalTicketNumber = 1;
      await prefs.setString('daily_ticket_date', todayStr);
    } else {
      // 🔵 SAME DAY: Increment
      finalTicketNumber = lastTicket + 1;
    }

    // 2. Save the new number permanently
    await prefs.setInt('daily_ticket_seq', finalTicketNumber);

    // 3. Update the Order Object with the FINALIZED number
    // (This overrides whatever was shown in the preview if the day changed mid-order)
    final completedOrder = state!.copyWith(
      orderMode: currentMode,
      ticketNumber: finalTicketNumber.toString().padLeft(3, '0'),
    );

    // 4. Add to History
    await ref.read(historyProvider.notifier).addOrder(completedOrder);

    state = null;
    return completedOrder;
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, Order?>((ref) {
  return OrderNotifier(ref);
});
