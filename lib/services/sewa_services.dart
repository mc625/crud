import 'package:cloud_firestore/cloud_firestore.dart';

class SewaServices {
  static Future<List<Map<String, dynamic>>> fetchBarang() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("dbbarang").get();
    return querySnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchPaket() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("dbpaket").get();
    return querySnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  static Future<void> submitData({required Map<String, dynamic> data}) async {
    await FirebaseFirestore.instance.collection("dbsewa").add(data);
  }
}
