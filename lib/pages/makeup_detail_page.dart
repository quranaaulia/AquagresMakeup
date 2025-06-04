import 'package:flutter/material.dart';
import '../transaction/transcation_page.dart';
import 'package:url_launcher/url_launcher.dart';

class MakeupDetailPage extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final String brand;
  final String price;
  final String category;
  final String productType;

  const MakeupDetailPage({
    Key? key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.brand,
    required this.price,
    required this.category,
    required this.productType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  child: imagePath.isNotEmpty
                      ? Image.network(
                          imagePath,
                          fit: BoxFit.cover,
                          height: 300,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 300,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_not_supported, 
                                       size: 64, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('Image not available',
                                       style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 300,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 300,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported, 
                                   size: 64, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('No image available',
                                   style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                ),
                Container(
                  padding: EdgeInsets.all(16.0),
                  color: Colors.black.withOpacity(0.4),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          brand,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          price,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.orange[700],
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          productType,
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.purple[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Divider(),
                  SizedBox(height: 16.0),
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    description.isNotEmpty ? description : 'No description available for this makeup product.',
                    style: TextStyle(
                      fontSize: 16.0,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Divider(),
                  SizedBox(height: 16.0),
                  Text(
                    'Product Details:',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  _buildDetailRow('Brand', brand),
                  _buildDetailRow('Category', category),
                  _buildDetailRow('Product Type', productType),
                  _buildDetailRow('Price', price),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionPage(
                      makeupTitle: title,
                      makeupBrand: brand,
                      makeupPrice: price,
                      makeupCategory: category,
                      productType: productType,
                      customerName: '',
                    ),
                  ),
                );
              },
              icon: Icon(Icons.shopping_cart),
              label: Text('Buy Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                _launchBrandUrl(brand);
              },
              icon: Icon(Icons.open_in_browser),
              label: Text('Visit Brand'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
        color: Colors.transparent,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _launchBrandUrl(String brand) async {
    final url = 'https://www.google.com/search?q=${Uri.encodeComponent(brand + ' makeup official website')}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}