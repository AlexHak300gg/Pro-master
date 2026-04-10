import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'choice_of_tests.dart';
import 'registration.dart';
import 'theme/themed_background.dart';
import 'theme/app_theme.dart';
import 'theme/theme_manager.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final dbRef = FirebaseDatabase.instance.ref().child("users");
  final _login = TextEditingController();
  final _password = TextEditingController();
  bool remember = false;
  bool loading = false;
  String error = '';

  @override
  void initState() {
    super.initState();
    // Загружаем сохраненные данные
    _loadSavedCredentials();
  }

  // Загрузка сохраненных данных
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLogin = prefs.getString('savedLogin');
    final savedPassword = prefs.getString('savedPassword');
    final savedRemember = prefs.getBool('rememberMe') ?? false;

    if (savedRemember && savedLogin != null && savedPassword != null) {
      setState(() {
        _login.text = savedLogin;
        _password.text = savedPassword;
        remember = savedRemember;
      });
    }
  }

  // Сохранение данных
  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (remember) {
      await prefs.setString('savedLogin', _login.text);
      await prefs.setString('savedPassword', _password.text);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('savedLogin');
      await prefs.remove('savedPassword');
      await prefs.setBool('rememberMe', false);
    }
  }

  Future<void> _loginUser() async {
    setState(() {
      loading = true;
      error = '';
    });

    try {
      final snapshot = await dbRef.get();
      if (snapshot.exists) {
        final users = snapshot.value as Map;
        bool found = false;
        String? loggedUserId;

        users.forEach((key, value) {
          if ((value['login'] == _login.text ||
              value['email'] == _login.text ||
              value['phone'] == _login.text) &&
              value['password'] == _password.text) {
            found = true;
            loggedUserId = key;
          }
        });

        if (found && loggedUserId != null) {
          // Сохраняем данные если выбрано "Запомнить меня"
          await _saveCredentials();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => ChoiceOfTestsPage(userId: loggedUserId!)
            ),
          );
        } else {
          setState(() => error = "Неверный логин или пароль");
        }
      } else {
        setState(() => error = "Пользователь не найден");
      }
    } catch (e) {
      setState(() => error = "Ошибка подключения");
    }

    setState(() => loading = false);
  }

  @override
  void dispose() {
    _login.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2D),
      body: Stack(
        children: [
          // Фоновый виджет
          const ThemedBackground(),

          // Слабое градиентное затемнение чтобы текст был читаемым
          if (context.watch<ThemeManager>().currentTheme != SeasonTheme.profgid && context.watch<ThemeManager>().currentTheme != SeasonTheme.greeting)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0A0F2D).withValues(alpha: 0.4),
                    const Color(0xFF1E3A8A).withValues(alpha: 0.3),
                    const Color(0xFF0A0F2D).withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Заголовок
                  Center(
                    child: Text(
                      "Добро пожаловать",
                      style: GoogleFonts.nunito(
                        fontSize: 32,
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
                  ),

                  const SizedBox(height: 8),

                  Center(
                    child: Text(
                      "Войдите в свой аккаунт",
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            blurRadius: 5,
                            color: Colors.black.withValues(alpha: 0.5),
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Карточка с формой
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withValues(alpha: 0.4),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Поле логина
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _login,
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              labelText: "Логин, email или телефон",
                              labelStyle: GoogleFonts.nunito(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: Colors.blueAccent[400],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Поле пароля
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _password,
                            obscureText: true,
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              labelText: "Пароль",
                              labelStyle: GoogleFonts.nunito(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.blueAccent[400],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Запомнить меня
                        Row(
                          children: [
                            Transform.scale(
                              scale: 0.9,
                              child: Checkbox(
                                value: remember,
                                onChanged: (v) {
                                  setState(() {
                                    remember = v!;
                                  });
                                  if (!remember) {
                                    _clearSavedCredentials();
                                  }
                                },
                                activeColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                            Text(
                              "Запомнить меня",
                              style: GoogleFonts.nunito(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Функция восстановления пароля в разработке",
                                      style: GoogleFonts.nunito(),
                                    ),
                                    backgroundColor: Colors.blueAccent,
                                  ),
                                );
                              },
                              child: Text(
                                "",
                                style: GoogleFonts.nunito(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Сообщение об ошибке
                        if (error.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red[400], size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    error,
                                    style: GoogleFonts.nunito(
                                      color: Colors.red[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Кнопка входа
                        Container(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C63FF),
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              shadowColor: const Color(0xFF6C63FF).withValues(alpha: 0.5),
                            ),
                            onPressed: loading ? null : _loginUser,
                            child: loading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : Text(
                              "Войти",
                              style: GoogleFonts.nunito(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Разделитель
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: Colors.grey[300]),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                "или",
                                style: GoogleFonts.nunito(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: Colors.grey[300]),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Кнопка регистрации
                        Container(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF6C63FF),
                              side: const BorderSide(color: Color(0xFF6C63FF), width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.white,
                              elevation: 2,
                            ),
                            onPressed: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const RegistrationPage()),
                            ),
                            child: Text(
                              "Создать аккаунт",
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Очистка сохраненных данных
  Future<void> _clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('savedLogin');
    await prefs.remove('savedPassword');
  }
}