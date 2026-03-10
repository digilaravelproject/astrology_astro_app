import 'package:flutter/material.dart';

/// A premium "Loyal" ribbon tag used on customer cards across the app.
/// Place inside a [Stack] — use [LoyalBadge.positioned()] for card top-left corner.
class LoyalBadge extends StatelessWidget {
  final String label;
  final BadgeStyle style;

  const LoyalBadge({
    Key? key,
    this.label = 'Loyal',
    this.style = BadgeStyle.card,
  }) : super(key: key);

  /// Top-left ribbon for cards — drop into a Stack
  static Widget positioned({String label = 'Loyal', double top = -14, double left = -2}) {
    return Positioned(
      top: top,
      left: left,
      child: LoyalBadge(label: label, style: BadgeStyle.card),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCard = style == BadgeStyle.card;

    return Container(
      padding: EdgeInsets.fromLTRB(isCard ? 10 : 8, isCard ? 4 : 3, isCard ? 14 : 10, isCard ? 4 : 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6F00), Color(0xFFFFB300)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: isCard
            ? const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              )
            : BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6F00).withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(1, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium_rounded, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1.0,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

enum BadgeStyle { card, pill }
