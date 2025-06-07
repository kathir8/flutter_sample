import 'package:flutter/material.dart';
import 'models/date_format_utils.dart';
import 'models/booking_model.dart';

class BookSlot extends StatefulWidget {
  final String initialTime;
  final Map<String, List<BookingSlot>> bookings;
  final DateTime selectedDate;
  final Function() onBookingSuccess;
  final List<String> allTimeSlots;

  const BookSlot({
    super.key,
    required this.initialTime,
    required this.bookings,
    required this.selectedDate,
    required this.onBookingSuccess,
    required this.allTimeSlots,
  });

  @override
  State<BookSlot> createState() => _BookSlotState();
}

class _BookSlotState extends State<BookSlot> {
  late String _currentTime;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  List<BookingSlot> _matchedCustomers = [];

  @override
  void initState() {
    super.initState();
    _currentTime = widget.initialTime;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _navigateTimeSlot(int direction) {
    final currentIndex = widget.allTimeSlots.indexOf(_currentTime);
    if (currentIndex == -1) return;

    int newIndex = currentIndex;
    bool found = false;

    // Find next available slot in direction
    while (!found) {
      newIndex += direction;
      if (newIndex < 0 || newIndex >= widget.allTimeSlots.length) break;

      final potentialTime = widget.allTimeSlots[newIndex];
      final isBooked = _isSlotBooked(potentialTime);

      if (!isBooked) {
        found = true;
        setState(() => _currentTime = potentialTime);
      }
    }
  }

  bool _isSlotBooked(String time) {
    final dateKey = formatDate(widget.selectedDate, DateFormatType.iso);
    final bookingsForDate = widget.bookings[dateKey] ?? [];
    return bookingsForDate.any((slot) => slot.time == time);
  }

  void _onNameChanged(String input) {
    final input = _nameController.text.trim().toLowerCase();
    if (input.isEmpty) {
      setState(() => _matchedCustomers = []);
      return;
    }

    final allBookings = widget.bookings.values.expand((list) => list);
    final uniqueCustomers = {
      for (var c in allBookings) '${c.name}_${c.phone}': c,
    }.values.toList();

    setState(() {
      _matchedCustomers = uniqueCustomers
          .where((c) => c.name.toLowerCase().contains(input))
          .toList();

      if (_matchedCustomers.length > 3) {
        _matchedCustomers = _matchedCustomers.sublist(0, 3);
      }
    });
  }

  Widget _buildSuggestions() {
    if (_matchedCustomers.isEmpty) return const SizedBox();

    return Positioned(
      top: 60, // adjust this if needed (below name field)
      left: 0,
      right: 0,
      child: Material(
        elevation: 6,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          constraints: const BoxConstraints(
            maxHeight: 3 * 60.0, // 3 items
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _matchedCustomers.length,
            itemBuilder: (context, index) {
              final customer = _matchedCustomers[index];
              return Column(
                children: [
                  ListTile(
                    dense: true,
                    title: Text(customer.name),
                    subtitle: Text(
                      customer.phone,
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      setState(() {
                        _nameController.text = customer.name;
                        _phoneController.text = customer.phone;
                        _matchedCustomers.clear();
                      });
                    },
                  ),
                  if (index < _matchedCustomers.length - 1)
                    const Divider(
                      thickness: 0.5,
                      color: Colors.black12, // very light line
                      height: 0, // reduce spacing
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Book Slot', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left),
                onPressed: () => _navigateTimeSlot(-1),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  _currentTime,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: () => _navigateTimeSlot(1),
              ),
            ],
          ),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 250),
        child: SizedBox(
          width: double.maxFinite,
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    onChanged: _onNameChanged,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('CANCEL'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                        onPressed: _confirmBooking,
                        child: const Text('BOOK'),
                      ),
                    ],
                  ),
                ],
              ),
              _buildSuggestions(), // Suggestion list floats over everything
            ],
          ),
        ),
      ),
    );
  }

  void _confirmBooking() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter customer name')),
      );
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone number')),
      );
      return;
    }

    if (_isSlotBooked(_currentTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$_currentTime slot is already booked')),
      );
      return;
    }

    final dateKey = formatDate(widget.selectedDate, DateFormatType.iso);
    final newBooking = BookingSlot(
      time: _currentTime,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    widget.bookings.putIfAbsent(dateKey, () => []);
    widget.bookings[dateKey]!.add(newBooking);

    _nameController.clear();
    _phoneController.clear();

    Navigator.pop(context);
    widget.onBookingSuccess();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${newBooking.name} booked for $_currentTime'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
