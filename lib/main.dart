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
import 'screens/offers_page.dart';
import 'screens/bookings_page.dart';
import 'screens/personal_information_page.dart';

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
    // Wrap your MaterialApp with ScreenUtilInit
    return ScreenUtilInit(
      designSize: const Size(360, 690), // Or your Figma design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Redbus Wannabe Auth',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(primarySwatch: Colors.orange),

          // Cek apakah user sudah login atau belum, lalu arahkan
          initialRoute:
              FirebaseAuth.instance.currentUser == null ? '/login' : '/home',

          routes: {
            '/register': (context) => const RegisterPage(),
            '/login': (context) => const LoginPage(),
            '/forget': (context) => const ForgetPasswordPage(),
            '/home': (context) => const HomePage(),
            '/profile': (context) => UserProfileScreen(),
            '/offers': (context) => const OffersScreen(),
            '/bookings': (context) => const BookingsPage(),
            '/personal-info': (context) => const PersonalInformationPage(),
          },
        );
      },
    );
  }
}