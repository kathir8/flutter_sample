class BookingSlot {
  final String time;
  final String name;
  final String phone;
  final DateTime? date;

  BookingSlot({
    required this.time,
    required this.name,
    required this.phone,
    this.date,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingSlot &&
          runtimeType == other.runtimeType &&
          time == other.time &&
          name == other.name &&
          phone == other.phone;

  @override
  int get hashCode => time.hashCode ^ name.hashCode ^ phone.hashCode;
}

class CustomerSummary {
  final String name;
  final String phone;
  final DateTime lastBookingDate;
  final int bookingCount;

  CustomerSummary({
    required this.name,
    required this.phone,
    required this.lastBookingDate,
    required this.bookingCount,
  });

  CustomerSummary copyWith({
    String? name,
    String? phone,
    DateTime? lastBookingDate,
    int? bookingCount,
  }) {
    return CustomerSummary(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      lastBookingDate: lastBookingDate ?? this.lastBookingDate,
      bookingCount: bookingCount ?? this.bookingCount,
    );
  }
}