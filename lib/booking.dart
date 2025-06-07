import 'package:flutter/material.dart';
import 'package:flutter_sample/book_slot.dart';
import 'login.dart';
import 'models/date_format_utils.dart';
import 'search_page.dart';
import 'models/booking_model.dart';
import 'cancel_slot.dart';

// Main booking screen widget for a selected driving school
class MainBooking extends StatefulWidget {
  final String selectedSchool;
  final String userEmail;

  const MainBooking({
    super.key,
    required this.selectedSchool,
    required this.userEmail,
  });

  @override
  State<MainBooking> createState() => _MainBookingState();
}

class _MainBookingState extends State<MainBooking> {
  DateTime _selectedDate = DateTime.now();
  final Map<String, List<BookingSlot>> _bookings = {};
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedBookedSlot;

  @override
  void initState() {
    super.initState();
    // Initialize with some sample data
    _bookings[formatDate(DateTime.now(), DateFormatType.iso)] = [
      BookingSlot(time: '10:00 AM', name: 'John Doe', phone: '1234567890'),
      BookingSlot(time: '11:30 AM', name: 'Jane Smith', phone: '9876543210'),
      BookingSlot(time: '12:00 PM', name: 'Jane Johnson', phone: '5551234567'),
      BookingSlot(time: '12:30 PM', name: 'Mike Johnson', phone: '5551234567'),
    ];
    _bookings[formatDate(
      DateTime.now().add(const Duration(days: 1)),
      DateFormatType.iso,
    )] = [
      BookingSlot(time: '10:00 AM', name: 'Mike Johnson', phone: '5551234567'),
    ];
    _bookings[formatDate(
      DateTime.now().subtract(const Duration(days: 1)),
      DateFormatType.iso,
    )] = [
      BookingSlot(time: '11:00 AM', name: 'Mike Johnson', phone: '5551234567'),
    ];
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Opens a date picker dialog to select a date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedBookedSlot = null; // Close any open booking details
      });
    }
  }

  // Navigates forward or backward by the given number of days
  void _navigateDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
      _selectedBookedSlot = null; // Close any open booking details
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get bookings and check if the date is in the past
    final dateKey = formatDate(_selectedDate, DateFormatType.iso);
    final slotsForSelectedDate = _bookings[dateKey] ?? [];
    final bookedTimes = slotsForSelectedDate.map((slot) => slot.time).toList();
    final isPastDate = _selectedDate.isBefore(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    );
    final timeSlots = _generateTimeSlots();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedSchool),
        actions: [
          IconButton(
            // Navigate to Search Page
            icon: const Icon(Icons.search),
            onPressed: () async {
              final selectedDate = await Navigator.push<DateTime?>(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPage(bookings: _bookings),
                ),
              );
              if (selectedDate != null) {
                setState(() {
                  _selectedDate = selectedDate;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Navigation Card (← Date →)
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date selector
                  IconButton(
                    icon: const Icon(Icons.arrow_left),
                    onPressed: () => _navigateDate(-1),
                    iconSize: 32,
                  ),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        formatDate(_selectedDate, DateFormatType.longDay),
                        style: TextStyle(
                          fontSize: 18,
                          color: isPastDate ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_right),
                    onPressed: () => _navigateDate(1),
                    iconSize: 32,
                  ),
                ],
              ),
            ),
          ),
          // Driving school info and user email
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.selectedSchool,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Logged in as: ${widget.userEmail}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Time slot Grid View
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                // Generate rows: each row has 2 time slots (columns)
                children: List.generate(
                  (timeSlots.length / 2).ceil(), // Number of rows needed
                  (rowIndex) {
                    // Calculate the indices of the two time slots for this row
                    final firstIndex = rowIndex * 2;
                    final secondIndex = firstIndex + 1;

                    // Get the first and second time slots (if available)
                    final firstSlot = timeSlots[firstIndex];
                    final secondSlot = secondIndex < timeSlots.length
                        ? timeSlots[secondIndex]
                        : null;

                    final isFirstColumnSelected =
                        _selectedBookedSlot == firstSlot;
                    final isSecondColumnSelected =
                        _selectedBookedSlot == secondSlot;

                    return Column(
                      children: [
                        Row(
                          // Display one row with up to two time slots
                          children: [
                            Expanded(
                              // First time slot (always present)
                              child: _buildTimeSlotCard(
                                firstSlot,
                                bookedTimes,
                                slotsForSelectedDate,
                              ),
                            ),
                            if (secondSlot != null) // Second time slot (only if within bounds)
                              Expanded(
                                child: _buildTimeSlotCard(
                                  secondSlot,
                                  bookedTimes,
                                  slotsForSelectedDate,
                                ),
                              ),
                          ],
                        ),

                        // Show booked details below the row if a selected slot is in this row
                        if (_selectedBookedSlot != null && (isFirstColumnSelected || isSecondColumnSelected))
                          CancelSlotWidget(
                            selectedDate: _selectedDate,
                            bookings: _bookings,
                            selectedBookedSlot: _selectedBookedSlot!,
                            onCancel: _cancelBooking,
                            isFirstColumnSelected: isFirstColumnSelected,
                            isSecondColumnSelected: isSecondColumnSelected,
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Generates time slots between 10:00 AM and 6:00 PM (inclusive)
  List<String> _generateTimeSlots() {
    final slots = <String>[];
    DateTime currentTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      10,
      0,
    ); // Start at 10:00 AM

    // Keep adding 30-minute intervals until 6:00 PM (inclusive)
    while (currentTime.hour < 18) {
      slots.add(formatDate(currentTime, DateFormatType.timeOnly));
      currentTime = currentTime.add(const Duration(minutes: 30));
    }
    return slots;
  }

  // Add these helper methods
  Widget _buildTimeSlotCard(
    String time,
    List<String> bookedTimes,
    List<BookingSlot> slotsForSelectedDate,
  ) {
    final isBooked = bookedTimes.contains(time);
    final isPastDate = _selectedDate.isBefore(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    );
    final bookedSlot = isBooked
        ? slotsForSelectedDate.firstWhere((slot) => slot.time == time)
        : null;

    return GestureDetector(
      onTap: () {
        if (isBooked) {
          setState(() {
            _selectedBookedSlot = _selectedBookedSlot == time ? null : time;
          });
        } else if (!isPastDate) {
          setState(() {
            _selectedBookedSlot = null; // Close any open booking details
          });
          showDialog(
            context: context,
            builder: (context) => BookSlot(
              initialTime: time,
              bookings: _bookings,
              selectedDate: _selectedDate,
              onBookingSuccess: () => setState(() {}),
              allTimeSlots: _generateTimeSlots(),
            ),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.all(8),
        color: isPastDate
            ? Colors.grey[200]
            : isBooked
            ? Colors.blue[100]
            : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isPastDate
                      ? Colors.grey
                      : isBooked
                      ? Colors.blue[800]
                      : Colors.black,
                ),
              ),
              if (isBooked)
                Text(bookedSlot!.name, style: const TextStyle(fontSize: 12)),
              if (isPastDate && !isBooked)
                const Text(
                  'Not available',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _cancelBooking(BookingSlot slot, String time) {
    final dateKey = formatDate(_selectedDate, DateFormatType.iso);
    setState(() {
      _bookings[dateKey]?.removeWhere(
        (s) => s.time == time && s.name == slot.name && s.phone == slot.phone,
      );
      _selectedBookedSlot = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking for ${slot.name} at $time cancelled'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
