import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Offer {
  final String id;
  final String title;
  final String description;
  final String couponCode;
  final DateTime validUntil;
  final Color backgroundColor;

  Offer({
    required this.id,
    required this.title,
    required this.description,
    required this.couponCode,
    required this.validUntil,
    required this.backgroundColor,
  });

  factory Offer.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Helper untuk parsing warna dari String Hex (misal "0xFF4A7C59")
    Color parseColor(String? hexString) {
      if (hexString == null) return const Color(0xFF16A085); // Default Teal
      try {
        return Color(int.parse(hexString));
      } catch (e) {
        return const Color(0xFF16A085);
      }
    }

    return Offer(
      id: doc.id,
      title: data['title'] ?? 'No Title',
      description: data['description'] ?? '',
      couponCode: data['coupon_code'] ?? 'CODE',
      validUntil: (data['valid_until'] as Timestamp).toDate(),
      backgroundColor: parseColor(data['background_color']), // Simpan di DB sebagai String
    );
  }
}