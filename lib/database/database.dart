import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/order.dart' as model;
import '../models/menu_item.dart' as menu_model;
import '../models/order_item.dart' as item_model;
import 'dart:convert';

part 'database.g.dart';

@DataClassName('OrderRow')
class Orders extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceNumber => text()();
  TextColumn get ticketNumber => text()();

  DateTimeColumn get orderDate => dateTime()();
  TextColumn get cashier => text()();
  RealColumn get totalAmount => real()();
  RealColumn get vatRate => real()();
  TextColumn get itemsJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MenuItemRow')
class MenuItems extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get price => real()();
  TextColumn get category => text()();
  RealColumn get priceQuarter => real().nullable()();
  RealColumn get priceHalf => real().nullable()();
  RealColumn get priceThreeQuarter => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Orders, MenuItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2; // Bumped version

  // --- ORDER OPERATIONS ---
  Future<List<model.Order>> getAllOrders() async {
    final query = select(orders)
      ..orderBy([
        (t) => OrderingTerm(expression: t.orderDate, mode: OrderingMode.desc),
      ]);

    final result = await query.get();

    return result.map((row) {
      final List<dynamic> itemsList = jsonDecode(row.itemsJson);
      final items =
          itemsList.map((i) => item_model.OrderItem.fromJson(i)).toList();

      return model.Order(
        id: row.id,
        invoiceNumber: row.invoiceNumber,
        ticketNumber: row.ticketNumber,
        dateTime: row.orderDate,
        items: items,
        cashier: row.cashier,
        vatRate: row.vatRate,
      );
    }).toList();
  }

  Future<void> insertOrder(model.Order order) async {
    await into(orders).insert(
      OrdersCompanion.insert(
        id: order.id,
        invoiceNumber: order.invoiceNumber,
        ticketNumber: order.ticketNumber,
        orderDate: order.dateTime,
        cashier: order.cashier,
        totalAmount: order.total,
        vatRate: order.vatRate,
        itemsJson: jsonEncode(order.items.map((e) => e.toJson()).toList()),
      ),
    );
  }

  // ... (Menu operations remain the same) ...
  Future<List<menu_model.MenuItem>> getAllMenuItems() async {
    final result = await select(menuItems).get();
    return result
        .map((row) => menu_model.MenuItem(
              id: row.id,
              name: row.name,
              price: row.price,
              category: row.category,
              priceQuarter: row.priceQuarter,
              priceHalf: row.priceHalf,
              priceThreeQuarter: row.priceThreeQuarter,
            ))
        .toList();
  }

  Future<void> insertMenuItem(menu_model.MenuItem item) async {
    await into(menuItems).insert(
      MenuItemsCompanion.insert(
        id: item.id,
        name: item.name,
        price: item.price,
        category: item.category,
        priceQuarter: Value(item.priceQuarter),
        priceHalf: Value(item.priceHalf),
        priceThreeQuarter: Value(item.priceThreeQuarter),
      ),
    );
  }

  Future<void> deleteMenuItem(String id) async {
    await (delete(menuItems)..where((t) => t.id.equals(id))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'restaurant_pos_v2.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
