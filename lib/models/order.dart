import 'order_item.dart';

class Order {
  final String id;
  final String invoiceNumber;
  final String ticketNumber;
  final List<OrderItem> items;
  final DateTime dateTime;
  final String cashier;
  final double vatRate;
  final String orderMode; // ✅ NEW FIELD

  Order({
    required this.id,
    required this.invoiceNumber,
    required this.ticketNumber,
    required this.items,
    required this.dateTime,
    required this.cashier,
    required this.vatRate,
    this.orderMode = 'Dine-in', // ✅ Default value
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);
  double get vat => subtotal * vatRate;
  double get total => subtotal + vat;

  Order copyWith({
    String? id,
    String? invoiceNumber,
    String? ticketNumber,
    List<OrderItem>? items,
    DateTime? dateTime,
    String? cashier,
    double? vatRate,
    String? orderMode, // ✅
  }) {
    return Order(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      items: items ?? this.items,
      dateTime: dateTime ?? this.dateTime,
      cashier: cashier ?? this.cashier,
      vatRate: vatRate ?? this.vatRate,
      orderMode: orderMode ?? this.orderMode, // ✅
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'ticketNumber': ticketNumber,
      'items': items.map((x) => x.toJson()).toList(),
      'dateTime': dateTime.toIso8601String(),
      'cashier': cashier,
      'vatRate': vatRate,
      'orderMode': orderMode, // ✅ Save it
    };
  }

  factory Order.fromJson(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      invoiceNumber: map['invoiceNumber'] ?? '',
      ticketNumber: map['ticketNumber'] ?? '',
      items: List<OrderItem>.from(
          map['items']?.map((x) => OrderItem.fromJson(x)) ?? []),
      dateTime: DateTime.parse(map['dateTime']),
      cashier: map['cashier'] ?? '',
      vatRate: map['vatRate']?.toDouble() ?? 0.15,
      orderMode: map['orderMode'] ??
          'Dine-in', // ✅ Load it (fallback to Dine-in for old orders)
    );
  }
}
