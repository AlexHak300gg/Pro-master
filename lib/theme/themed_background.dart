import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import 'animated_background.dart';
import 'app_theme.dart';
import 'particle_painters.dart';

/// Простой фоновый виджет для встраивания в Stack любого экрана.
/// Заменяет дублирующиеся классы Star + _buildStarBackground().
///
/// Использование:
///   body: Stack(
///     children: [
///       const ThemedBackground(),  // <-- вместо кастомного звёздного фона
///       SafeArea(child: ...),      // <-- контент поверх
///     ],
///   )
class ThemedBackground extends StatelessWidget {
  final bool showGradientOverlay;

  const ThemedBackground({
    super.key,
    this.showGradientOverlay = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, _) {
        final theme = themeManager.currentTheme;

        // Для profgid — только белая клетка без оверлеев
        if (theme == SeasonTheme.profgid) {
          return Positioned.fill(
            child: CustomPaint(
              painter: GraphPaperPainter(),
            ),
          );
        }

        // Для всех остальных — AnimatedBackground без child
        return AnimatedBackground(
          theme: theme,
          child: const SizedBox.shrink(),
        );
      },
    );
  }
}

/// Обёртка для целых страниц. Использует ThemedBackground + Scaffold.
class ThemedScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;

  const ThemedScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: appBar,
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
          body: Stack(
            children: [
              const ThemedBackground(showGradientOverlay: false),
              SafeArea(child: body),
            ],
          ),
        );
      },
    );
  }
}
