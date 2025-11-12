import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math' as math;

// Модель данных
@immutable
class FoundryLevel {
  final String task;
  final int correctMold;
  final List<String> molds;
  final List<IconData> icons;

  const FoundryLevel({
    required this.task,
    required this.correctMold,
    required this.molds,
    required this.icons,
  });
}

// Константы
class _AppColors {
  static const primary = Color(0xFF6C63FF);
  static const background = Color(0xFF0A0F2D);
  static const surface = Colors.white;
  static const metalGradient = [Color(0xFFFF6B35), Color(0xFFD32F2F)];
}

// Менеджер состояния
class _GameState extends ChangeNotifier {
  final String userId;
  final DatabaseReference _db;

  _GameState(this.userId) : _db = FirebaseDatabase.instance.ref() {
    _initFirebase();
  }

  static const _levels = [
    FoundryLevel(
      task: 'Выберите форму для отливки шестерни с зубьями',
      correctMold: 0,
      molds: ['Зубчатая', 'Круглая', 'Квадратная'],
      icons: [Icons.settings, Icons.circle_outlined, Icons.crop_square],
    ),
    FoundryLevel(
      task: 'Выберите форму для отливки круглого колеса',
      correctMold: 1,
      molds: ['Треугольная', 'Круглая', 'Звездочка'],
      icons: [Icons.change_history, Icons.circle, Icons.star_border],
    ),
    FoundryLevel(
      task: 'Выберите форму для отливки болта',
      correctMold: 2,
      molds: ['Звезда', 'Круг', 'Шестигранник'],
      icons: [Icons.star, Icons.circle, Icons.hexagon_outlined],
    ),
  ];

  int _currentLevel = 0;
  int _currentStep = 0; // 0=выбор, 1=заливка, 2=результат
  int _completed = 0;
  int? _selectedMold;
  double _fill = 0.0;
  bool _isPouring = false;
  bool _isSaving = false;

  // Публичные геттеры
  FoundryLevel get level => _levels[_currentLevel];
  int? get selectedMold => _selectedMold;
  double get fill => _fill;
  bool get isPouring => _isPouring;
  bool get canProceed => _selectedMold != null && !_isSaving;
  int get completedLevels => _completed;
  int get totalLevels => _levels.length;
  bool get isComplete => _currentLevel >= _levels.length;
  int get currentStep => _currentStep;

  // Actions
  void selectMold(int index) {
    _selectedMold = index;
    notifyListeners();
  }

  void updateFill(double value) {
    _fill = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  void setPouring(bool value) {
    _isPouring = value;
    notifyListeners();
  }

  void proceedToPouring() {
    _currentStep = 1; // ✅ ПЕРЕХОД К ЭКРАНУ ЗАЛИВКИ
    notifyListeners();
  }

  void completeLevel() {
    _completed++;
    _currentStep = 0;

    if (_currentLevel < _levels.length - 1) {
      _currentLevel++;
      _resetLevel();
    } else {
      _currentStep = 2; // ✅ ФИНАЛЬНЫЙ ЭКРАН
      notifyListeners();
    }
  }

  void _resetLevel() {
    _selectedMold = null;
    _fill = 0.0;
    _isPouring = false;
    notifyListeners();
  }

  void _initFirebase() {
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    FirebaseDatabase.instance.setPersistenceCacheSizeBytes(1000000);
  }

  Future<void> saveResult() async {
    if (_isSaving) return;

    _isSaving = true;
    notifyListeners();

    try {
      await _db.child('users/$userId/games/foundry').push().set({
        'completedLevels': _completed,
        'totalLevels': _levels.length,
        'timestamp': ServerValue.timestamp,
      });
    } catch (e) {
      debugPrint('Firebase error: $e');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}

// Главный экран
class FoundryGame extends StatefulWidget {
  final String userId;

  const FoundryGame({super.key, required this.userId});

  @override
  State<FoundryGame> createState() => _FoundryGameState();
}

class _FoundryGameState extends State<FoundryGame> with TickerProviderStateMixin {
  late final _GameState _state;
  late final AnimationController _pourCtrl;
  late final AnimationController _resultCtrl;

  @override
  void initState() {
    super.initState();
    _state = _GameState(widget.userId);
    _pourCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _resultCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
  }

  @override
  void dispose() {
    _state.dispose();
    _pourCtrl.dispose();
    _resultCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: _AppColors.background,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _AppColors.background,
                  _AppColors.primary.withOpacity(0.2),
                  _AppColors.background,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _Header(state: _state, onBack: () => Navigator.pop(context)),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildScreen(),
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

  Widget _buildScreen() {
    if (_state.currentStep == 2) {
      return _ResultScreen(
        controller: _resultCtrl,
        completed: _state.completedLevels,
        total: _state.totalLevels,
        onFinish: () => Navigator.pop(context),
        onSave: _state.saveResult,
      );
    }

    if (_state.currentStep == 1) {
      return _PouringScreen(
        state: _state,
        pourController: _pourCtrl,
      );
    }

    return _MoldSelectionScreen(state: _state);
  }
}

// Виджеты экранов
class _Header extends StatelessWidget {
  final _GameState state;
  final VoidCallback onBack;

  const _Header({required this.state, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _IconButton(icon: Icons.arrow_back, onTap: onBack),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Игра: Литейщик',
                  style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Уровень ${state._currentLevel + 1}/${state.totalLevels}',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: _AppColors.primary,
                    fontWeight: FontWeight.w600,
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

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _AppColors.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: const SizedBox(
          height: 40,
          width: 40,
          child: Icon(Icons.arrow_back, color: _AppColors.background),
        ),
      ),
    );
  }
}

class _MoldSelectionScreen extends StatelessWidget {
  final _GameState state;

  const _MoldSelectionScreen({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TaskCard(task: state.level.task),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: 3,
            itemBuilder: (context, index) => _MoldCard(
              index: index,
              state: state,
              label: state.level.molds[index],
              icon: state.level.icons[index],
            ),
          ),
        ),
        _ActionButton(
          label: 'Далее',
          enabled: state.canProceed,
          onTap: () => _validateAndProceed(context),
        ),
      ],
    );
  }

  void _validateAndProceed(BuildContext context) {
    if (state.selectedMold == state.level.correctMold) {
      state.proceedToPouring();
    } else {
      _showError(context);
    }
  }

  void _showError(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Text('Неверно!', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('Попробуйте выбрать другую форму.', style: GoogleFonts.nunito()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              backgroundColor: _AppColors.primary,
              foregroundColor: _AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Ок'),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final String task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        task,
        textAlign: TextAlign.center,
        style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _MoldCard extends StatelessWidget {
  final int index;
  final _GameState state;
  final String label;
  final IconData icon;

  const _MoldCard({
    required this.index,
    required this.state,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final selected = state.selectedMold == index;
    return GestureDetector(
      onTap: () => state.selectMold(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: selected ? _AppColors.primary : _AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: selected ? _AppColors.primary.withOpacity(0.4) : Colors.black12,
              blurRadius: selected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: selected ? _AppColors.surface : _AppColors.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? _AppColors.surface : _AppColors.background,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PouringScreen extends StatefulWidget {
  final _GameState state;
  final AnimationController pourController;

  const _PouringScreen({required this.state, required this.pourController});

  @override
  State<_PouringScreen> createState() => _PouringScreenState();
}

class _PouringScreenState extends State<_PouringScreen> {
  Offset _ladlePos = const Offset(60, 60);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _TaskCard(task: 'Заполните форму расплавленным металлом'),
        const SizedBox(height: 16),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onPanUpdate: (d) => setState(() {
                  _ladlePos = Offset(
                    (_ladlePos.dx + d.delta.dx).clamp(0, constraints.maxWidth - 80),
                    (_ladlePos.dy + d.delta.dy).clamp(0, constraints.maxHeight - 100),
                  );
                }),
                child: Stack(
                  children: [
                    Center(
                      child: _MoldContainer(
                        fill: widget.state.fill,
                        icon: widget.state.level.icons[widget.state.selectedMold ?? 0], // ✅ ПЕРЕДАЁМ ВЫБРАННУЮ ФОРМУ
                      ),
                    ),
                    _Ladle(
                      position: _ladlePos,
                      isPouring: widget.state.isPouring,
                      onPour: (pouring) {
                        widget.state.setPouring(pouring);
                        if (pouring) {
                          widget.pourController.forward();
                        } else {
                          widget.pourController.stop();
                        }
                      },
                      onFill: (v) => widget.state.updateFill(v),
                      controller: widget.pourController,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        _FillIndicator(fill: widget.state.fill),
        _ActionButton(
          label: 'Готово',
          enabled: widget.state.fill >= 0.95,
          onTap: _completeLevel,
        ),
      ],
    );
  }

  void _completeLevel() {
    widget.pourController.reset();
    widget.state.completeLevel(); // ✅ ИСПРАВЛЕННЫЙ ВЫЗОВ
  }
}

class _MoldContainer extends StatelessWidget {
  final double fill;
  final IconData icon; // ✅ ПАРАМЕТР ДЛЯ ФОРМЫ

  const _MoldContainer({
    required this.fill,
    required this.icon, // ✅ ОБЯЗАТЕЛЬНЫЙ ПАРАМЕТР
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AppColors.surface, width: 2),
      ),
      child: Stack(
        alignment: Alignment.center, // Центрируем иконку
        children: [
          // Фон с металлом
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 180,
              height: 220 * fill,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _AppColors.metalGradient,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
            ),
          ),
          // Иконка формы поверх
          Icon(
            icon,
            size: 80,
            color: Colors.white.withOpacity(0.8),
          ),
        ],
      ),
    );
  }
}

class _Ladle extends StatelessWidget {
  final Offset position;
  final bool isPouring;
  final ValueChanged<bool> onPour;
  final ValueChanged<double> onFill;
  final AnimationController controller;

  const _Ladle({
    required this.position,
    required this.isPouring,
    required this.onPour,
    required this.onFill,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTapDown: (_) => onPour(true),
        onTapUp: (_) => onPour(false),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
                border: Border.all(color: Colors.grey[700]!, width: 2),
              ),
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: _AppColors.metalGradient),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(22),
                    bottomRight: Radius.circular(22),
                  ),
                ),
              ),
            ),
            if (isPouring) _MetalStream(controller: controller, onFill: onFill),
          ],
        ),
      ),
    );
  }
}

class _MetalStream extends AnimatedWidget {
  final ValueChanged<double> onFill;

  const _MetalStream({
    required AnimationController controller,
    required this.onFill,
  }) : super(listenable: controller);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    onFill(animation.value);

    return CustomPaint(
      size: const Size(8, 32),
      painter: _StreamPainter(progress: animation.value),
    );
  }
}

class _StreamPainter extends CustomPainter {
  final double progress;

  _StreamPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(colors: _AppColors.metalGradient)
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height * progress),
      paint,
    );
  }

  @override
  bool shouldRepaint(_StreamPainter oldDelegate) => oldDelegate.progress != progress;
}

class _FillIndicator extends StatelessWidget {
  final double fill;

  const _FillIndicator({required this.fill});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Заполнено: ${(fill * 100).toStringAsFixed(0)}%',
            style: GoogleFonts.nunito(fontSize: 16, color: _AppColors.surface),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _AppColors.primary,
          disabledBackgroundColor: Colors.grey[600],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _ResultScreen extends StatelessWidget {
  final AnimationController controller;
  final int completed;
  final int total;
  final VoidCallback onFinish;
  final VoidCallback onSave;

  const _ResultScreen({
    required this.controller,
    required this.completed,
    required this.total,
    required this.onFinish,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    controller.forward();
    return Center(
      child: ScaleTransition(
        scale: CurvedAnimation(parent: controller, curve: Curves.elasticOut),
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: _AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _AppColors.primary.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 80, color: _AppColors.primary),
              const SizedBox(height: 16),
              Text('Отлично!', style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Вы завершили все уровни!',
                style: GoogleFonts.nunito(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Отлито уровней: $completed/$total',
                style: GoogleFonts.nunito(fontSize: 14, color: _AppColors.primary),
              ),
              const SizedBox(height: 24),
              _ActionButton(
                label: 'Завершить',
                enabled: true,
                onTap: () {
                  onSave();
                  onFinish();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}