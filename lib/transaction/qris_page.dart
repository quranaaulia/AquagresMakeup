import 'package:flutter/material.dart';
import '../pages/home_page.dart';

class QRISPage extends StatelessWidget {
  final int totalPrice;

  const QRISPage({Key? key, required this.totalPrice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Pembayaran'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Total Pembayaran:',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Rp $totalPrice',
              style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            SizedBox(height: 32.0),
            Image.asset(
              'assets/qr.png', // Path ke gambar QR BCA
              width: 200,
              height: 200,
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                _showSuccessDialog(context);
              },
              child: Text('Pembayaran Selesai'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Pembayaran Berhasil'),
        content: Text('Terima kasih atas pembayarannya!'),
        actions: [
          TextButton(
            onPressed: () {
              // Navigasi ke halaman utama dan hapus semua halaman lainnya
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
                (route) => false, // predicate untuk menghapus semua halaman
              );
            },
            child: Text('Tutup'),
          ),
        ],
      );
    },
  );
}
}