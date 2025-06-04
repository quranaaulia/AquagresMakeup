// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'transcation_recap_page.dart'; // Import halaman Transaction Recap

class TransactionPage extends StatefulWidget {
  final String makeupTitle;
  final String makeupBrand;
  final String makeupPrice;
  final String makeupCategory;
  final String productType;
  final String customerName; // Tambahkan properti customerName

  const TransactionPage({
    Key? key,
    required this.makeupTitle,
    required this.makeupBrand,
    required this.makeupPrice,
    this.makeupCategory = '',
    this.productType = '',
    required this.customerName, // Tambahkan customerName ke constructor
  }) : super(key: key);

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  late DateTime _selectedDate = DateTime.now();
  int _makeupCount = 1;
  late String _customerName = ''; // Tambahkan variabel _customerName

  @override
  Widget build(BuildContext context) {
    double price = _parseMakeupPrice(widget.makeupPrice);

    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nama Produk: ${widget.makeupTitle}',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              'Brand: ${widget.makeupBrand}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 16.0),
            if (widget.makeupCategory.isNotEmpty)
              Column(
                children: [
                  Text(
                    'Kategori: ${widget.makeupCategory}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 8.0),
                ],
              ),
            if (widget.productType.isNotEmpty)
              Column(
                children: [
                  Text(
                    'Tipe Produk: ${widget.productType}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 16.0),
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Harga Produk:',
                  style: TextStyle(fontSize: 18.0),
                ),
                Text(
                  _formatPrice(widget.makeupPrice),
                  style: TextStyle(fontSize: 18.0),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tanggal Pemesanan:',
                  style: TextStyle(fontSize: 18.0),
                ),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: TextStyle(fontSize: 18.0),
                ),
                IconButton(
                  onPressed: () {
                    _selectDate(context);
                  },
                  icon: Icon(Icons.calendar_today),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Jumlah Produk:',
                  style: TextStyle(fontSize: 18.0),
                ),
                DropdownButton<int>(
                  value: _makeupCount,
                  onChanged: (value) {
                    setState(() {
                      _makeupCount = value!;
                    });
                  },
                  items: List.generate(10, (index) => index + 1)
                      .map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Harga:',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatTotalPrice(price * _makeupCount),
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            BookingForm(
              onTap: _navigateToTransactionRecap,
              onNameChanged: (value) {
                _customerName = value; // Tangkap nilai nama dari form
              },
            ),
          ],
        ),
      ),
    );
  }

  double _parseMakeupPrice(String makeupPrice) {
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
      
      return double.parse(cleanPrice);
    } catch (e) {
      // If parsing fails, return 0
      return 0.0;
    }
  }

  String _formatPrice(String makeupPrice) {
    if (makeupPrice.toLowerCase().contains('not available') || 
        makeupPrice.isEmpty || 
        makeupPrice == 'null') {
      return 'Price not available';
    }
    return makeupPrice;
  }

  String _formatTotalPrice(double totalPrice) {
    if (totalPrice == 0.0) {
      return 'Price not available';
    }
    return '\$${totalPrice.toStringAsFixed(2)}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _navigateToTransactionRecap() {
    if (_customerName.isNotEmpty) { // Periksa apakah nama tidak kosong
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TransactionRecapPage(
            makeupTitle: widget.makeupTitle,
            makeupBrand: widget.makeupBrand,
            makeupPrice: widget.makeupPrice,
            makeupCategory: widget.makeupCategory,
            productType: widget.productType,
            selectedDate: _selectedDate,
            makeupCount: _makeupCount,
            customerName: _customerName,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nama tidak boleh kosong'), // Tampilkan pesan jika nama kosong
        ),
      );
    }
  }
}

class BookingForm extends StatelessWidget {
  final VoidCallback onTap;
  final ValueChanged<String> onNameChanged; // Tambahkan properti onNameChanged

  const BookingForm({Key? key, required this.onTap, required this.onNameChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Form Pemesanan',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.0),
        TextFormField(
          onChanged: onNameChanged, // Panggil callback saat nilai berubah
          decoration: InputDecoration(
            labelText: 'Atas Nama',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16.0),
        Text(
          'Pembayaran hanya via QRIS BCA',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.0),
        Center(
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(300, 50),
              backgroundColor: Color.fromARGB(255, 0, 61, 228),
            ),
            child: Text(
              'Pesan Sekarang',
              style: TextStyle(
                color: Color.fromRGBO(242, 243, 237, 1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}