import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserProfileScreen extends StatelessWidget {
  UserProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView( // Added for scrollability on small screens
              child: Column(
                children: [
                  _buildProfileHeader(context),
                  _buildUserInfo(context),
                  _buildDivider(context),
                  _buildMyDetailsSection(context),
                  _buildMoreSection(context),
                ],
              ),
            ),
          ),
        ],
      ),
      // REPLACED CustomBottomBar with standard BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // To see all labels
        currentIndex: 3, // 'Profile' is the 4th item (index 3)
        selectedItemColor: Colors.teal[600],
        unselectedItemColor: Colors.black87,
        onTap: (index) {
          // Handle navigation here
          print('Tapped index: $index');
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
            icon: Icon(Icons.card_giftcard_outlined),
            activeIcon: Icon(Icons.card_giftcard),
            label: 'Referral',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 60.h, // Adjusted for status bar
        bottom: 24.h,
        left: 30.w, // Use .w for horizontal spacing
      ),
      // REPLACED appTheme.blue_gray_900
      color: Colors.blueGrey[900],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Profile',
            // REPLACED TextStyleHelper
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[100],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 30.w),
      child: Row(
        children: [
          // REPLACED CustomImageView
          ClipRRect(
            borderRadius: BorderRadius.circular(20.r), // .r for radius
            child: Image.asset(
              'assets/images/imgEllipse2.png', // <-- MAKE SURE YOU HAVE THIS IMAGE
              height: 40.h,
              width: 40.w,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: 40.h), // Placeholder
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lyria',
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                ),
                Text(
                  'lyriagbf@gmail.com',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      // REPLACED with standard Divider
      child: const Divider(height: 1, color: Colors.grey),
    );
  }

  Widget _buildMyDetailsSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 18.w),
            child: Text(
              'My details',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 18.h),
          _buildMenuRow(
            context,
            icon: Icons.person_pin, // Using a standard icon
            title: 'Personal information',
            onTap: () => print('Personal information tapped'),
          ),
          const Divider(indent: 18, endIndent: 18),
          _buildMenuRow(
            context,
            icon: Icons.book_online, // Using a standard icon
            title: 'Bookings',
            onTap: () => print('Bookings tapped'),
          ),
           const Divider(indent: 18, endIndent: 18),
        ],
      ),
    );
  }

  Widget _buildMoreSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 18.w),
            child: Text(
              'More',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 18.h),
           _buildMenuRow(
            context,
            icon: Icons.local_offer, // Using a standard icon
            title: 'Offers',
            onTap: () => print('Offers tapped'),
          ),
          const Divider(indent: 18, endIndent: 18),
          _buildMenuRow(
            context,
            icon: Icons.logout, // Using a standard icon
            title: 'Log out',
            onTap: () => _showLogoutDialog(context),
          ),
          const Divider(indent: 18, endIndent: 18),
        ],
      ),
    );
  }

  // REFACTORED _buildMenuRow to be more reusable
  Widget _buildMenuRow(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
        child: Row(
          children: [
            Icon(icon, size: 22.sp),
            SizedBox(width: 16.w),
            Text(
              title,
              style: TextStyle(fontSize: 16.sp),
            ),
            const Spacer(), // Pushes arrow to the end
            Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                print('User logged out');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}