import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- 1. ADD THIS IMPORT

class UserProfileScreen extends StatelessWidget {
  UserProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              // Added for scrollability on small screens
              child: Column(
                children: [
                  _buildProfileHeader(context),
                  _buildUserInfo(context), // <-- 2. THIS IS NOW UPDATED
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
        currentIndex: 2, // 'Profile' is the 3rd item (index 2)
        selectedItemColor: Colors.teal[600],
        unselectedItemColor: Colors.black87,
        // In user_profile_screen.dart, inside the BottomNavigationBar
        onTap: (index) {
          switch (index) {
            case 0:
              // Navigate to Home
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              // Navigate to Bookings
              Navigator.pushReplacementNamed(context, '/bookings');
              break;
            case 2:
              // We are already on the Profile page, do nothing.
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
      color: Color(0xFF345D56),
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

  // --- 2. UPDATED _buildUserInfo METHOD ---
  Widget _buildUserInfo(BuildContext context) {
    // 1. Get the current user from Firebase
    final user = FirebaseAuth.instance.currentUser;

    // 2. Prepare the display data with fallbacks
    String displayName = user?.displayName ?? user?.email ?? "User";
    if (user?.email != null && displayName == user!.email) {
      // Create a name from the email if no display name exists
      displayName = user.email!.split('@').first;
      // Capitalize the first letter
      displayName =
          "${displayName[0].toUpperCase()}${displayName.substring(1)}";
    }

    final String email = user?.email ?? 'No email provided';
    final String? photoUrl = user?.photoURL;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 30.w),
      child: Row(
        children: [
          // 3. Update the profile picture
          ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            // Check if a photoUrl exists, otherwise use the placeholder
            child: photoUrl != null
                ? Image.network(
                    photoUrl, // Load from the internet
                    height: 40.h,
                    width: 40.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.person, size: 40.h), // Placeholder on error
                  )
                : Image.asset(
                    'assets/images/imgEllipse2.png', // Local placeholder
                    height: 40.h,
                    width: 40.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.person, size: 40.h), // Placeholder
                  ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 4. Update the name
                Text(
                  displayName,
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                ),
                // 5. Update the email
                Text(
                  email,
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
            onTap: () {
                Navigator.pushNamed(context, '/offers');
            },
          ),
          const Divider(indent: 18, endIndent: 18),
          _buildMenuRow(
            context,
            icon: Icons.logout, // Using a standard icon
            title: 'Log out',
            onTap: () => _showLogoutDialog(context), // <-- 3. THIS IS UPDATED
          ),
          const Divider(indent: 18, endIndent: 18),
        ],
      ),
    );
  }

  // REFACTORED _buildMenuRow to be more reusable
  Widget _buildMenuRow(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
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

  // --- 3. UPDATED _showLogoutDialog METHOD ---
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
              // Make the button async to await for logout
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog first

                // --- This is the new logic ---
                await FirebaseAuth.instance.signOut();

                // Navigate to login screen and remove all other routes
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
                // --- End of new logic ---
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