import 'package:blood_pressure_app/Features/HealthDataInput/manger/health_records_cubit.dart';
import 'package:blood_pressure_app/Features/Profile/Presentation/Profile_view.dart';
import 'package:blood_pressure_app/core/Utils/Shared%20Methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Authentication/Data/User_Model.dart';
import '../../Emergency Contacts/Presentation/Emergency_Contacts_View.dart';
import '../../Emergency Contacts/Presentation/manger/emergency_cubit.dart';
import '../../GoalReminders/presentation/View/goal_reminders_view.dart';
import '../../HealthDataAnalysis/Presentation/health_data_analysis_view.dart';
import '../../Home/Presentation/Home_View.dart';
import '../../MedicationReminders/Presentation/medication_reminders_view.dart';
import '../../Notifications/Presentation/notifications_view.dart';
import '../../HealthDataInput/Presentation/health_data_input_view.dart';

// User state management
class UserStateCubit extends Cubit<UserState> {
  final String uid;

  UserStateCubit({required this.uid}) : super(UserInitial()) {
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (uid.isEmpty) {
      emit(UserError('User ID is empty'));
      return;
    }

    try {
      emit(UserLoading());

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        emit(UserError('User not found'));
        return;
      }

      // Update user data
      final userData = userDoc.data() as Map<String, dynamic>;
      final userModel = UserModel.fromJson(userData);

      // Calculate BMI and BMR
      double height = userModel.height ?? 180; // Default height is 180 cm
      double weight = userModel.weight ?? 80; // Default weight is 80 kg
      String gender = userModel.gender ?? 'Male'; // Default gender is Male
      DateTime dateOfBirth = DateTime.parse(userModel.dateOfBirth.toString() ?? '1990-01-01T00:00:00.000');
      int age = DateTime.now().year - dateOfBirth.year;

      if (DateTime.now().month < dateOfBirth.month ||
          (DateTime.now().month == dateOfBirth.month && DateTime.now().day < dateOfBirth.day)) {
        age--;
      }

      double bmi = calculateBMI(weight, height);
      double bmr = calculateBMR(weight, height, age, gender);

      // Create userStats map
      final userStats = {
        'height': height,
        'weight': weight,
        'age': age,
        'gender': gender,
        'bmi': bmi,
        'bmr': bmr,
      };

      // Update last active timestamp
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({
        'lastActive': DateTime.now().toIso8601String(),
      });

      emit(UserLoaded(userModel: userModel, userStats: userStats));
    } catch (e) {
      emit(UserError('Failed to load user data: ${e.toString()}'));
    }
  }

  double calculateBMI(double weight, double height) {
    // Calculate BMI and round to 1 decimal place
    double bmi = weight / ((height / 100) * (height / 100));
    return double.parse(bmi.toStringAsFixed(1));
  }

  double calculateBMR(double weight, double height, int age, String gender) {
    double bmr;
    if (gender.toLowerCase() == 'male') {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }
    // Round BMR to the nearest whole number since calories are typically shown as integers
    return double.parse(bmr.toStringAsFixed(0));
  }
}

// User states
abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserModel userModel;
  final Map<String, dynamic> userStats;

  UserLoaded({required this.userModel, required this.userStats});
}

class UserError extends UserState {
  final String message;

  UserError(this.message);
}

// Tab state management
class TabCubit extends Cubit<int> {
  TabCubit() : super(0);

  void changeTab(int index) => emit(index);
}

class TabScreen extends StatefulWidget {
  final String uid;
  const TabScreen({super.key, required this.uid});

  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> with TickerProviderStateMixin {
  bool _isSearchExpanded = false;
  bool _isRefreshing = false;
  late AnimationController _pageTransitionController;
  late AnimationController _searchExpandController;
  late AnimationController _backgroundAnimationController;
  late Animation<double> _backgroundAnimation;

  // Scroll controller for bottom navigation
  final ScrollController _navScrollController = ScrollController();

  // Global key for refresh indicator
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

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
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 30000),
    )..repeat();
    _backgroundAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_backgroundAnimationController);

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
    _navScrollController.dispose();
    super.dispose();
  }

  // Scroll to the selected tab in bottom navigation
  void _scrollToSelectedTab(int index) {
    if (_navScrollController.hasClients) {
      // Calculate approximate position of selected tab
      double screenWidth = MediaQuery.of(context).size.width;
      // Adjust tab width based on screen size for better responsiveness
      double tabWidth = screenWidth < 600 ? screenWidth / 4 : screenWidth / 6;
      double scrollOffset = (index * tabWidth) - (tabWidth * 1.5);
      _navScrollController.animateTo(
        scrollOffset.clamp(0, _navScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuad,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserStateCubit(uid: widget.uid),
        ),
        BlocProvider(
          create: (context) => TabCubit(),
        ),
        BlocProvider(
          create: (context) => EmergencyContactsCubit()..loadContacts(),
        ),
        BlocProvider(
          create: (context) => HealthDataCubit(),
        ),
      ],
      child: BlocBuilder<TabCubit, int>(
        builder: (context, selectedIndex) {
          // Auto-scroll to the selected tab on index changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToSelectedTab(selectedIndex);
          });

          return _buildScaffold(context, selectedIndex);
        },
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, int selectedIndex) {
    // Get screen dimensions for responsive layout
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final orientation = mediaQuery.orientation;
    final devicePixelRatio = mediaQuery.devicePixelRatio;

    // Responsive breakpoints
    final isExtraSmallScreen = screenWidth < 320;
    final isSmallScreen = screenWidth < 360 && !isExtraSmallScreen;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final isDesktop = screenWidth >= 900;

    // Landscape mode detection
    final isLandscape = orientation == Orientation.landscape;

    // Calculate responsive scale factors
    final baseFontScale = isExtraSmallScreen ? 0.7
        : isSmallScreen ? 0.8
        : isMediumScreen ? 1.0
        : isTablet ? 1.2
        : 1.4;

    // Apply landscape adjustments if needed
    final fontScale = isLandscape && !isDesktop ? baseFontScale * 0.9 : baseFontScale;
    final spacingScale = isLandscape && !isDesktop ? 0.8 : 1.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: () => _handleRefresh(context),
          color: Colors.teal,
          backgroundColor: Colors.white,
          strokeWidth: 3.0,
          displacement: 40.0,
          edgeOffset: 20.0,
          child: SafeArea(
            child: Column(
              children: [
                _buildEnhancedHeader(
                  context,
                  isExtraSmallScreen,
                  isSmallScreen,
                  fontScale,
                  isLandscape,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: _buildSelectedScreen(context, selectedIndex),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildModernBottomNavigation(
          context,
          selectedIndex,
          isExtraSmallScreen,
          isSmallScreen,
          isTablet,
          isLandscape,
          fontScale,
          spacingScale,
        ),
        floatingActionButton: _isRefreshing
            ? FloatingActionButton(
          mini: true,
          onPressed: () {},
          backgroundColor: Colors.teal.withOpacity(0.8),
          child: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
        )
            : null,
      ),
    );
  }

  Widget _buildSelectedScreen(BuildContext context, int selectedIndex) {
    return BlocBuilder<UserStateCubit, UserState>(
      builder: (context, state) {
        if (state is UserLoading && selectedIndex == 0) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.teal,
            ),
          );
        }

        // Get userStats from the state if available, otherwise use empty map
        Map<String, dynamic> userStats = {};
        if (state is UserLoaded) {
          userStats = state.userStats;
        }

        switch (selectedIndex) {
          case 0:
            return state is UserError
                ? Center(child: Text('Error: ${state.message}'))
                : HomeView(
              animationController: _pageTransitionController,
              userStats: userStats,
            );
          case 1:
            return MedicationRemindersScreen(animationController: _pageTransitionController);
          case 2:
            return GoalRemindersScreen(userId: widget.uid);
          case 3:
            return HealthDataInputScreen(animationController: _pageTransitionController);
          case 4:
            return HealthDataAnalysisScreen(animationController: _pageTransitionController);
          case 5:
            return EmergencyContactsScreen();
          case 6:
            return NotificationsScreen(animationController: _pageTransitionController);
          default:
            return Container();
        }
      },
    );
  }

  Future<void> _handleRefresh(BuildContext context) async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      await context.read<UserStateCubit>().fetchUserData();
      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data refreshed successfully'),
          backgroundColor: Colors.teal,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // Show error snackbar if refresh fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh data: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Widget _buildEnhancedHeader(
      BuildContext context,
      bool isExtraSmallScreen,
      bool isSmallScreen,
      double fontScale,
      bool isLandscape,
      ) {
    return BlocBuilder<UserStateCubit, UserState>(
      builder: (context, state) {
        // Determine user name and loading state
        String userName = 'User';
        bool isLoading = false;
        String? errorMessage;

        if (state is UserLoading) {
          isLoading = true;
        } else if (state is UserError) {
          errorMessage = state.message;
        } else if (state is UserLoaded) {
          userName = state.userModel.name ?? 'User';
        }

        // Adjust header height based on landscape mode
        final headerPaddingVertical = isLandscape ? 5.0 : 10.0;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            16 * fontScale,
            headerPaddingVertical * fontScale,
            16 * fontScale,
            5 * fontScale,
          ),
          margin: EdgeInsets.only(bottom: 5 * fontScale),
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
                            Expanded(
                              child: Text(
                                isLoading
                                    ? 'Loading...'
                                    : errorMessage != null
                                    ? 'Hello, User'
                                    : 'Hello, $userName',
                                style: GoogleFonts.poppins(
                                  fontSize: (isExtraSmallScreen ? 16 : (isSmallScreen ? 20 : 23)) * fontScale,
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
                            ),
                            IconButton(
                              onPressed: () {
                                navigateTo(
                                  context,
                                  ProfileScreen(uid: widget.uid),
                                );
                              },
                              icon: Icon(
                                Iconsax.user,
                                color: Colors.teal,
                                size: 24 * fontScale,
                              ),
                              padding: EdgeInsets.all(8 * fontScale),
                              constraints: BoxConstraints(
                                minWidth: 40 * fontScale,
                                minHeight: 40 * fontScale,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _refreshIndicatorKey.currentState?.show();
                              },
                              icon: Icon(
                                Iconsax.refresh,
                                color: Colors.teal,
                                size: 24 * fontScale,
                              ),
                              padding: EdgeInsets.all(8 * fontScale),
                              constraints: BoxConstraints(
                                minWidth: 40 * fontScale,
                                minHeight: 40 * fontScale,
                              ),
                              tooltip: 'Refresh data',
                            ),
                          ],
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _getGreeting(isLoading, errorMessage),
                            style: GoogleFonts.poppins(
                              fontSize: (isExtraSmallScreen ? 12 : (isSmallScreen ? 14 : 16)) * fontScale,
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
              SizedBox(height: 5 * fontScale),
            ],
          ),
        );
      },
    );
  }

  String _getGreeting(bool isLoading, String? errorMessage) {
    if (isLoading) {
      return "Loading...";
    }
    if (errorMessage != null) {
      return "Stay healthy today";
    }
    // Personalized greeting based on time of day
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good morning, have a great day!";
    } else if (hour < 17) {
      return "Good afternoon, stay healthy!";
    } else {
      return "Good evening, rest well!";
    }
  }

  Widget _buildModernBottomNavigation(
      BuildContext context,
      int selectedIndex,
      bool isExtraSmallScreen,
      bool isSmallScreen,
      bool isTablet,
      bool isLandscape,
      double fontScale,
      double spacingScale,
      ) {
    final horizontalMargin = isLandscape
        ? (isExtraSmallScreen ? 4 : (isSmallScreen ? 6 : 8)) * spacingScale
        : (isExtraSmallScreen ? 6 : (isSmallScreen ? 8 : 16)) * spacingScale;
    final verticalMargin = isLandscape
        ? (isExtraSmallScreen ? 4 : (isSmallScreen ? 6 : 8)) * spacingScale
        : (isExtraSmallScreen ? 6 : (isSmallScreen ? 8 : 16)) * spacingScale;

    return Container(
      height: 60,
      margin: EdgeInsets.symmetric(
        horizontal: horizontalMargin,
        vertical: verticalMargin,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(
            isExtraSmallScreen ? 25 : 40
        ),
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
            horizontal: (isExtraSmallScreen ? 4 : 8) * spacingScale,
            vertical: (isExtraSmallScreen ? 2 : 0) * spacingScale,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildModernNavItem(
                context,
                0,
                Iconsax.home,
                'Home',
                selectedIndex,
                isExtraSmallScreen,
                isSmallScreen,
                fontScale,
                spacingScale,
                isLandscape,
              ),
              _buildModernNavItem(
                context,
                1,
                FontAwesomeIcons.pills,
                'Meds',
                selectedIndex,
                isExtraSmallScreen,
                isSmallScreen,
                fontScale,
                spacingScale,
                isLandscape,
              ),
              _buildModernNavItem(
                context,
                2,
                Iconsax.activity,
                'Goals',
                selectedIndex,
                isExtraSmallScreen,
                isSmallScreen,
                fontScale,
                spacingScale,
                isLandscape,
              ),
              _buildModernNavItem(
                context,
                3,
                Iconsax.chart,
                'Input',
                selectedIndex,
                isExtraSmallScreen,
                isSmallScreen,
                fontScale,
                spacingScale,
                isLandscape,
              ),
              _buildModernNavItem(
                context,
                4,
                Iconsax.graph,
                'Analysis',
                selectedIndex,
                isExtraSmallScreen,
                isSmallScreen,
                fontScale,
                spacingScale,
                isLandscape,
              ),
              _buildModernNavItem(
                context,
                5,
                Iconsax.call,
                'Emergency',
                selectedIndex,
                isExtraSmallScreen,
                isSmallScreen,
                fontScale,
                spacingScale,
                isLandscape,
              ),
              _buildModernNavItem(
                context,
                6,
                Iconsax.notification,
                'Alerts',
                selectedIndex,
                isExtraSmallScreen,
                isSmallScreen,
                fontScale,
                spacingScale,
                isLandscape,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernNavItem(
      BuildContext context,
      int index,
      IconData icon,
      String label,
      int selectedIndex,
      bool isExtraSmallScreen,
      bool isSmallScreen,
      double fontScale,
      double spacingScale,
      bool isLandscape,
      ) {
    final isSelected = selectedIndex == index;
    // Adjust text for landscape mode (shorter label if needed)
    String displayLabel = label;
    if (isLandscape && label == 'Emergency') {
      displayLabel = 'SOS';
    } else if (isLandscape && label == 'Analysis') {
      displayLabel = 'Stats';
    }

    return GestureDetector(
      onTap: () => context.read<TabCubit>().changeTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: EdgeInsets.symmetric(
          horizontal: (isExtraSmallScreen ? 2 : (isSmallScreen ? 3 : 6)) * spacingScale,
          vertical: (isExtraSmallScreen ? 2 : 0) * spacingScale,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: (isExtraSmallScreen ? 6 : (isSmallScreen ? 8 : 12)) * spacingScale,
          vertical: (isExtraSmallScreen ? 4 : (isSmallScreen ? 6 : 8)) * spacingScale,
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
              size: (isExtraSmallScreen ? 16 : (isSmallScreen ? 18 : 22)) * fontScale,
            ),
            if (isSelected) ...[
              SizedBox(width: (isExtraSmallScreen ? 3 : (isSmallScreen ? 4 : 8)) * fontScale),
              Text(
                displayLabel,
                style: GoogleFonts.poppins(
                  color: Colors.teal.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: (isExtraSmallScreen ? 10 : (isSmallScreen ? 12 : 14)) * fontScale,
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