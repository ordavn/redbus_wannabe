import 'package:flutter/material.dart';

class SeatSelectionPage extends StatefulWidget {
  const SeatSelectionPage({super.key});

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  final List<int> _selectedSeats = [];
  final int seatPrice = 50000; // Price per seat

  @override
  Widget build(BuildContext context) {
    final bus =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    final int totalPrice = _selectedSeats.length * seatPrice;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Seats', style: TextStyle(fontSize: 18)),
            SizedBox(height: 4),
            Text(
              'Terminal Arjosari Malang',
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // SEAT AREA
            Expanded(
              child: Center(
                child: Container(
                  width: 220,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 12,
                  ),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.topRight,
                        child: Icon(
                          Icons.directions_bus,
                          size: 36,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                              ),
                          itemCount: 24,
                          itemBuilder: (context, index) {
                            final isSelected = _selectedSeats.contains(index);
                            final isUnavailable =
                                index % 7 == 0; // dummy unavailable

                            return GestureDetector(
                              onTap: isUnavailable
                                  ? null
                                  : () {
                                      setState(() {
                                        if (isSelected) {
                                          _selectedSeats.remove(index);
                                        } else {
                                          _selectedSeats.add(index);
                                        }
                                      });
                                    },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isUnavailable
                                        ? Colors.grey
                                        : isSelected
                                        ? Colors.green
                                        : Colors.black,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.event_seat,
                                    color: isUnavailable
                                        ? Colors.grey
                                        : isSelected
                                        ? Colors.green
                                        : Colors.black,
                                    size: 26,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            //BOTTOM PART: Number of seats + total price + buttons
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedSeats.length} Seat',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Rp. ${totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _selectedSeats.isEmpty
                          ? null
                          : () {
                              Navigator.pushNamed(
                                context,
                                '/payment',
                                arguments: {
                                  'bus': bus,
                                  'seats': _selectedSeats,
                                  'total': totalPrice,
                                },
                              );
                            },
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
