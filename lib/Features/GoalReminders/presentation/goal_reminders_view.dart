import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';

const Color kBaseColor = Colors.teal;

class GoalRemindersScreen extends StatefulWidget {
  final AnimationController animationController;

  const GoalRemindersScreen({super.key, required this.animationController});

  @override
  _GoalRemindersScreenState createState() => _GoalRemindersScreenState();
}

class _GoalRemindersScreenState extends State<GoalRemindersScreen> {
  late List<HealthGoal> _healthGoals;
  final TextEditingController _goalTitleController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();

  GoalCategory? _selectedCategory;
  GoalDuration _selectedDuration = GoalDuration.daily;

  @override
  void initState() {
    super.initState();
    _healthGoals = [
      HealthGoal(
        title: 'Daily Step Count',
        target: 10000,
        icon: Iconsax.activity,
        color: Colors.blue,
        category: GoalCategory.fitness,
        duration: GoalDuration.daily,
        currentProgress: 7500,
      ),
      HealthGoal(
        title: 'Meditation Practice',
        target: 30,
        icon: Iconsax.moon,
        color: Colors.purple,
        category: GoalCategory.mentalHealth,
        duration: GoalDuration.daily,
        currentProgress: 20,
      ),
      HealthGoal(
        title: 'Hydration Tracking',
        target: 2.5,
        icon: Iconsax.drop,
        color: Colors.teal,
        category: GoalCategory.wellness,
        duration: GoalDuration.daily,
        currentProgress: 1.8,
      ),
    ];
  }

  @override
  void dispose() {
    _goalTitleController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _showAddGoalBottomSheet() {
    _goalTitleController.clear();
    _targetController.clear();
    _selectedCategory = null;
    _selectedDuration = GoalDuration.daily;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Create New Goal',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kBaseColor,
                  ),
                ),
                const SizedBox(height: 24),

                // Goal Title
                Text(
                  'Goal Title',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _goalTitleController,
                  decoration: _inputDecoration('Enter goal title'),
                ),
                const SizedBox(height: 20),

                // Target Value
                Text(
                  'Target Value',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _targetController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(
                    _selectedDuration == GoalDuration.daily
                        ? 'Number of days'
                        : 'Number of months',
                  ),
                ),
                const SizedBox(height: 20),

                // Category Selection
                Text(
                  'Category',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: GoalCategory.values.map((category) {
                    final isSelected = _selectedCategory == category;
                    return ChoiceChip(
                      label: Text(
                        category.displayName,
                        style: GoogleFonts.poppins(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category : null;
                        });
                      },
                      selectedColor: kBaseColor,
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Duration Selection
                Text(
                  'Duration',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Text(
                          'Daily',
                          style: GoogleFonts.poppins(
                            color: _selectedDuration == GoalDuration.daily
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        selected: _selectedDuration == GoalDuration.daily,
                        onSelected: (selected) {
                          setState(() {
                            _selectedDuration = GoalDuration.daily;
                          });
                        },
                        selectedColor: kBaseColor,
                        backgroundColor: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: Text(
                          'Monthly',
                          style: GoogleFonts.poppins(
                            color: _selectedDuration == GoalDuration.monthly
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        selected: _selectedDuration == GoalDuration.monthly,
                        onSelected: (selected) {
                          setState(() {
                            _selectedDuration = GoalDuration.monthly;
                          });
                        },
                        selectedColor: kBaseColor,
                        backgroundColor: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Create Goal Button
                ElevatedButton(
                  onPressed: () {
                    if (_validateInputs()) {
                      _addNewGoal();
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBaseColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Create Goal',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _validateInputs() {
    if (_goalTitleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a goal title',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_targetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a target value',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a category',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  void _addNewGoal() {
    final newGoal = HealthGoal(
      title: _goalTitleController.text,
      target: double.parse(_targetController.text),
      icon: _getIconForCategory(_selectedCategory!),
      color: _getColorForCategory(_selectedCategory!),
      category: _selectedCategory!,
      duration: _selectedDuration,
      currentProgress: 0,
    );

    setState(() {
      _healthGoals.add(newGoal);
    });
  }

  IconData _getIconForCategory(GoalCategory category) {
    switch (category) {
      case GoalCategory.fitness:
        return Iconsax.activity;
      case GoalCategory.mentalHealth:
        return Iconsax.moon;
      case GoalCategory.wellness:
        return Iconsax.health;
    }
  }

  MaterialColor _getColorForCategory(GoalCategory category) {
    switch (category) {
      case GoalCategory.fitness:
        return Colors.blue;
      case GoalCategory.mentalHealth:
        return Colors.purple;
      case GoalCategory.wellness:
        return Colors.teal;
    }
  }

  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }

  Widget _buildGoalCard(HealthGoal goal) {
    double progressPercentage = (goal.currentProgress / goal.target) * 100;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: goal.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(goal.icon, color: goal.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          goal.category.displayName,
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: kBaseColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      goal.duration.displayName,
                      style: GoogleFonts.poppins(
                        color: kBaseColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progressPercentage / 100,
                backgroundColor: goal.color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(goal.color),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${goal.currentProgress.toStringAsFixed(1)} / ${goal.target}',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[700],
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${progressPercentage.toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(
                      color: goal.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildGoalCard(_healthGoals[index]),
              childCount: _healthGoals.length,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalBottomSheet,
        backgroundColor: kBaseColor,
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
    );
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

enum GoalDuration {
  daily,
  monthly;

  String get displayName {
    switch (this) {
      case GoalDuration.daily:
        return 'Daily';
      case GoalDuration.monthly:
        return 'Monthly';
    }
  }
}

class HealthGoal {
  final String title;
  final double target;
  final IconData icon;
  final MaterialColor color;
  final GoalCategory category;
  final GoalDuration duration;
  final double currentProgress;

  HealthGoal({
    required this.title,
    required this.target,
    required this.icon,
    required this.color,
    required this.category,
    required this.duration,
    this.currentProgress = 0,
  });
}