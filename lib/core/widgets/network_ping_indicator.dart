import 'package:flutter/material.dart';

class NetworkPingIndicator extends StatelessWidget {
  final int pingMs;

  const NetworkPingIndicator({
    Key? key,
    required this.pingMs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (pingMs <= 0) return const SizedBox.shrink();

    Color color;
    String text;

    if (pingMs < 150) {
      color = Colors.green;
      text = 'Good';
    } else if (pingMs < 400) {
      color = Colors.orange;
      text = 'Fair';
    } else {
      color = Colors.red;
      text = 'Poor';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            '$pingMs ms',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
