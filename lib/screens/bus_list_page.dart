import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BusListPage extends StatelessWidget {
  const BusListPage({super.key});

  // Custom Colors (sama dengan HomePage)
  static const Color _darkGreen = Color(0xFF345D56);
  static const Color _lightGray = Color(0xFFF2F2F2);
  static const Color _teal = Color(0xFF00897B);

  // Helper format rupiah
  String formatRupiah(int price) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(price);
  }

  String getTerminalName(String city) {
    // Ubah ke huruf kecil biar aman
    switch (city.toLowerCase()) {
      case 'malang':
        return 'Terminal Arjosari';
      case 'surabaya':
        return 'Terminal Bungurasih';
      case 'jogjakarta':
      case 'yogyakarta':
        return 'Terminal Giwangan';
      case 'jakarta':
        return 'Terminal Pulo Gebang';
      case 'bandung':
        return 'Terminal Leuwipanjang';
      default:
        return 'Terminal $city';
    }
  }

  @override
  Widget build(BuildContext context) {
    // TERIMA DATA DARI HALAMAN SEBELUMNYA
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final String selectedOrigin = args['origin'];
    final String selectedDestination = args['destination'];
    final String selectedDate = args['date'] ?? 'Today';
    final String terminalAsal = getTerminalName(selectedOrigin);
    final String terminalTujuan = getTerminalName(selectedDestination);

    return Scaffold(
      backgroundColor: _lightGray, // WARNA BACKGROUND DIUBAH
      appBar: AppBar(
        backgroundColor: _darkGreen, // WARNA APPBAR DIUBAH
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$selectedOrigin → $selectedDestination',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp, // MENGGUNAKAN .sp
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '$terminalAsal • $terminalTujuan',
              style: TextStyle(fontSize: 13.sp, color: Colors.white70),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(30.h),
          child: Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _teal, // WARNA TAG TANGGAL DIUBAH
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                selectedDate,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        centerTitle: false,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('trips')
            .where('origin', isEqualTo: selectedOrigin)
            .where('destination', isEqualTo: selectedDestination)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: _teal));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(fontSize: 14.sp),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bus_alert, size: 50.sp, color: Colors.grey),
                  SizedBox(height: 10.h),
                  Text(
                    'Tidak ada bus dari $selectedOrigin ke $selectedDestination',
                    style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                  ),
                ],
              ),
            );
          }

          final buses = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(12.w),
            itemCount: buses.length,
            itemBuilder: (context, index) {
              final busData = buses[index].data() as Map<String, dynamic>;

              return InkWell(
                borderRadius: BorderRadius.circular(15.r),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/busDetail',
                    arguments: busData,
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12.r,
                    ), // BORDER RADIUS DISESUAIKAN
                  ),
                  elevation: 2, // ELEVATION DIKURANGI
                  margin: EdgeInsets.only(bottom: 12.h),
                  color: Colors.white, // BACKGROUND CARD PUTIH
                  child: Padding(
                    padding: EdgeInsets.all(14.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // BARIS 1: NAMA BUS & HARGA
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              busData['name'] ?? 'Bus Tanpa Nama',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                color: _darkGreen, // WARNA NAMA BUS DIUBAH
                              ),
                            ),
                            Text(
                              formatRupiah(busData['price'] ?? 0),
                              style: TextStyle(
                                color: _teal, // WARNA HARGA DIUBAH
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),

                        // BARIS 2: JAM BERANGKAT - DURASI - JAM TIBA
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              busData['departure'] ?? '--:--',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  'Est. Time',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                                Icon(
                                  Icons.more_horiz,
                                  size: 18.sp,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                            Text(
                              busData['arrival'] ?? '--:--',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),

                        // BARIS 3: TIPE BUS & RATING
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              busData['type'] ?? 'Standard',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14.sp,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16.sp,
                                  color: _teal, // WARNA BINTANG DIUBAH
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  (busData['rating'] ?? 0.0).toString(),
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14.sp,
                                  ),
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
