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
    final bus = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final String busId = bus?['id'] ?? ''; 

    final int totalPrice = _selectedSeats.length * seatPrice;

    String dateStr = bus!['travelDate']?.substring(0, 10) ?? DateTime.now().toIso8601String().substring(0, 10);
    String sessionDocId = '${busId}_$dateStr'; 

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
              bus['name'] ?? 'Bus Selection',
              style: TextStyle(fontSize: 13.sp, color: Colors.white70),
            ),
          ],
        ),
      ),
      
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('trip_sessions')
            .doc(sessionDocId)
            .snapshots(),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<int> alreadyBookedSeats = [];

          if (snapshot.hasData && snapshot.data!.exists) {
            var sessionData = snapshot.data!.data() as Map<String, dynamic>;
            List<dynamic> bookedSeatsDynamic = sessionData['booked_seats'] ?? [];
            alreadyBookedSeats = bookedSeatsDynamic.map((e) => int.parse(e.toString())).toList();
          }

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
                              itemCount: 7, 
                              itemBuilder: (context, rowIndex) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      for (int i = 0; i < 2; i++)
                                        _buildSeat(rowIndex * 4 + i, alreadyBookedSeats),
                                      SizedBox(width: 30.w),
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
                            'Rp. ${totalPrice.toString()}',
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
                                  _confirmBooking(context, busId, bus);
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

  Widget _buildSeat(int index, List<int> alreadyBookedSeats) {
    final isSelected = _selectedSeats.contains(index);
    final isUnavailable = alreadyBookedSeats.contains(index); 

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
                ? Colors.grey
                : isSelected
                    ? Colors.white
                    : Colors.black54,
            size: 26.sp,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmBooking(BuildContext context, String busId, Map<String, dynamic>? busData) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String dateStr = busData!['travelDate']?.substring(0, 10) ?? DateTime.now().toIso8601String().substring(0, 10);
      String sessionDocId = '${busId}_$dateStr';

      final sessionRef = FirebaseFirestore.instance.collection('trip_sessions').doc(sessionDocId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(sessionRef);

        List<int> currentBooked = [];

        if (snapshot.exists) {
          List<dynamic> data = snapshot.get('booked_seats') ?? [];
          currentBooked = data.map((e) => int.parse(e.toString())).toList();
        }

        for (int seat in _selectedSeats) {
          if (currentBooked.contains(seat)) {
            throw Exception("Oh no! Seat $seat was just taken by someone else."); 
          }
        }

        List<int> newBookedList = [...currentBooked, ..._selectedSeats];

        if (snapshot.exists) {
          transaction.update(sessionRef, {'booked_seats': newBookedList});
        } else {
          transaction.set(sessionRef, {
            'tripId': busId,
            'date': dateStr,
            'booked_seats': newBookedList
          });
        }
      });

      Navigator.pop(context); 

      Navigator.pushNamed(
        context, 
        '/payment',
        arguments: {
          'bus': busData,
          'seats': _selectedSeats,
          'total': _selectedSeats.length * seatPrice,
        }
      );

    } catch (e) {
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: Colors.red,
        ),
      );
      
      setState(() {
        _selectedSeats.clear();
      });
    }
  }
}