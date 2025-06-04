import 'package:flutter/material.dart';
import 'transaction_provider.dart';
import 'package:provider/provider.dart';
import 'qris_page.dart';
import 'transaction.dart';

class TransactionRecapPage extends StatelessWidget {
  final String makeupTitle;
  final String makeupBrand;
  final String makeupPrice;
  final String makeupCategory;
  final String productType;
  final DateTime selectedDate;
  final int makeupCount;
  final String customerName;

  const TransactionRecapPage({
    Key? key,
    required this.makeupTitle,
    required this.makeupBrand,
    required this.makeupPrice,
    required this.selectedDate,
    required this.makeupCount,
    required this.customerName,
    this.makeupCategory = '',
    this.productType = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create transaction object to get calculated total price
    Transaction transaction = Transaction(
      makeupTitle: makeupTitle,
      makeupBrand: makeupBrand,
      makeupPrice: makeupPrice,
      selectedDate: selectedDate,
      makeupCount: makeupCount,
      customerName: customerName,
      makeupCategory: makeupCategory,
      productType: productType,
    );

    // Mendapatkan informasi ukuran layar
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Recap'),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenSize.width * 0.05), // Padding responsif
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Details:',
              style: TextStyle(fontSize: screenSize.width * 0.06, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            SizedBox(height: screenSize.height * 0.02), // Padding responsif
            _buildDetailItem('Customer Name', customerName, screenSize),
            _buildDetailItem('Product Name', makeupTitle, screenSize),
            _buildDetailItem('Brand', makeupBrand, screenSize),
            if (makeupCategory.isNotEmpty)
              _buildDetailItem('Category', makeupCategory, screenSize),
            if (productType.isNotEmpty)
              _buildDetailItem('Product Type', productType, screenSize),
            _buildDetailItem('Unit Price', transaction.formattedMakeupPrice, screenSize),
            _buildDetailItem('Date', '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}', screenSize),
            _buildDetailItem('Quantity', makeupCount.toString(), screenSize),
            SizedBox(height: screenSize.height * 0.04), // Padding responsif
            Text(
              'Total Price:',
              style: TextStyle(fontSize: screenSize.width * 0.06, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            Text(
              transaction.formattedTotalPrice,
              style: TextStyle(fontSize: screenSize.width * 0.07, color: Colors.green, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenSize.height * 0.06), // Padding responsif
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<TransactionProvider>(context, listen: false).addTransaction(transaction);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QRISPage(
                        totalPrice: transaction.totalPrice.toInt(),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  minimumSize: Size(screenSize.width * 0.8, screenSize.height * 0.06),
                  padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.08, vertical: screenSize.height * 0.02), // Padding responsif
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenSize.width * 0.03), // BorderRadius responsif
                  ),
                ),
                child: Text(
                  'Bayar Sekarang',
                  style: TextStyle(fontSize: screenSize.width * 0.05, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, String value, Size screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: screenSize.width * 0.04, fontWeight: FontWeight.bold, color: Colors.indigo),
        ),
        SizedBox(height: screenSize.height * 0.01), // Padding responsif
        Text(
          value,
          style: TextStyle(fontSize: screenSize.width * 0.035),
        ),
        SizedBox(height: screenSize.height * 0.015), // Padding responsif
      ],
    );
  }
}