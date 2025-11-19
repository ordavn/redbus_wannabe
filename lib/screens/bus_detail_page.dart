import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BusDetailPage extends StatelessWidget {
  const BusDetailPage({super.key});

  // Helper format rupiah
  String formatRupiah(int price) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  @override
  Widget build(BuildContext context) {
    // 1. TERIMA DATA DARI HALAMAN SEBELUMNYA
    final busData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (busData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(child: Text("Data bus tidak ditemukan")),
      );
    }

    // 2. AMBIL DATA UTAMA
    final String name = busData['name'] ?? 'Nama Bus';
    final int price = busData['price'] ?? 0;
    final String departureTime = busData['departure'] ?? '--:--';
    final String arrivalTime = busData['arrival'] ?? '--:--';
    final String type = busData['type'] ?? 'Standard';
    final String rating = (busData['rating'] ?? 0.0).toString();
    final String origin = busData['origin'] ?? 'Asal';
    final String destination = busData['destination'] ?? 'Tujuan';

    // 3. AMBIL DATA BARU (TERMINAL)
    // Jika di database belum diisi, akan muncul default 'Terminal ...'
    final String terminalOrigin = busData['terminal_origin'] ?? 'Terminal $origin';
    final String terminalDest = busData['terminal_dest'] ?? 'Terminal $destination';

    // 4. AMBIL DATA BARU (AMENITIES)
    // Kita ambil sebagai List<dynamic> lalu konversi ke List<String>
    final List<dynamic> amenitiesRaw = busData['amenities'] ?? [];
    final List<String> amenities = amenitiesRaw.map((e) => e.toString()).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        // ... (Actions tanggal tetap sama, bisa dinamiskan nanti)
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== BUS INFO CARD (SAMA SEPERTI SEBELUMNYA) =====
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        formatRupiah(price),
                        style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(departureTime, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(origin, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const Text('Est. Time', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(arrivalTime, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(destination, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$name, $type', style: const TextStyle(color: Colors.black54)),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.green, size: 16),
                          const SizedBox(width: 4),
                          Text(rating),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ===== BOARDING POINTS (DINAMIS) =====
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Boarding points',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(departureTime),
                          const Text('Today', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TERMINAL ASAL DARI DATABASE
                          Text(
                            terminalOrigin,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '$terminalOrigin Address',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ===== DROPPING POINTS (DINAMIS) =====
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dropping points',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(arrivalTime),
                          const Text('Today', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TERMINAL TUJUAN DARI DATABASE
                          Text(
                            terminalDest,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '$terminalDest Address',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ===== AMENITIES (DINAMIS LIST) =====
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Amenities',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),

                  // LOGIKA: Jika ada data amenities, tampilkan list.
                  // Jika kosong, tampilkan pesan "No amenities info".
                  if (amenities.isNotEmpty)
                    ...amenities.map((amenityName) {
                      return buildAmenity(amenityName);
                    })
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("No amenities info available.", style: TextStyle(color: Colors.grey)),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ===== CONFIRM BUTTON =====
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/seatSelection', arguments: busData);
            },
            child: const Text(
              'Confirm',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function untuk memilih ikon berdasarkan nama fasilitas
  Widget buildAmenity(String text) {
    IconData icon;

    // Logika sederhana memilih ikon
    if (text.toLowerCase().contains('charging') || text.toLowerCase().contains('power')) {
      icon = Icons.power;
    } else if (text.toLowerCase().contains('food') || text.toLowerCase().contains('drink') || text.toLowerCase().contains('meal')) {
      icon = Icons.fastfood;
    } else if (text.toLowerCase().contains('emergency')) {
      icon = Icons.emergency;
    } else if (text.toLowerCase().contains('fire')) {
      icon = Icons.fire_extinguisher;
    } else if (text.toLowerCase().contains('wifi')) {
      icon = Icons.wifi;
    } else if (text.toLowerCase().contains('tv')) {
      icon = Icons.tv;
    } else if (text.toLowerCase().contains('ac') || text.toLowerCase().contains('air')) {
      icon = Icons.ac_unit;
    } else {
      icon = Icons.check_circle_outline; // Ikon default
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54, size: 20),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}