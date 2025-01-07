import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future<void> addBarangDetails(Map<String, dynamic> barangInfoMap) async {
    return await FirebaseFirestore.instance
        .collection("dbbarang")
        .doc()
        .set(barangInfoMap);
  }

  Future<QuerySnapshot> getthisBarangInfo(String namabarang) async {
    return await FirebaseFirestore.instance
        .collection("dbbarang")
        .where("Nama Barang", isEqualTo: namabarang)
        .get();
  }

  Future<void> updateBarangDetails(String id, Map<String, dynamic> data) async {
    return await FirebaseFirestore.instance
        .collection("dbbarang")
        .doc(id)
        .update(data);
  }

  Future<void> deleteBarang(String id) async {
    return await FirebaseFirestore.instance
        .collection("dbbarang")
        .doc(id)
        .delete();
  }

  Future<QuerySnapshot> getAllBarang() async {
    return await FirebaseFirestore.instance.collection('dbbarang').get();
  }
}
