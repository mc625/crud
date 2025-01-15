import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../services/barang_services.dart';

class BarangPage extends StatefulWidget {
  BarangPage({super.key});

  @override
  State<BarangPage> createState() => _BarangPageState();
}

class _BarangPageState extends State<BarangPage> {
  List<Map<String, dynamic>> barangList = [];

  final TextEditingController namaBarangController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();
  String? selectedId;

  @override
  void initState() {
    super.initState();
    fetchAllBarang();
  }

  Future<void> fetchAllBarang() async {
    QuerySnapshot querySnapshot = await DatabaseMethods().getAllBarang();
    setState(() {
      barangList = querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  uploadData() async {
    double? harga = double.tryParse(hargaController.text);

    if (harga == null) {
      Fluttertoast.showToast(
          msg: "Harga tidak valid.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    Map<String, dynamic> uploaddata = {
      "Nama Barang": namaBarangController.text,
      "Harga": harga,
    };

    if (selectedId != null) {
      await DatabaseMethods().updateBarangDetails(selectedId!, uploaddata);
      Fluttertoast.showToast(
          msg: "Barang Berhasil Diedit",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      await DatabaseMethods().addBarangDetails(uploaddata);
      Fluttertoast.showToast(
          msg: "Barang Berhasil Disimpan",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    }

    fetchAllBarang();
    clearFields();
  }

  void clearFields() {
    namaBarangController.clear();
    hargaController.clear();
    selectedId = null;
  }

  void editBarang(Map<String, dynamic> barang) {
    namaBarangController.text = barang["Nama Barang"];
    hargaController.text = barang["Harga"].toString();
    selectedId = barang["id"];
  }

  void deleteBarang(String id) async {
    await DatabaseMethods().deleteBarang(id);
    Fluttertoast.showToast(
        msg: "Barang Berhasil Dihapus",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
    fetchAllBarang();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah/Edit Barang',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: namaBarangController,
              decoration: const InputDecoration(labelText: 'Nama Barang'),
            ),
            TextField(
              controller: hargaController,
              decoration: const InputDecoration(labelText: 'Harga'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => uploadData(),
              child: const Text('Submit'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: barangList.length,
                itemBuilder: (context, index) {
                  final barang = barangList[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                        "${barang["Nama Barang"]}",
                        style: TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                      subtitle: Text(
                        "Rp ${NumberFormat('#,###').format(barang["Harga"] is num ? barang["Harga"] : double.tryParse(barang["Harga"].toString()) ?? 0)}",
                        style: TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => editBarang(barang),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => deleteBarang(barang['id']),
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
    );
  }
}
