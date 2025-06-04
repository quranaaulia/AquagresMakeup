import 'package:flutter/material.dart';
import 'history_page.dart';
import 'makeup_detail_page.dart';
import 'package:tugasakhirtpm/models/makeup.dart'; // Import model yang sudah dipisah
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Makeup> makeups = [];
  List<Makeup> filteredMakeups = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Load dummy data immediately, then try to fetch from API
    loadSampleData();
    fetchMakeups();
  }

  void loadSampleData() {
    setState(() {
      makeups = _getSampleMakeupData();
      filteredMakeups = makeups;
      isLoading = false;
    });
  }

  Future<void> fetchMakeups() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      // Try the original API first
      final response = await http.get(
        Uri.parse('https://makeup-api.herokuapp.com/api/v1/products.json?brand=maybelline'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 15));

      print('Status code: ${response.statusCode}');
      print('Response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        if (data.isNotEmpty) {
          setState(() {
            makeups = data.map((json) => Makeup.fromJson(json)).toList();
            filteredMakeups = makeups;
            isLoading = false;
            errorMessage = '';
          });
          print('Successfully loaded ${makeups.length} products from API');
          return;
        }
      }
    } catch (e) {
      print('API Error: $e');
    }

    // If API fails, use enhanced sample data
    setState(() {
      makeups = _getSampleMakeupData();
      filteredMakeups = makeups;
      isLoading = false;
      errorMessage = 'API unavailable - showing sample products';
    });
  }

List<Makeup> _getSampleMakeupData() {
  return [
    Makeup(
      title: 'Maybelline Fit Me Matte + Poreless Foundation',
      description: 'Ideal for normal to oily skin, natural-looking finish.',
      imagePath: 'https://d3t32hsnjxo7q6.cloudfront.net/i/33f84981b70d78fd1e64db2f9c59c509_ra,w158,h184_pa,w158,h184.jpeg',
      brand: 'Maybelline',
      price: '\$7.99',
      category: 'Foundation',
      productType: 'foundation',
    ),
    Makeup(
      title: 'Maybelline Great Lash Mascara',
      description: 'Volumizing mascara that builds lashes without clumps.',
      imagePath: 'https://d3t32hsnjxo7q6.cloudfront.net/i/d8fa5a7b8d03f78e7f34015bba92e59b_ra,w158,h184_pa,w158,h184.png',
      brand: 'Maybelline',
      price: '\$4.99',
      category: 'Mascara',
      productType: 'mascara',
    ),
    Makeup(
      title: 'Maybelline Color Sensational Lipstick',
      description: 'Rich color lipstick with a creamy smooth texture.',
      imagePath: 'https://d3t32hsnjxo7q6.cloudfront.net/i/e4572dd478a2bba87f2c6e4df1e54ee0_ra,w158,h184_pa,w158,h184.jpeg',
      brand: 'Maybelline',
      price: '\$6.99',
      category: 'Lipstick',
      productType: 'lipstick',
    ),
    Makeup(
      title: 'Maybelline Instant Age Rewind Concealer',
      description: 'Covers dark circles and fine lines effortlessly.',
      imagePath: 'https://d3t32hsnjxo7q6.cloudfront.net/i/ff2773e57a798edc2d4dcb064abf2a8f_ra,w158,h184_pa,w158,h184.jpeg',
      brand: 'Maybelline',
      price: '\$8.99',
      category: 'Concealer',
      productType: 'concealer',
    ),
    Makeup(
      title: 'Maybelline Master Precise Liquid Eyeliner',
      description: 'Ultra-fine tip for precise application.',
      imagePath: 'https://d3t32hsnjxo7q6.cloudfront.net/i/7a487bd63d6d83a6ff5d29d8d4e7a83e_ra,w158,h184_pa,w158,h184.jpeg',
      brand: 'Maybelline',
      price: '\$5.99',
      category: 'Eyeliner',
      productType: 'eyeliner',
    ),
    Makeup(
      title: 'Maybelline Dream Matte Mousse Foundation',
      description: 'Air-soft matte finish for light to medium coverage.',
      imagePath: 'https://d3t32hsnjxo7q6.cloudfront.net/i/1cbf32e7de727d3aef1b7ddc73eabc1f_ra,w158,h184_pa,w158,h184.jpeg',
      brand: 'Maybelline',
      price: '\$9.99',
      category: 'Foundation',
      productType: 'foundation',
    ),
    Makeup(
      title: 'Maybelline City Bronzer',
      description: 'Silky bronzing powder for sculpted and glowing look.',
      imagePath: 'https://d3t32hsnjxo7q6.cloudfront.net/i/23a21957b8a41a63c5a2f2e4e611650b_ra,w158,h184_pa,w158,h184.jpeg',
      brand: 'Maybelline',
      price: '\$7.49',
      category: 'Bronzer',
      productType: 'bronzer',
    ),
    Makeup(
      title: 'Maybelline Expert Wear Eyeshadow',
      description: 'Long-lasting eyeshadow with intense color payoff.',
      imagePath: 'https://d3t32hsnjxo7q6.cloudfront.net/i/77e3214d643e2ea02e7cfbb616ac3f4e_ra,w158,h184_pa,w158,h184.jpeg',
      brand: 'Maybelline',
      price: '\$4.49',
      category: 'Eyeshadow',
      productType: 'eyeshadow',
    ),
    Makeup(
      title: 'Maybelline Baby Lips Lip Balm',
      description: 'Hydrating lip balm with subtle shine.',
      imagePath: 'https://d3t32hsnjxo7q6.cloudfront.net/i/62c227f9c4e2cfb5870ff74c98bb4f3e_ra,w158,h184_pa,w158,h184.jpeg',
      brand: 'Maybelline',
      price: '\$3.99',
      category: 'Lip Balm',
      productType: 'lip_balm',
    ),
    Makeup(
      title: 'Maybelline Brow Drama Sculpting Gel',
      description: 'Defines and tames brows with tinted gel.',
      imagePath: 'https://d3t32hsnjxo7q6.cloudfront.net/i/91e44971e0e14c5a92902b685be23a9d_ra,w158,h184_pa,w158,h184.jpeg',
      brand: 'Maybelline',
      price: '\$6.49',
      category: 'Eyebrow',
      productType: 'eyebrow',
    ),
  ];
}


  void filterMakeups(String query) {
    setState(() {
      filteredMakeups = makeups.where((makeup) {
        final titleLower = makeup.title.toLowerCase();
        final descriptionLower = makeup.description.toLowerCase();
        final brandLower = makeup.brand.toLowerCase();
        final categoryLower = makeup.category.toLowerCase();
        final searchLower = query.toLowerCase();

        return titleLower.contains(searchLower) ||
            descriptionLower.contains(searchLower) ||
            brandLower.contains(searchLower) ||
            categoryLower.contains(searchLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MAKEUP STORE',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.pink[600],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchMakeups,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.pink[400]!,
              Colors.purple[300]!,
              Colors.blue[300]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (errorMessage.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search makeup products...',
                    prefixIcon: Icon(Icons.search, color: Colors.pink[400]),
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  style: TextStyle(color: Colors.grey[800], fontSize: 16),
                  onChanged: (value) => filterMakeups(value),
                ),
              ),
              SizedBox(height: 20.0),
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleIconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HistoryPage()),
                  );
                },
                icon: Icon(Icons.history, color: Colors.white),
                tooltip: 'Purchase History',
              ),
            ],
          ),
        ),
        color: Colors.pink[600],
        elevation: 8,
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircularProgressIndicator(
                    color: Colors.pink[400],
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading makeup products...',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (filteredMakeups.isEmpty) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, color: Colors.grey[400], size: 48),
              SizedBox(height: 16),
              Text(
                'No makeup products found',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: fetchMakeups,
                icon: Icon(Icons.refresh),
                label: Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: 20),
      itemCount: filteredMakeups.length,
      itemBuilder: (context, index) {
        return buildMakeupCard(context, filteredMakeups[index]);
      },
    );
  }

  Widget buildMakeupCard(BuildContext context, Makeup makeup) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MakeupDetailPage(
              title: makeup.title,
              description: makeup.description,
              imagePath: makeup.imagePath,
              brand: makeup.brand,
              price: makeup.price,
              category: makeup.category,
              productType: makeup.productType,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                gradient: LinearGradient(
                  colors: [Colors.pink[50]!, Colors.purple[50]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  children: [
                    // Background pattern
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.pink[50]!, Colors.purple[50]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    // Image
                    Center(
                      child: makeup.imagePath.isNotEmpty
                          ? Image.network(
                              makeup.imagePath,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('Image loading error: $error');
                                return _buildProductPlaceholder(makeup.category);
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 180,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                      color: Colors.pink[400],
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                            )
                          : _buildProductPlaceholder(makeup.category),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          makeup.title,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.pink[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.pink[200]!),
                        ),
                        child: Text(
                          makeup.productType.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10.0,
                            color: Colors.pink[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    makeup.brand,
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    makeup.category,
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Colors.purple[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 12.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        makeup.price,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[600],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.pink[400]!, Colors.purple[400]!],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'VIEW DETAILS',
                          style: TextStyle(
                            fontSize: 11.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductPlaceholder(String category) {
    IconData icon;
    Color color;
    
    switch (category.toLowerCase()) {
      case 'foundation':
        icon = Icons.face;
        color = Colors.orange[300]!;
        break;
      case 'lipstick':
      case 'lip balm':
        icon = Icons.favorite;
        color = Colors.red[300]!;
        break;
      case 'mascara':
        icon = Icons.visibility;
        color = Colors.purple[300]!;
        break;
      case 'eyeshadow':
        icon = Icons.palette;
        color = Colors.blue[300]!;
        break;
      case 'eyeliner':
        icon = Icons.edit;
        color = Colors.grey[600]!;
        break;
      case 'concealer':
        icon = Icons.healing;
        color = Colors.green[300]!;
        break;
      case 'bronzer':
        icon = Icons.wb_sunny;
        color = Colors.amber[400]!;
        break;
      case 'eyebrow':
        icon = Icons.architecture;
        color = Colors.brown[400]!;
        break;
      default:
        icon = Icons.shopping_bag;
        color = Colors.pink[300]!;
    }

    return Container(
      height: 180,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 60,
            color: color,
          ),
          SizedBox(height: 12),
          Text(
            category.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class CircleIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Icon icon;
  final String tooltip;

  const CircleIconButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: ShapeDecoration(
          color: Colors.pink[400],
          shape: CircleBorder(),
          shadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: icon,
          tooltip: tooltip,
          color: Colors.white,
        ),
      ),
    );
  }
}