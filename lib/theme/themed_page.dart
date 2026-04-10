import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../theme/app_theme.dart';
import 'animated_background.dart';

/// Универсальный wrapper для всех экранов (кроме карты).
/// Автоматически применяет текущую тему и её фон.
class ThemedPage extends StatelessWidget {
  final Widget child;
  final String? userId;
  final bool useAnimatedBackground;
  final Color? scaffoldBackgroundColor;

  const ThemedPage({
    super.key,
    required this.child,
    this.userId,
    this.useAnimatedBackground = true,
    this.scaffoldBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, _) {
        final theme = themeManager.currentTheme;

        Widget content;
        if (useAnimatedBackground) {
          content = AnimatedBackground(
            theme: theme,
            child: child,
          );
        } else {
          content = Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.getBackgroundColor(theme),
                  AppTheme.getBackgroundColor(theme).withValues(alpha: 0.8),
                  AppTheme.getSurfaceColor(theme).withValues(alpha: 0.6),
                ],
              ),
            ),
            child: child,
          );
        }

        return Scaffold(
          backgroundColor: scaffoldBackgroundColor ?? Colors.transparent,
          body: content,
        );
      },
    );
  }
}
