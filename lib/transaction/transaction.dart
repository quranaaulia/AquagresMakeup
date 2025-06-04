// transaction.dart

class Transaction {
  final String makeupTitle;
  final String makeupBrand;
  final String makeupPrice;
  final DateTime selectedDate;
  final int makeupCount;
  final String customerName;
  final double totalPrice;
  final String makeupCategory;
  final String productType;

  Transaction({
    required this.makeupTitle,
    required this.makeupBrand,
    required this.makeupPrice,
    required this.selectedDate,
    required this.makeupCount,
    required this.customerName,
    this.makeupCategory = '',
    this.productType = '',
  }) : totalPrice = _calculateTotalPrice(makeupPrice, makeupCount);

  static double _calculateTotalPrice(String makeupPrice, int makeupCount) {
    // Handle different price formats from the API
    if (makeupPrice.toLowerCase().contains('not available') || 
        makeupPrice.isEmpty || 
        makeupPrice == 'null') {
      return 0.0;
    }
    
    try {
      // Remove currency symbols and parse
      String cleanPrice = makeupPrice
          .replaceAll('\$', '')
          .replaceAll('USD', '')
          .replaceAll('Rp', '')
          .replaceAll('.', '')
          .replaceAll(',', '')
          .trim();
      
      double price = double.parse(cleanPrice);
      return price * makeupCount;
    } catch (e) {
      // If parsing fails, return 0
      return 0.0;
    }
  }

  // Helper method to format total price for display
  String get formattedTotalPrice {
    if (totalPrice == 0.0) {
      return 'Price not available';
    }
    return '\$${totalPrice.toStringAsFixed(2)}';
  }

  // Helper method to get formatted individual price
  String get formattedMakeupPrice {
    if (makeupPrice.toLowerCase().contains('not available') || 
        makeupPrice.isEmpty || 
        makeupPrice == 'null') {
      return 'Price not available';
    }
    return makeupPrice;
  }

  // Convert to Map for storage/serialization
  Map<String, dynamic> toMap() {
    return {
      'makeupTitle': makeupTitle,
      'makeupBrand': makeupBrand,
      'makeupPrice': makeupPrice,
      'selectedDate': selectedDate.toIso8601String(),
      'makeupCount': makeupCount,
      'customerName': customerName,
      'totalPrice': totalPrice,
      'makeupCategory': makeupCategory,
      'productType': productType,
    };
  }

  // Create from Map for loading/deserialization
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      makeupTitle: map['makeupTitle'] ?? '',
      makeupBrand: map['makeupBrand'] ?? '',
      makeupPrice: map['makeupPrice'] ?? '',
      selectedDate: DateTime.parse(map['selectedDate']),
      makeupCount: map['makeupCount'] ?? 1,
      customerName: map['customerName'] ?? '',
      makeupCategory: map['makeupCategory'] ?? '',
      productType: map['productType'] ?? '',
    );
  }

  // Create a copy with modified values
  Transaction copyWith({
    String? makeupTitle,
    String? makeupBrand,
    String? makeupPrice,
    DateTime? selectedDate,
    int? makeupCount,
    String? customerName,
    String? makeupCategory,
    String? productType,
  }) {
    return Transaction(
      makeupTitle: makeupTitle ?? this.makeupTitle,
      makeupBrand: makeupBrand ?? this.makeupBrand,
      makeupPrice: makeupPrice ?? this.makeupPrice,
      selectedDate: selectedDate ?? this.selectedDate,
      makeupCount: makeupCount ?? this.makeupCount,
      customerName: customerName ?? this.customerName,
      makeupCategory: makeupCategory ?? this.makeupCategory,
      productType: productType ?? this.productType,
    );
  }
}