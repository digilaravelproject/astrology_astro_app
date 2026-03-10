import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';

class KundliChartWidget extends StatefulWidget {
  final String title;
  final Map<int, List<String>>? planetData; // House number (1-12) -> List of planets
  
  const KundliChartWidget({
    super.key, 
    required this.title, 
    this.planetData,
  });

  @override
  State<KundliChartWidget> createState() => _KundliChartWidgetState();
}

class _KundliChartWidgetState extends State<KundliChartWidget> {
  bool isNorthIndian = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildToggleItem("North Indian", isNorthIndian, () => setState(() => isNorthIndian = true)),
                const SizedBox(width: 4),
                _buildToggleItem("South Indian", !isNorthIndian, () => setState(() => isNorthIndian = false)),
              ],
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: CustomPaint(
                  painter: KundliPainter(
                    isNorthIndian: isNorthIndian,
                    planetData: widget.planetData ?? {},
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          child: AppText(
            widget.title,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleItem(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive ? [BoxShadow(color: AppColors.primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))] : null,
        ),
        child: AppText(
          label,
          fontSize: 13,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          color: isActive ? Colors.white : AppColors.textColorSecondary,
        ),
      ),
    );
  }
}

class KundliPainter extends CustomPainter {
  final bool isNorthIndian;
  final Map<int, List<String>> planetData;

  KundliPainter({required this.isNorthIndian, required this.planetData});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryColor.withOpacity(0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    if (isNorthIndian) {
      _drawNorthIndianChart(canvas, size, paint);
      _drawNorthIndianPlanets(canvas, size);
    } else {
      _drawSouthIndianChart(canvas, size, paint);
      _drawSouthIndianPlanets(canvas, size);
    }
  }

  void _drawNorthIndianChart(Canvas canvas, Size size, Paint paint) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
    canvas.drawLine(Offset(size.width / 2, 0), Offset(0, size.height / 2), paint);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width / 2, size.height), paint);
    canvas.drawLine(Offset(size.width / 2, size.height), Offset(size.width, size.height / 2), paint);
    canvas.drawLine(Offset(size.width, size.height / 2), Offset(size.width / 2, 0), paint);
  }

  void _drawNorthIndianPlanets(Canvas canvas, Size size) {
    final housePositions = {
      1: Offset(size.width / 2, size.height / 4),
      2: Offset(size.width / 4, size.height / 8),
      3: Offset(size.width / 8, size.height / 4),
      4: Offset(size.width / 4, size.height / 2),
      5: Offset(size.width / 8, size.height * 0.75),
      6: Offset(size.width / 4, size.height * 0.875),
      7: Offset(size.width / 2, size.height * 0.75),
      8: Offset(size.width * 3/4, size.height * 0.875),
      9: Offset(size.width * 7/8, size.height * 0.75),
      10: Offset(size.width * 3/4, size.height / 2),
      11: Offset(size.width * 7/8, size.height / 4),
      12: Offset(size.width * 3/4, size.height / 8),
    };

    planetData.forEach((house, planets) {
      if (housePositions.containsKey(house)) {
        _drawPlanetText(canvas, housePositions[house]!, planets);
      }
    });
  }

  void _drawSouthIndianChart(Canvas canvas, Size size, Paint paint) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    final cellW = size.width / 4;
    final cellH = size.height / 4;
    for (int i = 1; i < 4; i++) {
      canvas.drawLine(Offset(i * cellW, 0), Offset(i * cellW, size.height), paint);
      canvas.drawLine(Offset(0, i * cellH), Offset(size.width, i * cellH), paint);
    }
  }

  void _drawSouthIndianPlanets(Canvas canvas, Size size) {
    final cellW = size.width / 4;
    final cellH = size.height / 4;
    
    // South Indian sign positions
    final signPositions = {
      12: Offset(0 * cellW + cellW/2, 0 * cellH + cellH/2),
      1: Offset(1 * cellW + cellW/2, 0 * cellH + cellH/2),
      2: Offset(2 * cellW + cellW/2, 0 * cellH + cellH/2),
      3: Offset(3 * cellW + cellW/2, 0 * cellH + cellH/2),
      4: Offset(3 * cellW + cellW/2, 1 * cellH + cellH/2),
      5: Offset(3 * cellW + cellW/2, 2 * cellH + cellH/2),
      6: Offset(3 * cellW + cellW/2, 3 * cellH + cellH/2),
      7: Offset(2 * cellW + cellW/2, 3 * cellH + cellH/2),
      8: Offset(1 * cellW + cellW/2, 3 * cellH + cellH/2),
      9: Offset(0 * cellW + cellW/2, 3 * cellH + cellH/2),
      10: Offset(0 * cellW + cellW/2, 2 * cellH + cellH/2),
      11: Offset(0 * cellW + cellW/2, 1 * cellH + cellH/2),
    };

    planetData.forEach((sign, planets) {
      if (signPositions.containsKey(sign)) {
        _drawPlanetText(canvas, signPositions[sign]!, planets);
      }
    });
  }

  void _drawPlanetText(Canvas canvas, Offset position, List<String> planets) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    String planetStr = planets.join(" ");
    if (planets.length > 3) {
      planetStr = "${planets.take(2).join(" ")}\n${planets.skip(2).join(" ")}";
    }

    textPainter.text = TextSpan(
      text: planetStr,
      style: TextStyle(
        color: Colors.black87,
        fontSize: planetStr.contains("\n") ? 7 : 9,
        fontWeight: FontWeight.w600,
      ),
    );

    textPainter.layout();
    textPainter.paint(canvas, position - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant KundliPainter oldDelegate) => 
      oldDelegate.isNorthIndian != isNorthIndian || oldDelegate.planetData != planetData;
}
