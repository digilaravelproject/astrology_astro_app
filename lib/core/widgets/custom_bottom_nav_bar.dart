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

    return Container(
      height: 140,
      padding: const EdgeInsets.only(bottom: 20),
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
            height: 70,
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
            top: 30,
            child: _buildElevatedItem(widget.selectedIndex),
          ),
        ],
      ),
    );
  }

  double _calculateLeftPosition(int selectedIndex, int totalItems) {
    // Total width available for items (scaffold padding/margins + container margins)
    final double availableWidth = Get.width - 20; // 10 margin on each side
    final double itemWidth = availableWidth / totalItems;
    // We want the center of the item. 
    // The elevated item is 50px wide, so we subtract 25 to center it on the item's center.
    return 10 + (itemWidth * selectedIndex) + (itemWidth / 2) - 25;
  }

  Widget _buildNavItem(int index) {
    final item = widget.items[index];

    return GestureDetector(
      onTap: () => widget.onItemSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            item.icon,
            color: Colors.grey.shade400,
            size: 24,
          ),
          const SizedBox(height: 4),
          AppText(
            item.label,
            fontSize: 8,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade400,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryColor,
                    Color(0xFFE94E4E), // Using a secondary color for gradient matching astrologer theme
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
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            AppText(
              item.label,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
