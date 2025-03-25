import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class GoalRemindersScreen extends StatefulWidget {
  final AnimationController animationController;

  const GoalRemindersScreen({super.key, required this.animationController});

  @override
  _GoalRemindersScreenState createState() => _GoalRemindersScreenState();
}

class _GoalRemindersScreenState extends State<GoalRemindersScreen> with SingleTickerProviderStateMixin {
  late AnimationController _goalAnimationController;

  // Expanded list of health goals with more categories
  final List<HealthGoal> _healthGoals = [
    HealthGoal(
      title: 'Daily Steps',
      target: 10000,
      current: 6542,
      icon: Iconsax.activity,
      color: Colors.blue,
      category: GoalCategory.fitness,
    ),
    HealthGoal(
      title: 'Water Intake',
      target: 8,
      current: 5,
      icon: Iconsax.activity1,
      color: Colors.teal,
      unit: 'glasses',
      category: GoalCategory.nutrition,
    ),
    HealthGoal(
      title: 'Meditation',
      target: 30,
      current: 15,
      icon: Iconsax.message,
      color: Colors.purple,
      unit: 'mins',
      category: GoalCategory.mentalHealth,
    ),
    HealthGoal(
      title: 'Sleep Hours',
      target: 8,
      current: 6.5,
      icon: Iconsax.moon,
      color: Colors.indigo,
      unit: 'hrs',
      category: GoalCategory.wellness,
    ),
  ];

  // Goal categories for filtering and organization
  final List<GoalCategory> _selectedCategories = [];

  // Text controllers for goal creation/editing
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _currentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _goalAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _goalAnimationController.dispose();
    _titleController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  // Method to add a new goal
  void _addNewGoal() {
    final newGoal = HealthGoal(
      title: _titleController.text,
      target: double.parse(_targetController.text),
      current: double.parse(_currentController.text),
      icon: Iconsax.chart, // Default icon, could be made customizable
      color: Colors.orange, // Could be randomly selected or user-picked
      category: GoalCategory.values.first, // Default category
    );

    setState(() {
      _healthGoals.add(newGoal);
    });

    // Clear controllers and close modal
    _titleController.clear();
    _targetController.clear();
    _currentController.clear();
    Navigator.of(context).pop();
  }

  // Method to edit an existing goal
  void _editGoal(HealthGoal goal) {
    setState(() {
      final index = _healthGoals.indexOf(goal);
      _healthGoals[index] = goal.copyWith(
        title: _titleController.text.isNotEmpty ? _titleController.text : goal.title,
        target: _targetController.text.isNotEmpty
            ? double.parse(_targetController.text)
            : goal.target,
        current: _currentController.text.isNotEmpty
            ? double.parse(_currentController.text)
            : goal.current,
      );
    });

    // Clear controllers and close modal
    _titleController.clear();
    _targetController.clear();
    _currentController.clear();
    Navigator.of(context).pop();
  }

  // Filter goals by category
  List<HealthGoal> _filterGoals() {
    if (_selectedCategories.isEmpty) return _healthGoals;
    return _healthGoals.where((goal) =>
        _selectedCategories.contains(goal.category)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredGoals = _filterGoals();

    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: GoalCategory.values.map((category) {
                    final isSelected = _selectedCategories.contains(category);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(
                          category.displayName,
                          style: GoogleFonts.poppins(
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: Colors.deepPurple,
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              _selectedCategories.add(category);
                            } else {
                              _selectedCategories.remove(category);
                            }
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Goals List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Health Goals',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple.shade700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.add_circle, color: Colors.deepPurple),
                    onPressed: () => _showGoalModal(null),
                  ),
                ],
              ),
            ),

            // Conditional rendering for goals
            filteredGoals.isEmpty
                ? _buildEmptyStateWidget()
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredGoals.length,
              itemBuilder: (context, index) {
                return _buildGoalProgressCard(filteredGoals[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Empty state widget when no goals are present
  Widget _buildEmptyStateWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.chart,
            size: 100,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          Text(
            'No Goals Yet',
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Tap + to create your first health goal',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // Goal progress card widget
  Widget _buildGoalProgressCard(HealthGoal goal) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            goal.color.withOpacity(0.1),
            goal.color.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: goal.color.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: goal.color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            goal.icon,
            color: goal.color,
            size: 28,
          ),
        ),
        title: Text(
          goal.title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: goal.color.shade700,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            LinearPercentIndicator(
              barRadius: const Radius.circular(10),
              lineHeight: 10,
              percent: goal.progress,
              progressColor: goal.color,
              backgroundColor: goal.color.withOpacity(0.3),
              animation: true,
            ),
            const SizedBox(height: 10),
            Text(
              '${goal.current.toStringAsFixed(1)} / ${goal.target.toStringAsFixed(1)} ${goal.unit}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Iconsax.edit,
            color: goal.color,
          ),
          onPressed: () => _showGoalModal(goal),
        ),
      ),
    );
  }

  // Unified modal for adding and editing goals
  void _showGoalModal(HealthGoal? existingGoal) {
    // Pre-fill controllers if editing an existing goal
    if (existingGoal != null) {
      _titleController.text = existingGoal.title;
      _targetController.text = existingGoal.target.toString();
      _currentController.text = existingGoal.current.toString();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              existingGoal == null ? 'Add New Goal' : 'Edit Goal',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Goal Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _targetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Target Value',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _currentController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Current Value',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                if (existingGoal == null) {
                  _addNewGoal();
                } else {
                  _editGoal(existingGoal);
                }
              },
              child: Text(
                existingGoal == null ? 'Create Goal' : 'Update Goal',
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
    );
  }
}

// Enum for goal categories
enum GoalCategory {
  fitness,
  nutrition,
  mentalHealth,
  wellness;

  // Getter for display name
  String get displayName {
    switch (this) {
      case GoalCategory.fitness:
        return 'Fitness';
      case GoalCategory.nutrition:
        return 'Nutrition';
      case GoalCategory.mentalHealth:
        return 'Mental Health';
      case GoalCategory.wellness:
        return 'Wellness';
    }
  }
}

// Health Goal class with more robust implementation
class HealthGoal {
  final String title;
  final double target;
  final double current;
  final IconData icon;
  final MaterialColor color;
  final String unit;
  final GoalCategory category;

  HealthGoal({
    required this.title,
    required this.target,
    required this.current,
    required this.icon,
    required this.color,
    this.unit = '',
    required this.category,
  });

  // Computed progress property
  double get progress {
    final calculatedProgress = current / target;
    return calculatedProgress > 1.0 ? 1.0 : calculatedProgress;
  }

  // Copy method for easy modification
  HealthGoal copyWith({
    String? title,
    double? target,
    double? current,
    IconData? icon,
    MaterialColor? color,
    String? unit,
    GoalCategory? category,
  }) {
    return HealthGoal(
      title: title ?? this.title,
      target: target ?? this.target,
      current: current ?? this.current,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      unit: unit ?? this.unit,
      category: category ?? this.category,
    );
  }
}