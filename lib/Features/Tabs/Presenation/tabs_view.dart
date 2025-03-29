import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:iconsax/iconsax.dart';

import '../../Emergency Contacts/Presentation/Emergency_Contacts_View.dart';
import '../../GoalReminders/presentation/goal_reminders_view.dart';
import '../../MedicationReminders/Presentation/medication_reminders_view.dart';
import '../../Notifications/Presentation/notifications_view.dart';
import '../../Profile/Presentation/Profile_View.dart';
import '../../HealthDataInput/Presentation/health_data_input_view.dart';
import '../../HealthDataAnalysis/Presentation/health_data_analysis_view.dart';
import '../../DataHistory/Presentation/data_history_view.dart'; // Add import for new screen

// Main Tab Screen with Enhanced UI
class TabScreen extends StatefulWidget {
  const TabScreen({super.key});

  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isSearchExpanded = false;

  late AnimationController _pageTransitionController;
  late AnimationController _searchExpandController;
  late AnimationController _pulseAnimationController;
  late AnimationController _backgroundAnimationController;
  late Animation<double> _backgroundAnimation;

  late PageController _pageController;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _pageTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _searchExpandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 30000),
    )..repeat();

    _backgroundAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_backgroundAnimationController);

    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 0.99,
    );

    _screens = [
      ProfileManagementScreen(animationController: _pageTransitionController),
      MedicationRemindersScreen(animationController: _pageTransitionController),
      GoalRemindersScreen(animationController: _pageTransitionController),
      HealthDataInputScreen(animationController: _pageTransitionController),
      HealthDataAnalysisScreen(animationController: _pageTransitionController),
      DataHistoryScreen(animationController: _pageTransitionController), // New screen added
      EmergencyContactsScreen(),
      NotificationsScreen(animationController: _pageTransitionController),
    ];

    _pageTransitionController.forward();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _pageTransitionController.dispose();
    _searchExpandController.dispose();
    _pulseAnimationController.dispose();
    _backgroundAnimationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    _pageTransitionController.reset();

    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutQuint,
      );
    });

    _pageTransitionController.forward();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (_isSearchExpanded) {
        _searchExpandController.forward();
      } else {
        _searchExpandController.reverse();
      }
    });
  }

  void _showAddOptionsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Add New Item',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[800],
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    _buildAddOptionCard(
                      icon: Iconsax.health,
                      title: 'Medication',
                      color: Colors.blue,
                    ),
                    _buildAddOptionCard(
                      icon: Iconsax.heart_circle,
                      title: 'Health Data',
                      color: Colors.redAccent,
                    ),
                    _buildAddOptionCard(
                      icon: Iconsax.activity,
                      title: 'Workout',
                      color: Colors.deepPurple,
                    ),
                    _buildAddOptionCard(
                      icon: Iconsax.cup,
                      title: 'Meal',
                      color: Colors.orange,
                    ),
                    _buildAddOptionCard(
                      icon: Iconsax.timer,
                      title: 'Reminder',
                      color: Colors.teal,
                    ),
                    _buildAddOptionCard(
                      icon: Iconsax.profile_add,
                      title: 'Contact',
                      color: Colors.green,
                    ),
                    _buildAddOptionCard(
                      icon: Iconsax.share,
                      title: 'Share Data',
                      color: Colors.purple,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Column(
          children: [
            _buildEnhancedHeader(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  if (_selectedIndex != index) {
                    setState(() {
                      _selectedIndex = index;
                      _pageTransitionController.reset();
                      _pageTransitionController.forward();
                    });
                  }
                },
                children: _screens,
              ),
            ),
          ],
        ),
        floatingActionButton: _buildAdvancedFAB(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _buildModernBottomNavigation(),
      ),
    );
  }

  Widget _buildEnhancedHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, Ahmed',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [
                            Colors.teal.shade700,
                            Colors.green.shade700,
                          ],
                        ).createShader(
                          const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                        ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Stay healthy today',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.teal.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 5),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }


  Widget _buildAdvancedFAB() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _showAddOptionsModal();
      },
      child: AnimatedBuilder(
        animation: _pulseAnimationController,
        builder: (context, child) {
          final scale = 1.0 + _pulseAnimationController.value * 0.05;

          return Transform.scale(
            scale: scale,
            child: Container(
              height: 65,
              width: 65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.teal.shade500, Colors.green.shade600],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 10,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Iconsax.add,
                color: Colors.white,
                size: 32,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddOptionCard({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.pop(context);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.7), color],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 15),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernBottomNavigation() {
    return Container(
      height: 80,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildModernNavItem(0, Iconsax.profile_2user, 'Profile'),
          _buildModernNavItem(1, Iconsax.health, 'Meds'),
          _buildModernNavItem(2, Iconsax.activity, 'Goals'),
          _buildModernNavItem(3, Iconsax.chart, 'Input'),
          _buildModernNavItem(4, Iconsax.graph, 'Analysis'),
          _buildModernNavItem(5, Iconsax.calendar, 'History'), // New tab
          _buildModernNavItem(6, Iconsax.call, 'Emergency'),
          _buildModernNavItem(7, Iconsax.notification, 'Alerts'),
        ],
      ),
    );
  }

  Widget _buildModernNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.teal.shade700 : Colors.grey.shade500,
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.teal.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}