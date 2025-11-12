import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'registration.dart';
import 'login.dart';

class MainAnimationPage extends StatefulWidget {
  const MainAnimationPage({super.key});

  @override
  State<MainAnimationPage> createState() => _MainAnimationPageState();
}

class _MainAnimationPageState extends State<MainAnimationPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _rotationAnim = Tween<double>(begin: -0.25, end: 0.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFFF8A30),
      body: SafeArea(
        child: Stack(
          children: [
            // 🌟 Увеличенная звезда
            Positioned(
              top: -120,
              left: -60,
              child: Transform.rotate(
                angle: 20.23 * (math.pi / 180),
                child: SizedBox(
                  width: 480,  // увеличена ширина
                  height: 480, // увеличена высота
                  child: CustomPaint(
                    painter: _FullStarPainter(),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(color: Colors.transparent),
              ),
            ),

            // Основное содержимое
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: isSmall ? 20 : 60),
                  Text(
                    "ПрофГид\nСПО УР",
                    style: GoogleFonts.amaticSc(
                      fontSize: isSmall ? 70 : 80, // увеличенный шрифт
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),

                  // Уменьшенная белая плашка
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: FractionalTranslation(
                      translation: const Offset(-0.03, 0.0),
                      child: Container(
                        width: size.width * 0.75,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Привет! Я Настя — твой цифровой гид в мире профессий.\n"
                              "Вместе мы подберём специальность, которая подойдёт именно тебе!",
                          style: GoogleFonts.nunito(
                            fontSize: isSmall ? 12 : 13,
                            color: Colors.black87,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildButton(
                    text: "Войти",
                    backgroundColor: Colors.white,
                    textColor: const Color(0xFF6C63FF),
                    height: isSmall ? 42 : 48,
                    fontSize: isSmall ? 15 : 16,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildButton(
                    text: "Создать аккаунт",
                    backgroundColor: const Color(0xFF6C63FF),
                    textColor: Colors.white,
                    height: isSmall ? 42 : 48,
                    fontSize: isSmall ? 15 : 16,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const RegistrationPage()),
                      );
                    },
                  ),
                  SizedBox(height: isSmall ? 10 : 20),
                ],
              ),
            ),

            // Маскот
            Positioned(
              bottom: -size.height * 0.05,
              right: -size.width * 0.15,
              child: Transform.rotate(
                angle: -0.25,
                child: Image.asset(
                  'assets/g27.png',
                  height: size.height * 0.75,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // 🖐️ Рука, которая махает ладонью, с основанием у локтя героя
            // 🖐️ Рука, которая махает ладонью
            Positioned(
              bottom: size.height * 0.39, // чуть выше локтя
              right: size.width * 0.33,   // чуть левее, чтобы основание совпадало с локтем
              child: AnimatedBuilder(
                animation: _rotationAnim,
                builder: (_, child) {
                  return Transform.rotate(
                    angle: _rotationAnim.value,
                    alignment: Alignment.bottomRight, // вращение от локтя
                    child: child,
                  );
                },
                child: Image.asset(
                  'assets/g26.png',
                  height: size.height * 0.2,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
    double height = 48,
    double fontSize = 16,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _FullStarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerRadius = size.width * 0.45;
    final innerRadius = outerRadius * 0.4;

    for (int i = 0; i < 10; i++) {
      final angle = i * math.pi / 5 - math.pi / 2;
      final r = i.isEven ? outerRadius : innerRadius;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
