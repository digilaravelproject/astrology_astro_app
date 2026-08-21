import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'app_text.dart';

class NavItem {
  final IconData icon;
  final String label;

  NavItem({required this.icon, required this.label});
}

class CustomBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final List<NavItem> items;
  final Function(int) onItemSelected;
  final Color? gradientColor;

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.items,
    required this.onItemSelected,
    this.gradientColor,
  }) : super(key: key);

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color fadeColor = widget.gradientColor ?? Colors.white;
    final int itemsCount = widget.items.length;
    final double bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 100 + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset : 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            fadeColor.withOpacity(0.0),
            fadeColor.withOpacity(0.9),
            fadeColor,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Main Nav Bar Container
          Container(
            height: 65,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(itemsCount, (index) {
                return Expanded(
                  child: widget.selectedIndex == index
                      ? const SizedBox.shrink()
                      : _buildNavItem(index),
                );
              }),
            ),
          ),

          // Elevated selected item
          Positioned(
            left: _calculateLeftPosition(widget.selectedIndex, itemsCount),
            top: 5,
            child: _buildElevatedItem(widget.selectedIndex),
          ),
        ],
      ),
    );
  }

  double _calculateLeftPosition(int selectedIndex, int totalItems) {
    final double availableWidth = Get.width - 20;
    final double itemWidth = availableWidth / totalItems;
    return 10 + (itemWidth * selectedIndex) + (itemWidth / 2) - 25;
  }

  Widget _buildNavItem(int index) {
    final item = widget.items[index];

    return GestureDetector(
      onTap: () => widget.onItemSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            item.icon,
            color: Colors.grey.shade400,
            size: 22,
          ),
          const SizedBox(height: 2),
          AppText(
            item.label,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade400,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildElevatedItem(int index) {
    final item = widget.items[index];

    return GestureDetector(
      onTap: () => widget.onItemSelected(index),
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryColor,
                    Color(0xFFE94E4E),
                  ],
                  stops: [0.0, 1.0],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Icon(
                item.icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 2),
            AppText(
              item.label,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryColor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
