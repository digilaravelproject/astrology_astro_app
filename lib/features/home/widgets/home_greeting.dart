import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_text.dart';

class HomeGreeting extends StatelessWidget {
  final String? name;
  final String? greeting;

  const HomeGreeting({
    Key? key,
    this.name,
    this.greeting,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              greeting ?? AppStrings.hello,
              style: GoogleFonts.poppins(
                fontSize: 22, // Increased size to match screenshot better
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              name ?? AppStrings.guest,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryColor, // Using primary pink from astrologer app
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 4),
            const WavingEmoji(),
          ],
        ),
      ],
    );
  }
}

class WavingEmoji extends StatefulWidget {
  const WavingEmoji({Key? key}) : super(key: key);

  @override
  State<WavingEmoji> createState() => _WavingEmojiState();
}

class _WavingEmojiState extends State<WavingEmoji> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: (_controller.value - 0.5) * 0.4,
          child: AppText("👋", fontSize: 24),
        );
      },
    );
  }
}
