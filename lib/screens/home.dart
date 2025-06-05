import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugasakhirtpm/services/api.dart';
import 'package:tugasakhirtpm/models/model.dart';
import 'package:tugasakhirtpm/screens/detail.dart';
import 'package:tugasakhirtpm/screens/cart.dart';
import 'package:tugasakhirtpm/screens/profile.dart';
import 'package:tugasakhirtpm/screens/login.dart';
import 'package:tugasakhirtpm/screens/notifikasiscreen.dart';
import 'package:tugasakhirtpm/screens/favorite.dart';
import 'package:hive/hive.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<Home> {
  final String brand = 'maybelline';
  int _currentIndex = 0;
  late Box _cacheBox;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortOption = 'Filter';

  List<ContentModel> _allData = [];
  List<ContentModel> _filteredData = [];
  List<String> _favoriteIds = [];

  bool _isLoading = true;
  String? _error;
  String? _username;

  // Menggunakan tema warna yang sama dengan LoginPage
  final Color primaryPurple = const Color(0xFFB19CD9);
  final Color secondaryBlue = const Color(0xFF8EC5FC);
  final Color accentPink = const Color(0xFFE0C3FC);
  final Color softWhite = const Color(0xFFF8F9FA);
  final Color _darkText = const Color(0xFF333333);

  @override
  void initState() {
    super.initState();
    _cacheBox = Hive.box('makeup_cache');
    _loadUsername();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _filterData();
      });
    });

    _loadData();
    _loadFavorites();
  }

  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('username');
    if (user == null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/');
    } else {
      setState(() {
        _username = user;
      });
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final favoriteKey = 'favorites_$username';
    final favoritesJson = prefs.getStringList(favoriteKey) ?? [];
    
    setState(() {
      _favoriteIds = favoritesJson.map((json) {
        final decoded = jsonDecode(json);
        return decoded['id'].toString();
      }).toList();
    });
  }

  Future<void> _toggleFavorite(ContentModel product) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? '';
      final favoriteKey = 'favorites_$username';
      final favoritesJson = prefs.getStringList(favoriteKey) ?? [];
      
      final productId = product.id.toString();
      final isFavorite = _favoriteIds.contains(productId);
      
      if (isFavorite) {
        // Remove from favorites
        final updatedFavorites = favoritesJson.where((json) {
          final decoded = jsonDecode(json);
          return decoded['id'].toString() != productId;
        }).toList();
        
        await prefs.setStringList(favoriteKey, updatedFavorites);
        
        setState(() {
          _favoriteIds.remove(productId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} removed from favorites'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // Add to favorites
        final productJson = jsonEncode(product.toJson());
        final updatedFavorites = [...favoritesJson, productJson];
        
        await prefs.setStringList(favoriteKey, updatedFavorites);
        
        setState(() {
          _favoriteIds.add(productId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} added to favorites'),
            backgroundColor: Colors.green.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update favorites'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadData() async {
    try {
      final result = await ApiService.fetchData(brand);
      final encoded = jsonEncode(result.map((e) => e.toJson()).toList());
      _cacheBox.put(brand, encoded);
      _allData = result;
      _error = null;
    } catch (e) {
      final cachedData = _cacheBox.get(brand);
      if (cachedData != null) {
        final List decoded = jsonDecode(cachedData);
        _allData = decoded.map((e) => ContentModel.fromJson(e)).toList();
        _error = null;
      } else {
        _error = e.toString();
      }
    }
    _filterData();
    setState(() => _isLoading = false);
  }

  void _filterData() {
    List<ContentModel> result =
        _searchQuery.isEmpty
            ? List.from(_allData)
            : _allData.where((item) {
              final name = item.name.toLowerCase();
              final category = (item.category ?? '').toLowerCase();
              final productType = (item.productType ?? '').toLowerCase();
              return name.contains(_searchQuery) ||
                  category.contains(_searchQuery) ||
                  productType.contains(_searchQuery);
            }).toList();

    _applySort(result);
  }

  void _applySort(List<ContentModel> data) {
    switch (_sortOption) {
      case 'Low to High':
        data.sort(
          (a, b) => double.tryParse(
            a.price.toString(),
          )!.compareTo(double.tryParse(b.price.toString())!),
        );
        break;
      case 'High to Low':
        data.sort(
          (a, b) => double.tryParse(
            b.price.toString(),
          )!.compareTo(double.tryParse(a.price.toString())!),
        );
        break;
      case 'Filter':
      default:
        break;
    }

    setState(() {
      _filteredData = data;
    });
  }

  void logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => Login()),
      (route) => false,
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

  Widget _buildSearchAndFilter() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: _buildGradientContainer(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        secondaryBlue.withOpacity(0.1),
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
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search beautiful products...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: Icon(Icons.search_rounded, color: primaryPurple),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryPurple, width: 2),
                      ),
                    ),
                    style: TextStyle(color: _darkText),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        accentPink.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: accentPink.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _sortOption,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _sortOption = value;
                          _filterData();
                        });
                      }
                    },
                    items: [
                      'Filter',
                      'Low to High',
                      'High to Low',
                    ].map(
                      (label) => DropdownMenuItem(
                        value: label,
                        child: Text(
                          label, 
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _darkText,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ).toList(),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryPurple, width: 2),
                      ),
                    ),
                    dropdownColor: Colors.white,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryPurple),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(ContentModel item) {
    final isFavorite = _favoriteIds.contains(item.id.toString());
    
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
            ).then((_) => _loadFavorites()); // Refresh favorites when coming back
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
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                          size: 20,
                        ),
                        onPressed: () => _toggleFavorite(item),
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

  Widget _buildSidebar() {
    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.grid_view_rounded,
        'label': 'Products',
        'index': 0,
      },
      {
        'icon': Icons.shopping_bag_rounded,
        'label': 'Cart',
        'index': 1,
      },
      {
        'icon': Icons.person_rounded,
        'label': 'Profile',
        'index': 2,
      },
      {
        'icon': Icons.favorite_rounded,
        'label': 'Favorites',
        'index': 3,
      },
    ];

    return Container(
      width: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            softWhite,
            accentPink.withOpacity(0.2),
            secondaryBlue.withOpacity(0.3),
            primaryPurple.withOpacity(0.4),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(3, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Logo/Brand area
          Container(
            height: 60,
            width: 60,
            margin: const EdgeInsets.only(bottom: 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryPurple, secondaryBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryPurple.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.brush_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          // Menu items
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: menuItems.map((item) {
                final isSelected = _currentIndex == item['index'];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        setState(() {
                          _currentIndex = item['index'];
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.9),
                                    accentPink.withOpacity(0.2),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: primaryPurple.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item['icon'],
                              color: isSelected 
                                  ? primaryPurple 
                                  : Colors.white.withOpacity(0.8),
                              size: 24,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item['label'],
                              style: TextStyle(
                                color: isSelected 
                                    ? primaryPurple 
                                    : Colors.white.withOpacity(0.8),
                                fontSize: 10,
                                fontWeight: isSelected 
                                    ? FontWeight.w600 
                                    : FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _getSelectedPage(int index) {
    switch (index) {
      case 0:
        if (_isLoading) {
          return Center(
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
          );
        }
        if (_error != null) {
          return Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: $_error'),
                ],
              ),
            ),
          );
        }
        if (_filteredData.isEmpty) {
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryPurple.withOpacity(0.1), accentPink.withOpacity(0.1)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.search_off_rounded,
                      size: 48,
                      color: primaryPurple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No beautiful products found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    'Try adjusting your search or filters',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Column(
          children: [
            _buildSearchAndFilter(),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: _filteredData.length,
                itemBuilder: (context, index) {
                  final item = _filteredData[index];
                  return _buildProductCard(item);
                },
              ),
            ),
          ],
        );
      case 1:
        return const Cart();
      case 2:
        return ProfilePage();
      case 3:
        return const Favorite();
      default:
        return const Center(child: Text('Page Not Found'));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_username == null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                softWhite,
                accentPink.withOpacity(0.3),
                secondaryBlue.withOpacity(0.4),
                primaryPurple.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.white, Colors.white.withOpacity(0.8)],
          ).createShader(bounds),
          child: Text(
            'Welcome, $_username! 💄',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
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
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_rounded, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationPage(),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              onPressed: () => logout(context),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(),
          // Main content
          Expanded(
            child: Container(
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
              child: _getSelectedPage(_currentIndex),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}