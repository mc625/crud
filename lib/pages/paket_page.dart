import 'package:flutter/material.dart';
import '../services/paketset.dart';
import '../services/paket_services.dart';

class PaketPage extends StatefulWidget {
  PaketPage({super.key});

  @override
  State<PaketPage> createState() => _PaketPageState();
}

class _PaketPageState extends State<PaketPage> {
  List<Map<String, dynamic>> paketList = [];
  final PaketServices paketServices =
      PaketServices(); // Inisialisasi PaketServices

  @override
  void initState() {
    super.initState();
    fetchAllPaket();
  }

  Future<void> fetchAllPaket() async {
    paketList = await paketServices.fetchAllPaket();
    setState(() {});
  }

  void deletePaket(String id) async {
    await paketServices.deletePaket(id);
    fetchAllPaket(); // Ambil kembali daftar paket
  }

  void editPaket(Map<String, dynamic> paket) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaketSetPage(paket: paket),
      ),
    ).then((_) {
      fetchAllPaket(); // Refresh daftar setelah kembali
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Paket'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: paketList.isEmpty
                  ? Center(child: Text("Tidak ada paket yang tersedia"))
                  : ListView.builder(
                      itemCount: paketList.length,
                      itemBuilder: (context, index) {
                        final paket = paketList[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          padding: const EdgeInsets.all(16.0),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: Colors.blue, width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    paket["Nama Paket"],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  Text(
                                    'Rp.${paket["Harga Paket"]}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              ...paket["Barang"].map<Widget>((item) {
                                return Text(
                                    '${item["Jumlah"]}x ${item["Nama Barang"]}');
                              }).toList(),
                              const SizedBox(height: 8.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () => editPaket(paket),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () => deletePaket(paket['id']),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaketSetPage(),
                  ),
                ).then((_) {
                  fetchAllPaket(); // Refresh daftar setelah kembali
                });
              },
              child: const Text('Tambah Paket'),
            ),
          ],
        ),
      ),
    );
  }
}
