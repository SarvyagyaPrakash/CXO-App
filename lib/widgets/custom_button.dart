import 'package:flutter/material.dart';
import '../theme.dart';

enum ButtonType { filled, outline, text }

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final ButtonType type;
  final Widget? icon;
  final double? width;
  final double height;
  final bool isLoading;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.type = ButtonType.filled,
    this.icon,
    this.width,
    this.height = 52.0,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(key) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: _buildDecoration(),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: widget.isLoading ? null : widget.onTap,
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.backgroundDark),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.text,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: _buildTextColor(),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (widget.icon != null) ...[
                            const SizedBox(width: 8),
                            widget.icon!,
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    switch (widget.type) {
      case ButtonType.filled:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: AppColors.tealGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryTeal.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case ButtonType.outline:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryTeal, width: 1.5),
          color: Colors.transparent,
        );
      case ButtonType.text:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.accentBlueDark,
          border: Border.all(color: AppColors.cardBorder, width: 1.0),
        );
    }
  }

  Color _buildTextColor() {
    switch (widget.type) {
      case ButtonType.filled:
        return AppColors.backgroundDark;
      case ButtonType.outline:
        return AppColors.primaryTeal;
      case ButtonType.text:
        return AppColors.textPrimary;
    }
  }
}
