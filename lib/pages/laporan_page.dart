import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'invoice_page.dart';

class LaporanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<QuerySnapshot>>(
        future: Future.wait([
          FirebaseFirestore.instance.collection('dbsewa').get(),
          FirebaseFirestore.instance.collection('dbselesai').get(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          final sewaDocs = snapshot.data![0].docs;
          final selesaiDocs = snapshot.data![1].docs;

          if (sewaDocs.isEmpty && selesaiDocs.isEmpty) {
            return Center(child: Text('Data tidak ditemukan.'));
          }

          double totalPemasukanAktif = 0;
          double totalPemasukanSelesai = 0;

          sewaDocs.forEach((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final harga = data['total_biaya'] ?? 0;
            totalPemasukanAktif += harga;
          });

          selesaiDocs.forEach((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final harga = data['total_biaya'] ?? 0;
            totalPemasukanSelesai += harga;
          });

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sewa Aktif',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Rp ${NumberFormat('#,###').format(totalPemasukanAktif)}',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 3),
                Expanded(
                  child: ListView.builder(
                    itemCount: sewaDocs.length,
                    itemBuilder: (context, index) {
                      final data =
                          sewaDocs[index].data() as Map<String, dynamic>;
                      final laporan = data['nama'] ?? 'Tanpa Nama';
                      final harga = data['total_biaya'] ?? 0;
                      final sewaId = sewaDocs[index].id;

                      final tanggalPengembalian = data['tanggal_pengembalian'];
                      String tanggalPengembalianFormatted = '';
                      if (tanggalPengembalian != null) {
                        tanggalPengembalianFormatted = DateFormat('dd-MM-yyyy')
                            .format(tanggalPengembalian.toDate());
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InvoicePage(
                                sewaId: sewaId,
                                isCompleted: false,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${index + 1}: $laporan'),
                                  SizedBox(height: 4),
                                  Text(
                                    'Pengembalian: $tanggalPengembalianFormatted',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.black87),
                                  ),
                                ],
                              ),
                              Text('Rp ${NumberFormat('#,###').format(harga)}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sewa Selesai',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Rp ${NumberFormat('#,###').format(totalPemasukanSelesai)}',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 3),
                Expanded(
                  child: ListView.builder(
                    itemCount: selesaiDocs.length,
                    itemBuilder: (context, index) {
                      final data =
                          selesaiDocs[index].data() as Map<String, dynamic>;
                      final laporan = data['nama'] ?? 'Tanpa Nama';
                      final harga = data['total_biaya'] ?? 0;
                      final selesaiId = selesaiDocs[index].id;

                      final tanggalPengembalian = data['tanggal_pengembalian'];
                      String tanggalPengembalianFormatted = '';
                      if (tanggalPengembalian != null) {
                        tanggalPengembalianFormatted = DateFormat('dd-MM-yyyy')
                            .format(tanggalPengembalian.toDate());
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InvoicePage(
                                sewaId: selesaiId,
                                isCompleted: true,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${index + 1}: $laporan'),
                                  SizedBox(height: 4),
                                  Text(
                                    'Pengembalian: $tanggalPengembalianFormatted',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.black87),
                                  ),
                                ],
                              ),
                              Text('Rp ${NumberFormat('#,###').format(harga)}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
