import 'package:flutter/material.dart';
import 'login.dart';
import 'models/date_format_utils.dart';
import 'search_page.dart';
import 'models/booking_slot.dart';

// Main booking screen widget for a selected driving school
class MainBookingPage extends StatefulWidget {
  final String selectedSchool;
  final String userEmail;

  const MainBookingPage({
    super.key,
    required this.selectedSchool,
    required this.userEmail,
  });

  @override
  State<MainBookingPage> createState() => _MainBookingPageState();
}

class _MainBookingPageState extends State<MainBookingPage> {
  DateTime _selectedDate = DateTime.now();
  final Map<String, List<BookingSlot>> _bookings = {};
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with some sample data
    _bookings[formatDate(DateTime.now(), DateFormatType.iso)] = [
      BookingSlot(time: '10:00 AM', name: 'John Doe', phone: '1234567890'),
      BookingSlot(time: '11:30 AM', name: 'Jane Smith', phone: '9876543210'),
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
      });
    }
  }

  // Navigates forward or backward by the given number of days
  void _navigateDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  // Handles booking a time slot
  void _bookSlot(String time) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Book Slot'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Customer Name'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Validate input and save the booking
              if (_nameController.text.isNotEmpty &&
                  _phoneController.text.isNotEmpty) {
                setState(() {
                  final dateKey = formatDate(_selectedDate, DateFormatType.iso);
                  _bookings.putIfAbsent(dateKey, () => []);
                  _bookings[dateKey]!.add(
                    BookingSlot(
                      time: time,
                      name: _nameController.text,
                      phone: _phoneController.text,
                    ),
                  );
                  _nameController.clear();
                  _phoneController.clear();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Slot booked successfully!')),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  // Displays a dialog showing details of a booked slot
  void _viewBookingDetails(BookingSlot slot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time: ${slot.time}'),
            Text('Name: ${slot.name}'),
            Text('Phone: ${slot.phone}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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

          // Slot Grid View
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: _generateTimeSlots().map((time) {
                final isBooked = bookedTimes.contains(time);
                final bookedSlot = isBooked
                    ? slotsForSelectedDate.firstWhere(
                        (slot) => slot.time == time,
                      )
                    : null;

                return GestureDetector(
                  onTap: () {
                    if (isBooked) {
                      _viewBookingDetails(bookedSlot!);
                    } else if (!isPastDate) {
                      _bookSlot(time);
                    }
                  },
                  child: Card(
                    color: isPastDate
                        ? Colors.grey[200]
                        : isBooked
                        ? Colors.blue[100]
                        : Colors.white,
                    child: Center(
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
                            Text(
                              bookedSlot!.name,
                              style: const TextStyle(fontSize: 12),
                            ),
                          if (isPastDate && !isBooked)
                            const Text(
                              'Not available',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
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
      // Until 6:00 PM
      slots.add(formatDate(currentTime, DateFormatType.timeOnly));
      currentTime = currentTime.add(const Duration(minutes: 30));
    }

    return slots;
  }
}
