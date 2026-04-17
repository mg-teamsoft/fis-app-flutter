import 'dart:ui' as ui;

import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:flutter/material.dart';

class CardButton extends StatelessWidget {
  const CardButton({
    required this.title,
    required this.description,
    required this.imageIcon,
    required this.buttonIcon,
    required this.onPressed,
    super.key,
    this.textColor,
    this.backgroundColor,
  });
  final String title;
  final String description;
  final Widget imageIcon;
  final IconData buttonIcon;
  final VoidCallback onPressed;
  final Color? textColor;
  final List<Color>? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: ThemeRadius.circular24,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          minHeight: ThemeSize.avatarXXL,
          maxHeight: ThemeSize.avatarXXL,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: const Alignment(0.8, 0.8),
            colors: backgroundColor ??
                [
                  context.colorScheme.primary,
                  context.colorScheme.primaryContainer,
                ],
          ),
          borderRadius: ThemeRadius.circular24,
          boxShadow: [
            BoxShadow(
              color: (textColor ?? context.colorScheme.onSurface)
                  .withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              top: 10,
              right: 10,
              child: Opacity(
                opacity: 0.2,
                child: imageIcon,
              ),
            ),
            Padding(
              padding: const ThemePadding.all32(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: Container(
                        padding: const ThemePadding.all10(),
                        color: (textColor ?? context.colorScheme.onSurface)
                            .withValues(alpha: 0.2),
                        child: Icon(
                          buttonIcon,
                          color: textColor ?? context.colorScheme.onSurface,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor ?? context.colorScheme.onSurface,
                          letterSpacing: -0.48,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: (textColor ?? context.colorScheme.onSurface)
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
