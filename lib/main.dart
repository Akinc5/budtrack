import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/add_income_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/summary_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<Alignment>> _animations;
  int _currentIndex = 0;

  final List<Widget> _pages = [
    AddIncomeScreen(),
    AddExpenseScreen(),
    SummaryScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // Initialize multiple controllers and animations
    _controllers = List.generate(6, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(seconds: 8 + index * 3),
      )..repeat(reverse: true);
    });

    _animations = [
      Tween<Alignment>(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).animate(CurvedAnimation(parent: _controllers[0], curve: Curves.easeInOut)),

      Tween<Alignment>(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).animate(CurvedAnimation(parent: _controllers[1], curve: Curves.easeInOut)),

      Tween<Alignment>(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).animate(CurvedAnimation(parent: _controllers[2], curve: Curves.easeInOut)),
      Tween<Alignment>(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
      ).animate(CurvedAnimation(parent: _controllers[3], curve: Curves.easeInOut)),
      Tween<Alignment>(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).animate(CurvedAnimation(parent: _controllers[4], curve: Curves.easeInOut)),
    ];
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildAnimatedCircle(Animation<Alignment> animation, double size, double opacity) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Align(
          alignment: animation.value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(opacity),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(opacity + 0.1),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromARGB(255, 14, 134, 181), Color(0xFF4059F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Multiple animated circles
          _buildAnimatedCircle(_animations[0], 120, 0.2),
          _buildAnimatedCircle(_animations[1], 180, 0.25),
          _buildAnimatedCircle(_animations[2], 140, 0.3),
          _buildAnimatedCircle(_animations[3], 80, 0.35),
          _buildAnimatedCircle(_animations[4], 40, 0.45),

          // Centered welcome text
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Welcome to our Budget Tracker \nChatBud',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        currentIndex: _currentIndex,
        onTap: (index) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => _pages[index]),
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Income',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money_off),
            label: 'Expense',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Summary',
          ),
        ],
      ),
    );
  }
}
