import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BusDetailPage extends StatelessWidget {
  const BusDetailPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    // 1. TERIMA DATA DARI HALAMAN SEBELUMNYA
    final busData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

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
    final String terminalOrigin =
        busData['terminal_origin'] ?? 'Terminal $origin';
    final String terminalDest =
        busData['terminal_dest'] ?? 'Terminal $destination';

    // 4. AMBIL DATA BARU (AMENITIES)
    final List<dynamic> amenitiesRaw = busData['amenities'] ?? [];
    final List<String> amenities = amenitiesRaw
        .map((e) => e.toString())
        .toList();

    return Scaffold(
      backgroundColor: _lightGray, // WARNA BACKGROUND DIUBAH
      appBar: AppBar(
        backgroundColor: _darkGreen, // WARNA APPBAR DIUBAH
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          name,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
      ),

      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // ===== BUS INFO CARD =====
          Card(
            elevation: 2, // ELEVATION DIKURANGI
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: _darkGreen, // WARNA NAMA BUS DIUBAH
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      Text(
                        formatRupiah(price),
                        style: TextStyle(
                          color: _teal, // WARNA HARGA DIUBAH
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            departureTime,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp,
                            ),
                          ),
                          Text(
                            origin,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Est. Time',
                        style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            arrivalTime,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp,
                            ),
                          ),
                          Text(
                            destination,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$name, $type',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14.sp,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: _teal, // WARNA BINTANG DIUBAH
                            size: 16.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(rating, style: TextStyle(fontSize: 14.sp)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // ===== BOARDING POINTS =====
          Card(
            elevation: 2,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Boarding points',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            departureTime,
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          Text(
                            'Today',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            terminalOrigin,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                          Text(
                            '$terminalOrigin Address',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12.sp,
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

          SizedBox(height: 10.h),

          // ===== DROPPING POINTS =====
          Card(
            elevation: 2,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dropping points',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(arrivalTime, style: TextStyle(fontSize: 14.sp)),
                          Text(
                            'Today',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            terminalDest,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                          Text(
                            '$terminalDest Address',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12.sp,
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

          SizedBox(height: 10.h),

          // ===== AMENITIES =====
          Card(
            elevation: 2,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amenities',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  if (amenities.isNotEmpty)
                    ...amenities.map((amenityName) {
                      return buildAmenity(amenityName);
                    })
                  else
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Text(
                        "No amenities info available.",
                        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                      ),
                    ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // ===== CONFIRM BUTTON =====
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _teal, // WARNA BUTTON DIUBAH
              minimumSize: Size(double.infinity, 50.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/seatSelection',
                arguments: busData,
              );
            },
            child: Text(
              'Confirm',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
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
    if (text.toLowerCase().contains('charging') ||
        text.toLowerCase().contains('power')) {
      icon = Icons.power;
    } else if (text.toLowerCase().contains('food') ||
        text.toLowerCase().contains('drink') ||
        text.toLowerCase().contains('meal')) {
      icon = Icons.fastfood;
    } else if (text.toLowerCase().contains('emergency')) {
      icon = Icons.emergency;
    } else if (text.toLowerCase().contains('fire')) {
      icon = Icons.fire_extinguisher;
    } else if (text.toLowerCase().contains('wifi')) {
      icon = Icons.wifi;
    } else if (text.toLowerCase().contains('tv')) {
      icon = Icons.tv;
    } else if (text.toLowerCase().contains('ac') ||
        text.toLowerCase().contains('air')) {
      icon = Icons.ac_unit;
    } else {
      icon = Icons.check_circle_outline; // Ikon default
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Icon(
            icon,
            color: _teal, // WARNA ICON AMENITIES DIUBAH
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Text(
            text,
            style: TextStyle(color: Colors.black87, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}
