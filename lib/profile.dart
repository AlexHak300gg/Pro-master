import 'dart:io';
import 'dart:math' as math;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'widgets/bottom_nav.dart';
import 'ege_screen.dart';
import 'oge_screen.dart';
import 'admission_chances_screen.dart';
import 'merch_shop_screen.dart';
import 'settings/theme_settings_page.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  /* ---------- анимация ---------- */
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slideOffset;

  /* ---------- данные ---------- */
  final _db = FirebaseDatabase.instance.ref();
  final _picker = ImagePicker();
  File? _avatarFile;

  String name = '';
  String email = '';
  String phone = '';
  List<String> favColleges = [];
  List<String> favProfessions = [];

  int _bottomIndex = 4;

  /* ---------- stars ---------- */
  late final AnimationController _starCtrl;
  final List<Star> _stars = [];
  final _random = math.Random();

  @override
  void initState() {
    super.initState();

    /* fade & slide */
    _fadeCtrl = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic),
    );

    _slideCtrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideOffset = Tween<Offset>(
      begin: const Offset(0, .15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutBack));

    /* stars */
    _starCtrl = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _initStars();

    _loadData().then((_) {
      _fadeCtrl.forward();
      _slideCtrl.forward();
    });
  }

  void _initStars() {
    for (int i = 0; i < 150; i++) {
      _stars.add(Star(
        x: _random.nextDouble() * 1.5 - 0.5,
        y: _random.nextDouble() * 2 - 1,
        speed: 0.3 + _random.nextDouble() * 0.7,
        size: 2 + _random.nextDouble() * 4,
        delay: _random.nextDouble() * 3,
        brightness: 0.6 + _random.nextDouble() * 0.4,
      ));
    }
  }

  Future<void> _loadData() async {
    final userSnap = await _db.child('users/${widget.userId}').get();
    if (userSnap.exists && userSnap.value != null) {
      final map = Map<String, dynamic>.from(userSnap.value as Map);
      setState(() {
        name = map['name'] ?? 'Пользователь';
        email = map['email'] ?? 'email@example.com';
        phone = map['phone'] ?? '+7 XXX XXX XX XX';
      });
    }

    final colSnap = await _db.child('users/${widget.userId}/favoriteColleges').get();
    if (colSnap.exists && colSnap.value != null) {
      final map = Map<String, dynamic>.from(colSnap.value as Map);
      favColleges = map.keys.cast<String>().toList();
    }

    final profSnap = await _db.child('users/${widget.userId}/favoriteProfessions').get();
    if (profSnap.exists && profSnap.value != null) {
      final map = Map<String, dynamic>.from(profSnap.value as Map);
      favProfessions = map.keys.cast<String>().toList();
    }
  }

  Future<void> _pickAvatar() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (xFile == null) return;
    setState(() => _avatarFile = File(xFile.path));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Фото обновлено',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onBottomTap(int index) {
    if (index == _bottomIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/choice_tests',
            arguments: widget.userId);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/map_page',
            arguments: widget.userId);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/college_rating',
            arguments: widget.userId);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/professions',
            arguments: widget.userId);
        break;
      case 4:
        break;
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Выход', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        content: Text('Уверены, что хотите выйти?',
            style: GoogleFonts.nunito()),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text('Отмена', style: GoogleFonts.nunito()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, '/', (r) => false),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Выйти', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  /* ---------- stars background ---------- */
  Widget _buildStars() {
    return AnimatedBuilder(
      animation: _starCtrl,
      builder: (_, __) {
        return Stack(
          children: _stars.map((star) {
            final progress = (_starCtrl.value * star.speed + star.delay) % 2.0;
            final x = star.x + progress * 1.5;
            final y = star.y + progress * 1.5;
            final opacity = x > 0 && x < 1.5 && y > -0.5 && y < 1.5
                ? (1.0 - (progress / 2.0).abs()) * star.brightness
                : 0.0;
            final pulse =
                (math.sin(_starCtrl.value * 5 * math.pi + star.delay * 8) + 1) /
                    2;
            final currentOpacity = opacity * (0.8 + 0.2 * pulse);

            return Positioned(
              left: x * MediaQuery.of(context).size.width,
              top: y * MediaQuery.of(context).size.height,
              child: Opacity(
                opacity: currentOpacity.clamp(0.0, 1.0),
                child: Container(
                  width: star.size,
                  height: star.size,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.withOpacity(0.9),
                        blurRadius: star.size * 3,
                        spreadRadius: star.size * 0.8,
                      ),
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.6),
                        blurRadius: star.size * 6,
                        spreadRadius: star.size * 2,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.95),
                        blurRadius: 1,
                        spreadRadius: 0.5,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  /* ---------- build ---------- */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2D),
      body: Stack(
        children: [
          /* stars */
          _buildStars(),

          /* gradient overlay */
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0A0F2D).withOpacity(0.6),
                  const Color(0xFF1E3A8A).withOpacity(0.4),
                  const Color(0xFF0A0F2D).withOpacity(0.6),
                ],
              ),
            ),
          ),

          /* content */
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideOffset,
                child: ListView(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  children: [
                    /* header */
                    Text(
                      'Мой профиль',
                      style: GoogleFonts.nunito(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.yellow,
                        shadows: [
                          Shadow(
                            blurRadius: 15,
                            color: Colors.orange.withOpacity(0.7),
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Управление вашими данными',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    /* avatar + name */
                    _AvatarCard(
                      avatar: _avatarFile,
                      name: name,
                      userId: widget.userId,
                      onTap: _pickAvatar,
                    ),
                    const SizedBox(height: 20),

                    /* info */
                    _InfoRow(icon: Icons.email, title: 'Email', value: email),
                    _InfoRow(icon: Icons.phone, title: 'Телефон', value: phone),
                    const SizedBox(height: 20),

                    /* favourites */
                    _FavSection(title: 'Избранные колледжи', items: favColleges),
                    _FavSection(title: 'Избранные профессии', items: favProfessions),
                    const SizedBox(height: 24),

                    /* sections */
                    _SectionTitle('Подготовка к экзаменам'),
                    _FeatureBtn(
                      title: 'ЕГЭ',
                      subtitle: 'Подготовка к ЕГЭ',
                      icon: Icons.school,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EGEScreen(userId: widget.userId)),
                      ),
                    ),
                    _FeatureBtn(
                      title: 'ОГЭ',
                      subtitle: 'Подготовка к ОГЭ',
                      icon: Icons.school_outlined,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => OGEScreen(userId: widget.userId)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _SectionTitle('Карьерная ориентация'),
                    _FeatureBtn(
                      title: 'Шансы поступления',
                      subtitle: 'Рассчитайте свои шансы',
                      icon: Icons.trending_up,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AdmissionChancesScreen(userId: widget.userId)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _SectionTitle('Магазин'),
                    _FeatureBtn(
                      title: 'Магазин мерча',
                      subtitle: 'Купите мерч за баллы',
                      icon: Icons.shopping_bag,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MerchShopScreen(userId: widget.userId)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _SectionTitle('Настройки'),
                    Hero(
                      tag: 'theme_settings_hero',
                      child: _FeatureBtn(
                        title: 'Тема приложения',
                        subtitle: 'Выберите внешний вид',
                        icon: Icons.palette,
                        onTap: () => Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) =>
                                ThemeSettingsPage(userId: widget.userId),
                            transitionsBuilder: (_, anim, __, child) =>
                                FadeTransition(opacity: anim, child: child),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    /* logout */
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout, size: 20),
                        label: Text('Выйти из аккаунта',
                            style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _bottomIndex,
        onTap: _onBottomTap, userId: '',
      ),
    );
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _starCtrl.dispose();
    super.dispose();
  }
}

/* ============================ UI-WIDGETS ============================ */

class _AvatarCard extends StatelessWidget {
  final File? avatar;
  final String name;
  final String userId;
  final VoidCallback onTap;

  const _AvatarCard({
    required this.avatar,
    required this.name,
    required this.userId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.yellow,
                        Colors.orange,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeInBack,
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: avatar != null
                        ? ClipOval(
                      key: ValueKey(avatar),
                      child: Image.file(avatar!,
                          width: 120, height: 120, fit: BoxFit.cover),
                    )
                        : Icon(Icons.person,
                        key: const ValueKey('def'),
                        size: 60,
                        color: Colors.white.withOpacity(0.9)),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.camera_alt,
                        color: Colors.yellow.shade700, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(name,
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0A0F2D),
              )),
          Text('ID: $userId',
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.yellow.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.yellow.shade700, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  )),
              Text(value,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: const Color(0xFF0A0F2D),
                    fontWeight: FontWeight.w700,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(text,
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          )),
    );
  }
}

class _FavSection extends StatelessWidget {
  final String title;
  final List<String> items;

  const _FavSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.star, color: Colors.yellow.shade700, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0A0F2D),
                  )),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(items.length.toString(),
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.yellow.shade700,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Text('Пока ничего нет',
                style: GoogleFonts.nunito(
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ))
          else
            ...items.map((i) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.circle,
                      size: 6, color: Colors.yellow.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(i,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: const Color(0xFF0A0F2D),
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }
}

class _FeatureBtn extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _FeatureBtn({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.yellow.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.yellow.shade700, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: const Color(0xFF0A0F2D),
                        fontWeight: FontWeight.w700,
                      )),
                  Text(subtitle,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }
}

/* ---------- star model ---------- */
class Star {
  final double x;
  final double y;
  final double speed;
  final double size;
  final double delay;
  final double brightness;

  Star({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.delay,
    required this.brightness,
  });
}