import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InvoicePage extends StatefulWidget {
  final String sewaId;
  final bool isCompleted;

  InvoicePage({required this.sewaId, this.isCompleted = false});

  @override
  _InvoicePageState createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  Future<Map<String, dynamic>?> fetchData() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection(widget.isCompleted ? 'dbselesai' : 'dbsewa')
        .doc(widget.sewaId)
        .get();
    return snapshot.data() as Map<String, dynamic>?;
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd-MM-yyyy').format(date);
  }

  Future<void> moveDataToCompleted() async {
    final sewaData = await fetchData();
    if (sewaData != null) {
      await FirebaseFirestore.instance.collection('dbselesai').add(sewaData);
      if (!widget.isCompleted) {
        await FirebaseFirestore.instance
            .collection('dbsewa')
            .doc(widget.sewaId)
            .delete();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaksi selesai')),
        );
        Navigator.pop(context);
      }
    }
  }

  void showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Selesai?'),
          content: Text('Konfirmasi jika transaksi ini selesai'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                moveDataToCompleted();
              },
              child: Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Data tidak ditemukan.'));
          }

          final data = snapshot.data!;
          final barang = data['barang'] as List<dynamic>? ?? [];
          final paket = data['paket'] as Map<String, dynamic>? ?? {};

          List<Widget> barangWidgets = [];

          if (barang.isNotEmpty) {
            barangWidgets.add(Container(
              color: Colors.blue.shade100,
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: Text('BARANG',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Text('HARGA',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Text('QTY',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Text('TOTAL',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ));

            barangWidgets.addAll(barang.map((item) {
              double itemTotal =
                  (double.tryParse(item["Harga"].toString()) ?? 0) *
                      (item["Jumlah"] ?? 1);
              return buildItemRow(
                '  ${item["Nama Barang"]}',
                'Rp ${NumberFormat('#,###').format(double.tryParse(item["Harga"].toString()) ?? 0)}',
                '${item["Jumlah"]}',
                'Rp ${NumberFormat('#,###').format(itemTotal)}',
              );
            }).toList());
          }

          List<Widget> paketWidgets = [];
          if (paket.isNotEmpty) {
            paketWidgets.add(Row(
              children: [
                Text('PAKET: ',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(paket["Nama Paket"] ?? "",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ));

            paketWidgets.add(Container(
              color: Colors.blue.shade100,
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: Text('DESKRIPSI',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Text('QTY',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ));

            List<dynamic> barangDalamPaket = paket['Barang'] ?? [];
            for (var item in barangDalamPaket) {
              if (item is Map<String, dynamic>) {
                String namaBarang = item["Nama Barang"] ?? "";
                String jumlah = item["Jumlah"]?.toString() ?? "0";

                paketWidgets.add(buildItemRow(namaBarang, jumlah));
              }
            }
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('INVOICE',
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.red)),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Image.asset('assets/images/logo_soko.png',
                          height: 50),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text('No.${data['no_invoice']}',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('Nama:  \t\t${data['nama']}',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('No.Hp: \t\t${data['no_hp']}',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('Alamat: \t${data['alamat']}',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(
                    'Tanggal Peminjaman:   \t\t${formatDate((data['tanggal_peminjaman'] as Timestamp).toDate())}',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(
                    'Tanggal Pengembalian: \t${formatDate((data['tanggal_pengembalian'] as Timestamp).toDate())}',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                SizedBox(height: 24),
                ...barangWidgets,
                ...paketWidgets,
                SizedBox(height: 16),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TOTAL KESELURUHAN:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                        'Rp ${NumberFormat('#,###').format(double.tryParse(data['total_biaya'].toString()) ?? 0)}',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: !widget.isCompleted
          ? FloatingActionButton(
              onPressed: () {
                showConfirmationDialog(context);
              },
              child: Icon(Icons.check),
              backgroundColor: Colors.green,
              tooltip: 'Pindahkan ke dbselesai',
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget buildItemRow(String description, String price,
      [String? qty, String? total]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(description)),
          Expanded(child: Text(price)),
          if (qty != null) Expanded(child: Text(qty)),
          if (total != null) Expanded(child: Text(total)),
        ],
      ),
    );
  }
}
