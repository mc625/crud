import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SewaPage extends StatefulWidget {
  @override
  _SewaPageState createState() => _SewaPageState();
}

class _SewaPageState extends State<SewaPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  List<Map<String, dynamic>> selectedBarang = [];
  Map<String, dynamic>? selectedPaket; // Menyimpan paket yang dipilih
  double totalCost = 0;

  void calculateTotal() {
    totalCost = 0;
    for (var item in selectedBarang) {
      double harga = double.tryParse(item["Harga"].toString()) ?? 0;
      totalCost += harga;
    }
    if (selectedPaket != null) {
      totalCost += double.tryParse(selectedPaket!["Harga"].toString()) ?? 0;
    }
    setState(() {});
  }

  Future<void> chooseBarang() async {
    if (selectedPaket != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Anda sudah memilih paket. Hapus paket untuk memilih barang.")),
      );
      return;
    }

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("dbbarang").get();
    List<Map<String, dynamic>> barangList = querySnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Pilih Barang"),
          content: SingleChildScrollView(
            child: Column(
              children: barangList.map((barang) {
                return CheckboxListTile(
                  title: Text(barang["Nama Barang"]),
                  subtitle: Text('Rp ${barang["Harga"]}'),
                  value: selectedBarang.contains(barang),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedBarang.add(barang);
                      } else {
                        selectedBarang.remove(barang);
                      }
                      calculateTotal();
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Submit pilihan barang
                Navigator.of(context).pop();
              },
              child: Text("Tutup"),
            ),
            TextButton(
              onPressed: () {
                // Submit pilihan barang
                setState(() {
                  // Logika untuk menyimpan pilihan barang bisa ditambahkan di sini
                });
                Navigator.of(context).pop();
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  Future<void> choosePaket() async {
    if (selectedBarang.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Anda sudah memilih barang. Hapus barang untuk memilih paket.")),
      );
      return;
    }

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("dbpaket").get();
    List<Map<String, dynamic>> paketList = querySnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Pilih Paket"),
          content: SingleChildScrollView(
            child: Column(
              children: paketList.map((paket) {
                return RadioListTile<Map<String, dynamic>>(
                  title: Text(paket["Nama Paket"]),
                  subtitle: Text('Rp ${paket["Harga"]}'),
                  value: paket,
                  groupValue: selectedPaket,
                  onChanged: (Map<String, dynamic>? value) {
                    setState(() {
                      selectedPaket = value;
                      calculateTotal();
                    });
                    Navigator.of(context)
                        .pop(); // Tutup dialog setelah memilih paket
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Tutup"),
            ),
          ],
        );
      },
    );
  }

  Future<void> submitData() async {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        addressController.text.isEmpty ||
        startDate == null ||
        endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Semua field harus diisi.")),
      );
      return;
    }

    // Membuat data untuk disimpan
    Map<String, dynamic> data = {
      "nama": nameController.text,
      "no_hp": phoneController.text,
      "alamat": addressController.text,
      "tanggal_peminjaman": startDate,
      "tanggal_pengembalian": endDate,
      "barang": selectedBarang,
      "paket": selectedPaket,
      "total_biaya": totalCost,
    };

    // Menyimpan data ke Firestore
    await FirebaseFirestore.instance
        .collection("dbsewa")
        .add(data)
        .then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data berhasil disimpan!")),
      );
      // Reset data setelah menyimpan
      nameController.clear();
      phoneController.clear();
      addressController.clear();
      setState(() {
        selectedBarang.clear();
        selectedPaket = null;
        totalCost = 0;
        startDate = null;
        endDate = null;
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $error")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Sewa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'No hp'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'Alamat'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration:
                        InputDecoration(labelText: 'Tanggal Peminjaman'),
                    readOnly: true,
                    onTap: () async {
                      startDate = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      setState(() {});
                    },
                    controller: TextEditingController(
                      text: startDate == null
                          ? ''
                          : "${startDate!.toLocal()}".split(' ')[0],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration:
                        InputDecoration(labelText: 'Tanggal Pengembalian'),
                    readOnly: true,
                    onTap: () async {
                      endDate = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      setState(() {});
                    },
                    controller: TextEditingController(
                      text: endDate == null
                          ? ''
                          : "${endDate!.toLocal()}".split(' ')[0],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: chooseBarang,
                  child: Text('Pilih Barang'),
                ),
                ElevatedButton(
                  onPressed: choosePaket,
                  child: Text('Pilih Paket'),
                ),
                Text('Rp $totalCost', style: TextStyle(fontSize: 20)),
              ],
            ),
            SizedBox(height: 20),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: ListView.builder(
                itemCount:
                    selectedBarang.length + (selectedPaket != null ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < selectedBarang.length) {
                    final item = selectedBarang[index];
                    return ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item["Nama Barang"]),
                          Text('Rp ${item["Harga"]}'),
                        ],
                      ),
                    );
                  } else {
                    return ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(selectedPaket!["Nama Paket"]),
                          Text('Rp ${selectedPaket!["Harga"]} (Paket)'),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: submitData,
                  child: Text('Submit'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Batal'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
