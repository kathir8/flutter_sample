import 'package:flutter/material.dart';
import 'models/booking_model.dart';

class CancelSlotWidget extends StatelessWidget {
  final String cancelledDate;
  final BookingSlot bookedSlot;
  final Function(BookingSlot) onCancel;
  final bool isFirstColumnSelected;
  final bool isSecondColumnSelected;
  final bool isDisabled;

  const CancelSlotWidget({
    super.key,
    required this.cancelledDate,
    required this.bookedSlot,
    required this.onCancel,
    required this.isFirstColumnSelected,
    required this.isSecondColumnSelected,
    required this.isDisabled,
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
                        painter: TrianglePainter(isDisabled:isDisabled),
                      ),
                    )
                  : const SizedBox(),
            ),
            Expanded(
              child: isSecondColumnSelected
                  ? Center(
                      child: CustomPaint(
                        size: const Size(20, 10),
                        painter: TrianglePainter(isDisabled:isDisabled),
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        ),

        _buildBookedDetails(context),
      ],
    );
  }

  Widget _buildBookedDetails(BuildContext context) {
    if (bookedSlot.name.isEmpty) {
      return Container();
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 4),
      color:  isDisabled ? Colors.grey[200] : Colors.blue[50],
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
                if (!isDisabled)
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
                            text: cancelledDate,
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
                        title: const Text('Cancel booking'),
                        content: message,
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () {
                              onCancel(bookedSlot);
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
  final bool isDisabled;
  TrianglePainter({required this.isDisabled});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDisabled ? Colors.grey.shade200 : Colors.blue.shade50
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
