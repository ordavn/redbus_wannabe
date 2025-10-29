import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Impor halaman dari folder baru
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/forget_password_page.dart';
import 'screens/home_page.dart';
import 'screens/user_profile_screen.dart';

Future<void> main() async {
  // Pastikan Flutter dan Firebase sudah siap sebelum app berjalan
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

// Root app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Redbus Wannabe Auth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange),

      // Cek apakah user sudah login atau belum, lalu arahkan
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/login' : '/home',
      
      routes: {
        '/register': (context) => const RegisterPage(),
        '/login': (context) => const LoginPage(),
        '/forget': (context) => const ForgetPasswordPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}