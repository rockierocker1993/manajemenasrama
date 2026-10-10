import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class QuickAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final int notificationCount;

  const QuickAction({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.notificationCount = 0,
  });

  @override
  State<QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<QuickAction> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: 88,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: _isHovered
                          ? AppColors.primary.withOpacity(.2)
                          : AppColors.primary.withOpacity(.1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(widget.icon, color: AppColors.primary),
                  ),

                  if (widget.notificationCount > 0)
                    Positioned(
                      top: -6,
                      right: -6,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(
                          widget.notificationCount > 99
                              ? '99+'
                              : widget.notificationCount.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              Flexible(
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
