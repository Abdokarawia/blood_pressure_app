import 'package:blood_pressure_app/Features/Profile/Presentation/Profile_view.dart';
import 'package:blood_pressure_app/core/Utils/Shared%20Methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:iconsax/iconsax.dart';

import '../../Emergency Contacts/Presentation/Emergency_Contacts_View.dart';
import '../../GoalReminders/presentation/goal_reminders_view.dart';
import '../../HealthDataAnalysis/Presentation/health_data_analysis_view.dart';
import '../../Home/Presentation/Home_View.dart';
import '../../MedicationReminders/Presentation/medication_reminders_view.dart';
import '../../Notifications/Presentation/notifications_view.dart';
import '../../HealthDataInput/Presentation/health_data_input_view.dart';

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
  late AnimationController _backgroundAnimationController;
  late Animation<double> _backgroundAnimation;

  late PageController _pageController;
  late List<Widget> _screens;

  // Scroll controller for bottom navigation
  final ScrollController _navScrollController = ScrollController();

  late ProfileData _profileData;


  @override
  void initState() {
    super.initState();

    _profileData = ProfileData(
      name: 'Mohamed Elshamry',
      age: 35,
      gender: 'Male',
      height: 175.0,
      weight: 70.0,
      heartRate: 72,
      bloodPressureProfile: BloodPressureProfile(
        systolic: 120,
        diastolic: 80,
        historicalReadings: [
          BloodPressureReading(date: DateTime(2024, 1, 1), systolic: 118, diastolic: 78),
          BloodPressureReading(date: DateTime(2024, 2, 1), systolic: 122, diastolic: 82),
          BloodPressureReading(date: DateTime(2024, 3, 1), systolic: 120, diastolic: 80),
        ],
      ),
      medicalConditions: ['Mild Hypertension', 'Seasonal Allergies'],
      healthGoals: HealthGoals(
        weightGoal: 68.0,
        dailyStepGoal: 12000,
        sleepHoursGoal: 8,
      ),
    );

    _pageTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _searchExpandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

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
      HomeManagementScreen(animationController: _pageTransitionController),
      MedicationRemindersScreen(animationController: _pageTransitionController),
      GoalRemindersScreen(animationController: _pageTransitionController),
      HealthDataInputScreen(animationController: _pageTransitionController),
      HealthDataAnalysisScreen(animationController: _pageTransitionController),
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
    _backgroundAnimationController.dispose();
    _pageController.dispose();
    _navScrollController.dispose();
    super.dispose();
  }

  // Scroll to the selected tab in bottom navigation
  void _scrollToSelectedTab() {
    if (_navScrollController.hasClients) {
      // Calculate approximate position of selected tab
      double tabWidth = MediaQuery.of(context).size.width / 4; // Approximate width
      double scrollOffset = (_selectedIndex * tabWidth) - (tabWidth * 1.5);

      _navScrollController.animateTo(
        scrollOffset.clamp(0, _navScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuad,
      );
    }
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

    // Scroll to the selected tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedTab();
    });
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

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive layout
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Define breakpoints
    final isExtraSmallScreen = screenWidth < 320;
    final isSmallScreen = screenWidth < 360 && !isExtraSmallScreen;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;
    final isTablet = screenWidth >= 600;

    // Auto-scroll to the selected tab on initial load and page changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedTab();
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: SafeArea(
          child: Column(
            children: [
              _buildEnhancedHeader(context, isExtraSmallScreen, isSmallScreen),
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

                      // Scroll to the selected tab on page change
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToSelectedTab();
                      });
                    }
                  },
                  children: _screens,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildModernBottomNavigation(context, isExtraSmallScreen, isSmallScreen, isTablet),
      ),
    );
  }

  Widget _buildEnhancedHeader(BuildContext context, bool isExtraSmallScreen, bool isSmallScreen) {
    final scale = isExtraSmallScreen ? 0.7 : (isSmallScreen ? 0.8 : 1.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          16 * scale,
          10 * scale,
          16 * scale,
          5 * scale
      ),
      margin: EdgeInsets.only(bottom: 5 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Hello, Mohamed',
                          style: GoogleFonts.poppins(
                            fontSize: isExtraSmallScreen ? 18 : (isSmallScreen ? 22 : 28),
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
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Spacer(),
                        IconButton(onPressed: (){
                          navigateTo(context, EditProfileScreen(profileData: _profileData, ));
                        }, icon: Icon(Iconsax.user , color: Colors.teal,))
                      ],
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Stay healthy today',
                        style: GoogleFonts.poppins(
                          fontSize: isExtraSmallScreen ? 12 : (isSmallScreen ? 14 : 16),
                          color: Colors.teal.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 5 * scale),
        ],
      ),
    );
  }

  Widget _buildModernBottomNavigation(BuildContext context, bool isExtraSmallScreen, bool isSmallScreen, bool isTablet) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = isExtraSmallScreen ? 0.7 : (isSmallScreen ? 0.85 : 1.0);

    return Container(
      height: isExtraSmallScreen ? 65 : (isSmallScreen ? 70 : (isTablet ? 90 : 80)),
      margin: EdgeInsets.symmetric(
        horizontal: isExtraSmallScreen ? 6 : (isSmallScreen ? 8 : 16),
        vertical: isExtraSmallScreen ? 6 : (isSmallScreen ? 8 : 16),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(isExtraSmallScreen ? 25 : 40),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: _navScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isExtraSmallScreen ? 4 : 8,
            vertical: isExtraSmallScreen ? 2 : 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildModernNavItem(0, Iconsax.home, 'Home', isExtraSmallScreen, isSmallScreen),
              _buildModernNavItem(1, Iconsax.health, 'Meds', isExtraSmallScreen, isSmallScreen),
              _buildModernNavItem(2, Iconsax.activity, 'Goals', isExtraSmallScreen, isSmallScreen),
              _buildModernNavItem(3, Iconsax.chart, 'Input', isExtraSmallScreen, isSmallScreen),
              _buildModernNavItem(4, Iconsax.graph, 'Health Analysis', isExtraSmallScreen, isSmallScreen),
              _buildModernNavItem(5, Iconsax.call, 'Emergency', isExtraSmallScreen, isSmallScreen),
              _buildModernNavItem(6, Iconsax.notification, 'Alerts', isExtraSmallScreen, isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernNavItem(int index, IconData icon, String label, bool isExtraSmallScreen, bool isSmallScreen) {
    final isSelected = _selectedIndex == index;
    final scale = isExtraSmallScreen ? 0.7 : (isSmallScreen ? 0.85 : 1.0);

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: EdgeInsets.symmetric(
          horizontal: isExtraSmallScreen ? 2 : (isSmallScreen ? 3 : 6),
          vertical: isExtraSmallScreen ? 2 : 0,
        ),
        padding: EdgeInsets.symmetric(
            horizontal: isExtraSmallScreen ? 6 : (isSmallScreen ? 8 : 12),
            vertical: isExtraSmallScreen ? 4 : (isSmallScreen ? 6 : 8)
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(isExtraSmallScreen ? 15 : 20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.teal.shade700 : Colors.grey.shade500,
              size: isExtraSmallScreen ? 16 : (isSmallScreen ? 18 : 22),
            ),
            if (isSelected) ...[
              SizedBox(width: isExtraSmallScreen ? 3 : (isSmallScreen ? 4 : 8)),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.teal.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: isExtraSmallScreen ? 10 : (isSmallScreen ? 12 : 14),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}