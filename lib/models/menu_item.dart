class MenuItem {
  final String id;
  final String name;
  final double price; // This is the Base Price (Full / 1.0)
  final String category;

  // ✅ NEW: Optional Custom Prices for specific portions
  final double? priceQuarter; // Price for 0.25
  final double? priceHalf; // Price for 0.50
  final double? priceThreeQuarter; // Price for 0.75

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.priceQuarter,
    this.priceHalf,
    this.priceThreeQuarter,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'category': category,
        'priceQuarter': priceQuarter,
        'priceHalf': priceHalf,
        'priceThreeQuarter': priceThreeQuarter,
      };

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      category: json['category'],
      // ✅ Load new fields (nullable)
      priceQuarter: (json['priceQuarter'] as num?)?.toDouble(),
      priceHalf: (json['priceHalf'] as num?)?.toDouble(),
      priceThreeQuarter: (json['priceThreeQuarter'] as num?)?.toDouble(),
    );
  }
}
