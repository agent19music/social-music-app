import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuxWarsButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final bool isLoading;
  final bool isMobile;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const AuxWarsButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
    this.textColor,
    this.icon,
    this.isLoading = false,
    this.isMobile = false,
    this.width,
    this.padding,
    this.borderRadius,
  });

  @override
  State<AuxWarsButton> createState() => _AuxWarsButtonState();
}

class _AuxWarsButtonState extends State<AuxWarsButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? const Color(0xFF1DB954);
    final textColor = widget.textColor ?? Colors.white;

    return GestureDetector(
      onTapDown: widget.onPressed != null && !widget.isLoading
          ? (_) => _onTapDown()
          : null,
      onTapUp: widget.onPressed != null && !widget.isLoading
          ? (_) => _onTapUp()
          : null,
      onTapCancel: widget.onPressed != null && !widget.isLoading
          ? () => _onTapCancel()
          : null,
      onTap: widget.onPressed != null && !widget.isLoading
          ? widget.onPressed
          : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              padding: widget.padding ??
                  EdgeInsets.symmetric(
                    horizontal: widget.isMobile ? 16 : 20,
                    vertical: widget.isMobile ? 12 : 16,
                  ),
              decoration: BoxDecoration(
                gradient: widget.isLoading
                    ? LinearGradient(
                        colors: [Colors.grey, Colors.grey.shade600],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color,
                          color.withOpacity(0.8),
                        ],
                      ),
                borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(widget.isLoading ? 0.1 : 0.3),
                    blurRadius: _isPressed ? 4 : 8,
                    spreadRadius: _isPressed ? 0 : 1,
                    offset:
                        _isPressed ? const Offset(0, 1) : const Offset(0, 2),
                  ),
                ],
              ),
              child: widget.isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: widget.isMobile ? 16 : 20,
                          height: widget.isMobile ? 16 : 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(textColor),
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          widget.text,
                          style: TextStyle(
                            color: textColor,
                            fontSize: widget.isMobile ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: textColor,
                            size: widget.isMobile ? 16 : 18,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          style: TextStyle(
                            color: textColor,
                            fontSize: widget.isMobile ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  void _onTapDown() {
    HapticFeedback.lightImpact();
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
  }

  void _onTapUp() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }
}

// Specialized button variants that match your aux wars design
class AuxWarsPill extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isSelected;
  final bool isMobile;

  const AuxWarsPill({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
    this.isSelected = false,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? const Color(0xFF1DB954);

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: primaryColor.withOpacity(isSelected ? 1.0 : 0.5),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : primaryColor,
            fontSize: isMobile ? 12 : 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class AuxWarsIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final bool isMobile;
  final double? size;
  final String? tooltip;

  const AuxWarsIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.isMobile = false,
    this.size,
    this.tooltip,
  });

  @override
  State<AuxWarsIconButton> createState() => _AuxWarsIconButtonState();
}

class _AuxWarsIconButtonState extends State<AuxWarsIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.backgroundColor ?? const Color(0xFF1DB954);
    final iconColor = widget.color ?? Colors.white;
    final size = widget.size ?? (widget.isMobile ? 40.0 : 48.0);

    Widget button = GestureDetector(
      onTapDown: widget.onPressed != null
          ? (_) {
              HapticFeedback.lightImpact();
              _animationController.forward();
            }
          : null,
      onTapUp: widget.onPressed != null
          ? (_) {
              _animationController.reverse();
            }
          : null,
      onTapCancel: widget.onPressed != null
          ? () {
              _animationController.reverse();
            }
          : null,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                color: iconColor,
                size: widget.isMobile ? 18 : 22,
              ),
            ),
          );
        },
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}
