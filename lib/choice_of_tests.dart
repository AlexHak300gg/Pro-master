import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tests.dart';
import 'widgets/bottom_nav.dart';
import 'theme/themed_background.dart';
import 'theme/app_theme.dart';
import 'theme/theme_manager.dart';
import 'package:provider/provider.dart';

class ChoiceOfTestsPage extends StatefulWidget {
  final String userId;
  const ChoiceOfTestsPage({super.key, required this.userId});

  @override
  State<ChoiceOfTestsPage> createState() => _ChoiceOfTestsPageState();
}

class _ChoiceOfTestsPageState extends State<ChoiceOfTestsPage> {
  @override
  void initState() {
    super.initState();
  }

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/map_page', arguments: widget.userId);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/chat', arguments: widget.userId);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/professions', arguments: widget.userId);
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile', arguments: widget.userId);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tests = [
      {
        "title": "Дифференциально-диагностический опросник",
        "desc": "Помогает определить профессиональные склонности и интересы.",
        "icon": Icons.psychology_outlined,
        "color": Colors.blueAccent,
      },
      {
        "title": "Тест Голланда",
        "desc": "Определяет тип личности и подходящие профессии.",
        "icon": Icons.person_search_outlined,
        "color": Colors.green,
      },
      {
        "title": "Выбор профессии для подростков",
        "desc": "Для определения предпочтений и будущей карьеры.",
        "icon": Icons.emoji_people_outlined,
        "color": Colors.orange,
      },
      {
        "title": "Методика \"Профиль\"",
        "desc": "Выявляет сильные стороны личности и профессиональные направления.",
        "icon": Icons.insights_outlined,
        "color": Colors.purple,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2D),
      body: Stack(
        children: [
          const ThemedBackground(),

          // Градиентный оверлей
          if (context.watch<ThemeManager>().currentTheme != SeasonTheme.profgid && context.watch<ThemeManager>().currentTheme != SeasonTheme.greeting)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0A0F2D).withValues(alpha: 0.6),
                    const Color(0xFF1E3A8A).withValues(alpha: 0.4),
                    const Color(0xFF0A0F2D).withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Профориентационные",
                        style: GoogleFonts.nunito(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black.withValues(alpha: 0.5),
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "тесты",
                        style: GoogleFonts.nunito(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.yellow,
                          shadows: [
                            Shadow(
                              blurRadius: 15,
                              color: Colors.orange.withValues(alpha: 0.7),
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Выберите тест для определения вашего профессионального пути",
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Список тестов
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.builder(
                      itemCount: tests.length,
                      itemBuilder: (context, i) {
                        final t = tests[i];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Material(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white.withValues(alpha: 0.95),
                            elevation: 8,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TestPage(testName: t["title"] as String, userId: widget.userId),
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      t["color"] as Color,
                                      (t["color"] as Color).withValues(alpha: 0.8),
                                    ],
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        t["icon"] as IconData,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t["title"] as String, //
                                            style: GoogleFonts.nunito(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            t["title"] as String,
                                            style: GoogleFonts.nunito(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            color: Colors.white.withValues(alpha: 0.9),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.3),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 0,
        onTap: (index) => _navigate(context, index),
        userId: widget.userId,
      ),
    );
  }
}

