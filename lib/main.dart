import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';
import 'package:animated_background/animated_background.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Конструктор Сообществ',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF0A0A0A),
        cardTheme: CardThemeData(
          elevation: 15,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          color: Colors.transparent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFF6B6B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            shadowColor: Color(0xFF00FFFF).withOpacity(0.5),
          ),
        ),
        textTheme: TextTheme(
          headlineLarge: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white, shadows: [Shadow(blurRadius: 10, color: Color(0xFF00FFFF))]),
          headlineSmall: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white, shadows: [Shadow(blurRadius: 6, offset: Offset(0, 2), color: Color(0xFF00FFFF))]),
          bodyMedium: GoogleFonts.roboto(fontSize: 16, color: Colors.white70),
        ),
      ),
      home: LoginScreen(),
    );
  }
}

class UserProfile {
  String name;
  List<String> interests;
  List<String> skills;
  List<String> badges;
  UserProfile({required this.name, this.interests = const [], this.skills = const [], this.badges = const []});
}

class CollectionItem {
  String type;
  String title;
  String content;
  CollectionItem({required this.type, required this.title, required this.content});
}

class MarkovChain {
  final Map<String, List<String>> transitions = {};
  final Random random = Random();

  void train(List<String> words) {
    for (int i = 0; i < words.length - 1; i++) {
      String current = words[i];
      String next = words[i + 1];
      transitions.putIfAbsent(current, () => []).add(next);
    }
  }

  String generate(int length) {
    if (transitions.isEmpty) return 'Робототехника ИИ';
    String current = transitions.keys.elementAt(random.nextInt(transitions.length));
    List<String> result = [current];
    for (int i = 0; i < length - 1; i++) {
      List<String>? nextWords = transitions[current];
      if (nextWords == null || nextWords.isEmpty) break;
      current = nextWords[random.nextInt(nextWords.length)];
      result.add(current);
    }
    return result.join(' ');
  }
}

class ScaleTransitionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  ScaleTransitionButton({required this.onPressed, required this.child});

  @override
  _ScaleTransitionButtonState createState() => _ScaleTransitionButtonState();
}

class _ScaleTransitionButtonState extends State<ScaleTransitionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: ElevatedButton(
              onPressed: widget.onPressed,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegister = true;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: Duration(seconds: 2))..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(_glowController);
    _checkSavedCredentials();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _checkSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userName') && prefs.containsKey('password')) {
      setState(() {
        _isRegister = false;
      });
    }
  }

  Future<void> _handleAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final inputName = _nameController.text;
    final inputPassword = _passwordController.text;

    if (inputName.isEmpty || inputPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Заполните все поля')));
      return;
    }

    if (_isRegister) {
      await prefs.setString('userName', inputName);
      await prefs.setString('password', inputPassword);
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => BottomNavScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(begin: Offset(0, 0.1), end: Offset.zero).animate(animation),
                child: child,
              ),
            );
          },
        ),
      );
    } else {
      final savedName = prefs.getString('userName');
      final savedPassword = prefs.getString('password');
      if (inputName == savedName && inputPassword == savedPassword) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => BottomNavScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(begin: Offset(0, 0.1), end: Offset.zero).animate(animation),
                  child: child,
                ),
              );
            },
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Неверное имя или пароль')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: ParticleOptions(
            baseColor: Color(0xFF00FFFF),
            spawnMaxRadius: 10,
            spawnMinRadius: 5,
            particleCount: 30,
            spawnOpacity: 0.3,
          ),
        ),
        vsync: this,
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [Color(0xFF00FFFF).withOpacity(_glowAnimation.value), Colors.transparent],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.android, size: 80, color: Colors.white),
                  );
                },
              ),
              SizedBox(height: 40),
              TextField(
                controller: _nameController,
                style: GoogleFonts.roboto(),
                decoration: InputDecoration(
                  labelText: 'Имя пользователя',
                  labelStyle: GoogleFonts.roboto(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Color(0xFF00FFFF)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Color(0xFF00FFFF), width: 2),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: GoogleFonts.roboto(),
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  labelStyle: GoogleFonts.roboto(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Color(0xFF00FFFF)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Color(0xFF00FFFF), width: 2),
                  ),
                ),
              ),
              SizedBox(height: 30),
              ScaleTransitionButton(
                onPressed: _handleAuth,
                child: Text(
                  _isRegister ? 'Зарегистрироваться' : 'Войти',
                  style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isRegister = !_isRegister;
                  });
                },
                child: Text(
                  _isRegister ? 'Уже есть аккаунт? Войти' : 'Нет аккаунта? Зарегистрироваться',
                  style: GoogleFonts.roboto(color: Color(0xFF00FFFF)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomNavScreen extends StatefulWidget {
  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    CommunitiesScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(begin: Offset(0.1, 0), end: Offset.zero).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Сообщества',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF00FFFF),
        unselectedItemColor: Colors.grey,
        backgroundColor: Color(0xFF1A1A2E),
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String userName = '';
  List<String> _news = [];
  bool _isLoading = true;
  late MarkovChain _markovChain;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  final List<String> roboticsWords = [
    'робототехника', 'ИИ', 'датчик', 'автоматизация', 'манипулятор', 'дрон', 'лидар', 'ROS', 'Arduino', 'кинематика',
    'контроллер', 'алгоритм', 'сенсор', 'актуатор', 'автономный', 'микроконтроллер', 'серводвигатель', 'гироскоп'
  ];
  final List<String> rssFeeds = [
    'https://habr.com/rss/all/',
    'https://hi-tech.mail.ru/rss',
    'https://www.themoscowtimes.com/rss/technology',
  ];

  @override
  void initState() {
    super.initState();
    _markovChain = MarkovChain();
    _markovChain.train(roboticsWords);
    _glowController = AnimationController(vsync: this, duration: Duration(seconds: 2))..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(_glowController);
    _loadUserName();
    _loadNews();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'Пользователь';
    });
  }

  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
    });

    List<String> newsTitles = [];
    try {
      for (String feedUrl in rssFeeds) {
        final response = await http.get(Uri.parse(feedUrl));
        if (response.statusCode == 200) {
          final rss = RssFeed.parse(response.body);
          for (int i = 0; i < (rss.items?.length ?? 0) && newsTitles.length < 5; i++) {
            final title = rss.items![i].title ?? 'Новость без заголовка';
            newsTitles.add(title);
            _markovChain.train(title.split(' '));
          }
        }
      }
      setState(() {
        _news = newsTitles.take(10).toList();
      });
    } catch (e) {
      _news = List.generate(10, (_) => _markovChain.generate(5));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки новостей: $e. Показаны сгенерированные данные.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: ParticleOptions(
            baseColor: Color(0xFF00FFFF),
            spawnMaxRadius: 10,
            spawnMinRadius: 5,
            particleCount: 30,
            spawnOpacity: 0.3,
          ),
        ),
        vsync: this,
        child: Column(
          children: [
            AppBar(
              title: Text('Главная - $userName', style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0A0A0A), Color(0xFF1A1A2E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _glowAnimation,
                            builder: (context, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF00FFFF).withOpacity(_glowAnimation.value),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: RotationTransition(
                                  turns: Tween(begin: 0.0, end: 1.0).animate(
                                    AnimationController(
                                      vsync: this,
                                      duration: Duration(seconds: 2),
                                    )..repeat(),
                                  ),
                                  child: Icon(Icons.android, color: Colors.white, size: 50),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 16),
                          Text('Загрузка новостей...', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    )
                  : AnimationLimiter(
                      child: RefreshIndicator(
                        onRefresh: _loadNews,
                        child: ListView.builder(
                          padding: EdgeInsets.all(8),
                          itemCount: _news.length,
                          itemBuilder: (context, index) {
                            final imagePath = index % 2 == 0 ? 'assets/png1.png' : 'assets/png2.png';
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 600),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: ScaleAnimation(
                                  scale: 0.9,
                                  child: FadeInAnimation(
                                    child: Card(
                                      child: AnimatedBuilder(
                                        animation: _glowAnimation,
                                        builder: (context, child) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(24),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color(0xFF00FFFF).withOpacity(_glowAnimation.value),
                                                  blurRadius: 12,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(16),
                                              child: Row(
                                                children: [
                                                  ScaleAnimation(
                                                    scale: 0.8,
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(12),
                                                      child: Image.asset(imagePath, width: 80, height: 80, fit: BoxFit.cover),
                                                    ),
                                                  ),
                                                  SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          _news[index],
                                                          style: Theme.of(context).textTheme.headlineSmall,
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        SizedBox(height: 8),
                                                        Text(
                                                          'Источник: RSS ${index + 1}',
                                                          style: GoogleFonts.roboto(color: Colors.white70, fontSize: 12),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  RotationTransition(
                                                    turns: Tween(begin: 0.0, end: 1.0).animate(
                                                      AnimationController(
                                                        vsync: this,
                                                        duration: Duration(seconds: 10),
                                                      )..repeat(),
                                                    ),
                                                    child: Icon(Icons.android, color: Color(0xFF00FFFF), size: 24),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommunitiesScreen extends StatefulWidget {
  @override
  _CommunitiesScreenState createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> with TickerProviderStateMixin {
  List<String> interests = [];
  List<String> communities = ['AI в машиностроении', 'Робототехника'];
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: Duration(seconds: 2))..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(_glowController);
    _loadInterests();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _loadInterests() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      interests = prefs.getStringList('interests') ?? [];
    });
  }

  List<String> _getRecommendations() {
    return communities.where((community) {
      return interests.any((interest) => community.toLowerCase().contains(interest.toLowerCase()));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: ParticleOptions(
            baseColor: Color(0xFF00FFFF),
            spawnMaxRadius: 10,
            spawnMinRadius: 5,
            particleCount: 30,
            spawnOpacity: 0.3,
          ),
        ),
        vsync: this,
        child: Column(
          children: [
            AppBar(
              title: Text('Сообщества', style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0A0A0A), Color(0xFF1A1A2E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Expanded(
              child: AnimationLimiter(
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 600),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      horizontalOffset: 50.0,
                      child: FadeInAnimation(
                        child: widget,
                      ),
                    ),
                    children: [
                      Text('Рекомендуемые сообщества:', style: Theme.of(context).textTheme.headlineSmall),
                      ..._getRecommendations().map((community) => AnimatedBuilder(
                            animation: _glowAnimation,
                            builder: (context, child) {
                              return Card(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF00FFFF).withOpacity(_glowAnimation.value),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    title: Text(community, style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
                                    trailing: RotationTransition(
                                      turns: Tween(begin: 0.0, end: 1.0).animate(
                                        AnimationController(
                                          vsync: this,
                                          duration: Duration(seconds: 10),
                                        )..repeat(),
                                      ),
                                      child: Icon(Icons.arrow_forward, color: Color(0xFF00FFFF)),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation, secondaryAnimation) => CommunityScreen(community: community),
                                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: SlideTransition(
                                                position: Tween<Offset>(begin: Offset(0, 0.1), end: Offset.zero).animate(animation),
                                                child: child,
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _interestsController = TextEditingController();
  final _skillsController = TextEditingController();
  List<String> badges = [];
  List<String> reflections = [];
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: Duration(seconds: 2))..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(_glowController);
    _loadProfile();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('userName') ?? '';
      _interestsController.text = prefs.getStringList('interests')?.join(', ') ?? '';
      _skillsController.text = prefs.getStringList('skills')?.join(', ') ?? '';
      badges = prefs.getStringList('badges') ?? [];
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameController.text);
    await prefs.setStringList('interests', _interestsController.text.split(',').map((e) => e.trim()).toList());
    await prefs.setStringList('skills', _skillsController.text.split(',').map((e) => e.trim()).toList());
    if (!badges.contains('Профиль заполнен')) {
      badges.add('Профиль заполнен');
      await prefs.setStringList('badges', badges);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: ParticleOptions(
            baseColor: Color(0xFF00FFFF),
            spawnMaxRadius: 10,
            spawnMinRadius: 5,
            particleCount: 30,
            spawnOpacity: 0.3,
          ),
        ),
        vsync: this,
        child: Column(
          children: [
            AppBar(
              title: Text('Профиль', style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0A0A0A), Color(0xFF1A1A2E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _nameController,
                        style: GoogleFonts.roboto(),
                        decoration: InputDecoration(
                          labelText: 'Имя',
                          labelStyle: GoogleFonts.roboto(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Color(0xFF00FFFF)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Color(0xFF00FFFF), width: 2),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _interestsController,
                        style: GoogleFonts.roboto(),
                        decoration: InputDecoration(
                          labelText: 'Интересы (через запятую)',
                          labelStyle: GoogleFonts.roboto(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Color(0xFF00FFFF)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Color(0xFF00FFFF), width: 2),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _skillsController,
                        style: GoogleFonts.roboto(),
                        decoration: InputDecoration(
                          labelText: 'Навыки (через запятую)',
                          labelStyle: GoogleFonts.roboto(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Color(0xFF00FFFF)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Color(0xFF00FFFF), width: 2),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text('Достижения:', style: Theme.of(context).textTheme.headlineSmall),
                      ...badges.map((badge) => AnimatedBuilder(
                            animation: _glowAnimation,
                            builder: (context, child) {
                              return Card(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFFFF6B6B), Color(0xFF1A1A2E)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF00FFFF).withOpacity(_glowAnimation.value),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: ListTile(title: Text(badge, style: GoogleFonts.roboto(fontWeight: FontWeight.bold))),
                                ),
                              );
                            },
                          )),
                      SizedBox(height: 20),
                      ScaleTransitionButton(
                        onPressed: _saveProfile,
                        child: Text('Сохранить', style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
                      ),
                      ScaleTransitionButton(
                        onPressed: () {
                          setState(() {
                            reflections.add('Рефлексия ${DateTime.now()}');
                          });
                        },
                        child: Text('Добавить рефлексию', style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(height: 20),
                      Text('Рефлексии:', style: Theme.of(context).textTheme.headlineSmall),
                      ...reflections.map((reflection) => AnimatedBuilder(
                            animation: _glowAnimation,
                            builder: (context, child) {
                              return Card(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF00FFFF).withOpacity(_glowAnimation.value),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: ListTile(title: Text(reflection, style: GoogleFonts.roboto())),
                                ),
                              );
                            },
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommunityScreen extends StatefulWidget {
  final String community;
  CommunityScreen({required this.community});

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with TickerProviderStateMixin {
  final List<CollectionItem> collection = [
    CollectionItem(type: 'literature', title: 'Книга по AI', content: 'assets/book.pdf'),
    CollectionItem(type: 'case', title: 'Кейс: Робототехника', content: 'Решение задачи'),
  ];
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: Duration(seconds: 2))..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(_glowController);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: ParticleOptions(
            baseColor: Color(0xFF00FFFF),
            spawnMaxRadius: 10,
            spawnMinRadius: 5,
            particleCount: 30,
            spawnOpacity: 0.3,
          ),
        ),
        vsync: this,
        child: Column(
          children: [
            AppBar(
              title: Text(widget.community, style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0A0A0A), Color(0xFF1A1A2E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Лента новостей', style: Theme.of(context).textTheme.headlineSmall),
                      AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, child) {
                          return Card(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF00FFFF).withOpacity(_glowAnimation.value),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ListTile(title: Text('Новость 1: Новый проект запущен', style: GoogleFonts.roboto())),
                            ),
                          );
                        },
                      ),
                      AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, child) {
                          return Card(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF00FFFF).withOpacity(_glowAnimation.value),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ListTile(title: Text('Новость 2: Вебинар по AI', style: GoogleFonts.roboto())),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      Text('Обсуждение', style: Theme.of(context).textTheme.headlineSmall),
                      AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, child) {
                          return Card(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF00FFFF).withOpacity(_glowAnimation.value),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ListTile(title: Text('Сообщение: Какой софт используете?', style: GoogleFonts.roboto())),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      Text('Коллекция', style: Theme.of(context).textTheme.headlineSmall),
                      ...collection.map((item) => AnimatedBuilder(
                            animation: _glowAnimation,
                            builder: (context, child) {
                              return Card(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF00FFFF).withOpacity(_glowAnimation.value),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    title: Text(item.title, style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
                                    subtitle: Text(item.type, style: GoogleFonts.roboto()),
                                  ),
                                ),
                              );
                            },
                          )),
                      SizedBox(height: 20),
                      ScaleTransitionButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Лаборатория: Виртуальная доска')));
                        },
                        child: Text('Лаборатория', style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
                      ),
                      ScaleTransitionButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Коворкинг: Неформальный чат')));
                        },
                        child: Text('Коворкинг', style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}