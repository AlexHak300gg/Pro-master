import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/bottom_nav.dart';
import 'theme/themed_background.dart';

class PlacesListPage extends StatefulWidget {
  final String userId;
  const PlacesListPage({super.key, required this.userId});

  @override
  State<PlacesListPage> createState() => _PlacesListPageState();
}

class _PlacesListPageState extends State<PlacesListPage> {
  final _db = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> places = [];
  bool _isLoading = true;
  final int _currentIndex = 1;
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  void _loadPlaces() async {
    final snapshot = await _db.child('places').get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final placesList = <Map<String, dynamic>>[];

      for (final placeId in data.keys) {
        final placeData = Map<String, dynamic>.from(data[placeId] as Map);
        placeData['id'] = placeId;
        placeData['averageRating'] = 5.0;
        placeData['reviewsCount'] = 0;

        placesList.add(placeData);
      }

      setState(() {
        places = placesList;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigate(int index) {
    final routes = [
      '/choice_tests',
      '/map_page',
      '/chat',
      '/professions',
      '/profile',
    ];
    if (index >= 0 && index < routes.length) {
      Navigator.pushReplacementNamed(context, routes[index], arguments: widget.userId);
    }
  }

  void _showPlaceDetails(Map<String, dynamic> place) {
    showGeneralDialog(
      context: context,
      barrierLabel: "Place Details",
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isDarkMode
                    ? [const Color(0xFF1E3A8A), const Color(0xFF0A0F2D)]
                    : [Colors.white, const Color(0xFFE3F2FD)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                // Заголовок
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.place,
                        color: Color(0xFF6C63FF),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        place['name'] as String,
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: _isDarkMode ? Colors.white70 : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),

                // Рейтинг — всегда 5 звёзд
                Row(
                  children: const [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 22),
                        Icon(Icons.star, color: Colors.amber, size: 22),
                        Icon(Icons.star, color: Colors.amber, size: 22),
                        Icon(Icons.star, color: Colors.amber, size: 22),
                        Icon(Icons.star, color: Colors.amber, size: 22),
                      ],
                    ),
                    SizedBox(width: 8),
                    Text(
                      '5.0 — Отличное место!',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Описание
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    place['description'] as String,
                    style: GoogleFonts.nunito(
                      color: _isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Крутой комментарий
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6C63FF).withValues(alpha: 0.15),
                        const Color(0xFF4A90E2).withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFF6C63FF), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getCoolComment(place['name'] as String),
                          style: GoogleFonts.nunito(
                            color: _isDarkMode ? Colors.white : const Color(0xFF0A0F2D),
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Кнопка ссылки
                if (place['url'] != null && place['url'].toString().isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _launchURL(place['url'] as String);
                    },
                    icon: const Icon(Icons.link, size: 18),
                    label: Text(
                      'Перейти по ссылке',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      transitionBuilder: (_, anim, __, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }

  void _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  String _getCoolComment(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('колледж') || lower.contains('техникум')) {
      final comments = [
        '🎓 Топовое учебное заведение с крутыми преподавателями!',
        '🚀 Здесь готовят настоящих профессионалов!',
        '⭐ Отличный старт карьеры — выпускники востребованы!',
        '💪 Качественное образование и практика с первого курса!',
        '🏆 Один из лучших колледжей в Удмуртии!',
      ];
      return comments[name.hashCode.abs() % comments.length];
    }
    if (lower.contains('проф')) {
      return '🔥 Перспективное место для старта карьеры!';
    }
    if (lower.contains('парк') || lower.contains('сквер')) {
      return '🌿 Отличное место для отдыха и вдохновения!';
    }
    if (lower.contains('музей') || lower.contains('культ')) {
      return '🎨 Кладезь знаний и культурного обогащения!';
    }
    final comments = [
      '✨ Рекомендовано абитуриентами — 5 из 5!',
      '💎 Настоящая жемчужина Удмуртии!',
      '🌟 Must visit для каждого студента!',
      '🎯 Идеальное место для развития навыков!',
      '👍 Проверено — тут действительно круто!',
    ];
    return comments[name.hashCode.abs() % comments.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? const Color(0xFF0A0F2D) : Colors.grey[100],
      body: Stack(
        children: [
          const ThemedBackground(),
          SafeArea(
            child: Column(
              children: [
                // Заголовок
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _isDarkMode ? Colors.white.withValues(alpha: 0.95) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF6C63FF)),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Интересные места",
                              style: GoogleFonts.nunito(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: _isDarkMode ? const Color(0xFF0A0F2D) : Colors.black,
                              ),
                            ),
                            Text(
                              "Удмуртская Республика",
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6C63FF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                
                // Список мест
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: const Color(0xFF6C63FF),
                          ),
                        )
                      : places.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.place_outlined,
                                    size: 64,
                                    color: _isDarkMode ? Colors.white30 : Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Пока нет добавленных мест',
                                    style: GoogleFonts.nunito(
                                      fontSize: 18,
                                      color: _isDarkMode ? Colors.white60 : Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Добавьте первое место на карте',
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      color: _isDarkMode ? Colors.white24 : Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: places.length,
                              itemBuilder: (context, index) {
                                final place = places[index];
                                return _buildPlaceCard(place);
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(currentIndex: _currentIndex, onTap: _navigate, userId: widget.userId),
    );
  }

  Widget _buildPlaceCard(Map<String, dynamic> place) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isDarkMode
              ? [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.05)]
              : [Colors.white, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showPlaceDetails(place),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.place,
                        color: Color(0xFF6C63FF),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place['name'] as String,
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            place['description'] as String,
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: _isDarkMode ? Colors.white70 : Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Icon(Icons.star, color: Colors.amber, size: 16),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '5.0',
                      style: GoogleFonts.nunito(
                        color: Colors.amber,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

