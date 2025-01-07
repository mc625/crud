import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class PaketServices {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchAllPaket() async {
    QuerySnapshot querySnapshot = await firestore.collection("dbpaket").get();
    return querySnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Menyimpan ID dokumen
      return data;
    }).toList();
  }

  Future<void> deletePaket(String id) async {
    await firestore.collection("dbpaket").doc(id).delete();
    Fluttertoast.showToast(
      msg: "Paket Berhasil Dihapus",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}
