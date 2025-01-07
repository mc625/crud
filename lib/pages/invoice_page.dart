import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class InvoicePage extends StatelessWidget {
  final String sewaId;

  InvoicePage({required this.sewaId});

  Future<Map<String, dynamic>?> fetchSewaData() async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('dbsewa').doc(sewaId).get();

    return snapshot.data() as Map<String, dynamic>?;
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd-MM-yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice Sewa'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchSewaData(),
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
          final paket = data['paket']
              as Map<String, dynamic>?; // Mengambil paket, jika ada

          List<Widget> barangWidgets = [];
          if (barang.isNotEmpty) {
            barangWidgets.add(Text('Barang yang Disewa:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)));
            barangWidgets.addAll(barang.map((item) {
              return Text(
                  '${item["Nama Barang"]} (x${item["Jumlah"]}) - Rp ${item["Harga"]}',
                  style: TextStyle(fontSize: 16));
            }).toList());
          }

          List<Widget> paketWidgets = [];
          if (paket != null) {
            paketWidgets.add(Text('${paket["Nama Paket"]}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)));

            // Menambahkan detail isi dari paket
            final barangDalamPaket = paket['Barang'] as List<dynamic>? ?? [];
            if (barangDalamPaket.isNotEmpty) {
              paketWidgets.addAll(barangDalamPaket.map((item) {
                return Text('${item["Jumlah"]}x ${item["Nama Barang"]}',
                    style: TextStyle(fontSize: 16));
              }).toList());
            }
          } else {
            paketWidgets.add(Text('Tidak ada paket yang disewa.',
                style: TextStyle(fontSize: 16)));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nama Penyewa: ${data['nama']}',
                    style: TextStyle(fontSize: 18)),
                Text('No HP: ${data['no_hp']}', style: TextStyle(fontSize: 18)),
                Text('Alamat: ${data['alamat']}',
                    style: TextStyle(fontSize: 18)),
                Text(
                    'Tanggal Peminjaman: ${formatDate((data['tanggal_peminjaman'] as Timestamp).toDate())}',
                    style: TextStyle(fontSize: 18)),
                Text(
                    'Tanggal Pengembalian: ${formatDate((data['tanggal_pengembalian'] as Timestamp).toDate())}',
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 20),
                Text('Total Biaya: Rp ${data['total_biaya']}',
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 20),
                ...barangWidgets,
                SizedBox(height: 20),
                ...paketWidgets,
              ],
            ),
          );
        },
      ),
    );
  }
}
