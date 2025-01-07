import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        backgroundColor: Colors.blue,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    title: const Text('Dashboard',
                        style: TextStyle(color: Colors.white)),
                    onTap: () => Navigator.pushNamed(context, '/dashboard'),
                  ),
                  ListTile(
                    title: const Text('Barang',
                        style: TextStyle(color: Colors.white)),
                    onTap: () => Navigator.pushNamed(context, '/barang'),
                  ),
                  ListTile(
                    title: const Text('Paket',
                        style: TextStyle(color: Colors.white)),
                    onTap: () => Navigator.pushNamed(context, '/paketpage'),
                  ),
                  ListTile(
                    title: const Text('Sewa',
                        style: TextStyle(color: Colors.white)),
                    onTap: () => Navigator.pushNamed(context, '/sewapage'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'SEWA AKTIF',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/');
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.blue, width: 1.5),
                ),
                child: const Text(
                  'Data Aktif 1',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/sewa');
        },
      ),
    );
  }
}
