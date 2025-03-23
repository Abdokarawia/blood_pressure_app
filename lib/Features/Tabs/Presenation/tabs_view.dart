import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'dart:math' as math;

// Main Tab Screen with Enhanced UI
class TabScreen extends StatefulWidget {
  const TabScreen({super.key});

  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isSearchExpanded = false;

  // Animation controllers
  late AnimationController _pageTransitionController;
  late AnimationController _searchExpandController;
  late AnimationController _pulseAnimationController;
  late AnimationController _backgroundAnimationController;
  late Animation<double> _backgroundAnimation;

  // Page view controller
  late PageController _pageController;

  // Define your tab screens here
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
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

    // Initialize page controller with physics for smooth page transitions
    _pageController = PageController(
      initialPage: 0,
      viewportFraction:
          0.99, // Slightly less than 1 to show a peek of the next page
    );

    // Initialize screens with the controllers
    _screens = [
      ProfileManagementScreen(animationController: _pageTransitionController),
      MedicationRemindersScreen(animationController: _pageTransitionController),
      GoalRemindersScreen(animationController: _pageTransitionController),
      EmergencyContactsScreen(animationController: _pageTransitionController),
      NotificationsScreen(animationController: _pageTransitionController),
    ];

    // Start with forward animation
    _pageTransitionController.forward();

    // Apply system UI style
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

    // Reset and run animations
    _pageTransitionController.reset();

    setState(() {
      _selectedIndex = index;
      // Animate to the new page
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // Animated Background
            AnimatedBuilder(
              animation: _backgroundAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFE0F2F1),
                        const Color(0xFFE8F5E9),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background decorative elements
                      Positioned(
                        top: -100,
                        right: -100,
                        child: Transform.rotate(
                          angle: _backgroundAnimation.value,
                          child: Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  Colors.teal.withOpacity(0.1),
                                  Colors.teal.withOpacity(0.0),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: screenHeight * 0.3,
                        left: -150,
                        child: Transform.rotate(
                          angle: -_backgroundAnimation.value * 0.7,
                          child: Container(
                            width: 400,
                            height: 400,
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  Colors.green.withOpacity(0.05),
                                  Colors.green.withOpacity(0.0),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Main Content
            SafeArea(
              child: Column(
                children: [
                  // Enhanced header
                  _buildEnhancedHeader(),

                  // Main content with PageView for smooth transitions
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
            ),

            // Floating search bar that expands when tapped
            _buildFloatingSearchBar(),
          ],
        ),
        floatingActionButton: _buildAdvancedFAB(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _buildGlassmorphicBottomNavigation(),
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
                    'Hello, Alex',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      foreground:
                          Paint()
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
                      // Animated heart icon
                      AnimatedBuilder(
                        animation: _pulseAnimationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + _pulseAnimationController.value * 0.2,
                            child: Icon(
                              Icons.favorite,
                              color: Colors.redAccent.withOpacity(
                                0.7 + _pulseAnimationController.value * 0.3,
                              ),
                              size: 16,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),

              // Enhanced profile avatar with glow effect
              GestureDetector(
                onTap: () {
                  // Profile tap effect
                  HapticFeedback.lightImpact();
                  // Could navigate to profile details
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Animated glow effect
                    AnimatedBuilder(
                      animation: _pulseAnimationController,
                      builder: (context, child) {
                        return Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.teal.withOpacity(
                                  0.2 + 0.1 * _pulseAnimationController.value,
                                ),
                                Colors.transparent,
                              ],
                              stops: const [0.6, 1.0],
                            ),
                          ),
                        );
                      },
                    ),

                    // Profile picture with border
                    Hero(
                      tag: 'profileAvatar',
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.teal.shade300,
                              Colors.green.shade400,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),

                    // Online indicator
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Health stats summary - a new addition
          AnimatedBuilder(
            animation: _pageTransitionController,
            builder: (context, child) {
              return Opacity(
                opacity: _pageTransitionController.value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - _pageTransitionController.value)),
                  child: child,
                ),
              );
            },
            child: _buildHealthStatsSummary(),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStatsSummary() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildStatCard(
              icon: Icons.monitor_heart_outlined,
              value: '72',
              label: 'BPM',
              color: Colors.redAccent,
            ),
            _buildStatCard(
              icon: Icons.directions_walk_rounded,
              value: '5,432',
              label: 'Steps',
              color: Colors.blue,
            ),
            _buildStatCard(
              icon: Icons.local_fire_department_outlined,
              value: '1,240',
              label: 'Calories',
              color: Colors.orange,
            ),
            _buildStatCard(
              icon: Icons.nightlight_outlined,
              value: '7.5h',
              label: 'Sleep',
              color: Colors.indigo,
            ),
            _buildStatCard(
              icon: Icons.water_drop_outlined,
              value: '1.8L',
              label: 'Water',
              color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color.withOpacity(0.8),
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingSearchBar() {
    return Positioned(
      top: 186,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedBuilder(
          animation: _searchExpandController,
          builder: (context, child) {
            final width =
                _isSearchExpanded
                    ? MediaQuery.of(context).size.width * 0.95
                    : MediaQuery.of(context).size.width * 0.9;

            return Container(
              width: width,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _toggleSearch,
                      splashColor: Colors.teal.withOpacity(0.1),
                      highlightColor: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isSearchExpanded ? Icons.close : Icons.search,
                              color: Colors.teal.shade700,
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child:
                                  _isSearchExpanded
                                      ? TextFormField(
                                        autofocus: true,
                                        decoration: InputDecoration(
                                          hintText:
                                              'Search for health services',
                                          hintStyle: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.grey[400],
                                          ),
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      )
                                      : Text(
                                        'Search for health services',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                            ),
                            if (!_isSearchExpanded)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.mic,
                                  size: 16,
                                  color: Colors.teal.shade700,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
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
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            ),
          );
        },
      ),
    );
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    _buildAddOptionCard(
                      icon: Icons.medication_outlined,
                      title: 'Medication',
                      color: Colors.blue,
                    ),
                    _buildAddOptionCard(
                      icon: Icons.monitor_heart_outlined,
                      title: 'Health Data',
                      color: Colors.redAccent,
                    ),
                    _buildAddOptionCard(
                      icon: Icons.fitness_center_outlined,
                      title: 'Workout',
                      color: Colors.deepPurple,
                    ),
                    _buildAddOptionCard(
                      icon: Icons.local_dining_outlined,
                      title: 'Meal',
                      color: Colors.orange,
                    ),
                    _buildAddOptionCard(
                      icon: Icons.alarm_outlined,
                      title: 'Reminder',
                      color: Colors.teal,
                    ),
                    _buildAddOptionCard(
                      icon: Icons.person_add_outlined,
                      title: 'Contact',
                      color: Colors.green,
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

  Widget _buildAddOptionCard({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.pop(context);
        // Could navigate to respective creation screens
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

  Widget _buildGlassmorphicBottomNavigation() {
    return Container(
      height: 90,
      margin: const EdgeInsets.fromLTRB(6, 0, 6, 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.person_outline, 'Profile'),
                _buildNavItem(1, Icons.medication_outlined, 'Meds'),
                const SizedBox(width: 60), // Space for FAB
                _buildNavItem(3, Icons.emergency_outlined, 'Emergency'),
                _buildNavItem(4, Icons.notifications_outlined, 'Alerts'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        height: 90,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: isSelected ? 54 : 44,
          width: isSelected ? 90 : 80,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 16 : 12,
            vertical: isSelected ? 8 : 6,
          ),
          margin: EdgeInsets.only(
            top: isSelected ? 0 : 2,
            bottom: isSelected ? 2 : 0,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.teal.withOpacity(0.15)
                : Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected
                  ? Colors.teal.withOpacity(0.3)
                  : Colors.transparent,
              width: 1,
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: Colors.teal.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Animated Icon Container
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: EdgeInsets.all(isSelected ? 4 : 2),
                height: isSelected ? 24 : 20,
                width: isSelected ? 24 : 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Colors.teal.withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Colors.teal.shade700
                      : Colors.grey.shade500,
                  size: isSelected ? 22 : 18,
                ),
              ),
              const SizedBox(height: 6),
              // Animated Text
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                style: GoogleFonts.poppins(
                  color: isSelected
                      ? Colors.teal.shade700
                      : Colors.grey.shade500,
                  fontSize: isSelected ? 12 : 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: isSelected ? 0.5 : 0.2,
                  shadows: isSelected
                      ? [
                    Shadow(
                      color: Colors.teal.withOpacity(0.2),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ]
                      : [],
                ),
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Enhanced BaseScreen with more animation effects
class BaseScreen extends StatefulWidget {
  final String title;
  final IconData icon;
  final String description;
  final List<Widget> actionWidgets;
  final Color primaryColor;
  final Color secondaryColor;
  final AnimationController? animationController;

  const BaseScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
    this.actionWidgets = const [],
    this.primaryColor = const Color(0xFF2A9D8F),
    this.secondaryColor = const Color(0xFFE0F2F1),
    this.animationController,
  });

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _headerAnimation;
  late Animation<double> _contentAnimation;
  late Animation<double> _iconRotation;
  late Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();
    // Use provided controller or create new one
    _controller =
        widget.animationController ??
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1000),
        );

    _headerAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutQuint),
    );

    _contentAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutQuad),
    );

    _iconRotation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _iconScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.2), weight: 60),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 40),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    if (widget.animationController == null) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    if (widget.animationController == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Container(
      margin: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          // Header section with enhanced animation
          AnimatedBuilder(
            animation: _headerAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _headerAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - _headerAnimation.value)),
                  child: child,
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(20, isSmallScreen ? 10 : 20, 20, 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.primaryColor.withOpacity(0.2),
                    widget.secondaryColor.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryColor.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Animated icon
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _iconScale.value,
                        child: Transform.rotate(
                          angle: _iconRotation.value,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: widget.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.icon,
                              color: widget.primaryColor,
                              size: 28,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 15),
                  // Title and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: widget.primaryColor,
                          ),
                        ),
                        if (widget.description.isNotEmpty)
                          Text(
                            widget.description,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Action widgets
                  Row(children: widget.actionWidgets),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

}

// Profile Management Screen
class ProfileManagementScreen extends StatelessWidget {
  final AnimationController animationController;

  const ProfileManagementScreen({super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Profile Management',
      icon: Icons.person,
      description: 'Manage your health profile and preferences',
      primaryColor: Colors.teal.shade700,
      animationController: animationController,
      actionWidgets: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.teal),
          onPressed: () {
            // Edit profile action
            HapticFeedback.lightImpact();
          },
        ),
      ],
      // Override BaseScreen to provide custom content
    );
  }
}

// Medication Reminders Screen
class MedicationRemindersScreen extends StatelessWidget {
  final AnimationController animationController;

  const MedicationRemindersScreen({
    super.key,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Medication Reminders',
      icon: Icons.medication_outlined,
      description: 'Track and manage your medications',
      primaryColor: Colors.blue.shade700,
      animationController: animationController,
      actionWidgets: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
          onPressed: () {
            // Add medication action
            HapticFeedback.lightImpact();
          },
        ),
      ],
      // Override BaseScreen to provide custom content
    );
  }
}

// Goal Reminders Screen
class GoalRemindersScreen extends StatelessWidget {
  final AnimationController animationController;

  const GoalRemindersScreen({super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Health Goals',
      icon: Icons.flag_outlined,
      description: 'Set and track your health goals',
      primaryColor: Colors.deepPurple.shade600,
      animationController: animationController,
      actionWidgets: [
        IconButton(
          icon: const Icon(Icons.add_task, color: Colors.deepPurple),
          onPressed: () {
            // Add goal action
            HapticFeedback.lightImpact();
          },
        ),
      ],
      // Override BaseScreen to provide custom content
    );
  }
}

// Emergency Contacts Screen
class EmergencyContactsScreen extends StatelessWidget {
  final AnimationController animationController;

  const EmergencyContactsScreen({super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Emergency Contacts',
      icon: Icons.emergency_outlined,
      description: 'Manage your emergency contacts',
      primaryColor: Colors.redAccent.shade700,
      animationController: animationController,
      actionWidgets: [
        IconButton(
          icon: const Icon(Icons.person_add_outlined, color: Colors.redAccent),
          onPressed: () {
            // Add contact action
            HapticFeedback.lightImpact();
          },
        ),
      ],
      // Override BaseScreen to provide custom content
    );
  }
}

// Notifications Screen
class NotificationsScreen extends StatelessWidget {
  final AnimationController animationController;

  const NotificationsScreen({super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Notifications',
      icon: Icons.notifications_outlined,
      description: 'Manage your health alerts',
      primaryColor: Colors.amber.shade700,
      animationController: animationController,
      actionWidgets: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.amber),
          onPressed: () {
            // Notification settings action
            HapticFeedback.lightImpact();
          },
        ),
      ],
      // Override BaseScreen to provide custom content
    );
  }
}
