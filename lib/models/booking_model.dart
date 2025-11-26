import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String userId;
  final String tripId;
  final String from;
  final String to;
  final DateTime date;
  final String time;
  final String busType;
  final int totalPrice;
  final List<dynamic> seats;
  final String status; // 'Completed' atau 'Canceled'

  Booking({
    required this.id,
    required this.userId,
    required this.tripId,
    required this.from,
    required this.to,
    required this.date,
    required this.time,
    required this.busType,
    required this.totalPrice,
    required this.seats,
    required this.status,
  });

  // Factory untuk mengubah Data Firebase menjadi Object Booking
  factory Booking.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Booking(
      id: doc.id,
      userId: data['userId'] ?? '',
      tripId: data['busId'] ?? '',
      from: data['origin'] ?? '',
      to: data['destination'] ?? '',
      // Mengubah Timestamp Firebase jadi DateTime
      date: (data['date'] as Timestamp).toDate(), 
      time: data['departureTime'] ?? '',
      busType: data['busName'] ?? '', // Kita pakai nama bus sebagai tipe
      totalPrice: data['totalPrice'] ?? 0,
      seats: data['seats'] ?? [],
      status: data['status'] ?? 'Completed',
    );
  }
}