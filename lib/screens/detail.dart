import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tugasakhirtpm/models/makeup.dart'; // model CartItem Hive

class Detail extends StatefulWidget {
  final String id;
  final String name;
  final String pictureId;
  final String description;
  final String price;
  final String priceSign;
  final String userId; 

  final String category;
  final String productType;
  final List<String> tagList;

  const Detail({
    super.key,
    required this.id,
    required this.name,
    required this.pictureId,
    required this.description,
    required this.price,
    required this.priceSign,
    required this.userId,
    required this.category,
    required this.productType,
    required this.tagList,
  });

  @override
  State<Detail> createState() => _DetailPageState();
}

class _DetailPageState extends State<Detail> {
  late Box<CartItem> cartBox;

  // Menggunakan tema warna yang sama dengan ListPage
  final Color primaryPurple = const Color(0xFFB19CD9);
  final Color secondaryBlue = const Color(0xFF8EC5FC);
  final Color accentPink = const Color(0xFFE0C3FC);
  final Color softWhite = const Color(0xFFF8F9FA);
  final Color _darkText = const Color(0xFF333333);

  @override
  void initState() {
    super.initState();
    cartBox = Hive.box<CartItem>('cart_box');
  }

  void addToCart() {
    final String key = '${widget.userId}_${widget.id}'; // ← ini penting!
    final existingItem = cartBox.get(key);

    if (existingItem != null) {
      final updatedItem = existingItem.copyWith(
        quantity: existingItem.quantity + 1,
      );
      cartBox.put(key, updatedItem);
    } else {
      cartBox.put(
        key,
        CartItem(
          id: widget.id,
          name: widget.name,
          imageUrl: widget.pictureId,
          price: widget.price,
          priceSign: widget.priceSign,
          quantity: 1,
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Product "${widget.name}" added to cart!',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        elevation: 8,
      ),
    );
  }

  Widget _buildGradientContainer({required Widget child, List<Color>? colors}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors ?? [
            Colors.white.withOpacity(0.9),
            accentPink.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.white, Colors.white.withOpacity(0.8)],
          ).createShader(bounds),
          child: const Text(
            'Product Details',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryPurple, secondaryBlue],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              softWhite,
              accentPink.withOpacity(0.1),
              secondaryBlue.withOpacity(0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Container
              Center(
                child: _buildGradientContainer(
                  colors: [
                    Colors.white,
                    secondaryBlue.withOpacity(0.05),
                    accentPink.withOpacity(0.05),
                  ],
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      height: 280,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            secondaryBlue.withOpacity(0.1),
                            accentPink.withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: Image.network(
                        widget.pictureId,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryPurple.withOpacity(0.1),
                                  secondaryBlue.withOpacity(0.1),
                                ],
                              ),
                            ),
                            child: Icon(
                              Icons.image_not_supported_rounded,
                              size: 60,
                              color: primaryPurple.withOpacity(0.5),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryPurple.withOpacity(0.1),
                                  secondaryBlue.withOpacity(0.1),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [primaryPurple, secondaryBlue],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Product Name
              _buildGradientContainer(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _darkText,
                      height: 1.3,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Category and Product Type
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryPurple.withOpacity(0.1),
                            accentPink.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: primaryPurple.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.category_rounded,
                            size: 16,
                            color: primaryPurple,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              widget.category.isNotEmpty ? widget.category : '-',
                              style: TextStyle(
                                color: primaryPurple,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            secondaryBlue.withOpacity(0.1),
                            accentPink.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: secondaryBlue.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.style_rounded,
                            size: 16,
                            color: secondaryBlue,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              widget.productType.isNotEmpty ? widget.productType : '-',
                              style: TextStyle(
                                color: secondaryBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Price
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryPurple, secondaryBlue],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryPurple.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    "€${widget.price}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Description Section
              _buildGradientContainer(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primaryPurple.withOpacity(0.2), accentPink.withOpacity(0.2)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.description_rounded,
                              size: 20,
                              color: primaryPurple,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Description',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _darkText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.description,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: _darkText.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Add to Cart Button
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryPurple, secondaryBlue],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryPurple.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: addToCart,
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.shopping_cart_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Add to Cart',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}