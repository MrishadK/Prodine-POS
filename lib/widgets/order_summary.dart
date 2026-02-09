import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/order_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/order_mode_provider.dart'; // ✅ IMPORT NEW PROVIDER
import '../services/printer_service.dart';

class OrderSummary extends ConsumerWidget {
  const OrderSummary({super.key});

  // ... (Keep your existing _showQuantityDialog and _updateQty functions here) ...
  void _showQuantityDialog(
      BuildContext context, WidgetRef ref, String itemId, double currentQty) {
    // ... (Paste your existing dialog code here) ...
    // For brevity, I am not repeating the full dialog code I gave you before.
    // Just keep it exactly as it was.
    final controller = TextEditingController(text: currentQty.toString());
    controller.selection =
        TextSelection(baseOffset: 0, extentOffset: controller.text.length);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adjust Quantity'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          onSubmitted: (value) => _updateQty(context, ref, itemId, value),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () => _updateQty(context, ref, itemId, controller.text),
            child: const Text('UPDATE'),
          ),
        ],
      ),
    );
  }

  void _updateQty(
      BuildContext context, WidgetRef ref, String itemId, String value) {
    if (value.startsWith('.')) value = '0$value';
    final newQty = double.tryParse(value);
    if (newQty != null) {
      ref.read(orderProvider.notifier).updateQuantity(itemId, newQty);
    }
    Navigator.pop(context);
  }
  // ... (End of dialog functions) ...

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderProvider);
    final orderMode = ref.watch(orderModeProvider); // ✅ WATCH MODE

    if (order == null || order.items.isEmpty) {
      return Container(
        color: Colors.white,
        child: const Center(
            child: Text('Select items to start order',
                style: TextStyle(color: Colors.grey, fontSize: 18))),
      );
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // ✅ NEW: ORDER MODE SELECTOR
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                _buildModeButton(ref, 'Dine-in', Icons.restaurant, orderMode),
                const SizedBox(width: 8),
                _buildModeButton(
                    ref, 'Take Away', Icons.shopping_bag, orderMode),
                const SizedBox(width: 8),
                _buildModeButton(
                    ref, 'Delivery', Icons.delivery_dining, orderMode),
              ],
            ),
          ),

          const Divider(height: 1),

          // --- TABLE HEADER ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            color: const Color(0xFFE3F2FD),
            child: const Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text('Nature of Goods',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 1,
                    child: Text('Price',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 1,
                    child: Text('Qty',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 1,
                    child: Text('Total',
                        textAlign: TextAlign.end,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 30),
              ],
            ),
          ),

          // --- ORDER ITEMS LIST ---
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: order.items.length,
              separatorBuilder: (c, i) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = order.items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Item Name
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.nameOverride.isNotEmpty
                              ? item.nameOverride
                              : item.menuItem.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                      // Price
                      Expanded(
                        flex: 1,
                        child: Text(item.priceOverride.toStringAsFixed(2),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 14)),
                      ),
                      // Qty
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: InkWell(
                            onTap: () => _showQuantityDialog(
                                context, ref, item.menuItem.id, item.quantity),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFFAFAFA),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text(item.quantityLabel,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C5F7C),
                                      fontSize: 14)),
                            ),
                          ),
                        ),
                      ),
                      // Total
                      Expanded(
                        flex: 1,
                        child: Text(
                          item.subtotal.toStringAsFixed(2),
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      // Delete
                      SizedBox(
                        width: 30,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.close,
                              color: Colors.red, size: 20),
                          onPressed: () => ref
                              .read(orderProvider.notifier)
                              .removeItem(item.menuItem.id),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),

          // --- FOOTER (TOTALS) ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                _buildRow('Total Taxable Amount', order.subtotal),
                _buildRow(
                    'Total VAT (${(order.vatRate * 100).toInt()}%)', order.vat),
                const Divider(),
                _buildRow('Total Amount Due', order.total, isTotal: true),
                const SizedBox(height: 16),
                Row(children: [
                  // Clear Button
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () =>
                            ref.read(orderProvider.notifier).clearOrder(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Icon(Icons.delete_outline, size: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Checkout Button
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final settings = ref.read(settingsProvider);
                          final currentMode =
                              ref.read(orderModeProvider); // Get Mode

                          // 1. Print (Pass Mode)
                          await ThermalPrinterService.printOrder(
                              order, PrintLayout.standard80mm, settings,
                              orderMode: currentMode); // ✅ Pass Mode Here

                          // 2. Complete
                          await ref
                              .read(orderProvider.notifier)
                              .completeOrder();

                          // 3. Reset Mode
                          ref.read(orderModeProvider.notifier).state =
                              'Dine-in';
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C5F7C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.print),
                        label: const Text('CHECKOUT & PRINT',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper for Mode Buttons
  Widget _buildModeButton(
      WidgetRef ref, String label, IconData icon, String currentMode) {
    final isSelected = currentMode == label;
    return Expanded(
      child: InkWell(
        onTap: () => ref.read(orderModeProvider.notifier).state = label,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2C5F7C) : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color:
                    isSelected ? const Color(0xFF2C5F7C) : Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 20,
                  color: isSelected ? Colors.white : Colors.grey[600]),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color: isTotal ? Colors.black : Colors.grey[700])),
        Text('${amount.toStringAsFixed(2)} SAR',
            style: TextStyle(
                fontSize: isTotal ? 20 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                color: isTotal ? Colors.green[700] : Colors.black)),
      ]),
    );
  }
}
