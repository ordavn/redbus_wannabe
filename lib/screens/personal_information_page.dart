import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PersonalInformationPage extends StatelessWidget {
  const PersonalInformationPage({super.key});

  // Custom Colors
  static const Color _darkGreen = Color(0xFF345D56);
  static const Color _lightGray = Color(0xFFF2F2F2);

  @override
  Widget build(BuildContext context) {
    // Get the current user
    final user = FirebaseAuth.instance.currentUser;

    // Prepare display name
    String displayName = user?.displayName ?? user?.email ?? "User";
    if (user?.email != null && displayName == user!.email) {
      displayName = user.email!.split('@').first;
      displayName =
          "${displayName[0].toUpperCase()}${displayName.substring(1)}";
    }

    // Prepare email
    final String email = user?.email ?? 'No email provided';

    return Scaffold(
      backgroundColor: _lightGray,
      appBar: AppBar(
        backgroundColor: _darkGreen,
        foregroundColor: Colors.white,
        title: Text(
          'Personal information',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal details',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.h),
            _buildInfoField(
              label: 'Name',
              value: displayName,
            ),
            SizedBox(height: 16.h),
            _buildInfoField(
              label: 'Email',
              value: email,
            ),
            SizedBox(height: 16.h),
            _buildInfoField(
              label: 'Date of birth',
              value: '10/03/2002', // Dummy data
            ),
            SizedBox(height: 16.h),
            _buildInfoField(
              label: 'Phone number',
              value: '+62082198737890', // Dummy data as in Figma
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to create the read-only fields
  Widget _buildInfoField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
        ),
        SizedBox(height: 4.h),
        TextFormField(
          initialValue: value,
          readOnly: true, 
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: const BorderSide(color: _darkGreen),
            ),
          ),
        ),
      ],
    );
  }
}