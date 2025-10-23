import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    // Kita gunakan timer untuk pindah halaman setelah beberapa detik
    Timer(const Duration(seconds: 3), () {
      // Cek apakah pengguna sudah login atau belum
      if (FirebaseAuth.instance.currentUser == null) {
        // Jika belum, arahkan ke halaman login
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        // Jika sudah, arahkan ke halaman home
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // WARNA LATAR SESUAI SCREENSHOT (#003D2D)
      backgroundColor: const Color(0xFF003D2D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Teks "GreenBus"
            const Text(
              "GreenBus",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            // Ikon logo di bagian bawah
            Icon(
              Icons.location_on_outlined,
              color: Colors.white.withOpacity(0.3),
              size: 80,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}