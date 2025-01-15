import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'barang_services.dart';

class PaketSetPage extends StatefulWidget {
  final Map<String, dynamic>? paket;

  PaketSetPage({super.key, this.paket});

  @override
  State<PaketSetPage> createState() => _PaketSetPageState();
}

class _PaketSetPageState extends State<PaketSetPage> {
  List<Map<String, dynamic>> barangList = [];
  List<bool> selectedItems = [];
  List<TextEditingController> jumlahControllers = [];
  final TextEditingController namaPaketController = TextEditingController();
  final TextEditingController hargaPaketController = TextEditingController();

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

      selectedItems = List<bool>.filled(barangList.length, false);
      jumlahControllers =
          List.generate(barangList.length, (index) => TextEditingController());

      if (widget.paket != null) {
        namaPaketController.text = widget.paket!["Nama Paket"];
        hargaPaketController.text = widget.paket!["Harga Paket"];

        for (var barang in widget.paket!["Barang"]) {
          int index = barangList
              .indexWhere((item) => item["id"] == barang["ID Barang"]);
          if (index != -1) {
            selectedItems[index] = true;
            jumlahControllers[index].text = barang["Jumlah"].toString();
          }
        }
      }
    });
  }

  uploadPaket() async {
    if (namaPaketController.text.isEmpty || hargaPaketController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Nama dan harga paket tidak boleh kosong",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    Map<String, dynamic> paketData = {
      "Nama Paket": namaPaketController.text,
      "Harga Paket": hargaPaketController.text,
      "Barang": [],
    };

    for (int i = 0; i < barangList.length; i++) {
      if (selectedItems[i]) {
        int jumlah = int.tryParse(jumlahControllers[i].text) ?? 1;
        paketData["Barang"].add({
          "Nama Barang": barangList[i]["Nama Barang"],
          "ID Barang": barangList[i]["id"],
          "Jumlah": jumlah,
        });
      }
    }

    if (widget.paket != null) {
      await FirebaseFirestore.instance
          .collection("dbpaket")
          .doc(widget.paket!['id'])
          .update(paketData);
      Fluttertoast.showToast(
        msg: "Paket Berhasil Diperbarui",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else {
      await FirebaseFirestore.instance.collection("dbpaket").add(paketData);
      Fluttertoast.showToast(
        msg: "Paket Berhasil Disimpan",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    }
    clearFields();
    Navigator.pop(context);
  }

  void clearFields() {
    namaPaketController.clear();
    hargaPaketController.clear();
    selectedItems.fillRange(0, selectedItems.length, false);
    jumlahControllers.forEach((controller) => controller.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah/Edit Paket',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: namaPaketController,
              decoration: const InputDecoration(labelText: 'Nama Paket'),
            ),
            TextField(
              controller: hargaPaketController,
              decoration: const InputDecoration(labelText: 'Harga Paket'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: barangList.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          title: Text(barangList[index]["Nama Barang"]),
                          value: selectedItems[index],
                          onChanged: (bool? value) {
                            setState(() {
                              selectedItems[index] = value ?? false;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: jumlahControllers[index],
                          decoration: const InputDecoration(
                            labelText: 'Jumlah',
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: uploadPaket,
              child: const Text('Simpan Paket'),
            ),
          ],
        ),
      ),
    );
  }
}
