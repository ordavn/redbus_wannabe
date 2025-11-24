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

  final int totalSeats = 28; // 7 baris x 4 kolom (2 kiri + 2 kanan)

  // Custom Colors (sama dengan HomePage)
  static const Color _darkGreen = Color(0xFF345D56);
  static const Color _lightGray = Color(0xFFF2F2F2);
  static const Color _teal = Color(0xFF00897B);

  @override
  Widget build(BuildContext context) {
    final bus =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    final int totalPrice = _selectedSeats.length * seatPrice;

    return Scaffold(
      backgroundColor: _lightGray, // WARNA BACKGROUND DIUBAH
      appBar: AppBar(
        backgroundColor: _darkGreen, // WARNA APPBAR DIUBAH
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
              'Terminal Arjosari Malang',
              style: TextStyle(fontSize: 13.sp, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: Padding(
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
                  padding: EdgeInsets.symmetric(
                    vertical: 24.h,
                    horizontal: 12.w,
                  ),
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
                          itemCount: 7, // jumlah baris
                          itemBuilder: (context, rowIndex) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Kiri: 2 kursi
                                  for (int i = 0; i < 2; i++)
                                    _buildSeat(rowIndex * 4 + i),
                                  SizedBox(width: 30.w), // jarak tengah
                                  // Kanan: 2 kursi
                                  for (int i = 2; i < 4; i++)
                                    _buildSeat(rowIndex * 4 + i),
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

            // Bagian bawah
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
                        'Rp. ${totalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: _teal, // WARNA HARGA DIUBAH
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _teal, // WARNA BUTTON DIUBAH
                        disabledBackgroundColor: Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      onPressed: _selectedSeats.isEmpty
                          ? null
                          : () {
                              Navigator.pushNamed(
                                context,
                                '/payment',
                                arguments: {
                                  'bus': bus,
                                  'seats': _selectedSeats,
                                  'total': totalPrice,
                                },
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeat(int index) {
    final isSelected = _selectedSeats.contains(index);
    final isUnavailable = index % 5 == 0; // contoh dummy unavailable seat

    return GestureDetector(
      onTap: isUnavailable
          ? null
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
          border: Border.all(
            color: isUnavailable
                ? Colors.grey
                : isSelected
                ? _teal // WARNA BORDER SEAT SELECTED DIUBAH
                : Colors.black,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Center(
          child: Icon(
            Icons.event_seat,
            color: isUnavailable
                ? Colors.grey
                : isSelected
                ? _teal // WARNA ICON SEAT SELECTED DIUBAH
                : Colors.black,
            size: 26.sp,
          ),
        ),
      ),
    );
  }
}
