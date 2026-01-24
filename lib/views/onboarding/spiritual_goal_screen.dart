import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';
import '../../routes/app_pages.dart';

class SpiritualGoalScreen extends StatefulWidget {
  const SpiritualGoalScreen({super.key});

  @override
  State<SpiritualGoalScreen> createState() => _SpiritualGoalScreenState();
}

class _SpiritualGoalScreenState extends State<SpiritualGoalScreen> with TickerProviderStateMixin {
  // App Theme Colors
  static const Color primaryPurple = Color(0xFF8F66FF);
  static const Color lightPurple = Color(0xFFAB80FF);
  static const Color darkPurple = Color(0xFF2D1B69);
  static const Color goldAccent = Color(0xFFD4AF37);

  String? selectedGoal;
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  final List<Map<String, dynamic>> goals = [
    {
      'id': 'pray_consistently',
      'title': 'Pray Consistently',
      'subtitle': 'Never miss a prayer',
      'icon': Icons.mosque_rounded,
      'gradient': [const Color(0xFF8F66FF), const Color(0xFF6B4EE6)],
    },
    {
      'id': 'read_quran',
      'title': 'Read Quran',
      'subtitle': 'Daily Quran reading',
      'icon': Icons.menu_book_rounded,
      'gradient': [const Color(0xFFD4AF37), const Color(0xFFB8860B)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2D1B69), // Dark purple
              Color(0xFF8F66FF), // Primary purple
              Color(0xFFAB80FF), // Light purple
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FadeTransition(
                opacity: _fadeController,
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Greeting Text
                    Text(
                      'Salam',
                      style: GoogleFonts.amiri(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: goldAccent,
                        height: 1.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Welcome Text
                    Text(
                      'Welcome to Muslim Pro',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 30),

                    // App Logo with glow effect
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: goldAccent.withOpacity(0.4),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Image.asset('assets/images/Quraniocn.png', height: 180),
                    ),

                    const SizedBox(height: 30),

                    // Question Text
                    Text(
                      'What is your spiritual goal?',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    // Goal Options
                    ...goals.map((goal) => _buildGoalOption(goal)),

                    const SizedBox(height: 10),

                    // Setup Text - Updated with white/gold theme
                    Text(
                      'Setup your app and stay on track',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 15),

                    // Start Button - Updated with gold accent
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: selectedGoal != null ? 1.0 : 0.5,
                      child: SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: selectedGoal != null ? _onContinue : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: goldAccent,
                            foregroundColor: darkPurple,
                            elevation: selectedGoal != null ? 12 : 0,
                            shadowColor: goldAccent.withOpacity(0.5),
                            disabledBackgroundColor: Colors.white.withOpacity(0.3),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Bismillah,',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: selectedGoal != null ? Colors.white : Colors.white70,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Let\'s Start',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: selectedGoal != null ? Colors.white : Colors.white70,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: selectedGoal != null ? Colors.white : Colors.white70,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalOption(Map<String, dynamic> goal) {
    final isSelected = selectedGoal == goal['id'];

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGoal = goal['id'];
        });
        _scaleController.forward().then((_) => _scaleController.reverse());
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white.withOpacity(0.25), Colors.white.withOpacity(0.15)],
                )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? goldAccent : Colors.white.withOpacity(0.3),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: goldAccent.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Icon Container
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [goldAccent, goldAccent.withOpacity(0.8)],
                      )
                    : LinearGradient(
                        colors: [Colors.white.withOpacity(0.25), Colors.white.withOpacity(0.15)],
                      ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: goldAccent.withOpacity(0.5),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                goal['icon'] as IconData,
                color: isSelected ? darkPurple : Colors.white,
                size: 28,
              ),
            ),

            const SizedBox(width: 16),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal['title'],
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? goldAccent : Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    goal['subtitle'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Check Icon
            AnimatedScale(
              duration: const Duration(milliseconds: 300),
              scale: isSelected ? 1.0 : 0.0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [goldAccent, goldAccent.withOpacity(0.8)]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: goldAccent.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onContinue() {
    if (selectedGoal == null) return;

    // Save the selected goal
    final storage = GetStorage();
    storage.write('spiritual_goal', selectedGoal);
    storage.write('onboarding_completed_step_1', true);

    // Navigate to notification permission screen
    Get.toNamed(Routes.NOTIFICATION_PERMISSION);
  }
}
