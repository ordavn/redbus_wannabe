import 'package:flutter/material.dart';

class BusListPage extends StatelessWidget {
  const BusListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> buses = [
      {
        'name': 'MTrans.co.id',
        'route': 'Malang → Surabaya',
        'price': 'Rp 50.000',
        'departure': '20:30',
        'arrival': '23:40',
        'type': 'AC Sleeper 2+1',
        'rating': '4.5',
      },
      {
        'name': 'JURAGAN 99',
        'route': 'Malang → Jogjakarta',
        'price': 'Rp 135.000',
        'departure': '10:00',
        'arrival': '16:20',
        'type': 'Sleeper Bus',
        'rating': '4.7',
      },
      {
        'name': 'Harapan Jaya',
        'route': 'Madura → Surabaya',
        'price': 'Rp 35.000',
        'departure': '11:00',
        'arrival': '13:15',
        'type': 'Economy 2+2',
        'rating': '4.3',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Malang → Surabaya',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 4),
            Text(
              'Terminal Arjosari • Terminal Bungurasih',
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[800],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '15 Oct, Wed',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        ),
        centerTitle: false,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: buses.length,
        itemBuilder: (context, index) {
          final bus = buses[index];
          return InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/busDetail',
                arguments: bus, // kirim data bus ke halaman detail
              );
            },

            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Top row: Bus name + price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          bus['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          bus['price'],
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    //Middle row: departure time, duration, arrival time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          bus['departure'],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Column(
                          children: [
                            Text(
                              '3h 10m',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Icon(
                              Icons.more_horiz,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        Text(
                          bus['arrival'],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    //Bottom row: bus type, seats, rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          bus['type'],
                          style: const TextStyle(color: Colors.black54),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              bus['rating'],
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
