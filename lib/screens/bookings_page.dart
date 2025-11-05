import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';
import 'booking_details_page.dart';
// 1. ADD FIREBASE IMPORTS
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  // 0 = Completed, 1 = Canceled
  int _selectedToggle = 0;

  // Colors from Figma
  static const Color _darkGreen = Color(0xFF345D56);
  static const Color _teal = Color(0xFF00897B);
  static const Color _lightGray = Color(0xFFF2F2F2);
  static const Color _confirmedGreen = Color(0xFF2E7D32); // For 'Completed'
  static const Color _canceledRed = Color(0xFFC62828); // For 'Canceled'

  // 2. NEW FUNCTION TO GET THE DATA STREAM
  Stream<List<Booking>> _fetchBookingsStream() {
    // ---
    // STEP 1: USE THIS FOR DUMMY DATA (FOR NOW)
    // This instantly returns your dummy list as a "stream"
    return Stream.value(dummyBookings);
    // ---

    /*
    // ---
    // STEP 2: USE THIS FOR REAL FIREBASE DATA (LATER)
    // When you're ready, delete the "Stream.value(dummyBookings)" line
    // and uncomment the code below.
    
    // Get the current user
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // If no user, return a stream of an empty list
      return Stream.value([]);
    }

    // This will listen for REAL-TIME updates from Firestore
    return FirebaseFirestore.instance
        .collection('users') // Or your main collection
        .doc(user.uid) // Get this user's document
        .collection('bookings') // Get their 'bookings' sub-collection
        .snapshots() // This returns the stream
        .map((snapshot) {
          // This converts the Firebase documents into Booking objects
          return snapshot.docs
              .map((doc) => Booking.fromFirestore(doc))
              .toList();
        });
    // ---
    */
  }

// Method to show cancel confirmation dialog
void _showCancelDialog(BuildContext context, Booking booking) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure that you want to cancel this booking?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  // Yes button (Red)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close confirmation dialog
                        
                        // TODO: Add actual cancel booking logic here
                        // For example: Update Firebase, change booking status, etc.
                        
                        // Show success dialog
                        _showBookingCanceledDialog(context);
                        
                        print('Booking canceled: ${booking.id}');
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _canceledRed, width: 2),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      child: Text(
                        'Yes',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: _canceledRed,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // No button (Green)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _teal,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      child: Text(
                        'No',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
// Method to show booking canceled success dialog
void _showBookingCanceledDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing by tapping outside
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Checkmark icon
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey[400]!,
                    width: 4.w,
                  ),
                ),
                child: Icon(
                  Icons.check,
                  size: 60.sp,
                  color: Colors.grey[400],
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Booking canceled.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 24.h),
              // Confirm button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    // Switch to Canceled tab
                    setState(() {
                      _selectedToggle = 1; // Switch to "Canceled" tab (index 1)
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _teal, width: 2),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: _teal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightGray,
      appBar: AppBar(
        backgroundColor: _darkGreen,
        automaticallyImplyLeading: false,
        title: Text(
          'My bookings',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white, size: 28.sp),
            onPressed: () {
              // TODO: Add refresh logic
              print('Refreshing bookings...');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildToggleButtons(),
          Expanded(
            // 4. USE A STREAMBUILDER WIDGET
            child: StreamBuilder<List<Booking>>(
              stream: _fetchBookingsStream(), // Get data from our new function
              builder: (context, snapshot) {
                // --- Handle all possible states ---

                // A. LOADING STATE
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // B. ERROR STATE
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // C. NO DATA OR EMPTY LIST STATE
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // NOTE: This will show "No trips yet!" for both
                  // dummy data (if list is empty) and real data
                  return _buildEmptyState();
                }

                // D. SUCCESS STATE (We have data!)
                final allBookings = snapshot.data!;

                // Now we filter the list *inside* the builder
                final filteredList = allBookings.where((booking) {
                  if (_selectedToggle == 0) {
                    return booking.status == 'Completed';
                  } else {
                    return booking.status == 'Canceled';
                  }
                }).toList();

                // Handle if the *filtered* list is empty
                if (filteredList.isEmpty) {
                  return _buildEmptyState();
                }

                // If we have data, show the list
                return _buildBookingsList(filteredList);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToggleButton(context, text: 'Completed', index: 0),
          _buildToggleButton(context, text: 'Canceled', index: 1),
        ],
      ),
    );
  }

  Widget _buildToggleButton(BuildContext context,
      {required String text, required int index}) {
    final bool isSelected = _selectedToggle == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedToggle = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 24.w),
        decoration: BoxDecoration(
          color: isSelected ? _teal : _lightGray,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }

  // --- Empty State (No Bookings) ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_bus_filled,
            size: 100.sp,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16.h),
          Text(
            'No trips yet!',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'You have not booked any trips yet.\nPlan your next journey today!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              // Navigate to Home page to book
              Navigator.pushReplacementNamed(context, '/home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _teal,
              padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            child: Text(
              "Book now",
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // --- List of Bookings ---
  Widget _buildBookingsList(List<Booking> bookings) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(booking);
      },
    );
  }

  Widget _buildBookingCard(Booking booking) {
    // Format date like "15 Wednesday"
    final String day = DateFormat('d').format(booking.date);
    final String weekday = DateFormat('EEEE').format(booking.date);
    final String time = booking.time.split(' - ').first; // Get "20:30"

    // Set color based on status
    final Color statusColor =
        booking.status == 'Completed' ? _confirmedGreen : _canceledRed;

    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: InkWell(
        onTap: () {
          // Navigate to Details Page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingDetailsPage(booking: booking),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.all(12.h),
          child: Row(
            children: [
              // Date Column
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  children: [
                    Text(
                      day, // "15"
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: _darkGreen,
                      ),
                    ),
                    Text(
                      weekday, // "Wednesday"
                      style:
                          TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      time, // "20:30"
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              // Info Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bus ticket',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          booking.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      booking.from, // "Terminal Aarjosari - ..."
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      booking.busType.split('-').first, // "Express"
                      style:
                          TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8.h),
                  // CANCEL button at bottom right
                  if (booking.status == 'Completed')
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: () {
                        // TODO: Add cancel booking logic
                        _showCancelDialog(context, booking);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(
                          'CANCEL',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: _teal,
                            fontWeight: FontWeight.w600,
                          ),
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
    ),
  );
}

  // --- Bottom Navigation Bar ---
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 1, // 'Bookings' is the 2nd item (index 1)
      selectedItemColor: _teal,
      unselectedItemColor: Colors.black87,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            // We are already on the Bookings page, do nothing.
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/profile');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'Bookings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}