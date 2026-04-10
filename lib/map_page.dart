import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'widgets/bottom_nav.dart';
import 'places_list_page.dart';
import 'dart:math';

class MapPage extends StatefulWidget {
  final String userId;
  const MapPage({super.key, required this.userId});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  int _currentIndex = 1;
  final MapController _mapController = MapController();
  late AnimationController _starController;
  final List<Star> _stars = [];
  final Random _random = Random();
  final _db = FirebaseDatabase.instance.ref();
  bool _isAddingPlace = false;
  bool _showUserPlaces = true;
  List<Map<String, dynamic>> userPlaces = [];

  final Map<String, Color> _typeColors = {
    "БПОУ УР": Colors.blueAccent,
    "АПОУ УР": Colors.green,
  };

  final List<Map<String, dynamic>> colleges = [
    {
      "name": "Сарапульский многопрофильный колледж",
      "lat": 56.441349,
      "lng": 53.737112,
      "url": "https://ciur.ru/sit/default.aspx",
      "city": "Сарапул",
      "type": "БПОУ УР"
    },
    {
      "name": "Ижевский торгово-экономический техникум",
      "lat": 56.858258,
      "lng": 53.244261,
      "url": "https://ciur.ru/itet/default.aspx",
      "city": "Ижевск",
      "type": "БПОУ УР"
    },
    {
      "name": "Глазовский аграрно-промышленный техникум",
      "lat": 58.139167,
      "lng": 52.658425,
      "url": "https://ciur.ru/gapt/default.aspx",
      "city": "Глазов",
      "type": "АПОУ УР"
    },
    {
      "name": "Сарапульский политехнический колледж",
      "lat": 56.474861,
      "lng": 53.798667,
      "url": "https://ciur.ru/sptk/default.aspx",
      "city": "Сарапул",
      "type": "БПОУ УР"
    },
    {
      "name": "Ижевский промышленно-экономический колледж",
      "lat": 56.864444,
      "lng": 53.273056,
      "url": "https://ciur.ru/ipek/default.aspx",
      "city": "Ижевск",
      "type": "АПОУ УР"
    },
    {
      "name": "Строительный техникум",
      "lat": 56.839722,
      "lng": 53.258333,
      "url": "https://ciur.ru/st/default.aspx",
      "city": "Ижевск",
      "type": "АПОУ УР"
    },
    {
      "name": "Глазовский технический колледж",
      "lat": 58.131944,
      "lng": 52.667500,
      "url": "https://ciur.ru/gtk/default.aspx",
      "city": "Глазов",
      "type": "БПОУ УР"
    },
    {
      "name": "Воткинский машиностроительный техникум имени В.Г. Садовникова",
      "lat": 57.059444,
      "lng": 53.987222,
      "url": "https://ciur.ru/vmt/default.aspx",
      "city": "Воткинск",
      "type": "БПОУ УР"
    },
    {
      "name": "Игринский политехнический техникум",
      "lat": 57.554444,
      "lng": 53.054444,
      "url": "https://ciur.ru/ipt/default.aspx",
      "city": "Игра",
      "type": "БПОУ УР"
    },
    {
      "name": "Ижевский техникум индустрии питания",
      "lat": 56.878056,
      "lng": 53.265278,
      "url": "https://ciur.ru/itip/default.aspx",
      "city": "Ижевск",
      "type": "БПОУ УР"
    },
    {
      "name": "Можгинский агропромышленный колледж имени Г.Г. Оревкова",
      "lat": 56.444722,
      "lng": 52.227778,
      "url": "https://ciur.ru/mapk/default.aspx",
      "city": "Можга",
      "type": "БПОУ УР"
    },
    {
      "name": "Можгинский педагогический колледж имени Т.К. Борисова",
      "lat": 56.448611,
      "lng": 52.234722,
      "url": "https://ciur.ru/mpk/default.aspx",
      "city": "Можга",
      "type": "БПОУ УР"
    },
    {
      "name": "Ижевский монтажный техникум",
      "lat": 56.847500,
      "lng": 53.270278,
      "url": "https://ciur.ru/imt/default.aspx",
      "city": "Ижевск",
      "type": "БПОУ УР"
    },
    {
      "name": "Дебёсский политехникум",
      "lat": 57.651111,
      "lng": 53.808333,
      "url": "https://ciur.ru/dpt/default.aspx",
      "city": "Дебёсы",
      "type": "БПОУ УР"
    },
    {
      "name": "Экономико-технологический колледж",
      "lat": 56.834167,
      "lng": 53.221667,
      "url": "https://ciur.ru/etk/default.aspx",
      "city": "Ижевск",
      "type": "АПОУ УР"
    },
    {
      "name": "Асановский аграрно-технический техникум",
      "lat": 56.252222,
      "lng": 53.468333,
      "url": "https://asanovo-att.ru/",
      "city": "Асаново",
      "type": "БПОУ УР"
    },
    {
      "name": "Техникум радиоэлектроники и информационных технологий имени А.В. Воскресенского",
      "lat": 56.821944,
      "lng": 53.205556,
      "url": "https://www.trit.biz/",
      "city": "Ижевск",
      "type": "АПОУ УР"
    },
    {
      "name": "Ижевский политехнический колледж",
      "lat": 56.863889,
      "lng": 53.298611,
      "url": "https://ciur.ru/ipk/default.aspx",
      "city": "Ижевск",
      "type": "АПОУ УР"
    },
    {
      "name": "Сюмсинский техникум лесного и сельского хозяйства",
      "lat": 57.111111,
      "lng": 51.605556,
      "url": "https://ciur.ru/stlsh/default.aspx",
      "city": "Сюмси",
      "type": "БПОУ УР"
    },
    {
      "name": "Топливно-энергетический колледж",
      "lat": 56.823611,
      "lng": 53.194444,
      "url": "https://ciur.ru/tek/default.aspx",
      "city": "Ижевск",
      "type": "АПОУ УР"
    },
    {
      "name": "Сарапульский колледж социально-педагогических технологий",
      "lat": 56.467222,
      "lng": 53.801389,
      "url": "https://ciur.ru/spk/default.aspx",
      "city": "Сарапул",
      "type": "БПОУ УР"
    },
    {
      "name": "Удмуртский республиканский социально-педагогический колледж",
      "lat": 56.845833,
      "lng": 53.251389,
      "url": "https://ciur.ru/urspk/default.aspx",
      "city": "Ижевск",
      "type": "БПОУ УР"
    },
    {
      "name": "Воткинский промышленный техникум",
      "lat": 57.051667,
      "lng": 54.001389,
      "url": "https://ciur.ru/vpt/default.aspx",
      "city": "Воткинск",
      "type": "БПОУ УР"
    },
    {
      "name": "Ижевский индустриальный техникум имени Е.Ф. Драгунова",
      "lat": 56.856389,
      "lng": 53.301667,
      "url": "https://ciur.ru/iit/default.aspx",
      "city": "Ижевск",
      "type": "БПОУ УР"
    },
    {
      "name": "Ижевский агростроительный техникум",
      "lat": 56.831944,
      "lng": 53.240278,
      "url": "https://ciur.ru/iast/default.aspx",
      "city": "Ижевск",
      "type": "БПОУ УР"
    },
    {
      "name": "Радиомеханический техникум имени В.А. Шутова",
      "lat": 56.876389,
      "lng": 53.279167,
      "url": "https://ciur.ru/rmt/default.aspx",
      "city": "Ижевск",
      "type": "БПОУ УР"
    },
    {
      "name": "Воткинский музыкально-педагогический колледж имени П.И. Чайковского",
      "lat": 57.047222,
      "lng": 53.994444,
      "url": "https://ciur.ru/vmpk/default.aspx",
      "city": "Воткинск",
      "type": "БПОУ УР"
    },
    {
      "name": "Ижевский машиностроительный техникум имени С.Н. Борина",
      "lat": 56.838056,
      "lng": 53.301389,
      "url": "https://ciur.ru/imst/default.aspx",
      "city": "Ижевск",
      "type": "БПОУ УР"
    },
    {
      "name": "Глазовский политехнический колледж",
      "lat": 58.143056,
      "lng": 52.661389,
      "url": "https://ciur.ru/glazovpk/default.aspx",
      "city": "Глазов",
      "type": "БПОУ УР"
    },
    {
      "name": "Увинский профессиональный колледж",
      "lat": 56.985278,
      "lng": 52.185278,
      "url": "https://ciur.ru/upk/default.aspx",
      "city": "Ува",
      "type": "БПОУ УР"
    },
    {
      "name": "Ярский политехникум",
      "lat": 58.246111,
      "lng": 52.105556,
      "url": "https://ciur.ru/yapt/default.aspx",
      "city": "Яр",
      "type": "БПОУ УР"
    },
    {
      "name": "Ижевский автотранспортный техникум",
      "lat": 56.850833,
      "lng": 53.289444,
      "url": "https://ciur.ru/iat/default.aspx",
      "city": "Ижевск",
      "type": "БПОУ УР"
    },
    {
      "name": "Сарапульский техникум машиностроения и информационных технологий",
      "lat": 56.461111,
      "lng": 53.791667,
      "url": "http://stmit.ru/",
      "city": "Сарапул",
      "type": "БПОУ УР"
    }
  ];

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();

    _initializeStars();
    _loadUserPlaces();
  }

  void _initializeStars() {
    for (int i = 0; i < 30; i++) {
      _stars.add(Star(
        x: _random.nextDouble() * 1.5 - 0.5,
        y: _random.nextDouble() * 2 - 1,
        speed: 0.3 + _random.nextDouble() * 0.7,
        size: 2.0 + _random.nextDouble() * 4.0,
        delay: _random.nextDouble() * 3.0,
        brightness: 0.6 + _random.nextDouble() * 0.4,
      ));
    }
  }

  void _loadUserPlaces() async {
    final snapshot = await _db.child('places').get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final placesList = <Map<String, dynamic>>[];
      
      for (final placeId in data.keys) {
        final placeData = Map<String, dynamic>.from(data[placeId] as Map);
        placeData['id'] = placeId;
        placesList.add(placeData);
      }
      
      setState(() {
        userPlaces = placesList;
      });
    }
  }

  bool _isInUdmurtia(LatLng point) {
    // Приблизительные границы Удмуртской Республики
    const double minLat = 56.0;
    const double maxLat = 58.5;
    const double minLng = 51.0;
    const double maxLng = 55.0;
    
    return point.latitude >= minLat && 
           point.latitude <= maxLat && 
           point.longitude >= minLng && 
           point.longitude <= maxLng;
  }

  Widget _buildStarBackground() {
    return const SizedBox();
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

  void _showAddPlaceDialog(LatLng point) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final urlController = TextEditingController();

    showGeneralDialog(
      context: context,
      barrierLabel: "Add Place",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, const Color(0xFFE3F2FD)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_location,
                        color: Color(0xFF6C63FF),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Добавить место',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isAddingPlace = false;
                        });
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Широта: ${point.latitude.toStringAsFixed(5)}',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.grey[600]!,
                  ),
                ),
                Text(
                  'Долгота: ${point.longitude.toStringAsFixed(5)}',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.grey[600]!,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Название места',
                    hintStyle: GoogleFonts.nunito(
                      color: Colors.grey[600],
                    ),
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: GoogleFonts.nunito(
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Описание места',
                    hintStyle: GoogleFonts.nunito(
                      color: Colors.grey[600],
                    ),
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: GoogleFonts.nunito(
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: urlController,
                  decoration: InputDecoration(
                    hintText: 'Ссылка на место (необязательно)',
                    hintStyle: GoogleFonts.nunito(
                      color: Colors.grey[600],
                    ),
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: GoogleFonts.nunito(
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isAddingPlace = false;
                        });
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Отмена',
                        style: GoogleFonts.nunito(
                          color: Colors.grey[700]!,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty || 
                            descriptionController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Заполните название и описание',
                                style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                              ),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }

                        final place = {
                          'name': nameController.text.trim(),
                          'description': descriptionController.text.trim(),
                          'url': urlController.text.trim(),
                          'lat': point.latitude,
                          'lng': point.longitude,
                          'addedBy': widget.userId,
                          'timestamp': ServerValue.timestamp,
                        };

                        await _db.child('places').push().set(place);
                        
                        setState(() {
                          _isAddingPlace = false;
                        });
                        if (mounted) {
                          Navigator.of(context).pop();
                          _loadUserPlaces();
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Место добавлено!',
                                style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
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
                        'Сохранить',
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
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

  void _showCollegeInfo(Map<String, dynamic> college) {
    final color = _typeColors[college['type']] ?? Colors.blueAccent;

    showGeneralDialog(
      context: context,
      barrierLabel: "College Info",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, const Color(0xFFE3F2FD)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: color.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.school,
                        color: color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        college['name'] as String,
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.location_city, college['city'] as String,
                    Colors.grey[700]!),
                _buildInfoRow(Icons.category, college['type'] as String, color),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Широта: ${college['lat'].toStringAsFixed(5)}',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.grey[600]!,
                        ),
                      ),
                      Text(
                        'Долгота: ${college['lng'].toStringAsFixed(5)}',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.grey[600]!,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Закрыть',
                        style: GoogleFonts.nunito(
                          color: Colors.grey[700]!,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _launchURL(college['url'] as String);
                      },
                      icon: const Icon(Icons.link, size: 18),
                      label: Text(
                        'сайт',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                )
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

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.nunito(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Marker _buildMarker(Map<String, dynamic> college) {
    final color = _typeColors[college['type']] ?? Colors.blueAccent;

    return Marker(
      point: LatLng(college['lat'] as double, college['lng'] as double),
      width: 50,
      height: 50,
      child: GestureDetector(
        onTap: () => _showCollegeInfo(college),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.6),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.school,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Marker _buildUserPlaceMarker(Map<String, dynamic> place) {
    return Marker(
      point: LatLng(place['lat'] as double, place['lng'] as double),
      width: 50,
      height: 50,
      child: GestureDetector(
        onTap: () => _showUserPlaceInfo(place),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.6),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.place,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showUserPlaceInfo(Map<String, dynamic> place) {
    showGeneralDialog(
      context: context,
      barrierLabel: "Place Info",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, const Color(0xFFE3F2FD)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.red.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.place,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        place['name'] as String,
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.description, place['description'] as String,
                    Colors.grey[700]!),
                if (place['url'] != null && place['url'].toString().isNotEmpty)
                  _buildInfoRow(Icons.link, place['url'] as String, Colors.red),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Широта: ${place['lat'].toStringAsFixed(5)}',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.grey[600]!,
                        ),
                      ),
                      Text(
                        'Долгота: ${place['lng'].toStringAsFixed(5)}',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.grey[600]!,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Закрыть',
                        style: GoogleFonts.nunito(
                          color: Colors.grey[700]!,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (place['url'] != null && place['url'].toString().isNotEmpty) ...[
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _launchURL(place['url'] as String);
                        },
                        icon: const Icon(Icons.link, size: 18),
                        label: Text(
                          'сайт',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ],
                )
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

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // Звездный фон (только в темной теме)
          _buildStarBackground(),

          // Карта
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(56.848, 53.213),
              initialZoom: 8.5,
              maxZoom: 18,
              minZoom: 6,
              onTap: _isAddingPlace ? (TapPosition tapPosition, LatLng point) {
                if (_isInUdmurtia(point)) {
                  _showAddPlaceDialog(point);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Можно добавлять места только на территории Удмуртской Республики',
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  setState(() {
                    _isAddingPlace = false;
                  });
                }
              } : null,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.profaritashion',
              ),
              MarkerLayer(
                markers: [
                  ...colleges.map(_buildMarker),
                  if (_showUserPlaces) ...userPlaces.map(_buildUserPlaceMarker),
                ],
              ),
            ],
          ),

          // Красивый заголовок с легендой внутри
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Заголовок и кнопка темы в одной строке
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Карта колледжей и мест",
                                style: GoogleFonts.nunito(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
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
                        // Кнопка скрытия/показа пользовательских мест
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _showUserPlaces = !_showUserPlaces;
                              });
                            },
                            icon: Icon(
                              _showUserPlaces ? Icons.visibility : Icons.visibility_off,
                              color: const Color(0xFF6C63FF),
                              size: 20,
                            ),
                            tooltip: _showUserPlaces ? 'Скрыть места' : 'Показать места',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Легенда внутри заголовка
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildCompactLegendItem(Colors.blueAccent, "БПОУ УР"),
                        _buildCompactLegendItem(Colors.green, "АПОУ УР"),
                        _buildCompactLegendItem(Colors.red, "Пользовательские места"),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${colleges.length + (_showUserPlaces ? userPlaces.length : 0)} мест",
                            style: GoogleFonts.nunito(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF6C63FF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Кнопки действий
          Positioned(
            bottom: 100,
            right: 16,
            child: Column(
              children: [
                // Кнопка рейтинга вузов (скрыта)
                // FloatingActionButton(
                //   onPressed: () {
                //     Navigator.pushNamed(context, '/college_rating', arguments: widget.userId);
                //   },
                //   backgroundColor: Colors.amber,
                //   foregroundColor: Colors.white,
                //   heroTag: "rating",
                //   child: const Icon(Icons.school),
                // ),
                // const SizedBox(height: 12),
                // Кнопка списка мест
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlacesListPage(userId: widget.userId),
                      ),
                    );
                  },
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  heroTag: "list",
                  child: const Icon(Icons.list),
                ),
                const SizedBox(height: 12),
                // Кнопка добавления места
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _isAddingPlace = !_isAddingPlace;
                    });
                    if (_isAddingPlace) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Нажмите на любое место в Удмуртии для добавления',
                            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: const Color(0xFF6C63FF),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  backgroundColor: _isAddingPlace ? Colors.orange : const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  heroTag: "add",
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 12),
                // Кнопка центрирования
                FloatingActionButton(
                  onPressed: () {
                    _mapController.move(const LatLng(56.848, 53.213), 8.5);
                  },
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  heroTag: "center",
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(currentIndex: _currentIndex, onTap: _navigate, userId: widget.userId),
    );
  }

  Widget _buildCompactLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.nunito(
            color: Colors.grey[600],
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

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
