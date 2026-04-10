import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../theme/app_theme.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String userId;
  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, _) {
        final theme = themeManager.currentTheme;
        final isDark = theme == SeasonTheme.space || theme == SeasonTheme.profgid;
        final primaryColor = AppTheme.getPrimaryColor(theme);
        final surfaceColor = AppTheme.getSurfaceColor(theme);

        final bgColor = isDark ? const Color(0xFF0A0F2D) : surfaceColor;
        final borderColor = primaryColor.withValues(alpha: isDark ? 0.3 : 0.4);
        final activeIconColor = isDark ? Colors.yellow : primaryColor;
        final activeTextColor = isDark ? Colors.yellow : primaryColor;
        final inactiveColor = isDark ? Colors.white70 : Colors.black54;
        final activeBgColor = isDark
            ? Colors.blueAccent.withValues(alpha: 0.2)
            : primaryColor.withValues(alpha: 0.1);
        final activeBorderColor = isDark
            ? Colors.blueAccent.withValues(alpha: 0.5)
            : primaryColor.withValues(alpha: 0.6);

        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : primaryColor).withValues(alpha: isDark ? 0.5 : 0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
            border: Border(
              top: BorderSide(color: borderColor, width: 1.5),
            ),
          ),
          child: SafeArea(
            child: SizedBox(
              height: 72,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 4 навигационные кнопки
                  Row(
                    children: [
                      _NavItem(
                        icon: Icons.psychology_outlined,
                        label: "Тесты",
                        isActive: currentIndex == 0,
                        activeIconColor: activeIconColor,
                        activeTextColor: activeTextColor,
                        inactiveColor: inactiveColor,
                        activeBgColor: activeBgColor,
                        activeBorderColor: activeBorderColor,
                        onTap: () => onTap(0),
                      ),
                      _NavItem(
                        icon: Icons.school_outlined,
                        label: "Вузы",
                        isActive: currentIndex == 1,
                        activeIconColor: activeIconColor,
                        activeTextColor: activeTextColor,
                        inactiveColor: inactiveColor,
                        activeBgColor: activeBgColor,
                        activeBorderColor: activeBorderColor,
                        onTap: () => onTap(1),
                      ),
                      // Место для центральной кнопки
                      const Expanded(child: SizedBox.shrink()),
                      _NavItem(
                        icon: Icons.work_outline,
                        label: "Профессии",
                        isActive: currentIndex == 3,
                        activeIconColor: activeIconColor,
                        activeTextColor: activeTextColor,
                        inactiveColor: inactiveColor,
                        activeBgColor: activeBgColor,
                        activeBorderColor: activeBorderColor,
                        onTap: () => onTap(3),
                      ),
                      _NavItem(
                        icon: Icons.person_outline,
                        label: "Профиль",
                        isActive: currentIndex == 4,
                        activeIconColor: activeIconColor,
                        activeTextColor: activeTextColor,
                        inactiveColor: inactiveColor,
                        activeBgColor: activeBgColor,
                        activeBorderColor: activeBorderColor,
                        onTap: () => onTap(4),
                      ),
                    ],
                  ),
                  // Центральная кнопка чата
                  GestureDetector(
                    onTap: () => onTap(2),
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            primaryColor,
                            primaryColor.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline,
                        size: 26,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeIconColor;
  final Color activeTextColor;
  final Color inactiveColor;
  final Color activeBgColor;
  final Color activeBorderColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeIconColor,
    required this.activeTextColor,
    required this.inactiveColor,
    required this.activeBgColor,
    required this.activeBorderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? activeBgColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(color: activeBorderColor, width: 1)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: isActive ? activeIconColor : inactiveColor,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  fontSize: 9,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? activeTextColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
