import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme_manager.dart';
import '../theme/app_theme.dart';
import '../theme/themed_background.dart';

class ThemeSettingsPage extends StatefulWidget {
  final String userId;

  const ThemeSettingsPage({super.key, required this.userId});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = context.watch<ThemeManager>();
    final currentTheme = themeManager.currentTheme;
    final isDark = currentTheme == SeasonTheme.space || currentTheme == SeasonTheme.profgid;
    final primaryColor = AppTheme.getPrimaryColor(currentTheme);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const ThemedBackground(),
          Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.getBackgroundColor(currentTheme).withValues(alpha: 0.6),
                        primaryColor.withValues(alpha: 0.4),
                        AppTheme.getBackgroundColor(currentTheme).withValues(alpha: 0.6),
                      ],
                    )
                  : null,
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Настройки темы',
                          style: GoogleFonts.nunito(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Выберите оформление приложения',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Сетка тем
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: SeasonTheme.values.length,
                        itemBuilder: (context, index) {
                          final theme = SeasonTheme.values[index];
                          final isSelected = theme == currentTheme;
                          return _buildThemeCard(theme, isSelected, themeManager);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(SeasonTheme theme, bool isSelected, ThemeManager themeManager) {
    final primaryColor = AppTheme.getPrimaryColor(theme);

    // Единый стиль карточки: белый фон, цветная иконка
    return GestureDetector(
      onTap: () async {
        await themeManager.setTheme(theme);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(theme.icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Тема "${theme.displayName}" применена',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              backgroundColor: primaryColor,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey[200]!,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: primaryColor, width: 2)
                    : null,
              ),
              child: Icon(
                theme.icon,
                size: 32,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              theme.displayName,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? primaryColor : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              _getThemeSubtitle(theme),
              style: GoogleFonts.nunito(
                fontSize: 10,
                color: Colors.black45,
              ),
              textAlign: TextAlign.center,
            ),
            if (isSelected) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Активна',
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getThemeSubtitle(SeasonTheme theme) {
    switch (theme) {
      case SeasonTheme.summer:
        return 'Тёплые оранжевые тона';
      case SeasonTheme.autumn:
        return 'Уютные коричневые тона';
      case SeasonTheme.winter:
        return 'Холодные голубые тона';
      case SeasonTheme.spring:
        return 'Свежие зелёные тона';
      case SeasonTheme.profgid:
        return 'Тёмно-синий с клеткой';
      case SeasonTheme.space:
        return 'Космос со звёздами';
      case SeasonTheme.greeting:
        return 'Как на приветственном экране';
    }
  }
}
