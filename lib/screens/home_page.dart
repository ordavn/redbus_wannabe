import 'package:firebase_auth/firebase_auth.dart';
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
  // Get the current user
  final user = FirebaseAuth.instance.currentUser;

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
  final DateTime _dayAfterTomorrow = DateTime.now().add(const Duration(days: 2));

  // Custom Colors from the design
  static const Color _darkGreen = Color(0xFF345D56);
  static const Color _lightGray = Color(0xFFF2F2F2);
  static const Color _darkerGray = Color(0xFFE0E0E0);
  static const Color _teal = Color(0xFF00897B); // Button color
  static const Color _headerFieldColor =
      Color(0xFF4A7C75); // Color for From/To fields in header

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
          _buildHeader(), // The new header, contains From/To fields
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h), // Spacing from header
                  _buildAvailableDates(context),
                  _buildPassengerCounter(),
                  _buildSearchButton(),
                  _buildOffersSection(),
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
    String displayName = user?.displayName ?? user?.email ?? "User";
    if (user?.email != null && displayName == user!.email) {
      displayName = user!.email!.split('@').first;
    }
    // Capitalize first letter
    displayName = "${displayName[0].toUpperCase()}${displayName.substring(1)}";

    return SliverAppBar(
      backgroundColor: _darkGreen,
      // FIX 2: Reduced height to shrink the gap
      expandedHeight: 180.h,
      pinned: true,
      elevation: 0,
      automaticallyImplyLeading: false,

      // FIX 1: Add top padding to the title
      title: Padding(
        padding: EdgeInsets.only(top: 8.h),
        child: Text(
          "Hi $displayName,",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),

      // FIX 1: Add top padding to the avatar
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16.w, top: 8.h),
          child: _buildProfileAvatar(),
        ),
      ],

      flexibleSpace: FlexibleSpaceBar(
        background: _buildExpandedHeaderBackground(),
        collapseMode: CollapseMode.parallax, // Fades out
      ),
    );
  }

  // Expanded header (The 'background' for FlexibleSpaceBar)
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
          color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500),
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

  // --- Available Dates Widget ---
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
            _buildDateChip(
              context,
              label: "Today",
              date: _today,
              index: 0,
            ),
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

// --- Calendar Bottom Sheet ---
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
                            fontSize: 18.sp, fontWeight: FontWeight.bold),
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
                    selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      // This function now *only* updates the state
                      setModalState(() {
                        _selectedDate = selectedDay;
                      });
                      // Update the main page state as well
                      setState(() {
                        _selectedDateIndex = 3; // "Other"
                        _selectedDate = selectedDay;
                      });

                      // --- THIS LINE IS NOW REMOVED ---
                      // Navigator.of(context).pop();
                      // ---
                    },
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      titleTextStyle: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.w600),
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

  // --- Passenger Counter Widget ---
  Widget _buildPassengerCounter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      margin: EdgeInsets.symmetric(
          vertical: 20.h), // No horizontal margin needed
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

  // FIX: Added animation/feedback
  Widget _buildCounterButton(
      {required IconData icon, required VoidCallback onPressed}) {
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

  // --- Search Button Widget ---
  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Handle search action
          print("Searching busses...");
          print("From: ${_fromController.text}");
          print("To: ${_toController.text}");
          print("Date: ${DateFormat.yMd().format(_selectedDate)}");
          print("Passengers: $_personCount");
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _teal,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.r), // SHARPER
          ),
        ),
        child: Text(
          "Search busses",
          style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white),
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
                      color: _teal),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 120.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildOfferCard(),
                SizedBox(width: 12.w),
                _buildOfferCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard() {
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
            "Save up to 60% on ALL tickets",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Valid till: 26 Oct",
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
              "LOVEОСТВ",
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