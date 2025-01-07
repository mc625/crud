import 'package:crud/pages/dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'pages/barang_page.dart';
import 'pages/login_page.dart';
import 'services/paketset.dart';
import 'pages/paket_page.dart';
import 'pages/sewa_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
        '/dashboard': (context) => const Dashboard(),
        '/barang': (context) => BarangPage(),
        '/paketset': (context) => PaketSetPage(),
        '/paketpage': (context) => PaketPage(),
        '/sewapage': (context) => SewaPage(),
      },
    );
  }
}
