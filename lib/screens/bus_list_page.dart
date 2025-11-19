import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BusListPage extends StatelessWidget {
  const BusListPage({super.key});

  // Helper format rupiah
  String formatRupiah(int price) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  String getTerminalName(String city) {
    // Ubah ke huruf kecil biar aman
    switch (city.toLowerCase()) {
      case 'malang':
        return 'Terminal Arjosari';
      case 'surabaya':
        return 'Terminal Bungurasih'; // Purabaya
      case 'jogjakarta':
      case 'yogyakarta':
        return 'Terminal Giwangan';
      case 'jakarta':
        return 'Terminal Pulo Gebang';
      case 'bandung':
        return 'Terminal Leuwipanjang';
      default:
        return 'Terminal $city'; // Default kalau kota tidak dikenal
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. TERIMA DATA DARI HALAMAN SEBELUMNYA
    final Map<String, dynamic> args = 
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    
    final String selectedOrigin = args['origin'];      // "Malang"
    final String selectedDestination = args['destination']; // "Jogjakarta"
    final String selectedDate = args['date'] ?? 'Today'; 
    final String terminalAsal = getTerminalName(selectedOrigin);
    final String terminalTujuan = getTerminalName(selectedDestination);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2. JUDUL DINAMIS (Sesuai Pilihan User)
            Text(
              '$selectedOrigin → $selectedDestination', 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              '$terminalAsal • $terminalTujuan', // Nanti bisa didinamiskan juga
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[800],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                selectedDate, // Tanggal Dinamis
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        ),
        centerTitle: false,
      ),

      // 3. FILTER QUERY DATABASE
// ... (Bagian atas kode BusListPage tetap sama) ...

      // GANTI BAGIAN BODY DENGAN INI:
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('trips')
            .where('origin', isEqualTo: selectedOrigin)
            .where('destination', isEqualTo: selectedDestination)
            .snapshots(),
        
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
             return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bus_alert, size: 50, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text(
                    'Tidak ada bus dari $selectedOrigin ke $selectedDestination',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final buses = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: buses.length,
            itemBuilder: (context, index) {
              // 1. AMBIL DATA DARI FIREBASE
              final busData = buses[index].data() as Map<String, dynamic>;

              return InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  // Navigasi ke detail bus (opsional)
                  Navigator.pushNamed(context, '/busDetail', arguments: busData);
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- BARIS 1: NAMA BUS & HARGA ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              busData['name'] ?? 'Bus Tanpa Nama',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                            Text(
                              // Format Harga (pastikan ada fungsi formatRupiah di class ini)
                              formatRupiah(busData['price'] ?? 0),
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // --- BARIS 2: JAM BERANGKAT - DURASI - JAM TIBA ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              busData['departure'] ?? '--:--', // Jam Berangkat
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Column(
                              children: [
                                Text(
                                  'Est. Time', // Bisa dihitung manual nanti
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Icon(
                                  Icons.more_horiz,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                            Text(
                              busData['arrival'] ?? '--:--', // Jam Tiba
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // --- BARIS 3: TIPE BUS & RATING ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              busData['type'] ?? 'Standard', // Tipe Bus
                              style: const TextStyle(color: Colors.black54),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  // Pastikan rating diubah jadi String
                                  (busData['rating'] ?? 0.0).toString(),
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}