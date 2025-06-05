class ContentModel {
  final String id;
  final String brand;
  final String name;
  final String price;
  final String priceSign;
  final String currency;
  final String imageUrl;
  final String productLink;
  final String websiteLink;
  final String description;
  final String category;
  final String productType;
  final List<String> tagList;
  final String createdAt;
  final String updatedAt;
  final String productApiUrl;
  final String apiFeaturedImage;
  final List<ColorOption> productColors;

  ContentModel({
    required this.id,
    required this.brand,
    required this.name,
    required this.price,
    required this.priceSign,
    required this.currency,
    required this.imageUrl,
    required this.productLink,
    required this.websiteLink,
    required this.description,
    required this.category,
    required this.productType,
    required this.tagList,
    required this.createdAt,
    required this.updatedAt,
    required this.productApiUrl,
    required this.apiFeaturedImage,
    required this.productColors,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    var colorsList =
        (json['product_colors'] as List?)
            ?.map((color) => ColorOption.fromJson(color))
            .toList() ??
        [];

    var tagList =
        (json['tag_list'] as List?)?.map((tag) => tag.toString()).toList() ??
        [];

    return ContentModel(
      id: json['id'].toString(),
      brand: json['brand'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] ?? '',
      priceSign: json['price_sign'] ?? '',
      currency: json['currency'] ?? '',
      imageUrl: json['image_link'] ?? '',
      productLink: json['product_link'] ?? '',
      websiteLink: json['website_link'] ?? '',
      description: json['description'] ?? '',
      category: (json['category']?.toString().trim().isEmpty ?? true) ? '-' : json['category'],
      productType: (json['product_type']?.toString().trim().isEmpty ?? true) ? '-' : json['product_type'],
      tagList: tagList,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      productApiUrl: json['product_api_url'] ?? '',
      apiFeaturedImage: json['api_featured_image'] ?? '',
      productColors: colorsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'name': name,
      'price': price,
      'price_sign': priceSign,
      'currency': currency,
      'image_link': imageUrl,
      'product_link': productLink,
      'website_link': websiteLink,
      'description': description,
      'category': category,
      'product_type': productType,
      'tag_list': tagList,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'product_api_url': productApiUrl,
      'api_featured_image': apiFeaturedImage,
      'product_colors': productColors.map((color) => color.toJson()).toList(),
    };
  }
}

class ColorOption {
  final String hexValue;
  final String colorName;

  ColorOption({required this.hexValue, required this.colorName});

  factory ColorOption.fromJson(Map<String, dynamic> json) {
    return ColorOption(
      hexValue: json['hex_value'] ?? '',
      colorName: json['colour_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'hex_value': hexValue, 'colour_name': colorName};
  }
}
