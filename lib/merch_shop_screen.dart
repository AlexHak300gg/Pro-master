import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/themed_background.dart';
import 'theme/app_theme.dart';
import 'theme/theme_manager.dart';
import 'package:provider/provider.dart';

class MerchShopScreen extends StatefulWidget {
  final String userId;
  const MerchShopScreen({super.key, required this.userId});

  @override
  State<MerchShopScreen> createState() => _MerchShopScreenState();
}

class _MerchShopScreenState extends State<MerchShopScreen> {
  final _db = FirebaseDatabase.instance.ref();

  late List<Map<String, dynamic>> merchandise;
  Map<int, int> cartItems = {};

  @override
  void initState() {
    super.initState();
    _initializeMerchandise();
  }

  void _initializeMerchandise() {
    merchandise = [
      {
        'id': 0,
        'name': 'Футболка',
        'price': 500,
        'description': 'Стильная футболка с логотипом',
        'icon': Icons.shopping_bag,
      },
      {
        'id': 1,
        'name': 'Шорты',
        'price': 400,
        'description': 'Удобные спортивные шорты',
        'icon': Icons.shopping_bag,
      },
      {
        'id': 2,
        'name': 'Ручки',
        'price': 100,
        'description': 'Набор качественных ручек (5 шт)',
        'icon': Icons.edit,
      },
      {
        'id': 3,
        'name': 'Блокнот',
        'price': 200,
        'description': 'Красивый блокнот для заметок',
        'icon': Icons.note,
      },
    ];
  }

  void _addToCart(int id) {
    setState(() {
      cartItems[id] = (cartItems[id] ?? 0) + 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Добавлено в корзину',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  int _getTotalPrice() {
    int total = 0;
    cartItems.forEach((id, count) {
      final item = merchandise.firstWhere((m) => m['id'] == id);
      total += (item['price'] as int) * count;
    });
    return total;
  }

  Future<void> _checkout() async {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Корзина пуста',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final totalPrice = _getTotalPrice();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Оформление заказа',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0A0F2D),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Сумма: $totalPrice баллов',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0A0F2D),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Товары:',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              ...cartItems.entries.map((entry) {
                final item = merchandise.firstWhere((m) => m['id'] == entry.key);
                return Text(
                  '${item['name']} x${entry.value}',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: const Color(0xFF0A0F2D),
                  ),
                );
              }).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Отмена',
                style: GoogleFonts.nunito(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _db.child('users/${widget.userId}/purchases').push().set({
                    'timestamp': DateTime.now().toIso8601String(),
                    'total': totalPrice,
                    'items': cartItems,
                  });

                  if (mounted) {
                    Navigator.of(context).pop();
                    setState(() => cartItems.clear());
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Заказ оформлен успешно!',
                          style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Ошибка при оформлении заказа',
                          style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Купить',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = _getTotalPrice();

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
                          'Магазин мерча',
                          style: GoogleFonts.nunito(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Badge(
                        label: Text(
                          cartItems.values.fold(0, (sum, v) => sum + v).toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: const Color(0xFF6C63FF),
                        child: const Icon(Icons.shopping_cart, color: Colors.white),
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
                      childAspectRatio: 0.75,
                    ),
                    itemCount: merchandise.length,
                    itemBuilder: (context, index) {
                      final item = merchandise[index];
                      return Container(
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
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    item['icon'] as IconData,
                                    color: const Color(0xFF6C63FF),
                                    size: 48,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'] as String,
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0A0F2D),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['description'] as String,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.nunito(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${item['price']} баллов',
                                        style: GoogleFonts.nunito(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF6C63FF),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => _addToCart(item['id'] as int),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF6C63FF),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Итого:',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0A0F2D),
                    ),
                  ),
                  Text(
                    '$totalPrice баллов',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF6C63FF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _checkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Купить товары',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
