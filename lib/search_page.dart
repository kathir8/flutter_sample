import 'package:flutter/material.dart';
import 'models/date_format_utils.dart';
import 'models/booking_model.dart';

class SearchPage extends StatefulWidget {
  final Map<String, List<BookingSlot>> bookings;

  const SearchPage({super.key, required this.bookings});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<CustomerSummary> _customerSummaries = [];
  List<BookingSlot> _customerBookings = [];
  String? _selectedCustomer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    setState(() {
      _customerSummaries = [];
      _selectedCustomer = null;

      if (_searchController.text.isNotEmpty) {
        final customerMap = <String, CustomerSummary>{};

        widget.bookings.forEach((dateStr, slots) {
          final date = DateTime.parse(dateStr);
          for (var slot in slots) {
            if (slot.name.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            )) {
              // Update or create customer summary
              if (!customerMap.containsKey(slot.name) ||
                  customerMap[slot.name]!.lastBookingDate.isBefore(date)) {
                customerMap[slot.name] = CustomerSummary(
                  name: slot.name,
                  phone: slot.phone,
                  lastBookingDate: date,
                  bookingCount: (customerMap[slot.name]?.bookingCount ?? 0) + 1,
                );
              } else {
                customerMap[slot.name] = customerMap[slot.name]!.copyWith(
                  bookingCount: customerMap[slot.name]!.bookingCount + 1,
                );
              }
            }
          }
        });

        _customerSummaries = customerMap.values.toList()
          ..sort((a, b) => b.lastBookingDate.compareTo(a.lastBookingDate));
      }
    });
  }

  void _showCustomerBookings(String customerName) {
    setState(() {
      _selectedCustomer = customerName;
      _customerBookings = [];

      widget.bookings.forEach((dateStr, slots) {
        final date = DateTime.parse(dateStr);
        for (var slot in slots) {
          if (slot.name == customerName) {
            _customerBookings.add(
              BookingSlot(
                time: slot.time,
                name: slot.name,
                phone: slot.phone,
                date: date,
              ),
            );
          }
        }
      });

      // Sort bookings by date (newest first)
      _customerBookings.sort((a, b) => b.date!.compareTo(a.date!));
    });
  }

  void _goBackToCustomerList() {
    setState(() {
      _selectedCustomer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _selectedCustomer == null
            ? const Text('Search Customers')
            : Text(_selectedCustomer!),
        leading: _selectedCustomer != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goBackToCustomerList,
              )
            : null,
      ),
      body: Column(
        children: [
          if(_selectedCustomer == null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by customer name',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              autofocus: true,
            ),
          ),
          Expanded(child: _buildResultsView()),
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    if (_selectedCustomer != null) {
      return _buildCustomerBookings();
    }

    if (_searchController.text.isEmpty) {
      return const Center(
        child: Text(
          'Enter customer name to search',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    if (_customerSummaries.isEmpty) {
      return const Center(
        child: Text('No customers found', style: TextStyle(fontSize: 18)),
      );
    }

    return _buildCustomerSummaries();
  }

  Widget _buildCustomerSummaries() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _customerSummaries.length,
      itemBuilder: (context, index) {
        final customer = _customerSummaries[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text(customer.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Phone: ${customer.phone}'),
                Text(
                  'Last booking: ${formatDate(customer.lastBookingDate, DateFormatType.iso)}',
                ),
                Text('Total bookings: ${customer.bookingCount}'),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCustomerBookings(customer.name),
          ),
        );
      },
    );
  }

  Widget _buildCustomerBookings() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_customerBookings.length} bookings found',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Phone: ${_customerBookings.isNotEmpty ? _customerBookings.first.phone : ''}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _customerBookings.length,
            itemBuilder: (context, index) {
              final booking = _customerBookings[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(
                    booking.time,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(formatDate(booking.date!, DateFormatType.fullLong)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
