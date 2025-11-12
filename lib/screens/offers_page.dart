import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A widget that displays a single offer card (for example, a discount or coupon)
/// This widget is used inside the Offers List to represent each offer visually.
class OfferCardWidget extends StatelessWidget {
  // Each offer is represented as a Map (key-value pairs)
  final Map<String, dynamic> offer;

  const OfferCardWidget({
    super.key,
    required this.offer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Outer margin for spacing between cards
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Color(offer['backgroundColor'] as int), // Dynamic background color
        borderRadius: BorderRadius.circular(16), // Rounded corners
        boxShadow: [
          // Adds a shadow below the card
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Padding inside the card
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOfferHeader(), // Title and icon
            SizedBox(height: 16.h),
            _buildOfferContent(), // Description and validity
            SizedBox(height: 24.h),
            _buildCouponSection(context), // Coupon code + copy button
          ],
        ),
      ),
    );
  }

  /// Builds the top part of the offer card (title + icon)
  Widget _buildOfferHeader() {
    return Row(
      children: [
        Icon(
          Icons.local_offer,
          color: Colors.white,
          size: 24.sp,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            offer['title'] as String,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis, // Avoids overflow
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  /// Builds the main content of the card — description and validity date
  Widget _buildOfferContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          offer['description'] as String,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Icon(
              Icons.schedule,
              color: Colors.white.withOpacity(0.8),
              size: 16.sp,
            ),
            SizedBox(width: 4.w),
            Text(
              'Valid till: ${offer['validTill'] as String}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the section showing the coupon code and copy functionality
  Widget _buildCouponSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Use code:',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // The coupon box with a copy icon
        GestureDetector(
          onTap: () => _copyCouponCode(context), // When tapped, copy coupon
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  offer['couponCode'] as String,
                  style: TextStyle(
                    color: Color(offer['backgroundColor'] as int),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.content_copy,
                  color: Color(offer['backgroundColor'] as int),
                  size: 16.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Function to copy the coupon code to clipboard
  void _copyCouponCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: offer['couponCode'] as String));
    
    // Shows confirmation using a SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Coupon code ${offer['couponCode']} copied!',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// This widget displays a list of offers using ListView.
/// It also supports pull-to-refresh functionality.
class OffersListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> offers;
  final VoidCallback? onRefresh;

  const OffersListWidget({
    super.key,
    required this.offers,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // If there are no offers, show an empty state message
    if (offers.isEmpty) {
      return _buildEmptyState();
    }

    // Otherwise, display the list of offers
    return RefreshIndicator(
      onRefresh: () async {
        if (onRefresh != null) {
          onRefresh!();
        }
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: const Color(0xFF16A085), // Teal color for refresh indicator
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          top: 16.h,
          bottom: 80.h, // Leave space for bottom navigation bar
        ),
        itemCount: offers.length,
        itemBuilder: (context, index) {
          return OfferCardWidget(
            offer: offers[index],
          );
        },
      ),
    );
  }

  /// Builds the "no offers available" UI
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined,
              color: Colors.grey[600],
              size: 80.sp,
            ),
            SizedBox(height: 24.h),
            Text(
              'No offers available',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Check back later for exciting deals and discounts!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A085),
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              ),
              child: Text(
                'Refresh',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The main OffersScreen — this is a full page that shows all offers.
/// It includes AppBar, body (offers list), and bottom navigation bar.
class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  int _currentBottomNavIndex = 0; // Track which bottom tab is active
  List<Map<String, dynamic>> _offers = []; // Holds the list of offers
  bool _isLoading = true; // Show loading spinner initially

  // Common colors used across this screen
  static const Color _darkGreen = Color(0xFF2F5233);
  static const Color _teal = Color(0xFF16A085);
  static const Color _lightGray = Color(0xFFF2F2F2);

  @override
  void initState() {
    super.initState();
    _loadOffers(); // Load data when the screen is opened
  }

  /// Simulates loading offer data (can be replaced with API call)
  void _loadOffers() {
    setState(() {
      _isLoading = true;
    });

    // Example data for demonstration
    _offers = [
      {
        "id": 1,
        "title": "Special Discount",
        "description": "Save up to 60% on ALL tickets",
        "validTill": "26 Oct",
        "couponCode": "LOVEOCTB",
        "backgroundColor": 0xFF4A7C59,
      },
      {
        "id": 2,
        "title": "Weekend Deal",
        "description": "Save up to 45% on weekend bookings",
        "validTill": "28 Oct",
        "couponCode": "WEEKEND45",
        "backgroundColor": 0xFF16A085,
      },
      {
        "id": 3,
        "title": "Flash Sale",
        "description": "Save up to 70% on selected events",
        "validTill": "25 Oct",
        "couponCode": "FLASH70",
        "backgroundColor": 0xFF2F5233,
      },
      {
        "id": 4,
        "title": "Early Bird Offer",
        "description": "Save up to 50% on advance bookings",
        "validTill": "30 Oct",
        "couponCode": "EARLY50",
        "backgroundColor": 0xFF0F4C75,
      },
      {
        "id": 5,
        "title": "Student Special",
        "description": "Save up to 40% with student ID",
        "validTill": "31 Oct",
        "couponCode": "STUDENT40",
        "backgroundColor": 0xFF4A7C59,
      },
      {
        "id": 6,
        "title": "Group Booking",
        "description": "Save up to 55% on group tickets",
        "validTill": "29 Oct",
        "couponCode": "GROUP55",
        "backgroundColor": 0xFF16A085,
      },
    ];

    // Stop loading animation after data is ready
    setState(() {
      _isLoading = false;
    });
  }

  /// Handles bottom navigation bar item taps
  void _onBottomNavTap(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        _showComingSoonDialog('Bookings');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  /// Shows a dialog for features not yet available
  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '$feature Coming Soon',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'This feature is currently under development and will be available soon.',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _currentBottomNavIndex = 0;
                });
              },
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: _teal,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Reloads the offer list when user pulls to refresh
  void _refreshOffers() {
    _loadOffers();
  }

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
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading ? _buildLoadingState() : _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// Shows a loading spinner while fetching data
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: _teal,
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading offers...',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// The main body that displays the list of offers
  Widget _buildBody() {
    return SafeArea(
      child: OffersListWidget(
        offers: _offers,
        onRefresh: _refreshOffers,
      ),
    );
  }

  /// The bottom navigation bar for switching between sections
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentBottomNavIndex,
      onTap: _onBottomNavTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: _teal,
      unselectedItemColor: Colors.grey[600],
      elevation: 4.0,
      selectedFontSize: 12.sp,
      unselectedFontSize: 12.sp,
      iconSize: 24.sp,
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 12.sp,
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 12.sp,
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.local_offer_outlined),
          activeIcon: Icon(Icons.local_offer),
          label: 'Offers',
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
