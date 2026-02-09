class RestaurantSettings {
  final String name;
  final String address;
  final String phone;
  final String vatNumber;
  final double vatRate;
  final String cashierName; // ✅ ADDED
  final String? logoPath;

  RestaurantSettings({
    this.name = 'ProDine Restaurant',
    this.address = '123 Food Street, Riyadh',
    this.phone = '050-123-4567',
    this.vatNumber = '30000000001',
    this.vatRate = 0.15,
    this.cashierName = 'Admin', // ✅ Default
    this.logoPath,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'phone': phone,
        'vatNumber': vatNumber,
        'vatRate': vatRate,
        'cashierName': cashierName,
        'logoPath': logoPath,
      };

  factory RestaurantSettings.fromJson(Map<String, dynamic> json) {
    return RestaurantSettings(
      name: json['name'] ?? 'ProDine Restaurant',
      address: json['address'] ?? '123 Food Street, Riyadh',
      phone: json['phone'] ?? '050-123-4567',
      vatNumber: json['vatNumber'] ?? '30000000001',
      vatRate: (json['vatRate'] as num?)?.toDouble() ?? 0.15,
      cashierName: json['cashierName'] ?? 'Admin',
      logoPath: json['logoPath'],
    );
  }

  RestaurantSettings copyWith({
    String? name,
    String? address,
    String? phone,
    String? vatNumber,
    double? vatRate,
    String? cashierName,
    String? logoPath,
  }) {
    return RestaurantSettings(
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      vatNumber: vatNumber ?? this.vatNumber,
      vatRate: vatRate ?? this.vatRate,
      cashierName: cashierName ?? this.cashierName,
      logoPath: logoPath ?? this.logoPath,
    );
  }
}
