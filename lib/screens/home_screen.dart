import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_income_screen.dart';
import 'add_expense_screen.dart';
import 'summary_screen.dart';
import 'package:chatbud/services/firestore_service.dart';

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
    const AddIncomeScreen(),
    const AddExpenseScreen(),
    const SummaryScreen(),
  ];

  void _showPhoneNumberDialog(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Phone Number'),
          content: TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: 'e.g. +91 9876543210',
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Submit'),
              onPressed: () async {
                String phoneNumber = phoneController.text.trim();
                if (phoneNumber.isNotEmpty) {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setString('phone_number', phoneNumber);

                  final firestoreService = FirestoreService();
                  await firestoreService.saveUser(phoneNumber);

                  print('Saved phone number: $phoneNumber');
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _checkPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phone_number');
    if (phoneNumber == null || phoneNumber.isEmpty) {
      // Show phone dialog if not saved
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPhoneNumberDialog(context);
      });
    } else {
      print('Phone already saved: $phoneNumber');
    }
  }

  @override
  void initState() {
    super.initState();

    // Start background animations
    _controllers = List.generate(5, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(seconds: 8 + index * 3),
      )..repeat(reverse: true);
    });

    _animations = [
      Tween(begin: Alignment.topLeft, end: Alignment.bottomRight).animate(
          CurvedAnimation(parent: _controllers[0], curve: Curves.easeInOut)),
      Tween(begin: Alignment.bottomLeft, end: Alignment.topRight).animate(
          CurvedAnimation(parent: _controllers[1], curve: Curves.easeInOut)),
      Tween(begin: Alignment.centerLeft, end: Alignment.centerRight).animate(
          CurvedAnimation(parent: _controllers[2], curve: Curves.easeInOut)),
      Tween(begin: Alignment.centerRight, end: Alignment.centerLeft).animate(
          CurvedAnimation(parent: _controllers[3], curve: Curves.easeInOut)),
      Tween(begin: Alignment.topRight, end: Alignment.bottomLeft).animate(
          CurvedAnimation(parent: _controllers[4], curve: Curves.easeInOut)),
    ];

    _checkPhoneNumber(); // Check for saved phone number
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildAnimatedCircle(
      Animation<Alignment> animation, double size, double opacity) {
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
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromARGB(255, 14, 134, 181), Color(0xFF4059F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Animated Circles
          ...List.generate(
            5,
            (index) => _buildAnimatedCircle(
              _animations[index],
              60.0 * (index + 1),
              0.2 + index * 0.05,
            ),
          ),
          // Welcome Text
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Welcome to our Budget Tracker\nChatBud',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(76, 9, 131, 207),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => _pages[index]),
          );
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.attach_money), label: 'Income'),
          BottomNavigationBarItem(
              icon: Icon(Icons.money_off), label: 'Expense'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Summary'),
        ],
      ),
    );
  }
}
