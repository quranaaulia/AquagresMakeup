import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:tugasakhirtpm/models/model.dart';
import 'package:tugasakhirtpm/screens/detail.dart';

class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<Favorite> {
  List<ContentModel> _favoriteProducts = [];
  bool _isLoading = true;

  // Theme colors matching ListPage
  final Color primaryPurple = const Color(0xFFB19CD9);
  final Color secondaryBlue = const Color(0xFF8EC5FC);
  final Color accentPink = const Color(0xFFE0C3FC);
  final Color softWhite = const Color(0xFFF8F9FA);
  final Color _darkText = const Color(0xFF333333);

  @override
  void initState() {
    super.initState();
    _loadFavoriteProducts();
  }

  Future<void> _loadFavoriteProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? '';
      final favoriteKey = 'favorites_$username';
      final favoritesJson = prefs.getStringList(favoriteKey) ?? [];
      
      setState(() {
        _favoriteProducts = favoritesJson
            .map((json) => ContentModel.fromJson(jsonDecode(json)))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFromFavorites(ContentModel product) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? '';
      final favoriteKey = 'favorites_$username';
      
      final updatedFavorites = _favoriteProducts
          .where((item) => item.id != product.id)
          .map((item) => jsonEncode(item.toJson()))
          .toList();
      
      await prefs.setStringList(favoriteKey, updatedFavorites);
      
      setState(() {
        _favoriteProducts.removeWhere((item) => item.id == product.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} removed from favorites'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to remove from favorites'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildFavoriteCard(ContentModel item) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            accentPink.withOpacity(0.05),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();
            final userId = prefs.getString('username') ?? '';
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Detail(
                  id: item.id,
                  name: item.name,
                  pictureId: item.imageUrl,
                  description: item.description,
                  price: item.price,
                  priceSign: item.priceSign,
                  userId: userId,
                  category: item.category,
                  productType: item.productType,
                  tagList: item.tagList,
                ),
              ),
            ).then((_) => _loadFavoriteProducts()); // Refresh when coming back
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            secondaryBlue.withOpacity(0.1),
                            accentPink.withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
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
                            size: 50,
                            color: primaryPurple.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () => _removeFromFavorites(item),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          item.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: _darkText,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryPurple.withOpacity(0.1),
                              accentPink.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.category_rounded,
                              size: 12,
                              color: primaryPurple,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                item.category ?? '-',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: primaryPurple,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              secondaryBlue.withOpacity(0.1),
                              accentPink.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.style_rounded,
                              size: 12,
                              color: secondaryBlue,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                item.productType ?? '-',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: secondaryBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryPurple, secondaryBlue],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primaryPurple.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          "€${item.price}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              accentPink.withOpacity(0.1),
            ],
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryPurple.withOpacity(0.1),
                    accentPink.withOpacity(0.1)
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 60,
                color: primaryPurple,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Favorite Products Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: _darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start adding products to your favorites\nby tapping the heart icon!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryPurple, secondaryBlue],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: primaryPurple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                '💄 Explore Products',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              softWhite,
              accentPink.withOpacity(0.1),
              secondaryBlue.withOpacity(0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
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
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            softWhite,
            accentPink.withOpacity(0.1),
            secondaryBlue.withOpacity(0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: _favoriteProducts.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                // Header section
                Container(
                  margin: const EdgeInsets.all(16),
                  child: _buildGradientContainer(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primaryPurple, secondaryBlue],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'My Favorite Products',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _darkText,
                                  ),
                                ),
                                Text(
                                  '${_favoriteProducts.length} ${_favoriteProducts.length == 1 ? 'product' : 'products'} saved',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Products grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: _favoriteProducts.length,
                    itemBuilder: (context, index) {
                      final item = _favoriteProducts[index];
                      return _buildFavoriteCard(item);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}