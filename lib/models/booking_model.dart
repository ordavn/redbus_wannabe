import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 1. Import Firestore

// 1. Define the Booking class
class Booking {
  final String id;
  final String from;
  final String to;
  final DateTime date;
  final String time;
  final String duration;
  final String busType;
  final String status; // 'Completed', 'Canceled'
  final String name;
  final String seat;
  final String ticketId;
  final double fare;

  Booking({
    required this.id,
    required this.from,
    required this.to,
    required this.date,
    required this.time,
    required this.duration,
    required this.busType,
    required this.status,
    required this.name,
    required this.seat,
    required this.ticketId,
    required this.fare,
  });

  // 2. ADD THIS "FROMFIRESTORE" FACTORY
  // This is the "converter" that builds a Booking from a Firebase document
  factory Booking.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    return Booking(
      id: doc.id,
      from: data['from'] ?? '',
      to: data['to'] ?? '',
      // Firestore uses Timestamp, so we MUST convert it to DateTime
      date: (data['date'] as Timestamp).toDate(),
      time: data['time'] ?? '',
      duration: data['duration'] ?? '',
      busType: data['busType'] ?? '',
      status: data['status'] ?? 'Unknown',
      name: data['name'] ?? '',
      seat: data['seat'] ?? '',
      ticketId: data['ticketId'] ?? '',
      fare: (data['fare'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// 2. Create the dummy data
// This list is still useful for testing
List<Booking> dummyBookings = [
  Booking(
    id: '151024MTRANS2A',
    from: 'Terminal Aarjosari',
    to: 'Terminal Purabaya',
    date: DateTime(2025, 4, 15),
    time: '20:30 - 23:40',
    duration: '03:10',
    busType: 'Mitrans - Double Deck (2+1)',
    status: 'Completed',
    name: 'Lyria',
    seat: '2A',
    ticketId: 'IND123456789',
    fare: 50000,
  ),
  Booking(
    id: '121024BUSC3B',
    from: 'Terminal Landungsari',
    to: 'Terminal Bungurasih',
    date: DateTime(2025, 4, 12),
    time: '10:00 - 12:30',
    duration: '02:30',
    busType: 'Express',
    status: 'Canceled',
    name: 'Lyria',
    seat: '3B',
    ticketId: 'IND987654321',
    fare: 45000,
  ),
  Booking(
    id: '101024TEST4C',
    from: 'Stasiun Kota Baru',
    to: 'Bandara Juanda',
    date: DateTime(2025, 4, 10),
    time: '07:00 - 09:00',
    duration: '02:00',
    busType: 'Shuttle',
    status: 'Completed',
    name: 'Lyria',
    seat: '4C',
    ticketId: 'IND456789123',
    fare: 70000,
  ),
];