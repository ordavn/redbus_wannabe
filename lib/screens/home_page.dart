import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Login Berhasil!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Selamat datang, ${user?.email ?? 'Pengguna'}"),
          ],
        ),
      ),

      // --- ADD THIS ENTIRE BLOCK ---
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        
        // 1. THIS IS THE IMPORTANT CHANGE
        currentIndex: 0, // 'Home' is the 1st item (index 0)

        selectedItemColor: Colors.teal[600],
        unselectedItemColor: Colors.black87,
        // In home_page.dart, inside the BottomNavigationBar
        onTap: (index) {
          switch (index) {
            case 0:
              // We are already on the Home page, do nothing.
              break;
            case 1:
              // TODO: Navigate to Bookings
              print('Bookings tapped');
              break;
            case 2:
              // Navigate to Profile
              Navigator.pushReplacementNamed(context, '/profile');
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
      // --- END OF NEW BLOCK ---
    );
  }
}