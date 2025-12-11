import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking_model.dart';

class BookingDetailsPage extends StatelessWidget {
  // Menerima data booking dari halaman sebelumnya
  final Booking booking;

  const BookingDetailsPage({super.key, required this.booking});

  // Colors from Figma
  static const Color _darkGreen = Color(0xFF345D56);
  static const Color _lightGray = Color(0xFFF2F2F2);

  @override
  Widget build(BuildContext context) {
    // 1. AMBIL NAMA USER DARI FIREBASE AUTH
    final user = FirebaseAuth.instance.currentUser;
    String displayName = user?.displayName ?? user?.email ?? "User";
    
    // Logika mempercantik nama (ambil depan email & kapitalisasi)
    if (user?.email != null && displayName == user!.email) {
      displayName = user.email!.split('@').first;
      if (displayName.isNotEmpty) {
        displayName = "${displayName[0].toUpperCase()}${displayName.substring(1)}";
      }
    }

    return Scaffold(
      backgroundColor: _lightGray,
      appBar: AppBar(
        backgroundColor: _darkGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Your booking details',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildJourneyCard(),
            SizedBox(height: 16.h),
            // Kirim nama user ke kartu penumpang
            _buildPassengerCard(displayName), 
            SizedBox(height: 16.h),
            _buildBookingCodeCard(),
          ],
        ),
      ),
    );
  }

  // --- KARTU 1: INFO PERJALANAN ---
  Widget _buildJourneyCard() {
    // Format tanggal: "15 Apr Wednesday"
    final String dateFormatted = DateFormat('d MMM EEEE').format(booking.date);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _darkGreen,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildJourneyRow(icon: Icons.adjust, text: booking.from),
          Padding(
            padding: EdgeInsets.only(left: 12.w),
            child: Icon(Icons.more_vert, color: Colors.white, size: 16.sp),
          ),
          _buildJourneyRow(icon: Icons.location_on, text: booking.to),
          
          Divider(color: Colors.white54, height: 24.h),
          
          // REVISI: booking.time (String)
          // booking.duration TIDAK ADA di database, jadi kita hardcode dulu atau hitung
          _buildDetailRow(
            title: booking.time, 
            subtitle: 'Duration: 3h 10m (Est.)' 
          ),
          
          SizedBox(height: 8.h),
          
          // REVISI: booking.busType
          _buildDetailRow(title: dateFormatted, subtitle: booking.busType),
        ],
      ),
    );
  }

  Widget _buildJourneyRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 24.sp),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12.sp, color: Colors.white70),
        ),
      ],
    );
  }

  // --- KARTU 2: INFO PENUMPANG & HARGA ---
  Widget _buildPassengerCard(String passengerName) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          _buildInfoRow('Name', passengerName),
          
          // REVISI: booking.seats (List) -> digabung jadi String "1, 2"
          _buildInfoRow('Seat No', booking.seats.join(', ')),
          
          // REVISI: booking.id (bukan ticketId)
          _buildInfoRow('Ticket No', booking.id),
          
          Divider(height: 24.h),
          
          // REVISI: booking.totalPrice (bukan fare)
          _buildInfoRow(
            'Fare', 
            NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(booking.totalPrice)
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // --- KARTU 3: KODE BOOKING ---
  Widget _buildBookingCodeCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Text(
            'YOUR BOOKING CODE',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 8.h),
          // REVISI: booking.id
          Text(
            booking.id,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: _darkGreen,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}