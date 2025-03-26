import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';

class GoalRemindersScreen extends StatefulWidget {
  final AnimationController animationController;

  const GoalRemindersScreen({super.key, required this.animationController});

  @override
  _GoalRemindersScreenState createState() => _GoalRemindersScreenState();
}

class _GoalRemindersScreenState extends State<GoalRemindersScreen> with SingleTickerProviderStateMixin {
  final List<String> _predefinedGoals = [
    'Blood Pressure Control',
    'Medication Adherence',
    'Blood Sugar Management',
    'Daily Step Count',
    'Sleep Quality',
    'Hydration Tracking',
    'Weight Management',
    'Mental Health Check-in',
    'Cardio Fitness',
    'Strength Training',
    'Nutrition Balance',
    'Stress Reduction',
    'Meditation Practice',
    'Water Intake',
  ];

  late List<HealthGoal> _healthGoals;
  late List<HealthGoal> _previousGoals;

  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String? _selectedGoalTitle;
  GoalCategory? _selectedCategory;
  ActivityType? _selectedActivityType;
  GoalDuration _selectedDuration = GoalDuration.daily;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    _healthGoals = [
      HealthGoal(
        title: 'Daily Step Count',
        target: 10000,
        icon: Iconsax.activity,
        color: Colors.blue,
        category: GoalCategory.fitness,
        activityType: ActivityType.exercise,
        duration: GoalDuration.daily,
        currentProgress: 7500,
        status: GoalStatus.inProgress,
      ),
      HealthGoal(
        title: 'Meditation Practice',
        target: 30,
        icon: Iconsax.moon,
        color: Colors.purple,
        category: GoalCategory.mentalHealth,
        activityType: ActivityType.mindfulness,
        duration: GoalDuration.daily,
        currentProgress: 20,
        status: GoalStatus.inProgress,
      ),
      HealthGoal(
        title: 'Hydration Tracking',
        target: 2.5,
        icon: Iconsax.map,
        color: Colors.teal,
        category: GoalCategory.wellness,
        activityType: ActivityType.hydration,
        duration: GoalDuration.daily,
        currentProgress: 1.8,
        status: GoalStatus.inProgress,
      ),
    ];

    _previousGoals = [
      HealthGoal(
        title: 'Weight Management',
        target: 75.0,
        icon: Iconsax.chart,
        color: Colors.green,
        category: GoalCategory.fitness,
        activityType: ActivityType.exercise,
        duration: GoalDuration.monthly,
        completedDate: DateTime(2024, 2, 15),
        status: GoalStatus.completed,
      ),
      HealthGoal(
        title: 'Blood Sugar Management',
        target: 120,
        icon: Iconsax.health,
        color: Colors.red,
        category: GoalCategory.wellness,
        activityType: ActivityType.diet,
        duration: GoalDuration.weekly,
        completedDate: DateTime(2024, 3, 10),
        status: GoalStatus.abandoned,
      ),
    ];
  }

  @override
  void dispose() {
    _targetController.dispose();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _showAddGoalBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New Goal',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedGoalTitle,
                hint: Text('Select Goal', style: GoogleFonts.poppins()),
                items: _predefinedGoals.map((goal) {
                  return DropdownMenuItem(
                    value: goal,
                    child: Text(goal, style: GoogleFonts.poppins(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGoalTitle = value;
                  });
                },
                decoration: _inputDecoration('Goal Title'),
                dropdownColor: Colors.white,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _targetController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Target Value'),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<GoalCategory>(
                value: _selectedCategory,
                hint: Text('Select Category', style: GoogleFonts.poppins()),
                items: GoalCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.displayName, style: GoogleFonts.poppins(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                decoration: _inputDecoration('Category'),
                dropdownColor: Colors.white,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<GoalDuration>(
                value: _selectedDuration,
                items: GoalDuration.values.map((duration) {
                  return DropdownMenuItem(
                    value: duration,
                    child: Text(duration.displayName, style: GoogleFonts.poppins(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDuration = value!;
                  });
                },
                decoration: _inputDecoration('Duration'),
                dropdownColor: Colors.white,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addNewGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  'Create Goal',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _addNewGoal() {
    if (_selectedGoalTitle != null && _targetController.text.isNotEmpty) {
      final newGoal = HealthGoal(
        title: _selectedGoalTitle!,
        target: double.parse(_targetController.text),
        icon: _getIconForGoal(_selectedGoalTitle!),
        color: _getColorForCategory(_selectedCategory),
        category: _selectedCategory ?? GoalCategory.wellness,
        activityType: _selectedActivityType ?? ActivityType.general,
        duration: _selectedDuration,
        currentProgress: 0,
        status: GoalStatus.inProgress,
      );

      setState(() {
        _healthGoals.add(newGoal);
      });

      _selectedGoalTitle = null;
      _targetController.clear();
      _selectedCategory = null;
      _selectedDuration = GoalDuration.daily;

      Navigator.pop(context);
    }
  }

  IconData _getIconForGoal(String goalTitle) {
    switch (goalTitle) {
      case 'Daily Step Count':
        return Iconsax.activity;
      case 'Meditation Practice':
        return Iconsax.moon;
      case 'Hydration Tracking':
        return Iconsax.money;
      case 'Blood Pressure Control':
        return Iconsax.health;
      default:
        return Iconsax.chart;
    }
  }

  MaterialColor _getColorForCategory(GoalCategory? category) {
    switch (category) {
      case GoalCategory.fitness:
        return Colors.blue;
      case GoalCategory.mentalHealth:
        return Colors.purple;
      case GoalCategory.wellness:
        return Colors.teal;
      default:
        return Colors.deepPurple;
    }
  }

  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: GoogleFonts.poppins(),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.deepPurple),
      ),
    );
  }

  Widget _buildGoalCard(HealthGoal goal) {
    double progressPercentage = goal.currentProgress != null && goal.target > 0
        ? (goal.currentProgress! / goal.target) * 100
        : 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: goal.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(goal.icon, color: goal.color),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      goal.title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${goal.duration.displayName} Goal',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progressPercentage / 100,
              backgroundColor: goal.color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(goal.color),
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress: ${goal.currentProgress?.toStringAsFixed(1) ?? '0'} / ${goal.target}',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${progressPercentage.toStringAsFixed(0)}%',
                  style: GoogleFonts.poppins(
                    color: goal.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNarrowScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header Section - Modified for View Goals
          SliverToBoxAdapter(
            child: FadeInDown(
              duration: Duration(milliseconds: 500),
              child: Container(
                margin: EdgeInsets.all(isNarrowScreen ? 10 : 20),
                padding: EdgeInsets.all(isNarrowScreen ? 15 : 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.withOpacity(0.2),
                      Colors.white.withOpacity(0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.chart,
                        color: Colors.deepPurple.shade700,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'View Goals',
                            style: GoogleFonts.poppins(
                              fontSize: isNarrowScreen ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple.shade700,
                            ),
                          ),
                          Text(
                            'Track and manage your health goals',
                            style: GoogleFonts.poppins(
                              fontSize: isNarrowScreen ? 10 : 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tab Bar Section
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.deepPurple,
                labelColor: Colors.deepPurple,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: 'Current Goals'),
                  Tab(text: 'Previous Goals'),
                ],
              ),
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(const Duration(seconds: 1));
                    setState(() {});
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(15),
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search goals...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onChanged: (value) {
                          // Implement search functionality
                        },
                      ),
                      const SizedBox(height: 15),
                      ..._healthGoals.map(_buildGoalCard).toList(),
                    ],
                  ),
                ),
                ListView(
                  padding: const EdgeInsets.all(15),
                  children: [
                    ..._previousGoals.map((goal) => _buildGoalCard(goal)).toList(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalBottomSheet,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

enum GoalCategory {
  fitness,
  mentalHealth,
  wellness;

  String get displayName {
    switch (this) {
      case GoalCategory.fitness:
        return 'Fitness';
      case GoalCategory.mentalHealth:
        return 'Mental Health';
      case GoalCategory.wellness:
        return 'Wellness';
    }
  }
}

enum ActivityType {
  exercise,
  mindfulness,
  hydration,
  diet,
  general;

  String get displayName {
    switch (this) {
      case ActivityType.exercise:
        return 'Exercise';
      case ActivityType.mindfulness:
        return 'Mindfulness';
      case ActivityType.hydration:
        return 'Hydration';
      case ActivityType.diet:
        return 'Diet';
      case ActivityType.general:
        return 'General';
    }
  }
}

enum GoalDuration {
  daily,
  weekly,
  monthly;

  String get displayName {
    switch (this) {
      case GoalDuration.daily:
        return 'Daily';
      case GoalDuration.weekly:
        return 'Weekly';
      case GoalDuration.monthly:
        return 'Monthly';
    }
  }
}

enum GoalStatus {
  inProgress,
  completed,
  abandoned;
}

class HealthGoal {
  final String title;
  final double target;
  final IconData icon;
  final MaterialColor color;
  final GoalCategory category;
  final ActivityType activityType;
  final GoalDuration duration;
  final double? currentProgress;
  final DateTime? completedDate;
  final GoalStatus status;

  HealthGoal({
    required this.title,
    required this.target,
    required this.icon,
    required this.color,
    required this.category,
    required this.activityType,
    required this.duration,
    this.currentProgress,
    this.completedDate,
    this.status = GoalStatus.inProgress,
  });
}