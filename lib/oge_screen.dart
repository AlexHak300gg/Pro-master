import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'theme/themed_background.dart';
import 'theme/app_theme.dart';
import 'theme/theme_manager.dart';
import 'package:provider/provider.dart';

class OGEScreen extends StatefulWidget {
  final String userId;
  const OGEScreen({super.key, required this.userId});

  @override
  State<OGEScreen> createState() => _OGEScreenState();
}

class _OGEScreenState extends State<OGEScreen> {
  final List<Map<String, String>> ogeSubjects = [
    {'name': 'Русский язык', 'url': 'https://oge.sdamgia.ru/'},
    {'name': 'Математика', 'url': 'https://oge.sdamgia.ru/'},
    {'name': 'Физика', 'url': 'https://oge.sdamgia.ru/'},
    {'name': 'Химия', 'url': 'https://oge.sdamgia.ru/'},
    {'name': 'Биология', 'url': 'https://oge.sdamgia.ru/'},
    {'name': 'История', 'url': 'https://oge.sdamgia.ru/'},
    {'name': 'Обществознание', 'url': 'https://oge.sdamgia.ru/'},
    {'name': 'Литература', 'url': 'https://oge.sdamgia.ru/'},
    {'name': 'География', 'url': 'https://oge.sdamgia.ru/'},
    {'name': 'Информатика', 'url': 'https://oge.sdamgia.ru/'},
    {'name': 'Английский язык', 'url': 'https://oge.sdamgia.ru/'},
    {'name': 'Немецкий язык', 'url': 'https://oge.sdamgia.ru/'},
  ];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2D),
      body: Stack(
        children: [
          const ThemedBackground(),
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
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      Expanded(
                        child: Text(
                          'Предметы ОГЭ',
                          style: GoogleFonts.nunito(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: ogeSubjects.length,
                    itemBuilder: (context, index) {
                      final subject = ogeSubjects[index];
                      return GestureDetector(
                        onTap: () => _launchUrl(subject['url']!),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.school,
                                  color: const Color(0xFF6C63FF),
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                subject['name']!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0A0F2D),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Решу ОГЭ',
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF6C63FF),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

