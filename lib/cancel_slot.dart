import 'package:flutter/material.dart';
import 'models/booking_model.dart';
import 'models/date_format_utils.dart';

class CancelSlotWidget extends StatelessWidget {
  final DateTime selectedDate;
  final Map<String, List<BookingSlot>> bookings;
  final String selectedBookedSlot;
  final Function(BookingSlot, String) onCancel;
  final bool isFirstColumnSelected;
  final bool isSecondColumnSelected;

  const CancelSlotWidget({
    super.key,
    required this.selectedDate,
    required this.bookings,
    required this.selectedBookedSlot,
    required this.onCancel,
    required this.isFirstColumnSelected,
    required this.isSecondColumnSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: isFirstColumnSelected
                  ? Center(
                      child: CustomPaint(
                        size: const Size(20, 10),
                        painter: TrianglePainter(),
                      ),
                    )
                  : const SizedBox(),
            ),
            Expanded(
              child: isSecondColumnSelected
                  ? Center(
                      child: CustomPaint(
                        size: const Size(20, 10),
                        painter: TrianglePainter(),
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        ),

        _buildBookedDetails(context, selectedBookedSlot),
      ],
    );
  }

  Widget _buildBookedDetails(BuildContext context, String time) {
    final dateKey = formatDate(selectedDate, DateFormatType.iso);
    final slotsForDate = bookings[dateKey] ?? [];
    final bookedSlot = slotsForDate.firstWhere((slot) => slot.time == time);

    if (bookedSlot.name.isEmpty) {
      return Container();
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 4),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Customer: ${bookedSlot.name}'),
                    Text('Phone: ${bookedSlot.phone}'),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                  onPressed: () {
                    final formattedDate = formatDate(
                      selectedDate,
                      DateFormatType.iso,
                    );
                    final message = RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          const TextSpan(
                            text:
                                'Are you sure you want to cancel booking for ',
                          ),
                          TextSpan(
                            text: bookedSlot.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: ' on '),
                          TextSpan(
                            text: formattedDate,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: ' at '),
                          TextSpan(
                            text: bookedSlot.time,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: '?'),
                        ],
                      ),
                    );

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Cancel Booking'),
                        content: message,
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () {
                              onCancel(bookedSlot, time);
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Yes',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Cancel booking'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade50
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
