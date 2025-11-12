import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileScreen extends StatelessWidget {
  UserProfileScreen({Key? key}) : super(key: key);

  String _getFallbackDisplayName(User? user) {
    if (user == null) return "User";
    String displayName = user.displayName ?? user.email ?? "User";
    if (user.email != null && displayName == user.email) {
      displayName = user.email!.split('@').first;
      displayName =
          "${displayName[0].toUpperCase()}${displayName.substring(1)}";
    }
    return displayName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2,
        selectedItemColor: Colors.teal[600],
        unselectedItemColor: Colors.black87,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/bookings');
              break;
            case 2:
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
        top: 60.h,
        bottom: 24.h,
        left: 30.w,
      ),
      color: const Color(0xFF345D56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Profile',
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
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return SizedBox.shrink();
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        String displayName;
        String email = user.email ?? 'No email provided';
        final String? photoUrl = user.photoURL; 

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data!.exists) {
          final userData = snapshot.data!.data()!;
          final String fullName = userData['full_name'] ?? '';
          email = userData['email'] ?? email; 
          displayName =
              fullName.isNotEmpty ? fullName : _getFallbackDisplayName(user);
        } else {
          displayName = _getFallbackDisplayName(user);
        }

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 30.w),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: photoUrl != null
                    ? Image.network(
                        photoUrl,
                        height: 40.h,
                        width: 40.w,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.person, size: 40.h),
                      )
                    : Image.asset(
                        'assets/images/imgEllipse2.png',
                        height: 40.h,
                        width: 40.w,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.person, size: 40.h),
                      ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName, 
                      style: TextStyle(
                          fontSize: 20.sp, fontWeight: FontWeight.bold),
                    ),
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
      },
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
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
            icon: Icons.person_pin,
            title: 'Personal information',
            onTap: () {
              Navigator.pushNamed(context, '/personal-info');
            },
          ),
          const Divider(indent: 18, endIndent: 18),
          _buildMenuRow(
            context,
            icon: Icons.book_online,
            title: 'Bookings',
            onTap: () {
              Navigator.pushReplacementNamed(context, '/bookings');
            },
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
            icon: Icons.local_offer,
            title: 'Offers',
            onTap: () {
              Navigator.pushNamed(context, '/offers');
            },
          ),
          const Divider(indent: 18, endIndent: 18),
          _buildMenuRow(
            context,
            icon: Icons.logout,
            title: 'Log out',
            onTap: () => _showLogoutDialog(context),
          ),
          const Divider(indent: 18, endIndent: 18),
        ],
      ),
    );
  }

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
            const Spacer(),
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
              onPressed: () async {
                Navigator.of(context).pop();
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
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