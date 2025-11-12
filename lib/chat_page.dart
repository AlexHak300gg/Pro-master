import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/bottom_nav.dart';

const String API_ENDPOINT =
    'https://api.intelligence.io.solutions/api/v1/chat/completions';
const String API_KEY =
    'io-v2-eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJvd25lciI6IjEzYTk1NjZlLWE5OWQtNDlmYy04YzJjLTE3MDFiYWY4YjYwMCIsImV4cCI6NDkxNDQyNzEzMH0.kgDeNQVg_p26eJBtdRb73gB1VFENY1y_oAH4mb0bfj3yQc_RCgpmQNi2mhWG7RHADkIfxewLUoU8Vv62Zx72YQ';
const String MODEL_ID = 'openai/gpt-oss-120b';

class CareerChatPage extends StatefulWidget {
  final String userId;

  const CareerChatPage({super.key, required this.userId});

  @override
  State<CareerChatPage> createState() => _CareerChatPageState();
}

class _CareerChatPageState extends State<CareerChatPage>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _loading = false;

  late final AnimationController _starCtrl;
  final List<_Star> _stars = [];
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _starCtrl = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _initStars();
    _loadChatHistory(); // 📥 загружаем сохранённые сообщения
  }

  void _initStars() {
    for (int i = 0; i < 120; i++) {
      _stars.add(_Star(
        x: _random.nextDouble() * 1.5 - 0.5,
        y: _random.nextDouble() * 2 - 1,
        speed: 0.3 + _random.nextDouble() * 0.7,
        size: 1.5 + _random.nextDouble() * 3,
        delay: _random.nextDouble() * 3,
        brightness: 0.6 + _random.nextDouble() * 0.4,
      ));
    }
  }

  String get _systemPrompt => '''
Ты — Настя ✨, умная, уверенная и доброжелательная ИИ-наставница.
Ты эксперт по профориентации, вузам и обучению в России.
Твои задачи:
— Помогать ученикам понять, какая профессия им подходит.
— Подсказывать, куда можно поступить, какие экзамены сдавать, как выбрать направление.
— Давать советы про учёбу, тайм-менеджмент, подготовку к экзаменам.
Не отвечай на вопросы вне темы образования и профориентации.
Стиль: доброжелательный, мотивирующий, уверенный. Можно немного вдохновения и метафор про звёзды, космос, путь к целям ✨
Отвечай коротко и понятно (1–3 предложения).
Пиши по-русски.
''';

  /// 🧩 Загрузка истории из SharedPreferences
  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'chat_history_${widget.userId}';
    final saved = prefs.getString(key);
    if (saved != null) {
      final data = jsonDecode(saved) as List;
      setState(() {
        _messages.clear();
        _messages.addAll(data.map((e) => _ChatMessage.fromJson(e)).toList());
      });
      _scrollToBottom();
    }
  }

  /// 💾 Сохранение чата
  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'chat_history_${widget.userId}';
    final data = jsonEncode(_messages.map((e) => e.toJson()).toList());
    await prefs.setString(key, data);
  }

  /// ❌ Очистка истории
  Future<void> _clearChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_history_${widget.userId}');
    setState(() => _messages.clear());
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(role: 'user', content: text));
      _loading = true;
      _controller.clear();
    });
    await _saveChatHistory();

    final payload = {
      "model": MODEL_ID,
      "messages": [
        {"role": "system", "content": _systemPrompt},
        ..._messages.map((m) => {"role": m.role, "content": m.content}),
      ],
      "max_tokens": 512,
      "temperature": 0.8,
    };

    try {
      final resp = await http.post(
        Uri.parse(API_ENDPOINT),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $API_KEY',
        },
        body: jsonEncode(payload),
      );

      String reply = 'Звёзды немного помолчали... 🌌';
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final first = (data['choices'] as List?)?.first;
        reply = first?['message']?['content'] ??
            first?['text'] ??
            reply;
      } else {
        reply = 'Ошибка связи с космосом (${resp.statusCode}) 🚀';
      }

      setState(() {
        _messages.add(_ChatMessage(role: 'assistant', content: reply));
      });
      await _saveChatHistory(); // 💾 сохраняем новый ответ
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(
          role: 'assistant',
          content: 'Потеряна связь с орбитой 🌌\n$e',
        ));
      });
      await _saveChatHistory();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Widget _buildStars() {
    return AnimatedBuilder(
      animation: _starCtrl,
      builder: (_, __) {
        return Stack(
          children: _stars.map((s) {
            final progress = (_starCtrl.value * s.speed + s.delay) % 2.0;
            final x = s.x + progress * 1.5;
            final y = s.y + progress * 1.5;
            final opacity = (1 - (progress / 2.0).abs()) * s.brightness;
            return Positioned(
              left: x * MediaQuery.of(context).size.width,
              top: y * MediaQuery.of(context).size.height,
              child: Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: Container(
                  width: s.size,
                  height: s.size,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.6),
                        blurRadius: s.size * 4,
                        spreadRadius: s.size * 1.2,
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

  Widget _buildBubble(_ChatMessage msg) {
    final isUser = msg.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color:
          isUser ? Colors.indigo.shade100 : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isUser ? 14 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 14),
          ),
        ),
        child: Text(
          msg.content,
          style: GoogleFonts.nunito(
            fontSize: 16,
            color: isUser ? Colors.indigo.shade900 : Colors.black87,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    if (index == 5) return;
    if (index == 4) {
      Navigator.pushNamed(context, '/profile', arguments: widget.userId);
    } else if (index == 0) {
      Navigator.pushNamed(context, '/tests', arguments: widget.userId);
    } else if (index == 1) {
      Navigator.pushNamed(context, '/universities', arguments: widget.userId);
    } else if (index == 3) {
      Navigator.pushNamed(context, '/professions', arguments: widget.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2D),
      appBar: AppBar(
        title: const Text('Настя ✨'),
        backgroundColor: const Color(0xFF0A0F2D),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.yellowAccent),
            tooltip: 'Очистить чат',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Очистить чат?'),
                  content: const Text('История будет удалена безвозвратно.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Отмена'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Удалить'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await _clearChatHistory();
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildStars(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (_, i) => _buildBubble(_messages[i]),
                  ),
                ),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child:
                    CircularProgressIndicator(color: Colors.yellowAccent),
                  ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Задай вопрос Насте...',
                            hintStyle:
                            const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _loading ? null : _sendMessage,
                        icon: const Icon(Icons.send_rounded,
                            color: Colors.yellowAccent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 5,
        onTap: _onNavTap,
        userId: widget.userId,
      ),
    );
  }

  @override
  void dispose() {
    _starCtrl.dispose();
    super.dispose();
  }
}

class _ChatMessage {
  final String role;
  final String content;

  _ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role, 'content': content};

  factory _ChatMessage.fromJson(Map<String, dynamic> json) =>
      _ChatMessage(role: json['role'], content: json['content']);
}

class _Star {
  final double x, y, speed, size, delay, brightness;
  _Star({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.delay,
    required this.brightness,
  });
}
