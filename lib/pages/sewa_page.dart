import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:crud/services/sewa_services.dart';

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
  Map<String, dynamic>? selectedPaket;
  List<Map<String, dynamic>> paketIsi = [];
  double totalCost = 0;

  String invoiceNumber = "";

  @override
  void initState() {
    super.initState();
    invoiceNumber = generateInvoiceNumber();
  }

  String generateInvoiceNumber() {
    DateTime now = DateTime.now();
    return DateFormat('yyyyMMddHHmmss').format(now);
  }

  void calculateTotal() {
    totalCost = selectedBarang.fold(
        0,
        (sum, item) =>
            sum +
            (double.tryParse(item["Harga"].toString()) ?? 0) *
                (item["Jumlah"] ?? 1));
    if (selectedPaket != null) {
      totalCost +=
          double.tryParse(selectedPaket!["Harga Paket"].toString()) ?? 0;
    }
    setState(() {});
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd-MM-yyyy').format(date);
  }

  String formatCurrency(double amount) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(amount);
  }

  Future<void> chooseBarang() async {
    if (selectedPaket != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Anda sudah memilih paket. Hapus paket untuk memilih barang.")));
      return;
    }

    List<Map<String, dynamic>> barangList = await SewaServices.fetchBarang();
    List<bool> selectedCheckboxes = List.filled(barangList.length, false);
    List<int> quantities = List.filled(barangList.length, 1);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Pilih Barang"),
          content: SingleChildScrollView(
            child: Column(
              children: barangList.map((barang) {
                int index = barangList.indexOf(barang);
                return StatefulBuilder(
                  builder: (context, setState) {
                    return Row(
                      children: [
                        Checkbox(
                          value: selectedCheckboxes[index],
                          onChanged: (bool? value) {
                            setState(() {
                              selectedCheckboxes[index] = value ?? false;
                              if (selectedCheckboxes[index]) {
                                selectedBarang.add(
                                    {...barang, "Jumlah": quantities[index]});
                              } else {
                                selectedBarang.removeWhere(
                                    (element) => element['id'] == barang['id']);
                              }
                              calculateTotal();
                            });
                          },
                        ),
                        Expanded(child: Text(barang["Nama Barang"])),
                        Text(formatCurrency(
                            double.tryParse(barang["Harga"].toString()) ?? 0)),
                        SizedBox(width: 10),
                        Container(
                          width: 50,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(hintText: '1'),
                            onChanged: (value) {
                              int qty = int.tryParse(value) ?? 1;
                              setState(() {
                                quantities[index] = qty;
                                if (selectedCheckboxes[index]) {
                                  selectedBarang[selectedBarang.indexWhere(
                                          (element) =>
                                              element['id'] == barang['id'])]
                                      ['Jumlah'] = qty;
                                }
                                calculateTotal();
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Tutup")),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedBarang.clear();
                  for (int i = 0; i < barangList.length; i++) {
                    if (selectedCheckboxes[i]) {
                      selectedBarang
                          .add({...barangList[i], "Jumlah": quantities[i]});
                    }
                  }
                  calculateTotal();
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Anda sudah memilih barang. Hapus barang untuk memilih paket.")));
      return;
    }

    List<Map<String, dynamic>> paketList = await SewaServices.fetchPaket();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Pilih Paket"),
          content: SingleChildScrollView(
            child: Column(
              children: paketList.map((paket) {
                return ListTile(
                  title: Text(paket["Nama Paket"]),
                  subtitle: Text(formatCurrency(
                      double.tryParse(paket["Harga Paket"].toString()) ?? 0)),
                  onTap: () async {
                    setState(() {
                      selectedPaket = paket;
                    });
                    if (selectedPaket != null) {
                      final isiPaketSnapshot = await FirebaseFirestore.instance
                          .collection("dbpaket")
                          .doc(selectedPaket!["id"])
                          .get();
                      if (isiPaketSnapshot.exists) {
                        List<dynamic> isi =
                            isiPaketSnapshot.data()!["Barang"] ?? [];
                        paketIsi.clear();
                        for (var item in isi) {
                          paketIsi.add({
                            "idBarang": item["ID Barang"],
                            "Jumlah": item["Jumlah"],
                            "Nama Barang": item["Nama Barang"]
                          });
                        }
                      }
                    }
                    calculateTotal();
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Tutup")),
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Semua field harus diisi.")));
      return;
    }

    Map<String, dynamic> data = {
      "nama": nameController.text,
      "no_hp": phoneController.text,
      "alamat": addressController.text,
      "tanggal_peminjaman": startDate,
      "tanggal_pengembalian": endDate,
      "barang": selectedBarang,
      "paket": selectedPaket,
      "total_biaya": totalCost,
      "no_invoice": invoiceNumber,
    };

    try {
      await SewaServices.submitData(data: data);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Data berhasil disimpan!")));
      nameController.clear();
      phoneController.clear();
      addressController.clear();
      setState(() {
        selectedBarang.clear();
        selectedPaket = null;
        paketIsi.clear();
        totalCost = 0;
        startDate = null;
        endDate = null;
        invoiceNumber = generateInvoiceNumber();
      });
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $error")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Sewa'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nama')),
            TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'No hp'),
                keyboardType: TextInputType.phone,
                style: TextStyle(fontSize: 16)),
            TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Alamat'),
                style: TextStyle(fontSize: 16)),
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
                    controller:
                        TextEditingController(text: formatDate(startDate)),
                    style: TextStyle(fontSize: 16),
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
                    controller:
                        TextEditingController(text: formatDate(endDate)),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(onPressed: chooseBarang, child: Text('Barang')),
                SizedBox(width: 10),
                ElevatedButton(onPressed: choosePaket, child: Text('Paket')),
                SizedBox(width: 10),
                Text(formatCurrency(totalCost), style: TextStyle(fontSize: 18)),
              ],
            ),
            SizedBox(height: 20),
            Container(
              height: 200,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5)),
              child: ListView.builder(
                itemCount:
                    selectedBarang.length + (selectedPaket != null ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < selectedBarang.length) {
                    final item = selectedBarang[index];
                    double totalItemCost =
                        (double.tryParse(item["Harga"].toString()) ?? 0) *
                            (item["Jumlah"] ?? 1);
                    return ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('(${item["Jumlah"]}x) ${item["Nama Barang"]}',
                              style: TextStyle(fontSize: 12)),
                          Text(formatCurrency(totalItemCost),
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      subtitle: Text(
                          formatCurrency(
                                  double.tryParse(item["Harga"].toString()) ??
                                      0) +
                              '/p',
                          style: TextStyle(fontSize: 12)),
                      trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => removeItem(index)),
                    );
                  } else {
                    return Column(
                      children: [
                        ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(selectedPaket!["Nama Paket"],
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: removePaket),
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: paketIsi.map((item) {
                              return Text(
                                  '   ${item["Jumlah"]}x ${item["Nama Barang"]}',
                                  style: TextStyle(fontSize: 16));
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Batal')),
                ElevatedButton(onPressed: submitData, child: Text('Submit')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void removeItem(int index) {
    setState(() {
      selectedBarang.removeAt(index);
      calculateTotal();
    });
  }

  void removePaket() {
    setState(() {
      selectedPaket = null;
      paketIsi.clear();
      calculateTotal();
    });
  }
}
