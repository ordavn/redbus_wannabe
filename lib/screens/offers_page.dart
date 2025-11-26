import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firebase
import 'package:intl/intl.dart'; // Import DateFormat
import '../models/offers_model.dart'; // Import Model

// --- WIDGET UTAMA: OffersScreen ---
class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  int _currentBottomNavIndex = 0; 

  // Colors
  static const Color _darkGreen = Color(0xFF2F5233);
  static const Color _teal = Color(0xFF16A085);
  static const Color _lightGray = Color(0xFFF2F2F2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightGray,
      appBar: AppBar(
        title: Text(
          'Offers',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: _darkGreen,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
      ),
      
      // --- GUNAKAN STREAMBUILDER DI SINI ---
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('offers')
            // Hanya tampilkan promo yang masih berlaku
            .where('valid_until', isGreaterThan: Timestamp.now()) 
            .snapshots(),
        builder: (context, snapshot) {
          // 1. Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: _teal));
          }

          // 2. Error
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // 3. Empty
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          // 4. Data Ada -> Konversi ke List<Offer>
          final offers = snapshot.data!.docs
              .map((doc) => Offer.fromFirestore(doc))
              .toList();

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            itemCount: offers.length,
            itemBuilder: (context, index) {
              return OfferCardWidget(offer: offers[index]);
            },
          );
        },
      ),
      
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_offer_outlined, size: 80.sp, color: Colors.grey),
          SizedBox(height: 16.h),
          Text("No offers available", style: TextStyle(fontSize: 18.sp, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentBottomNavIndex,
      onTap: (index) {
        setState(() => _currentBottomNavIndex = index);
        switch (index) {
          case 0: break; // Offers (Current)
          case 1: Navigator.pushReplacementNamed(context, '/bookings'); break;
          case 2: Navigator.pushReplacementNamed(context, '/profile'); break;
        }
      },
      selectedItemColor: _teal,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: 'Offers'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Bookings'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}

// --- WIDGET KARTU PROMO ---
class OfferCardWidget extends StatelessWidget {
  final Offer offer; // Pakai Model Offer

  const OfferCardWidget({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    // Format Tanggal: "26 Oct"
    String validDate = DateFormat('d MMM').format(offer.validUntil);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: offer.backgroundColor, // Warna dari Firebase
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.local_offer, color: Colors.white, size: 24.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    offer.title,
                    style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            
            // Content
            Text(
              offer.description,
              style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w700),
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            
            // Valid Until
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.white70, size: 16.sp),
                SizedBox(width: 4.w),
                Text("Valid till: $validDate", style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
              ],
            ),
            SizedBox(height: 24.h),

            // Coupon Code Section
            Row(
              children: [
                Text("Use code:", style: TextStyle(color: Colors.white70, fontSize: 16.sp)),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: offer.couponCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Code ${offer.couponCode} copied!")),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Text(
                          offer.couponCode,
                          style: TextStyle(
                            color: offer.backgroundColor, // Teks warna background
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(Icons.copy, size: 16.sp, color: offer.backgroundColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}