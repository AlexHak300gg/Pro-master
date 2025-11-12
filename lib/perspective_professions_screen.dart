import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'games/foundry_game.dart';
import 'games/qc_game.dart';
import 'games/stamper_game.dart';

class PerspectiveProfessionsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> perspectiveProfessions;
  final String userId;

  const PerspectiveProfessionsScreen({
    super.key,
    required this.perspectiveProfessions,
    required this.userId,
  });

  @override
  State<PerspectiveProfessionsScreen> createState() => _PerspectiveProfessionsScreenState();
}

class _PerspectiveProfessionsScreenState extends State<PerspectiveProfessionsScreen> {
  int _parseMaxSalary(String salary) {
    final matches = RegExp(r'(\d+)').allMatches(salary).toList();
    return matches.length > 1 ? int.parse(matches[1].group(1)!) : 0;
  }

  void _handlePlay(String name) {
    Widget? gameScreen;

    switch (name) {
      case 'Литейщик':
        gameScreen = FoundryGame(userId: widget.userId);
        break;
      case 'Технический контролер':
        gameScreen = QCGame(userId: widget.userId);
        break;
      case 'Штамповщик':
        gameScreen = StamperGame(userId: widget.userId);
        break;
      default:
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Игра для "$name" пока не доступна'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => gameScreen!),
    );
  }

  Widget _buildPlayButton(String name, {bool compact = false}) {
    final onTap = () => _handlePlay(name);
    if (compact) {
      return IconButton(
        onPressed: onTap,
        icon: const Icon(Icons.play_arrow_rounded),
        color: const Color(0xFF6C63FF),
        splashRadius: 22,
        tooltip: 'Играть',
      );
    }
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: const Icon(Icons.play_arrow_rounded),
      label: const Text('Играть'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedProfessions = List<Map<String, dynamic>>.from(widget.perspectiveProfessions);
    sortedProfessions.sort((a, b) {
      final maxA = _parseMaxSalary(a['salary']);
      final maxB = _parseMaxSalary(b['salary']);
      return maxB.compareTo(maxA);
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2D),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0A0F2D),
              const Color(0xFF1E3A8A).withOpacity(0.3),
              const Color(0xFF0A0F2D),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Заголовок
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Material(
                          color: const Color(0xFF6C63FF).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => Navigator.of(context).pop(),
                            child: const SizedBox(
                              height: 44,
                              width: 44,
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Color(0xFF0A0F2D),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Самые перспективные профессии",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0A0F2D),
                            ),
                          ),
                        ),
                        const SizedBox(width: 44),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Высокий спрос и хорошая зарплата в Удмуртии",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6C63FF),
                      ),
                    ),
                  ],
                ),
              ),

              // Места обучения - растянуто до конца
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Где учиться в Удмуртии",
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0A0F2D),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: sortedProfessions.map((profession) {
                              return _buildEducationInfo(profession);
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEducationInfo(Map<String, dynamic> profession) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6C63FF).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.school,
                color: const Color(0xFF6C63FF),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  profession['name'],
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0A0F2D),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            "Учебные заведения:",
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6C63FF),
            ),
          ),

          const SizedBox(height: 8),

          for (var college in profession['colleges'] as List)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.grey[600],
                    size: 12,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      college,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF0A0F2D),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          Row(
            children: [
              Icon(
                Icons.attach_money,
                color: Colors.green,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                "Зарплата: ${profession['salary']}",
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Кнопка "Играть" для всех профессий
          Align(
            alignment: Alignment.centerRight,
            child: _buildPlayButton(profession['name']),
          ),
        ],
      ),
    );
  }
}