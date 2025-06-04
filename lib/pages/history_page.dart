import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../transaction/transaction_provider.dart';
import '../transaction/transaction.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Transaction> transactions = Provider.of<TransactionProvider>(context).transactions;

    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
          ),
        ),
        child: transactions.isEmpty
            ? Center(
                child: Text(
                  'No transactions found',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(8.0),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    color: Colors.white.withOpacity(0.1),
                    child: ListTile(
                      title: Text(
                        transactions[index].makeupTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Brand: ${transactions[index].makeupBrand}',
                            style: TextStyle(color: Colors.white70),
                          ),
                          Text(
                            'Total: ${transactions[index].formattedTotalPrice}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      trailing: Text(
                        '${transactions[index].selectedDate.day}/${transactions[index].selectedDate.month}/${transactions[index].selectedDate.year}',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        _showTransactionDetails(context, transactions[index]);
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, Transaction transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blue,
          title: Text(
            'Detail Transaksi',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Pelanggan', transaction.customerName),
                _buildDetailRow('Produk', transaction.makeupTitle),
                _buildDetailRow('Brand', transaction.makeupBrand),
                if (transaction.makeupCategory.isNotEmpty)
                  _buildDetailRow('Kategori', transaction.makeupCategory),
                if (transaction.productType.isNotEmpty)
                  _buildDetailRow('Tipe Produk', transaction.productType),
                _buildDetailRow('Harga Satuan', transaction.formattedMakeupPrice),
                _buildDetailRow(
                  'Tanggal', 
                  '${transaction.selectedDate.day}/${transaction.selectedDate.month}/${transaction.selectedDate.year}'
                ),
                _buildDetailRow('Jumlah', '${transaction.makeupCount}'),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Pembayaran:',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        transaction.formattedTotalPrice,
                        style: TextStyle(
                          color: Colors.green[300],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Tutup pop-up
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: Text(
                      'OK',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}