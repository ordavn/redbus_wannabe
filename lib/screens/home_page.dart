import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- 1. IMPORT FIRESTORE
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- Firebase Instances ---
  final user = FirebaseAuth.instance.currentUser;
  final _firestore = FirebaseFirestore.instance; // <-- Instance Firestore

  // --- State untuk Data Firebase ---
  String _fullName = ""; // <-- Untuk menyimpan nama pengguna dari Firestore
  bool _isLoadingSearch = false; // <-- State loading untuk tombol search

  // Controllers for text fields
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  // State for date selection
  int _selectedDateIndex = 0;
  DateTime _selectedDate = DateTime.now();

  // State for passenger count
  int _personCount = 1;

  // Helper dates
  final DateTime _today = DateTime.now();
  final DateTime _tomorrow = DateTime.now().add(const Duration(days: 1));
  final DateTime _dayAfterTomorrow = DateTime.now().add(
    const Duration(days: 2),
  );

  // Custom Colors from the design
  static const Color _darkGreen = Color(0xFF345D56);
  static const Color _lightGray = Color(0xFFF2F2F2);
  static const Color _darkerGray = Color(0xFFE0E0E0);
  static const Color _teal = Color(0xFF00897B); // Button color
  static const Color _headerFieldColor = Color(
    0xFF4A7C75,
  ); // Color for From/To fields in header

  // --- LOGIC 1: Ambil Nama Pengguna saat Halaman Dimuat ---
  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user == null) return;
    try {
      final doc = await _firestore.collection('users').doc(user!.uid).get();
      if (doc.exists && doc.data() != null) {
        if (mounted) {
          setState(() {
            _fullName = doc.data()!['full_name'] ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      // Jika gagal, header akan menampilkan email (fallback)
    }
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightGray, // Main background color for the body
      body: CustomScrollView(
        slivers: [
          _buildHeader(), // <-- Header ini sekarang dinamis
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h), // Spacing from header
                  _buildAvailableDates(context),
                  _buildPassengerCounter(),
                  _buildSearchButton(), // <-- Tombol ini sekarang punya logic
                  _buildOffersSection(), // <-- Section ini sekarang dinamis
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // --- Header Widget ---
  Widget _buildHeader() {
    // --- LOGIC 1 (Lanjutan): Tampilkan nama ---
    String displayName;
    if (_fullName.isNotEmpty) {
      displayName = _fullName;
    } else {
      displayName = user?.displayName ?? user?.email ?? "User";
      if (user?.email != null && displayName == user!.email) {
        displayName = user!.email!.split('@').first;
      }
    }
    // Capitalize first letter
    displayName = "${displayName[0].toUpperCase()}${displayName.substring(1)}";
    // --- AKHIR DARI LOGIC 1 ---

    return SliverAppBar(
      backgroundColor: _darkGreen,
      expandedHeight: 180.h,
      pinned: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: EdgeInsets.only(top: 8.h),
        child: Text(
          "Hi $displayName,", // <-- UI Anda, sekarang dengan data dinamis
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16.w, top: 8.h),
          child: _buildProfileAvatar(),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _buildExpandedHeaderBackground(),
        collapseMode: CollapseMode.parallax,
      ),
    );
  }

  // ... (Widget _buildExpandedHeaderBackground, _buildProfileAvatar, _buildLocationField TIDAK BERUBAH) ...
  // ... (Ini adalah widget UI murni Anda, jadi kita tidak sentuh) ...
  Widget _buildExpandedHeaderBackground() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end, // Align to bottom
          children: [
            Stack(
              alignment: Alignment.centerRight,
              children: [
                Column(
                  children: [
                    _buildLocationField(_fromController, "From"),
                    SizedBox(height: 10.h), // Space between fields
                    _buildLocationField(_toController, "To"),
                  ],
                ),
                // Swap Button
                GestureDetector(
                  onTap: () {
                    final temp = _fromController.text;
                    _fromController.text = _toController.text;
                    _toController.text = temp;
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.swap_vert, color: _teal, size: 24.sp),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h), // Padding at the very bottom
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return CircleAvatar(
      radius: 20.r, // Slightly smaller to fit better
      backgroundColor: Colors.white,
      child: ClipOval(
        child: Image.asset(
          'assets/images/imgEllipse2.png', // <-- UPDATE THIS
          fit: BoxFit.cover,
          height: 40.h,
          width: 40.w,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.person, size: 20.r, color: _darkGreen),
        ),
      ),
    );
  }

  Widget _buildLocationField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white70, fontSize: 16.sp),
        filled: true,
        fillColor: _headerFieldColor, // Darker green from Figma
        border: InputBorder.none,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r), // SHARPER
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r), // SHARPER
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ... (Widget _buildAvailableDates, _buildDateChip, _showCalendarSheet TIDAK BERUBAH) ...
  // ... (Ini adalah widget UI murni Anda dengan state lokal, jadi kita tidak sentuh) ...
  Widget _buildAvailableDates(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Available dates",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDateChip(context, label: "Today", date: _today, index: 0),
            _buildDateChip(
              context,
              label: "Tomorrow",
              date: _tomorrow,
              index: 1,
            ),
            _buildDateChip(
              context,
              label: DateFormat('d MMM').format(_dayAfterTomorrow),
              date: _dayAfterTomorrow,
              index: 2,
            ),
            _buildDateChip(
              context,
              label: "Other",
              icon: Icons.calendar_month_outlined,
              index: 3,
              onTap: () => _showCalendarSheet(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateChip(
    BuildContext context, {
    required String label,
    IconData? icon,
    DateTime? date,
    required int index,
    VoidCallback? onTap,
  }) {
    final isSelected = _selectedDateIndex == index;

    return ChoiceChip(
      label: Text(label),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: FontWeight.w500,
      ),
      avatar: icon != null
          ? Icon(
              icon,
              size: 16.sp,
              color: isSelected ? Colors.white : Colors.black,
            )
          : null,
      selected: isSelected,
      selectedColor: _teal,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r), // Pill shape is correct
        side: BorderSide(color: isSelected ? _teal : _darkerGray),
      ),
      onSelected: (selected) {
        setState(() {
          _selectedDateIndex = index;
          if (date != null) {
            _selectedDate = date;
          }
        });
        if (onTap != null) {
          onTap();
        }
      },
      showCheckmark: false,
    );
  }

  void _showCalendarSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Select Date",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: 24.sp),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    focusedDay: _selectedDate,
                    currentDay: DateTime.now(),
                    selectedDayPredicate: (day) =>
                        isSameDay(_selectedDate, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setModalState(() {
                        _selectedDate = selectedDay;
                      });
                      setState(() {
                        _selectedDateIndex = 3; // "Other"
                        _selectedDate = selectedDay;
                      });
                    },
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      titleTextStyle: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: _darkerGray,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: _teal,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ... (Widget _buildPassengerCounter, _buildCounterButton TIDAK BERUBAH) ...
  // ... (Ini adalah widget UI murni Anda dengan state lokal, jadi kita tidak sentuh) ...
  Widget _buildPassengerCounter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      margin: EdgeInsets.symmetric(
        vertical: 20.h,
      ), // No horizontal margin needed
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r), // SHARPER
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: Colors.grey[600], size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                "$_personCount person",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Row(
            children: [
              _buildCounterButton(
                icon: Icons.remove,
                onPressed: () {
                  if (_personCount > 1) {
                    setState(() => _personCount--);
                  }
                },
              ),
              SizedBox(width: 12.w),
              _buildCounterButton(
                icon: Icons.add,
                onPressed: () {
                  setState(() => _personCount++);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    // Use Material and InkWell to get splash/hover animations
    return Material(
      color: _lightGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.r), // SHARPER
        side: BorderSide(color: _darkerGray),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4.r), // SHARPER
        child: Container(
          padding: EdgeInsets.all(4.r),
          child: Icon(icon, size: 20.sp, color: Colors.black),
        ),
      ),
    );
  }

  // --- LOGIC 2: Fungsi Baru untuk Tombol Search ---
  void _searchBuses() {
    // 1. Validasi input
    if (_fromController.text.trim().isEmpty ||
        _toController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Origin and Destination must be filled!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2. Kumpulkan semua parameter pencarian
    final searchParams = {
      'from': _fromController.text.trim(),
      'to': _toController.text.trim(),
      'date': _selectedDate,
      'passengers': _personCount,
    };

    // 3. Navigasi ke halaman /busList dan kirim 'searchParams'
    // Halaman /busList nanti akan menerima data ini dan melakukan query
    Navigator.pushNamed(context, '/busList', arguments: searchParams);
  }
  // --- AKHIR DARI LOGIC 2 ---

  // --- Search Button Widget ---
  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        // --- LOGIC 2 (Lanjutan): Hubungkan tombol ke fungsi baru ---
        onPressed: _isLoadingSearch ? null : _searchBuses,
        // ---
        style: ElevatedButton.styleFrom(
          backgroundColor: _teal,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.r), // SHARPER
          ),
        ),
        child: _isLoadingSearch
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                "Search busses",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  // --- Offers Section Widget ---
  Widget _buildOffersSection() {
    return Padding(
      padding: EdgeInsets.only(top: 24.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Offers for you",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/offers');
                },
                child: Text(
                  "View all",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: _teal,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // --- LOGIC 3: Ganti ListView statis dengan StreamBuilder ---
          SizedBox(
            height: 120.h,
            child: StreamBuilder<QuerySnapshot>(
              // Query: Ambil 5 promo teratas yang masih berlaku
              stream: _firestore
                  .collection('offers')
                  .where('valid_until', isGreaterThanOrEqualTo: Timestamp.now())
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                // Saat loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Jika error
                if (snapshot.hasError) {
                  return const Center(child: Text("Failed to load offers."));
                }
                // Jika tidak ada data
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No offers available."));
                }

                // Jika ada data, tampilkan ListView
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final offerDoc = snapshot.data!.docs[index];
                    // Ubah data Dokumen Firestore menjadi Map
                    final offerData = offerDoc.data() as Map<String, dynamic>;

                    // Beri jarak antar card
                    return Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      // Panggil widget _buildOfferCard Anda DENGAN data
                      child: _buildOfferCard(offerData),
                    );
                  },
                );
              },
            ),
          ),
          // --- AKHIR DARI LOGIC 3 ---
        ],
      ),
    );
  }

  // --- LOGIC 3 (Lanjutan): Modifikasi widget Anda untuk menerima data ---
  // Perhatikan perubahan signature: (Map<String, dynamic> offerData)
  Widget _buildOfferCard(Map<String, dynamic> offerData) {
    // Ambil data dari Map, berikan nilai default jika null
    String title = offerData['title'] ?? "Promo Spesial";
    String promoCode = offerData['promo_code'] ?? "PROMO";

    // Format tanggal
    Timestamp validUntilStamp = offerData['valid_until'] ?? Timestamp.now();
    String validUntil = DateFormat('d MMM').format(validUntilStamp.toDate());
    // ---

    // Ini adalah UI Anda, tidak saya ubah, hanya saya isi dengan data
    return Container(
      width: 250.w,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: _darkGreen,
        borderRadius: BorderRadius.circular(12.r), // This rounding is correct
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, // <-- Data dinamis
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 2, // Tambahan kecil agar teks tidak overflow
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),
          Text(
            "Valid till: $validUntil", // <-- Data dinamis
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[300]),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              promoCode, // <-- Data dinamis
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: _darkGreen,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
  // --- AKHIR DARI LOGIC 3 ---

  // --- Bottom Navigation Bar ---
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0, // 'Home' is the 1st item (index 0)
      selectedItemColor: _teal,
      unselectedItemColor: Colors.black87,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      onTap: (index) {
        switch (index) {
          case 0:
            // We are already on the Home page, do nothing.
            break;
          case 1:
            // Navigate to Bookings
            Navigator.pushReplacementNamed(context, '/bookings');
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
    );
  }
}