import 'package:flutter/material.dart';
import 'models/date_format_utils.dart';
import 'models/booking_model.dart';

class CustomerBookings extends StatefulWidget {
  final List<BookingSlot> bookings;

  const CustomerBookings({super.key, required this.bookings});

  @override
  State<CustomerBookings> createState() => _CustomerBookingsState();
}

class _CustomerBookingsState extends State<CustomerBookings> {
  Future<void> fetchData() async {
    await Future.delayed(Duration(seconds: 1)); // Simulate loading delay
    setState(() {}); // Refresh the UI
  }

  Future<void> _refreshData() async {
    await fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final List<BookingSlot> bookings = widget.bookings;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${bookings.length} bookings found',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Phone: ${bookings.isNotEmpty ? bookings.first.phone : ''}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            Expanded(
              child: bookings.isEmpty
                  ? const Center(child: Text("No bookings found"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final booking = bookings[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: ListTile(
                            title: Text(
                              booking.time,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              formatDate(
                                booking.date!,
                                DateFormatType.fullLong,
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
    );
  }
}
