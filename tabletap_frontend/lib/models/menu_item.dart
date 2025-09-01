class MenuItem {
  final int? id;
  final String name;
  final String description;
  final double price;
  final String category;

  MenuItem({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: json['price'] * 1.0,
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
    };
  }
}
