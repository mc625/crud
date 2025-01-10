import 'package:crud/pages/dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'pages/barang_page.dart';
import 'pages/login_page.dart';
import 'services/paketset.dart';
import 'pages/paket_page.dart';
import 'pages/sewa_page.dart';
import 'pages/laporan_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyDUH31l2JrxMRel8_WSVskDc8tWwNojl8g",
        authDomain: "crudapp-78677.firebaseapp.com",
        projectId: "crudapp-78677",
        storageBucket: "crudapp-78677.firebasestorage.app",
        messagingSenderId: "932419693269",
        appId: "1:932419693269:web:40af1d4c320005b414905c",
        measurementId: "G-NJ1YD6N6EF",
      ),
    ); // Konfigurasi untuk web
  } else {
    await Firebase.initializeApp(); // Konfigurasi untuk mobile
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rental App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/dashboard': (context) => Dashboard(),
        '/barang': (context) => BarangPage(),
        '/paketset': (context) => PaketSetPage(),
        '/paketpage': (context) => PaketPage(),
        '/sewapage': (context) => SewaPage(),
        '/laporan': (context) => LaporanPage(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }
}
