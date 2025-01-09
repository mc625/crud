import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:crud/pages/invoice_page.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final int _limit = 25; // Batasi jumlah item yang ditampilkan
  DocumentSnapshot?
      _lastDocument; // Untuk menyimpan dokumen terakhir yang dimuat
  List<Map<String, dynamic>> _rentals = []; // Daftar sewa aktif

  @override
  void initState() {
    super.initState();
    fetchActiveRentals();
  }

  Future<void> fetchActiveRentals() async {
    Query query = FirebaseFirestore.instance
        .collection("dbsewa")
        .orderBy("tanggal_peminjaman") // Urutkan berdasarkan tanggal peminjaman
        .limit(_limit); // Menggunakan limit yang baru

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    QuerySnapshot querySnapshot = await query.get();
    if (querySnapshot.docs.isNotEmpty) {
      _lastDocument = querySnapshot.docs.last; // Simpan dokumen terakhir
      List<Map<String, dynamic>> rentals = querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Menyimpan ID dokumen
        return data;
      }).toList();

      setState(() {
        _rentals.addAll(rentals); // Tambahkan data baru ke daftar
      });
    }
  }

  // Fungsi untuk memformat tanggal
  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd-MM-yyyy').format(date); // Format tanggal-bulan-tahun
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        backgroundColor: Colors.blue,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    title: Image.asset(
                      'assets/images/logo_soko.png',
                      height: 150,
                      width: 150,
                    ),
                    onTap: () => Navigator.pushNamed(context, '/dashboard'),
                  ),
                  ListTile(
                    title: const Text('Dashboard',
                        style: TextStyle(color: Colors.white)),
                    onTap: () => Navigator.pushNamed(context, '/dashboard'),
                  ),
                  ListTile(
                    title: const Text('Barang',
                        style: TextStyle(color: Colors.white)),
                    onTap: () => Navigator.pushNamed(context, '/barang'),
                  ),
                  ListTile(
                    title: const Text('Paket',
                        style: TextStyle(color: Colors.white)),
                    onTap: () => Navigator.pushNamed(context, '/paketpage'),
                  ),
                  ListTile(
                    title: const Text('Laporan',
                        style: TextStyle(color: Colors.white)),
                    onTap: () => Navigator.pushNamed(context, '/paketpage'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _rentals.clear(); // Bersihkan daftar saat refresh
              _lastDocument = null; // Reset dokumen terakhir
            });
            await fetchActiveRentals(); // Muat ulang data
          },
          child: Column(
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount:
                      _rentals.length + 1, // Tambahkan 1 untuk tombol load more
                  itemBuilder: (context, index) {
                    if (index == _rentals.length) {
                      // Tampilkan tombol load more jika belum memuat semua data
                      return ElevatedButton(
                        onPressed: fetchActiveRentals,
                        child: const Text('Load More'),
                      );
                    }

                    final rental = _rentals[index];

                    // Format tanggal
                    String formattedStartDate = formatDate(
                        (rental["tanggal_peminjaman"] as Timestamp).toDate());
                    String formattedEndDate = formatDate(
                        (rental["tanggal_pengembalian"] as Timestamp).toDate());

                    return GestureDetector(
                      onTap: () {
                        // Navigasi ke halaman invoice dengan ID sewa
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                InvoicePage(sewaId: rental['id']),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        padding: const EdgeInsets.all(16.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: Colors.blue, width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  rental[
                                      "nama"], // Ganti dengan field yang sesuai
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Rp.${rental["total_biaya"]}', // Ganti dengan field yang sesuai
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Tgl Peminjaman: $formattedStartDate', // Tampilkan tanggal yang diformat
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              'Tgl Pengembalian: $formattedEndDate', // Tampilkan tanggal yang diformat
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/sewapage');
        },
      ),
    );
  }
}
