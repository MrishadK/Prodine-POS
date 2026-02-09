// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $OrdersTable extends Orders with TableInfo<$OrdersTable, OrderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _invoiceNumberMeta =
      const VerificationMeta('invoiceNumber');
  @override
  late final GeneratedColumn<String> invoiceNumber = GeneratedColumn<String>(
      'invoice_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ticketNumberMeta =
      const VerificationMeta('ticketNumber');
  @override
  late final GeneratedColumn<String> ticketNumber = GeneratedColumn<String>(
      'ticket_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderDateMeta =
      const VerificationMeta('orderDate');
  @override
  late final GeneratedColumn<DateTime> orderDate = GeneratedColumn<DateTime>(
      'order_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _cashierMeta =
      const VerificationMeta('cashier');
  @override
  late final GeneratedColumn<String> cashier = GeneratedColumn<String>(
      'cashier', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalAmountMeta =
      const VerificationMeta('totalAmount');
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
      'total_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _vatRateMeta =
      const VerificationMeta('vatRate');
  @override
  late final GeneratedColumn<double> vatRate = GeneratedColumn<double>(
      'vat_rate', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _itemsJsonMeta =
      const VerificationMeta('itemsJson');
  @override
  late final GeneratedColumn<String> itemsJson = GeneratedColumn<String>(
      'items_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        invoiceNumber,
        ticketNumber,
        orderDate,
        cashier,
        totalAmount,
        vatRate,
        itemsJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'orders';
  @override
  VerificationContext validateIntegrity(Insertable<OrderRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('invoice_number')) {
      context.handle(
          _invoiceNumberMeta,
          invoiceNumber.isAcceptableOrUnknown(
              data['invoice_number']!, _invoiceNumberMeta));
    } else if (isInserting) {
      context.missing(_invoiceNumberMeta);
    }
    if (data.containsKey('ticket_number')) {
      context.handle(
          _ticketNumberMeta,
          ticketNumber.isAcceptableOrUnknown(
              data['ticket_number']!, _ticketNumberMeta));
    } else if (isInserting) {
      context.missing(_ticketNumberMeta);
    }
    if (data.containsKey('order_date')) {
      context.handle(_orderDateMeta,
          orderDate.isAcceptableOrUnknown(data['order_date']!, _orderDateMeta));
    } else if (isInserting) {
      context.missing(_orderDateMeta);
    }
    if (data.containsKey('cashier')) {
      context.handle(_cashierMeta,
          cashier.isAcceptableOrUnknown(data['cashier']!, _cashierMeta));
    } else if (isInserting) {
      context.missing(_cashierMeta);
    }
    if (data.containsKey('total_amount')) {
      context.handle(
          _totalAmountMeta,
          totalAmount.isAcceptableOrUnknown(
              data['total_amount']!, _totalAmountMeta));
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('vat_rate')) {
      context.handle(_vatRateMeta,
          vatRate.isAcceptableOrUnknown(data['vat_rate']!, _vatRateMeta));
    } else if (isInserting) {
      context.missing(_vatRateMeta);
    }
    if (data.containsKey('items_json')) {
      context.handle(_itemsJsonMeta,
          itemsJson.isAcceptableOrUnknown(data['items_json']!, _itemsJsonMeta));
    } else if (isInserting) {
      context.missing(_itemsJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      invoiceNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_number'])!,
      ticketNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ticket_number'])!,
      orderDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}order_date'])!,
      cashier: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cashier'])!,
      totalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_amount'])!,
      vatRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}vat_rate'])!,
      itemsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}items_json'])!,
    );
  }

  @override
  $OrdersTable createAlias(String alias) {
    return $OrdersTable(attachedDatabase, alias);
  }
}

class OrderRow extends DataClass implements Insertable<OrderRow> {
  final String id;
  final String invoiceNumber;
  final String ticketNumber;
  final DateTime orderDate;
  final String cashier;
  final double totalAmount;
  final double vatRate;
  final String itemsJson;
  const OrderRow(
      {required this.id,
      required this.invoiceNumber,
      required this.ticketNumber,
      required this.orderDate,
      required this.cashier,
      required this.totalAmount,
      required this.vatRate,
      required this.itemsJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['invoice_number'] = Variable<String>(invoiceNumber);
    map['ticket_number'] = Variable<String>(ticketNumber);
    map['order_date'] = Variable<DateTime>(orderDate);
    map['cashier'] = Variable<String>(cashier);
    map['total_amount'] = Variable<double>(totalAmount);
    map['vat_rate'] = Variable<double>(vatRate);
    map['items_json'] = Variable<String>(itemsJson);
    return map;
  }

  OrdersCompanion toCompanion(bool nullToAbsent) {
    return OrdersCompanion(
      id: Value(id),
      invoiceNumber: Value(invoiceNumber),
      ticketNumber: Value(ticketNumber),
      orderDate: Value(orderDate),
      cashier: Value(cashier),
      totalAmount: Value(totalAmount),
      vatRate: Value(vatRate),
      itemsJson: Value(itemsJson),
    );
  }

  factory OrderRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderRow(
      id: serializer.fromJson<String>(json['id']),
      invoiceNumber: serializer.fromJson<String>(json['invoiceNumber']),
      ticketNumber: serializer.fromJson<String>(json['ticketNumber']),
      orderDate: serializer.fromJson<DateTime>(json['orderDate']),
      cashier: serializer.fromJson<String>(json['cashier']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      vatRate: serializer.fromJson<double>(json['vatRate']),
      itemsJson: serializer.fromJson<String>(json['itemsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'invoiceNumber': serializer.toJson<String>(invoiceNumber),
      'ticketNumber': serializer.toJson<String>(ticketNumber),
      'orderDate': serializer.toJson<DateTime>(orderDate),
      'cashier': serializer.toJson<String>(cashier),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'vatRate': serializer.toJson<double>(vatRate),
      'itemsJson': serializer.toJson<String>(itemsJson),
    };
  }

  OrderRow copyWith(
          {String? id,
          String? invoiceNumber,
          String? ticketNumber,
          DateTime? orderDate,
          String? cashier,
          double? totalAmount,
          double? vatRate,
          String? itemsJson}) =>
      OrderRow(
        id: id ?? this.id,
        invoiceNumber: invoiceNumber ?? this.invoiceNumber,
        ticketNumber: ticketNumber ?? this.ticketNumber,
        orderDate: orderDate ?? this.orderDate,
        cashier: cashier ?? this.cashier,
        totalAmount: totalAmount ?? this.totalAmount,
        vatRate: vatRate ?? this.vatRate,
        itemsJson: itemsJson ?? this.itemsJson,
      );
  OrderRow copyWithCompanion(OrdersCompanion data) {
    return OrderRow(
      id: data.id.present ? data.id.value : this.id,
      invoiceNumber: data.invoiceNumber.present
          ? data.invoiceNumber.value
          : this.invoiceNumber,
      ticketNumber: data.ticketNumber.present
          ? data.ticketNumber.value
          : this.ticketNumber,
      orderDate: data.orderDate.present ? data.orderDate.value : this.orderDate,
      cashier: data.cashier.present ? data.cashier.value : this.cashier,
      totalAmount:
          data.totalAmount.present ? data.totalAmount.value : this.totalAmount,
      vatRate: data.vatRate.present ? data.vatRate.value : this.vatRate,
      itemsJson: data.itemsJson.present ? data.itemsJson.value : this.itemsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderRow(')
          ..write('id: $id, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('ticketNumber: $ticketNumber, ')
          ..write('orderDate: $orderDate, ')
          ..write('cashier: $cashier, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('vatRate: $vatRate, ')
          ..write('itemsJson: $itemsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, invoiceNumber, ticketNumber, orderDate,
      cashier, totalAmount, vatRate, itemsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderRow &&
          other.id == this.id &&
          other.invoiceNumber == this.invoiceNumber &&
          other.ticketNumber == this.ticketNumber &&
          other.orderDate == this.orderDate &&
          other.cashier == this.cashier &&
          other.totalAmount == this.totalAmount &&
          other.vatRate == this.vatRate &&
          other.itemsJson == this.itemsJson);
}

class OrdersCompanion extends UpdateCompanion<OrderRow> {
  final Value<String> id;
  final Value<String> invoiceNumber;
  final Value<String> ticketNumber;
  final Value<DateTime> orderDate;
  final Value<String> cashier;
  final Value<double> totalAmount;
  final Value<double> vatRate;
  final Value<String> itemsJson;
  final Value<int> rowid;
  const OrdersCompanion({
    this.id = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.ticketNumber = const Value.absent(),
    this.orderDate = const Value.absent(),
    this.cashier = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.vatRate = const Value.absent(),
    this.itemsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrdersCompanion.insert({
    required String id,
    required String invoiceNumber,
    required String ticketNumber,
    required DateTime orderDate,
    required String cashier,
    required double totalAmount,
    required double vatRate,
    required String itemsJson,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        invoiceNumber = Value(invoiceNumber),
        ticketNumber = Value(ticketNumber),
        orderDate = Value(orderDate),
        cashier = Value(cashier),
        totalAmount = Value(totalAmount),
        vatRate = Value(vatRate),
        itemsJson = Value(itemsJson);
  static Insertable<OrderRow> custom({
    Expression<String>? id,
    Expression<String>? invoiceNumber,
    Expression<String>? ticketNumber,
    Expression<DateTime>? orderDate,
    Expression<String>? cashier,
    Expression<double>? totalAmount,
    Expression<double>? vatRate,
    Expression<String>? itemsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (ticketNumber != null) 'ticket_number': ticketNumber,
      if (orderDate != null) 'order_date': orderDate,
      if (cashier != null) 'cashier': cashier,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (vatRate != null) 'vat_rate': vatRate,
      if (itemsJson != null) 'items_json': itemsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrdersCompanion copyWith(
      {Value<String>? id,
      Value<String>? invoiceNumber,
      Value<String>? ticketNumber,
      Value<DateTime>? orderDate,
      Value<String>? cashier,
      Value<double>? totalAmount,
      Value<double>? vatRate,
      Value<String>? itemsJson,
      Value<int>? rowid}) {
    return OrdersCompanion(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      orderDate: orderDate ?? this.orderDate,
      cashier: cashier ?? this.cashier,
      totalAmount: totalAmount ?? this.totalAmount,
      vatRate: vatRate ?? this.vatRate,
      itemsJson: itemsJson ?? this.itemsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (invoiceNumber.present) {
      map['invoice_number'] = Variable<String>(invoiceNumber.value);
    }
    if (ticketNumber.present) {
      map['ticket_number'] = Variable<String>(ticketNumber.value);
    }
    if (orderDate.present) {
      map['order_date'] = Variable<DateTime>(orderDate.value);
    }
    if (cashier.present) {
      map['cashier'] = Variable<String>(cashier.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (vatRate.present) {
      map['vat_rate'] = Variable<double>(vatRate.value);
    }
    if (itemsJson.present) {
      map['items_json'] = Variable<String>(itemsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrdersCompanion(')
          ..write('id: $id, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('ticketNumber: $ticketNumber, ')
          ..write('orderDate: $orderDate, ')
          ..write('cashier: $cashier, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('vatRate: $vatRate, ')
          ..write('itemsJson: $itemsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MenuItemsTable extends MenuItems
    with TableInfo<$MenuItemsTable, MenuItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MenuItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
      'price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priceQuarterMeta =
      const VerificationMeta('priceQuarter');
  @override
  late final GeneratedColumn<double> priceQuarter = GeneratedColumn<double>(
      'price_quarter', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _priceHalfMeta =
      const VerificationMeta('priceHalf');
  @override
  late final GeneratedColumn<double> priceHalf = GeneratedColumn<double>(
      'price_half', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _priceThreeQuarterMeta =
      const VerificationMeta('priceThreeQuarter');
  @override
  late final GeneratedColumn<double> priceThreeQuarter =
      GeneratedColumn<double>('price_three_quarter', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, price, category, priceQuarter, priceHalf, priceThreeQuarter];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'menu_items';
  @override
  VerificationContext validateIntegrity(Insertable<MenuItemRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('price_quarter')) {
      context.handle(
          _priceQuarterMeta,
          priceQuarter.isAcceptableOrUnknown(
              data['price_quarter']!, _priceQuarterMeta));
    }
    if (data.containsKey('price_half')) {
      context.handle(_priceHalfMeta,
          priceHalf.isAcceptableOrUnknown(data['price_half']!, _priceHalfMeta));
    }
    if (data.containsKey('price_three_quarter')) {
      context.handle(
          _priceThreeQuarterMeta,
          priceThreeQuarter.isAcceptableOrUnknown(
              data['price_three_quarter']!, _priceThreeQuarterMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MenuItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MenuItemRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      priceQuarter: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price_quarter']),
      priceHalf: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price_half']),
      priceThreeQuarter: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}price_three_quarter']),
    );
  }

  @override
  $MenuItemsTable createAlias(String alias) {
    return $MenuItemsTable(attachedDatabase, alias);
  }
}

class MenuItemRow extends DataClass implements Insertable<MenuItemRow> {
  final String id;
  final String name;
  final double price;
  final String category;
  final double? priceQuarter;
  final double? priceHalf;
  final double? priceThreeQuarter;
  const MenuItemRow(
      {required this.id,
      required this.name,
      required this.price,
      required this.category,
      this.priceQuarter,
      this.priceHalf,
      this.priceThreeQuarter});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['price'] = Variable<double>(price);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || priceQuarter != null) {
      map['price_quarter'] = Variable<double>(priceQuarter);
    }
    if (!nullToAbsent || priceHalf != null) {
      map['price_half'] = Variable<double>(priceHalf);
    }
    if (!nullToAbsent || priceThreeQuarter != null) {
      map['price_three_quarter'] = Variable<double>(priceThreeQuarter);
    }
    return map;
  }

  MenuItemsCompanion toCompanion(bool nullToAbsent) {
    return MenuItemsCompanion(
      id: Value(id),
      name: Value(name),
      price: Value(price),
      category: Value(category),
      priceQuarter: priceQuarter == null && nullToAbsent
          ? const Value.absent()
          : Value(priceQuarter),
      priceHalf: priceHalf == null && nullToAbsent
          ? const Value.absent()
          : Value(priceHalf),
      priceThreeQuarter: priceThreeQuarter == null && nullToAbsent
          ? const Value.absent()
          : Value(priceThreeQuarter),
    );
  }

  factory MenuItemRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MenuItemRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      price: serializer.fromJson<double>(json['price']),
      category: serializer.fromJson<String>(json['category']),
      priceQuarter: serializer.fromJson<double?>(json['priceQuarter']),
      priceHalf: serializer.fromJson<double?>(json['priceHalf']),
      priceThreeQuarter:
          serializer.fromJson<double?>(json['priceThreeQuarter']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'price': serializer.toJson<double>(price),
      'category': serializer.toJson<String>(category),
      'priceQuarter': serializer.toJson<double?>(priceQuarter),
      'priceHalf': serializer.toJson<double?>(priceHalf),
      'priceThreeQuarter': serializer.toJson<double?>(priceThreeQuarter),
    };
  }

  MenuItemRow copyWith(
          {String? id,
          String? name,
          double? price,
          String? category,
          Value<double?> priceQuarter = const Value.absent(),
          Value<double?> priceHalf = const Value.absent(),
          Value<double?> priceThreeQuarter = const Value.absent()}) =>
      MenuItemRow(
        id: id ?? this.id,
        name: name ?? this.name,
        price: price ?? this.price,
        category: category ?? this.category,
        priceQuarter:
            priceQuarter.present ? priceQuarter.value : this.priceQuarter,
        priceHalf: priceHalf.present ? priceHalf.value : this.priceHalf,
        priceThreeQuarter: priceThreeQuarter.present
            ? priceThreeQuarter.value
            : this.priceThreeQuarter,
      );
  MenuItemRow copyWithCompanion(MenuItemsCompanion data) {
    return MenuItemRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      price: data.price.present ? data.price.value : this.price,
      category: data.category.present ? data.category.value : this.category,
      priceQuarter: data.priceQuarter.present
          ? data.priceQuarter.value
          : this.priceQuarter,
      priceHalf: data.priceHalf.present ? data.priceHalf.value : this.priceHalf,
      priceThreeQuarter: data.priceThreeQuarter.present
          ? data.priceThreeQuarter.value
          : this.priceThreeQuarter,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MenuItemRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('price: $price, ')
          ..write('category: $category, ')
          ..write('priceQuarter: $priceQuarter, ')
          ..write('priceHalf: $priceHalf, ')
          ..write('priceThreeQuarter: $priceThreeQuarter')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, price, category, priceQuarter, priceHalf, priceThreeQuarter);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MenuItemRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.price == this.price &&
          other.category == this.category &&
          other.priceQuarter == this.priceQuarter &&
          other.priceHalf == this.priceHalf &&
          other.priceThreeQuarter == this.priceThreeQuarter);
}

class MenuItemsCompanion extends UpdateCompanion<MenuItemRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> price;
  final Value<String> category;
  final Value<double?> priceQuarter;
  final Value<double?> priceHalf;
  final Value<double?> priceThreeQuarter;
  final Value<int> rowid;
  const MenuItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.price = const Value.absent(),
    this.category = const Value.absent(),
    this.priceQuarter = const Value.absent(),
    this.priceHalf = const Value.absent(),
    this.priceThreeQuarter = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MenuItemsCompanion.insert({
    required String id,
    required String name,
    required double price,
    required String category,
    this.priceQuarter = const Value.absent(),
    this.priceHalf = const Value.absent(),
    this.priceThreeQuarter = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        price = Value(price),
        category = Value(category);
  static Insertable<MenuItemRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? price,
    Expression<String>? category,
    Expression<double>? priceQuarter,
    Expression<double>? priceHalf,
    Expression<double>? priceThreeQuarter,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (price != null) 'price': price,
      if (category != null) 'category': category,
      if (priceQuarter != null) 'price_quarter': priceQuarter,
      if (priceHalf != null) 'price_half': priceHalf,
      if (priceThreeQuarter != null) 'price_three_quarter': priceThreeQuarter,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MenuItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<double>? price,
      Value<String>? category,
      Value<double?>? priceQuarter,
      Value<double?>? priceHalf,
      Value<double?>? priceThreeQuarter,
      Value<int>? rowid}) {
    return MenuItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      priceQuarter: priceQuarter ?? this.priceQuarter,
      priceHalf: priceHalf ?? this.priceHalf,
      priceThreeQuarter: priceThreeQuarter ?? this.priceThreeQuarter,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (priceQuarter.present) {
      map['price_quarter'] = Variable<double>(priceQuarter.value);
    }
    if (priceHalf.present) {
      map['price_half'] = Variable<double>(priceHalf.value);
    }
    if (priceThreeQuarter.present) {
      map['price_three_quarter'] = Variable<double>(priceThreeQuarter.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MenuItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('price: $price, ')
          ..write('category: $category, ')
          ..write('priceQuarter: $priceQuarter, ')
          ..write('priceHalf: $priceHalf, ')
          ..write('priceThreeQuarter: $priceThreeQuarter, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $OrdersTable orders = $OrdersTable(this);
  late final $MenuItemsTable menuItems = $MenuItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [orders, menuItems];
}

typedef $$OrdersTableCreateCompanionBuilder = OrdersCompanion Function({
  required String id,
  required String invoiceNumber,
  required String ticketNumber,
  required DateTime orderDate,
  required String cashier,
  required double totalAmount,
  required double vatRate,
  required String itemsJson,
  Value<int> rowid,
});
typedef $$OrdersTableUpdateCompanionBuilder = OrdersCompanion Function({
  Value<String> id,
  Value<String> invoiceNumber,
  Value<String> ticketNumber,
  Value<DateTime> orderDate,
  Value<String> cashier,
  Value<double> totalAmount,
  Value<double> vatRate,
  Value<String> itemsJson,
  Value<int> rowid,
});

class $$OrdersTableFilterComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ticketNumber => $composableBuilder(
      column: $table.ticketNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get orderDate => $composableBuilder(
      column: $table.orderDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cashier => $composableBuilder(
      column: $table.cashier, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get vatRate => $composableBuilder(
      column: $table.vatRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemsJson => $composableBuilder(
      column: $table.itemsJson, builder: (column) => ColumnFilters(column));
}

class $$OrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ticketNumber => $composableBuilder(
      column: $table.ticketNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get orderDate => $composableBuilder(
      column: $table.orderDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cashier => $composableBuilder(
      column: $table.cashier, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get vatRate => $composableBuilder(
      column: $table.vatRate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemsJson => $composableBuilder(
      column: $table.itemsJson, builder: (column) => ColumnOrderings(column));
}

class $$OrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber, builder: (column) => column);

  GeneratedColumn<String> get ticketNumber => $composableBuilder(
      column: $table.ticketNumber, builder: (column) => column);

  GeneratedColumn<DateTime> get orderDate =>
      $composableBuilder(column: $table.orderDate, builder: (column) => column);

  GeneratedColumn<String> get cashier =>
      $composableBuilder(column: $table.cashier, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => column);

  GeneratedColumn<double> get vatRate =>
      $composableBuilder(column: $table.vatRate, builder: (column) => column);

  GeneratedColumn<String> get itemsJson =>
      $composableBuilder(column: $table.itemsJson, builder: (column) => column);
}

class $$OrdersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrdersTable,
    OrderRow,
    $$OrdersTableFilterComposer,
    $$OrdersTableOrderingComposer,
    $$OrdersTableAnnotationComposer,
    $$OrdersTableCreateCompanionBuilder,
    $$OrdersTableUpdateCompanionBuilder,
    (OrderRow, BaseReferences<_$AppDatabase, $OrdersTable, OrderRow>),
    OrderRow,
    PrefetchHooks Function()> {
  $$OrdersTableTableManager(_$AppDatabase db, $OrdersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> invoiceNumber = const Value.absent(),
            Value<String> ticketNumber = const Value.absent(),
            Value<DateTime> orderDate = const Value.absent(),
            Value<String> cashier = const Value.absent(),
            Value<double> totalAmount = const Value.absent(),
            Value<double> vatRate = const Value.absent(),
            Value<String> itemsJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OrdersCompanion(
            id: id,
            invoiceNumber: invoiceNumber,
            ticketNumber: ticketNumber,
            orderDate: orderDate,
            cashier: cashier,
            totalAmount: totalAmount,
            vatRate: vatRate,
            itemsJson: itemsJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String invoiceNumber,
            required String ticketNumber,
            required DateTime orderDate,
            required String cashier,
            required double totalAmount,
            required double vatRate,
            required String itemsJson,
            Value<int> rowid = const Value.absent(),
          }) =>
              OrdersCompanion.insert(
            id: id,
            invoiceNumber: invoiceNumber,
            ticketNumber: ticketNumber,
            orderDate: orderDate,
            cashier: cashier,
            totalAmount: totalAmount,
            vatRate: vatRate,
            itemsJson: itemsJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OrdersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OrdersTable,
    OrderRow,
    $$OrdersTableFilterComposer,
    $$OrdersTableOrderingComposer,
    $$OrdersTableAnnotationComposer,
    $$OrdersTableCreateCompanionBuilder,
    $$OrdersTableUpdateCompanionBuilder,
    (OrderRow, BaseReferences<_$AppDatabase, $OrdersTable, OrderRow>),
    OrderRow,
    PrefetchHooks Function()>;
typedef $$MenuItemsTableCreateCompanionBuilder = MenuItemsCompanion Function({
  required String id,
  required String name,
  required double price,
  required String category,
  Value<double?> priceQuarter,
  Value<double?> priceHalf,
  Value<double?> priceThreeQuarter,
  Value<int> rowid,
});
typedef $$MenuItemsTableUpdateCompanionBuilder = MenuItemsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<double> price,
  Value<String> category,
  Value<double?> priceQuarter,
  Value<double?> priceHalf,
  Value<double?> priceThreeQuarter,
  Value<int> rowid,
});

class $$MenuItemsTableFilterComposer
    extends Composer<_$AppDatabase, $MenuItemsTable> {
  $$MenuItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get priceQuarter => $composableBuilder(
      column: $table.priceQuarter, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get priceHalf => $composableBuilder(
      column: $table.priceHalf, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get priceThreeQuarter => $composableBuilder(
      column: $table.priceThreeQuarter,
      builder: (column) => ColumnFilters(column));
}

class $$MenuItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $MenuItemsTable> {
  $$MenuItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get priceQuarter => $composableBuilder(
      column: $table.priceQuarter,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get priceHalf => $composableBuilder(
      column: $table.priceHalf, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get priceThreeQuarter => $composableBuilder(
      column: $table.priceThreeQuarter,
      builder: (column) => ColumnOrderings(column));
}

class $$MenuItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MenuItemsTable> {
  $$MenuItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get priceQuarter => $composableBuilder(
      column: $table.priceQuarter, builder: (column) => column);

  GeneratedColumn<double> get priceHalf =>
      $composableBuilder(column: $table.priceHalf, builder: (column) => column);

  GeneratedColumn<double> get priceThreeQuarter => $composableBuilder(
      column: $table.priceThreeQuarter, builder: (column) => column);
}

class $$MenuItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MenuItemsTable,
    MenuItemRow,
    $$MenuItemsTableFilterComposer,
    $$MenuItemsTableOrderingComposer,
    $$MenuItemsTableAnnotationComposer,
    $$MenuItemsTableCreateCompanionBuilder,
    $$MenuItemsTableUpdateCompanionBuilder,
    (MenuItemRow, BaseReferences<_$AppDatabase, $MenuItemsTable, MenuItemRow>),
    MenuItemRow,
    PrefetchHooks Function()> {
  $$MenuItemsTableTableManager(_$AppDatabase db, $MenuItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MenuItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MenuItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MenuItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> price = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<double?> priceQuarter = const Value.absent(),
            Value<double?> priceHalf = const Value.absent(),
            Value<double?> priceThreeQuarter = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MenuItemsCompanion(
            id: id,
            name: name,
            price: price,
            category: category,
            priceQuarter: priceQuarter,
            priceHalf: priceHalf,
            priceThreeQuarter: priceThreeQuarter,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required double price,
            required String category,
            Value<double?> priceQuarter = const Value.absent(),
            Value<double?> priceHalf = const Value.absent(),
            Value<double?> priceThreeQuarter = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MenuItemsCompanion.insert(
            id: id,
            name: name,
            price: price,
            category: category,
            priceQuarter: priceQuarter,
            priceHalf: priceHalf,
            priceThreeQuarter: priceThreeQuarter,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MenuItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MenuItemsTable,
    MenuItemRow,
    $$MenuItemsTableFilterComposer,
    $$MenuItemsTableOrderingComposer,
    $$MenuItemsTableAnnotationComposer,
    $$MenuItemsTableCreateCompanionBuilder,
    $$MenuItemsTableUpdateCompanionBuilder,
    (MenuItemRow, BaseReferences<_$AppDatabase, $MenuItemsTable, MenuItemRow>),
    MenuItemRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db, _db.orders);
  $$MenuItemsTableTableManager get menuItems =>
      $$MenuItemsTableTableManager(_db, _db.menuItems);
}
