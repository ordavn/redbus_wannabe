import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController couponController = TextEditingController();
  bool isProcessing = false;
  double discount = 0;
  bool isCouponApplied = false;

  // Function to apply coupon
  void _applyCoupon(double total) {
    final couponCode = couponController.text.trim().toUpperCase();

    if (couponCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a coupon code")),
      );
      return;
    }

    setState(() {
      // Example coupon codes
      if (couponCode == "SAVE10") {
        discount = total * 0.10; // 10% discount
        isCouponApplied = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Coupon applied! 10% discount"),
            backgroundColor: Colors.green,
          ),
        );
      } else if (couponCode == "SAVE20") {
        discount = total * 0.20; // 20% discount
        isCouponApplied = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Coupon applied! 20% discount"),
            backgroundColor: Colors.green,
          ),
        );
      } else if (couponCode == "FIRST50") {
        discount = 50000; // Fixed 50k discount
        isCouponApplied = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Coupon applied! Rp. 50,000 discount"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        discount = 0;
        isCouponApplied = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid coupon code"),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final double total = (args['total'] ?? 50000).toDouble();
    final double finalTotal = (total - discount).clamp(0, double.infinity);

    // Generate QR code data
    final String qrData =
        "PAYMENT_ID_${DateTime.now().millisecondsSinceEpoch}_AMOUNT_${finalTotal.toInt()}";

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E5C4C),
        title: const Text(
          'Payment',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Total Amount Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Total Payment",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (discount > 0) ...[
                    Text(
                      "Rp. ${total.toInt()}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    "Rp. ${finalTotal.toInt()}",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E5C4C),
                    ),
                  ),
                  if (discount > 0)
                    Text(
                      "You saved Rp. ${discount.toInt()}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // QR Code Section
            const Text(
              "Scan QR Code to Pay",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 250.0,
                backgroundColor: Colors.white,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
              ),
            ),
            const SizedBox(height: 24),

            // Coupon Input Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Have a Coupon Code?",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: couponController,
                          decoration: InputDecoration(
                            hintText: "Enter coupon code",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          textCapitalization: TextCapitalization.characters,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _applyCoupon(total),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00897B),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Apply",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isCouponApplied)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Coupon applied: ${couponController.text.toUpperCase()}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Final Total",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  "Rp. ${finalTotal.toInt()}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E5C4C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E5C4C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: isProcessing
                    ? null
                    : () async {
                        setState(() => isProcessing = true);

                        // Simulate payment processing
                        await Future.delayed(const Duration(seconds: 2));

                        final success = Random().nextBool(); // Random success/fail
                        setState(() => isProcessing = false);

                        if (!mounted) return;

                        Navigator.pushNamed(
                          context,
                          success ? '/bookingComplete' : '/bookingFailed',
                        );
                      },
                child: isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Proceed to Pay",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    couponController.dispose();
    super.dispose();
  }
}