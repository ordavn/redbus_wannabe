import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SeatSelectionPage extends StatefulWidget {
  const SeatSelectionPage({super.key});

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  final List<int> _selectedSeats = [];
  final int seatPrice = 50000;
  final int totalSeats = 28;

  // Custom Colors
  static const Color _darkGreen = Color(0xFF345D56);
  static const Color _lightGray = Color(0xFFF2F2F2);
  static const Color _teal = Color(0xFF00897B);

  @override
  Widget build(BuildContext context) {
    // Mengambil data bus termasuk ID dokumennya
    final bus = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final String busId = bus?['id'] ?? ''; // Pastikan ID ini ada!

    final int totalPrice = _selectedSeats.length * seatPrice;

    return Scaffold(
      backgroundColor: _lightGray,
      appBar: AppBar(
        backgroundColor: _darkGreen,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Seats',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              bus?['name'] ?? 'Bus Selection',
              style: TextStyle(fontSize: 13.sp, color: Colors.white70),
            ),
          ],
        ),
      ),
      
      // WRAP BODY DENGAN STREAMBUILDER
      // Ini agar kita bisa melihat kursi yang dibooking orang lain secara REAL-TIME
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('trips').doc(busId).snapshots(),
        builder: (context, snapshot) {
          
          // 1. Handle Loading & Error
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Data bus tidak ditemukan"));
          }

          // 2. AMBIL DATA KURSI YANG SUDAH DIBOOKING DARI DATABASE
          // Kita ambil array 'booked_seats'. Jika belum ada, anggap list kosong.
          var busData = snapshot.data!.data() as Map<String, dynamic>;
          List<dynamic> bookedSeatsDynamic = busData['booked_seats'] ?? [];
          List<int> alreadyBookedSeats = bookedSeatsDynamic.map((e) => int.parse(e.toString())).toList();

          return Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      width: 250.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 12.w),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: Icon(
                              Icons.directions_bus,
                              size: 36.sp,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Expanded(
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 7, // 7 Baris
                              itemBuilder: (context, rowIndex) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Kiri: 2 kursi
                                      for (int i = 0; i < 2; i++)
                                        _buildSeat(rowIndex * 4 + i, alreadyBookedSeats),
                                      SizedBox(width: 30.w),
                                      // Kanan: 2 kursi
                                      for (int i = 2; i < 4; i++)
                                        _buildSeat(rowIndex * 4 + i, alreadyBookedSeats),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bagian Bawah (Total & Button)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_selectedSeats.length} Seat',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Rp. ${totalPrice.toString()}', // Formatlah pakai intl kalau mau
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: _teal,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _teal,
                            disabledBackgroundColor: Colors.grey[400],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                          onPressed: _selectedSeats.isEmpty
                              ? null
                              : () {
                                  // Panggil Fungsi Booking Aman
                                  _confirmBooking(context, busId, bus);
                                  Navigator.pushNamed(
                                    context, 
                                      '/payment', // Pindah ke Payment Page dulu
                                    arguments: {
                                      'bus': busData, // Bawa semua data bus
                                      'seats': _selectedSeats, // Bawa kursi yg dipilih
                                      'total': _selectedSeats.length * seatPrice, // Bawa total harga
                                    }
                                  );
                                },
                          child: Text(
                            'Confirm Booking',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget Kursi (Updated dengan logika booked)
  Widget _buildSeat(int index, List<int> alreadyBookedSeats) {
    final isSelected = _selectedSeats.contains(index);
    
    // CEK APAKAH KURSI INI SUDAH ADA DI DATABASE?
    final isUnavailable = alreadyBookedSeats.contains(index); 

    return GestureDetector(
      onTap: isUnavailable
          ? null // Jika sudah dibooking orang, gak bisa dipencet
          : () {
              setState(() {
                if (isSelected) {
                  _selectedSeats.remove(index);
                } else {
                  _selectedSeats.add(index);
                }
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          // Logika Warna:
          // Abu-abu = Punya orang lain (Unavailable)
          // Teal = Kita pilih (Selected)
          // Putih/Border Hitam = Kosong
          color: isUnavailable 
              ? Colors.grey[300] 
              : (isSelected ? _teal : Colors.white),
          border: Border.all(
            color: isUnavailable
                ? Colors.transparent
                : isSelected
                    ? _teal
                    : Colors.black26,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Center(
          child: Icon(
            Icons.event_seat,
            color: isUnavailable
                ? Colors.grey // Icon abu tua kalau booked
                : isSelected
                    ? Colors.white // Icon putih kalau selected
                    : Colors.black54, // Icon hitam kalau kosong
            size: 26.sp,
          ),
        ),
      ),
    );
  }

  // --- LOGIKA TRANSAKSI BOOKING (Anti Bentrok) ---
  Future<void> _confirmBooking(BuildContext context, String busId, Map<String, dynamic>? busData) async {
    // Tampilkan Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final tripRef = FirebaseFirestore.instance.collection('trips').doc(busId);

      // JALANKAN TRANSAKSI DATABASE
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // 1. Baca data bus TERBARU detik ini juga
        DocumentSnapshot snapshot = await transaction.get(tripRef);

        if (!snapshot.exists) {
          throw Exception("Bus trip does not exist!");
        }

        // 2. Ambil list kursi yang sudah laku saat ini
        List<dynamic> currentBooked = snapshot.get('booked_seats') ?? [];
        List<int> bookedList = currentBooked.map((e) => int.parse(e.toString())).toList();

        // 3. CEK TABRAKAN: Apakah kursi yang kita pilih, BARUSAN diambil orang?
        for (int seat in _selectedSeats) {
          if (bookedList.contains(seat)) {
            throw Exception("Oh no! Seat $seat was just taken by someone else."); 
          }
        }

        // 4. Jika aman, gabungkan kursi lama + kursi baru kita
        List<int> newBookedList = [...bookedList, ..._selectedSeats];

        // 5. Update Database
        transaction.update(tripRef, {
          'booked_seats': newBookedList
        });
      });

      // Tutup Loading
      Navigator.pop(context); 

      // Navigasi ke Pembayaran (atau success page)
      // Kirim data kursi yang berhasil diamankan
      Navigator.pushNamed(
        context, 
        '/payment', // Pastikan rute ini ada
        arguments: {
          'bus': busData,
          'seats': _selectedSeats,
          'total': _selectedSeats.length * seatPrice,
        }
      );

    } catch (e) {
      // Tutup Loading
      Navigator.pop(context);
      
      // Tampilkan Pesan Error (Misal: Kursi direbut orang)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: Colors.red,
        ),
      );
      
      // Refresh state (bersihkan pilihan)
      setState(() {
        _selectedSeats.clear();
      });
    }
  }
}