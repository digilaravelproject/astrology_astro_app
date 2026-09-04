import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';

class KundliChartWidget extends StatefulWidget {
  final String title;
  final String? northIndianSvg;
  final String? southIndianSvg;
  final Map<int, List<String>>? northIndianPlanetData;
  final Map<int, List<String>>? southIndianPlanetData;
  final bool isLoading;

  const KundliChartWidget({
    super.key,
    required this.title,
    this.northIndianSvg,
    this.southIndianSvg,
    Map<int, List<String>>? planetData,
    Map<int, List<String>>? northIndianPlanetData,
    this.southIndianPlanetData,
    this.isLoading = false,
  }) : northIndianPlanetData = northIndianPlanetData ?? planetData;

  @override
  State<KundliChartWidget> createState() => _KundliChartWidgetState();
}

class _KundliChartWidgetState extends State<KundliChartWidget> {
  bool isNorthIndian = true;

  void _openFullScreenChart() {
    final svgString =
        isNorthIndian ? widget.northIndianSvg : widget.southIndianSvg;
    final fallbackData =
        isNorthIndian
            ? widget.northIndianPlanetData
            : widget.southIndianPlanetData;

    if (widget.isLoading || (svgString == null && fallbackData == null)) return;

    Get.to(
      () => FullScreenChartScreen(
        title:
            "${widget.title.tr} (${(isNorthIndian ? 'North Indian' : 'South Indian').tr})",
        svgString: svgString,
        isNorthIndian: isNorthIndian,
        fallbackPlanetData: fallbackData,
      ),
      transition: Transition.fadeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildToggleItem(
                  "North Indian".tr,
                  isNorthIndian,
                  () => setState(() => isNorthIndian = true),
                ),
                const SizedBox(width: 4),
                _buildToggleItem(
                  "South Indian".tr,
                  !isNorthIndian,
                  () => setState(() => isNorthIndian = false),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: _openFullScreenChart,
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.12),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _buildChartContent(),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.fullscreen_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 16),
          child: GestureDetector(
            onTap: _openFullScreenChart,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  widget.title.tr,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.zoom_in,
                  size: 18,
                  color: AppColors.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartContent() {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }

    final svgString =
        isNorthIndian ? widget.northIndianSvg : widget.southIndianSvg;

    if (svgString != null && svgString.isNotEmpty) {
      return SvgPicture.string(svgString, fit: BoxFit.contain);
    }

    // Fallback to manual CustomPainter if no SVG exists
    final fallbackData =
        isNorthIndian
            ? widget.northIndianPlanetData
            : widget.southIndianPlanetData;
    if (fallbackData != null) {
      return CustomPaint(
        painter: KundliPainter(
          isNorthIndian: isNorthIndian,
          planetData: fallbackData,
        ),
      );
    }

    return Center(
      child: AppText("No chart available".tr, color: Colors.grey),
    );
  }

  Widget _buildToggleItem(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow:
              isActive
                  ? [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : [],
        ),
        child: AppText(
          label,
          color: isActive ? Colors.white : Colors.black87,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }
}

class FullScreenChartScreen extends StatelessWidget {
  final String title;
  final String? svgString;
  final bool isNorthIndian;
  final Map<int, List<String>>? fallbackPlanetData;

  const FullScreenChartScreen({
    super.key,
    required this.title,
    this.svgString,
    required this.isNorthIndian,
    this.fallbackPlanetData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: AppText(
          title,
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 5.0,
            clipBehavior: Clip.none,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: AspectRatio(aspectRatio: 1, child: _buildChartContent()),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartContent() {
    if (svgString != null && svgString!.isNotEmpty) {
      return SvgPicture.string(svgString!, fit: BoxFit.contain);
    }

    if (fallbackPlanetData != null) {
      return CustomPaint(
        painter: KundliPainter(
          isNorthIndian: isNorthIndian,
          planetData: fallbackPlanetData!,
        ),
      );
    }

    return Center(
      child: AppText("No chart available".tr, color: Colors.grey),
    );
  }
}

class KundliPainter extends CustomPainter {
  final bool isNorthIndian;
  final Map<int, List<String>>
  planetData; // Key: house (North) or signNumber (South)

  KundliPainter({required this.isNorthIndian, required this.planetData});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    if (isNorthIndian) {
      _drawNorthIndianChart(canvas, size, linePaint);
    } else {
      _drawSouthIndianChart(canvas, size, linePaint);
    }
  }

  void _drawNorthIndianChart(Canvas canvas, Size size, Paint paint) {
    final double w = size.width;
    final double h = size.height;

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);
    canvas.drawLine(Offset(0, 0), Offset(w, h), paint);
    canvas.drawLine(Offset(w, 0), Offset(0, h), paint);
    canvas.drawLine(Offset(w / 2, 0), Offset(0, h / 2), paint);
    canvas.drawLine(Offset(0, h / 2), Offset(w / 2, h), paint);
    canvas.drawLine(Offset(w / 2, h), Offset(w, h / 2), paint);
    canvas.drawLine(Offset(w, h / 2), Offset(w / 2, 0), paint);

    _drawPlanetsInNorthIndian(canvas, size);
  }

  void _drawPlanetsInNorthIndian(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Map<int, Offset> housePositions = {
      1: Offset(w * 0.5, h * 0.25),
      2: Offset(w * 0.25, h * 0.125),
      3: Offset(w * 0.125, h * 0.25),
      4: Offset(w * 0.25, h * 0.5),
      5: Offset(w * 0.125, h * 0.75),
      6: Offset(w * 0.25, h * 0.875),
      7: Offset(w * 0.5, h * 0.75),
      8: Offset(w * 0.75, h * 0.875),
      9: Offset(w * 0.875, h * 0.75),
      10: Offset(w * 0.75, h * 0.5),
      11: Offset(w * 0.875, h * 0.25),
      12: Offset(w * 0.75, h * 0.125),
    };

    planetData.forEach((house, planets) {
      if (housePositions.containsKey(house)) {
        final pos = housePositions[house]!;
        final text = planets.join(' ');
        _drawCenteredText(canvas, pos, text);
      }
    });
  }

  void _drawSouthIndianChart(Canvas canvas, Size size, Paint paint) {
    final double w = size.width;
    final double h = size.height;

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);

    final double cellW = w / 4;
    final double cellH = h / 4;

    for (int i = 1; i < 4; i++) {
      canvas.drawLine(Offset(i * cellW, 0), Offset(i * cellW, h), paint);
      canvas.drawLine(Offset(0, i * cellH), Offset(w, i * cellH), paint);
    }

    final Paint fillPaint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(cellW, cellH, cellW * 2, cellH * 2),
      fillPaint,
    );
    canvas.drawRect(Rect.fromLTWH(cellW, cellH, cellW * 2, cellH * 2), paint);

    _drawPlanetsInSouthIndian(canvas, size);
  }

  void _drawPlanetsInSouthIndian(Canvas canvas, Size size) {
    final double cellW = size.width / 4;
    final double cellH = size.height / 4;

    final Map<int, Offset> signPositions = {
      1: Offset(cellW * 1.5, cellH * 0.5),
      2: Offset(cellW * 2.5, cellH * 0.5),
      3: Offset(cellW * 3.5, cellH * 0.5),
      4: Offset(cellW * 3.5, cellH * 1.5),
      5: Offset(cellW * 3.5, cellH * 2.5),
      6: Offset(cellW * 3.5, cellH * 3.5),
      7: Offset(cellW * 2.5, cellH * 3.5),
      8: Offset(cellW * 1.5, cellH * 3.5),
      9: Offset(cellW * 0.5, cellH * 3.5),
      10: Offset(cellW * 0.5, cellH * 2.5),
      11: Offset(cellW * 0.5, cellH * 1.5),
      12: Offset(cellW * 0.5, cellH * 0.5),
    };

    planetData.forEach((signNum, planets) {
      if (signPositions.containsKey(signNum)) {
        final pos = signPositions[signNum]!;
        final text = planets.join(' ');
        _drawCenteredText(canvas, pos, text);
      }
    });
  }

  void _drawCenteredText(Canvas canvas, Offset center, String text) {
    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - (textPainter.width / 2),
        center.dy - (textPainter.height / 2),
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
