import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalInformationPage extends StatelessWidget {
  const PersonalInformationPage({super.key});

  // Custom Colors
  static const Color _darkGreen = Color(0xFF345D56);
  static const Color _lightGray = Color(0xFFF2F2F2);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User data not found"));
          }

          final data = snapshot.data!;
          final fullName = data['full_name'] ?? 'No name';
          final email = data['email'] ?? user.email ?? 'No email';
          final dob = data['date_of_birth'] ?? 'No date of birth';
          final phone = data['phone_number'] ?? 'No phone number';

          return Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personal details',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20.h),

                _buildInfoField(label: 'Name', value: fullName),
                SizedBox(height: 16.h),

                _buildInfoField(label: 'Email', value: email),
                SizedBox(height: 16.h),

                _buildInfoField(label: 'Date of birth', value: dob),
                SizedBox(height: 16.h),

                _buildInfoField(label: 'Phone number', value: phone),
              ],
            ),
          );
        },
      ),
    );
  }

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