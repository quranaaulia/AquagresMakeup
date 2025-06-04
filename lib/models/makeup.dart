class Makeup {
  final String title;
  final String description;
  final String imagePath;
  final String brand;
  final String price;
  final String category;
  final String productType;

  Makeup({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.brand,
    required this.price,
    required this.category,
    required this.productType,
  });

  factory Makeup.fromJson(Map<String, dynamic> json) {
    return Makeup(
      title: json['name']?.toString() ?? 'Unknown Product',
      description: json['description']?.toString() ?? 'No description available',
      imagePath: json['api_featured_image']?.toString() ?? 
                 json['image_link']?.toString() ?? '',
      brand: json['brand']?.toString() ?? 'Unknown Brand',
      price: json['price'] != null ? '\$${json['price']}' : 'Price not available',
      category: json['category']?.toString() ?? 'Unknown Category',
      productType: json['product_type']?.toString() ?? 'Unknown Type',
    );
  }

  // Method untuk convert ke JSON (opsional, untuk keperluan serialization)
  Map<String, dynamic> toJson() {
    return {
      'name': title,
      'description': description,
      'api_featured_image': imagePath,
      'brand': brand,
      'price': price.replaceAll('\$', ''),
      'category': category,
      'product_type': productType,
    };
  }

  // Method untuk membuat copy dengan perubahan tertentu (opsional)
  Makeup copyWith({
    String? title,
    String? description,
    String? imagePath,
    String? brand,
    String? price,
    String? category,
    String? productType,
  }) {
    return Makeup(
      title: title ?? this.title,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      category: category ?? this.category,
      productType: productType ?? this.productType,
    );
  }

  @override
  String toString() {
    return 'Makeup(title: $title, brand: $brand, price: $price, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Makeup &&
        other.title == title &&
        other.brand == brand &&
        other.price == price &&
        other.category == category &&
        other.productType == productType;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        brand.hashCode ^
        price.hashCode ^
        category.hashCode ^
        productType.hashCode;
  }
}