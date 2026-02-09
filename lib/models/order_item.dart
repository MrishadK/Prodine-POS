import 'menu_item.dart';

class OrderItem {
  final String id;
  final MenuItem menuItem;
  final double quantity; // This must be double
  final String nameOverride;
  final double priceOverride;

  OrderItem({
    required this.id,
    required this.menuItem,
    required this.quantity,
    String? nameOverride,
    double? priceOverride,
  })  : nameOverride = nameOverride ?? menuItem.name,
        priceOverride = priceOverride ?? menuItem.price;

  double get subtotal => priceOverride * quantity;

  // --- ADD THIS COPYWITH METHOD ---
  OrderItem copyWith({
    String? id,
    MenuItem? menuItem,
    double? quantity,
    String? nameOverride,
    double? priceOverride,
  }) {
    return OrderItem(
      id: id ?? this.id,
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      nameOverride: nameOverride ?? this.nameOverride,
      priceOverride: priceOverride ?? this.priceOverride,
    );
  }
  // -------------------------------

  String get quantityLabel {
    if (quantity == 1.0) return "1";
    if (quantity == 0.5) return "½";
    if (quantity == 0.25) return "¼";
    if (quantity == 0.75) return "¾";
    // Clean up decimals like 2.0 -> 2
    return quantity
        .toStringAsFixed(2)
        .replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
  }

  // ToJson and FromJson (keep as is or copy below if missing)
  Map<String, dynamic> toJson() => {
        'id': id,
        'menuItem': menuItem.id,
        'quantity': quantity,
        'nameOverride': nameOverride,
        'priceOverride': priceOverride,
        'itemDetails': {
          'name': menuItem.name,
          'price': menuItem.price,
          'category': menuItem.category,
        }
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final details = json['itemDetails'] ?? {};
    return OrderItem(
      id: json['id'],
      menuItem: MenuItem(
        id: json['menuItem'],
        name: details['name'] ?? 'Unknown',
        price: (details['price'] ?? 0).toDouble(),
        category: details['category'] ?? 'General',
      ),
      quantity: (json['quantity'] as num).toDouble(),
      nameOverride: json['nameOverride'],
      priceOverride: (json['priceOverride'] as num).toDouble(),
    );
  }
}
