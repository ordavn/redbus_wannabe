import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isProcessing = false;
  
  // State untuk Promo
  Map<String, dynamic>? _selectedPromo;
  int _discountAmount = 0;

  // Warna Custom
  static const Color _darkGreen = Color(0xFF345D56);
  static const Color _teal = Color(0xFF00897B);
  static const Color _lightGray = Color(0xFFF2F2F2);

  String formatRupiah(int price) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
        .format(price);
  }

  @override
  Widget build(BuildContext context) {
    // 1. TERIMA DATA DARI HALAMAN SEBELUMNYA
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final busData = args['bus'];
    final List<int> selectedSeats = args['seats'];
    final int originalPrice = args['total'];

    // 2. HITUNG HARGA FINAL (Setelah Diskon)
    final int finalPrice = originalPrice - _discountAmount;

    return Scaffold(
      backgroundColor: _lightGray,
      appBar: AppBar(
        backgroundColor: _darkGreen,
        title: const Text('Payment Review', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BAGIAN 1: RINCIAN PESANAN ---
            _buildSectionTitle('Booking Summary'),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  _buildRow("Bus", busData['name']),
                  _buildRow("Rute", "${busData['origin']} - ${busData['destination']}"),
                  _buildRow("Jam", "${busData['departure']} - ${busData['arrival']}"),
                  _buildRow("Kursi", selectedSeats.join(", ")),
                  const Divider(),
                  _buildRow("Subtotal", formatRupiah(originalPrice)),
                  
                  // Tampilkan baris Diskon jika ada promo
                  if (_selectedPromo != null)
                    _buildRow(
                      "Discount (${_selectedPromo!['coupon_code']})", 
                      "- ${formatRupiah(_discountAmount)}",
                      color: Colors.green
                    ),
                  
                  const Divider(),
                  _buildRow("Total Pay", formatRupiah(finalPrice), isBold: true, color: _teal),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // --- BAGIAN 2: PILIH PROMO (BARU) ---
            _buildSectionTitle('Promo Code'),
            _buildPromoSelector(originalPrice),

            SizedBox(height: 16.h),

            // --- BAGIAN 3: METODE PEMBAYARAN ---
            _buildSectionTitle('Payment Method'),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _teal, width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(Icons.qr_code_scanner, color: _teal, size: 30.sp),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("QRIS (Instant)",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                      Text("Scan with GoPay, OVO, BCA",
                          style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.check_circle, color: _teal),
                ],
              ),
            ),

            const Spacer(),

            // --- BAGIAN 4: TOMBOL BAYAR ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _teal,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
                onPressed: _isProcessing
                    ? null
                    : () => _showDummyQRISDialog(busData, selectedSeats, finalPrice), // Kirim Final Price
                child: Text(
                  "Pay Now ${formatRupiah(finalPrice)}",
                  style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _darkGreen),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 14.sp)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 14.sp,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET SELECTOR PROMO ---
  Widget _buildPromoSelector(int originalPrice) {
    return GestureDetector(
      onTap: () => _showPromoBottomSheet(originalPrice),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: _selectedPromo != null ? _teal : Colors.grey[300]!
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.confirmation_number_outlined, color: _selectedPromo != null ? _teal : Colors.grey),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedPromo != null 
                        ? "Applied: ${_selectedPromo!['title']}" 
                        : "Apply Promo Code",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: _selectedPromo != null ? _teal : Colors.black,
                    ),
                  ),
                  if (_selectedPromo != null)
                    Text(
                      "You saved ${formatRupiah(_discountAmount)}",
                      style: TextStyle(fontSize: 12.sp, color: Colors.green),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // --- BOTTOM SHEET DAFTAR PROMO ---
  void _showPromoBottomSheet(int originalPrice) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.w),
          height: 400.h,
          child: Column(
            children: [
              Text("Select a Promo", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.h),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('offers')
                      .where('valid_until', isGreaterThan: Timestamp.now())
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    
                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No promos available"));
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var promo = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                        
                        return Card(
                          margin: EdgeInsets.only(bottom: 12.h),
                          child: ListTile(
                            leading: Icon(Icons.local_offer, color: _teal),
                            title: Text(promo['title'] ?? 'Promo', style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(promo['description'] ?? ''),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _teal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                              ),
                              onPressed: () {
                                int percent = promo['discount_percent'] ?? 0; 
                                int discount = (originalPrice * percent / 100).toInt();

                                setState(() {
                                  _selectedPromo = promo;
                                  _discountAmount = discount;
                                });
                                Navigator.pop(context);
                              },
                              child: const Text("Use"),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- DIALOG DUMMY QRIS ---
  void _showDummyQRISDialog(Map<String, dynamic> busData, List<int> seats, int finalPrice) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // Timer 5 detik seolah-olah menunggu pembayaran
        Timer(const Duration(seconds: 5), () {
          Navigator.of(context).pop(); // Tutup QRIS
          _saveToFirebase(busData, seats, finalPrice); // Simpan Data
        });

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Scan QRIS", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 8.h),
                Text("Waiting for payment...", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                SizedBox(height: 20.h),
                
                // Generate QR Code
                QrImageView(
                  data: "PAY-${busData['name']}-$finalPrice-${DateTime.now().millisecondsSinceEpoch}",
                  version: QrVersions.auto,
                  size: 200.0,
                ),
                
                SizedBox(height: 20.h),
                const CircularProgressIndicator(),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- FUNGSI SIMPAN KE FIREBASE ---
  Future<void> _saveToFirebase(Map<String, dynamic> busData, List<int> seats, int finalPrice) async {
    setState(() => _isProcessing = true);
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      DateTime travelDate;
      if (busData['travelDate'] != null) {
        travelDate = DateTime.parse(busData['travelDate']);
      } else {
        travelDate = DateTime.now();
      }
      await FirebaseFirestore.instance.collection('bookings').add({
        'userId': user.uid,
        'busId': busData['id'],
        'busName': busData['name'],
        'origin': busData['origin'],
        'destination': busData['destination'],
        'departureTime': busData['departure'],
        'date': Timestamp.fromDate(travelDate),
        'seats': seats,
        'totalPrice': finalPrice, // Harga yang sudah didiskon
        'status': 'Completed',
        'promoCode': _selectedPromo?['coupon_code'] ?? '', // Simpan kode promo jika ada
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/bookings', (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment Successful!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}