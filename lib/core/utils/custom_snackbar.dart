import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

class CustomSnackBar {
  static OverlayEntry? _currentOverlay;

  static void _show({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Color? textColor,
  }) {
    final context = Get.overlayContext ?? Get.context;
    // Try to find the overlay state using the global navigator key
    final overlay = Get.key.currentState?.overlay ?? (context != null ? Overlay.of(context) : null);
    
    if (overlay == null) {
      debugPrint('CustomSnackBar: Overlay not found via Get.key or context');
      return;
    }

    final Color effectiveTextColor =
        textColor ??
        (backgroundColor.computeLuminance() > 0.5
            ? Colors.black
            : Colors.white);

    // Remove old overlay if any
    _currentOverlay?.remove();
    _currentOverlay = null;
    
    _currentOverlay = OverlayEntry(
      builder: (context) => _SnackbarWidget(
        title: title,
        message: message,
        backgroundColor: backgroundColor,
        icon: icon,
        textColor: effectiveTextColor,
        onDismiss: () {
          _currentOverlay?.remove();
          _currentOverlay = null;
        },
      ),
    );

    overlay.insert(_currentOverlay!);

    // Auto-remove after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (_currentOverlay != null) {
        _currentOverlay?.remove();
        _currentOverlay = null;
      }
    });
  }

  static void showSuccess(String message, {String title = 'Success'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.successColor,
      icon: Icons.check_circle_rounded,
    );
  }

  static void showError(String message, {String title = 'Error'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.errorColor,
      icon: Icons.error_rounded,
    );
  }

  static void showInfo(String message, {String title = 'Info'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.infoColor,
      icon: Icons.info_rounded,
    );
  }

  static void showWarning(String message, {String title = 'Warning'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.warningColor,
      icon: Icons.warning_rounded,
    );
  }
}

class _SnackbarWidget extends StatefulWidget {
  final String title;
  final String message;
  final Color backgroundColor;
  final IconData icon;
  final Color textColor;
  final VoidCallback onDismiss;

  const _SnackbarWidget({
    required this.title,
    required this.message,
    required this.backgroundColor,
    required this.icon,
    required this.textColor,
    required this.onDismiss,
  });

  @override
  State<_SnackbarWidget> createState() => _SnackbarWidgetState();
}

class _SnackbarWidgetState extends State<_SnackbarWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Start dismissal animation after 3.5 seconds
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _offsetAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: () {
                _controller.reverse().then((_) => widget.onDismiss());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(widget.icon, color: widget.textColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title.toUpperCase(),
                            style: TextStyle(
                              color: widget.textColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.message,
                            style: TextStyle(
                              color: widget.textColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: widget.textColor, size: 18),
                      onPressed: () {
                        _controller.reverse().then((_) => widget.onDismiss());
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
