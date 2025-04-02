import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:math' as math;

// --- Constants ---
const Color kBaseColor = Colors.teal;
const Color kCardBackgroundColor = Colors.white;
const Color kScaffoldBackgroundColor = Color(0xFFF4F6F8);

// --- Goal Reminders Screen ---
class GoalRemindersScreen extends StatefulWidget {
  const GoalRemindersScreen({super.key});

  @override
  _GoalRemindersScreenState createState() => _GoalRemindersScreenState();
}

class _GoalRemindersScreenState extends State<GoalRemindersScreen> {
  late List<HealthGoal> _healthGoals;

  // Controllers
  final TextEditingController _goalTitleController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _repetitionController = TextEditingController();
  final TextEditingController _daysToAchieveController = TextEditingController();
  final TextEditingController _currentValueController = TextEditingController();
  final TextEditingController _updateProgressController = TextEditingController();

  GoalCategory? _selectedCategory;
  GoalDuration? _selectedDuration = GoalDuration.daily;

  @override
  void initState() {
    super.initState();
    // Initialize with sample data
    _healthGoals = [
      HealthGoal(
        title: 'Daily Steps',
        target: 10000,
        repetition: 1,
        daysToAchieve: 30,
        daysAchieved: 22,
        icon: Iconsax.activity,
        color: Colors.blue,
        category: GoalCategory.steps,
        duration: GoalDuration.daily,
        currentProgress: 7500,
      ),
      HealthGoal(
        title: 'Sleep Goal',
        target: 8,
        repetition: 1,
        daysToAchieve: 30,
        daysAchieved: 10,
        icon: Iconsax.moon,
        color: Colors.purple,
        category: GoalCategory.sleepHours,
        duration: GoalDuration.daily,
        currentProgress: 6.5,
      ),
      HealthGoal(
        title: 'Water Intake',
        target: 2.5,
        repetition: 1,
        daysToAchieve: 30,
        daysAchieved: 15,
        icon: Iconsax.cup,
        color: Colors.teal,
        category: GoalCategory.hydration,
        duration: GoalDuration.daily,
        currentProgress: 1.8,
      ),
      HealthGoal(
        title: 'Monthly Run',
        target: 50,
        repetition: 4,
        daysToAchieve: 30,
        daysAchieved: 28,
        icon: Iconsax.location,
        color: Colors.green,
        category: GoalCategory.distanceCovered,
        duration: GoalDuration.monthly,
        currentProgress: 35.5,
      ),
    ];
  }

  @override
  void dispose() {
    _goalTitleController.dispose();
    _targetController.dispose();
    _repetitionController.dispose();
    _daysToAchieveController.dispose();
    _currentValueController.dispose();
    _updateProgressController.dispose();
    super.dispose();
  }

  Widget _buildTextFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText, IconData icon, {bool isDropdown = false}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey[700], size: 20),
      suffixIcon: isDropdown ? Icon(Iconsax.arrow_down_1, color: Colors.grey[700], size: 18) : null,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: kBaseColor.withOpacity(0.5), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  void _showAddGoalBottomSheet() {
    _goalTitleController.clear();
    _targetController.clear();
    _repetitionController.clear();
    _daysToAchieveController.clear();
    _currentValueController.clear();
    _selectedCategory = null;
    _selectedDuration = GoalDuration.daily;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
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
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Goal Title
                    _buildTextFieldLabel('Goal Title'),
                    TextField(
                      controller: _goalTitleController,
                      decoration: _inputDecoration('E.g., Morning Run', Iconsax.edit),
                    ),
                    const SizedBox(height: 20),

                    // Category Dropdown
                    _buildTextFieldLabel('Category'),
                    DropdownButtonFormField<GoalCategory>(
                      value: _selectedCategory,
                      decoration: _inputDecoration('Select category', Iconsax.category, isDropdown: true),
                      dropdownColor: Colors.white,
                      items: GoalCategory.values.map((category) {
                        return DropdownMenuItem<GoalCategory>(
                          value: category,
                          child: Text(
                            category.displayName,
                            style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) => value == null ? 'Please select a category' : null,
                    ),
                    const SizedBox(height: 20),

                    // Target and Repetition Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextFieldLabel('Target Value'),
                              TextField(
                                controller: _targetController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: _inputDecoration(_getTargetHint(_selectedCategory), Iconsax.chart_2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Current Value
                              _buildTextFieldLabel('Current Value'),
                              TextField(
                                controller: _currentValueController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: _inputDecoration('E.g., 2500 steps', Iconsax.direct_up),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Days to Achieve & Duration Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              _buildTextFieldLabel('Duration'),
                              DropdownButtonFormField<GoalDuration>(
                                value: _selectedDuration,
                                decoration: _inputDecoration('Frequency', Iconsax.clock, isDropdown: true),
                                dropdownColor: Colors.white,
                                items: GoalDuration.values.map((duration) {
                                  return DropdownMenuItem<GoalDuration>(
                                    value: duration,
                                    child: Text(
                                      duration.displayName,
                                      style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setModalState(() {
                                    _selectedDuration = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16,),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextFieldLabel('Repetition'),

                              TextField(
                                controller: _repetitionController,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration('Times', Iconsax.repeat),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildTextFieldLabel('Days to Achieve'),
                    TextField(
                      controller: _daysToAchieveController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Total Days', Iconsax.calendar_1),
                    ),


                    const SizedBox(height: 20),

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
                        elevation: 2,
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
            );
          },
        );
      },
    );
  }

  bool _validateInputs() {
    if (_goalTitleController.text.isEmpty ||
        _targetController.text.isEmpty ||
        _repetitionController.text.isEmpty ||
        _daysToAchieveController.text.isEmpty ||
        _selectedCategory == null ||
        _selectedDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill all fields and select category/duration.',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(10),
        ),
      );
      return false;
    }

    try {
      double.parse(_targetController.text);
      int.parse(_repetitionController.text);
      int.parse(_daysToAchieveController.text);

      if (_currentValueController.text.isNotEmpty) {
        double.parse(_currentValueController.text);
      }
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter valid numbers for all fields.',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(10),
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
      repetition: int.parse(_repetitionController.text),
      daysToAchieve: int.parse(_daysToAchieveController.text),
      daysAchieved: 0,
      icon: _getIconForCategory(_selectedCategory!),
      color: _getColorForCategory(_selectedCategory!),
      category: _selectedCategory!,
      duration: _selectedDuration!,
      currentProgress: _currentValueController.text.isNotEmpty
          ? double.parse(_currentValueController.text)
          : 0.0,
    );

    setState(() {
      _healthGoals.add(newGoal);
    });
  }

  Color _getDayProgressColor(double percent) {
    if (percent >= 0.7) return Colors.green.shade400;
    if (percent >= 0.4) return Colors.orange.shade400;
    return Colors.red.shade400;
  }

  Widget _buildGoalCard(HealthGoal goal, int index) {
    double progressPercent = (goal.target > 0) ? (goal.currentProgress / goal.target) : 0.0;
    progressPercent = progressPercent.clamp(0.0, 1.0);

    double daysPercent = (goal.daysToAchieve > 0) ? (goal.daysAchieved / goal.daysToAchieve) : 0.0;
    daysPercent = daysPercent.clamp(0.0, 1.0);

    Color daysIndicatorColor = _getDayProgressColor(daysPercent);

    return FadeInUp(
      delay: Duration(milliseconds: index * 100),
      duration: const Duration(milliseconds: 400),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 0.5,
        color: kCardBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: goal.color.withOpacity(0.1),
          highlightColor: goal.color.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: goal.color.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(goal.icon, color: goal.color, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal.title,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87,
                                  ),
                                  maxLines: 2, overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Target: ${goal.target.toStringAsFixed(goal.target.truncateToDouble() == goal.target ? 0 : 1)} ${_getTargetUnit(goal.category)} • ${goal.duration.displayName}',
                                  style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Text(
                        'Progress: ${goal.currentProgress.toStringAsFixed(goal.currentProgress.truncateToDouble() == goal.currentProgress ? 0 : 1)} / ${goal.target.toStringAsFixed(goal.target.truncateToDouble() == goal.target ? 0 : 1)}',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(Iconsax.calendar_tick, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Timeline:',
                            style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Text(
                            '${goal.daysAchieved}/${goal.daysToAchieve} days',
                            style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: daysPercent,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(daysIndicatorColor),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                CircularPercentIndicator(
                  radius: 40.0,
                  lineWidth: 8.0,
                  percent: progressPercent,
                  center: Text(
                    "${(progressPercent * 100).toStringAsFixed(0)}%",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16.0, color: goal.color),
                  ),
                  backgroundColor: goal.color.withOpacity(0.15),
                  progressColor: goal.color,
                  circularStrokeCap: CircularStrokeCap.round,
                  animation: true,
                  animationDuration: 800,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _healthGoals.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.note_remove, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No goals yet!',
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add your first goal.',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 80),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildGoalCard(_healthGoals[index], index),
                childCount: _healthGoals.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalBottomSheet,
        backgroundColor: kBaseColor,
        tooltip: 'Add New Goal',
        child: const Icon(Iconsax.add, color: Colors.white, size: 28),
        shape: const CircleBorder(),
      ),
    );
  }

  IconData _getIconForCategory(GoalCategory category) {
    switch (category) {
      case GoalCategory.heartRate: return Iconsax.heart;
      case GoalCategory.bloodPressure: return Iconsax.heart_circle;
      case GoalCategory.caloriesBurned: return Iconsax.flash_1;
      case GoalCategory.distanceCovered: return Iconsax.location;
      case GoalCategory.steps: return Iconsax.activity;
      case GoalCategory.activeMinutes: return Iconsax.timer_1;
      case GoalCategory.sleepHours: return Iconsax.moon;
      case GoalCategory.hydration: return Iconsax.cup;
      default: return Iconsax.task_square;
    }
  }

  MaterialColor _getColorForCategory(GoalCategory category) {
    switch (category) {
      case GoalCategory.heartRate: return Colors.red;
      case GoalCategory.bloodPressure: return Colors.pink;
      case GoalCategory.caloriesBurned: return Colors.orange;
      case GoalCategory.distanceCovered: return Colors.green;
      case GoalCategory.steps: return Colors.blue;
      case GoalCategory.activeMinutes: return Colors.cyan;
      case GoalCategory.sleepHours: return Colors.purple;
      case GoalCategory.hydration: return Colors.teal;
      default: return Colors.grey;
    }
  }

  String _getTargetHint(GoalCategory? category) {
    if (category == null) return 'Enter target value';
    return 'Target ${_getTargetUnit(category)}';
  }

  String _getTargetUnit(GoalCategory category) {
    switch (category) {
      case GoalCategory.heartRate: return 'BPM';
      case GoalCategory.bloodPressure: return 'mmHg';
      case GoalCategory.caloriesBurned: return 'kcal';
      case GoalCategory.distanceCovered: return 'km';
      case GoalCategory.steps: return 'steps';
      case GoalCategory.activeMinutes: return 'min';
      case GoalCategory.sleepHours: return 'hrs';
      case GoalCategory.hydration: return 'liters';
      default: return 'value';
    }
  }
}

// --- Enums ---
enum GoalCategory {
  heartRate,
  bloodPressure,
  caloriesBurned,
  distanceCovered,
  steps,
  activeMinutes,
  sleepHours,
  hydration;

  String get displayName {
    switch (this) {
      case GoalCategory.heartRate: return 'Heart Rate';
      case GoalCategory.bloodPressure: return 'Blood Pressure';
      case GoalCategory.caloriesBurned: return 'Calories Burned';
      case GoalCategory.distanceCovered: return 'Distance Covered';
      case GoalCategory.steps: return 'Steps';
      case GoalCategory.activeMinutes: return 'Active Minutes';
      case GoalCategory.sleepHours: return 'Sleep Hours';
      case GoalCategory.hydration: return 'Hydration';
    }
  }
}

enum GoalDuration {
  daily,
  weekly,
  monthly;

  String get displayName {
    switch (this) {
      case GoalDuration.daily: return 'Daily';
      case GoalDuration.weekly: return 'Weekly';
      case GoalDuration.monthly: return 'Monthly';
    }
  }
}

// --- Data Class HealthGoal ---
@immutable
class HealthGoal {
  final String title;
  final double target;
  final int repetition;
  final int daysToAchieve;
  final int daysAchieved;
  final IconData icon;
  final MaterialColor color;
  final GoalCategory category;
  final GoalDuration duration;
  final double currentProgress;

  const HealthGoal({
    required this.title,
    required this.target,
    required this.repetition,
    required this.daysToAchieve,
    required this.daysAchieved,
    required this.icon,
    required this.color,
    required this.category,
    required this.duration,
    required this.currentProgress,
  });

  HealthGoal copyWith({
    String? title,
    double? target,
    int? repetition,
    int? daysToAchieve,
    int? daysAchieved,
    IconData? icon,
    MaterialColor? color,
    GoalCategory? category,
    GoalDuration? duration,
    double? currentProgress,
  }) {
    return HealthGoal(
      title: title ?? this.title,
      target: target ?? this.target,
      repetition: repetition ?? this.repetition,
      daysToAchieve: daysToAchieve ?? this.daysToAchieve,
      daysAchieved: daysAchieved ?? this.daysAchieved,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      currentProgress: currentProgress ?? this.currentProgress,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is HealthGoal &&
              runtimeType == other.runtimeType &&
              title == other.title &&
              target == other.target &&
              repetition == other.repetition &&
              daysToAchieve == other.daysToAchieve &&
              daysAchieved == other.daysAchieved &&
              category == other.category &&
              duration == other.duration &&
              currentProgress == other.currentProgress;

  @override
  int get hashCode =>
      title.hashCode ^
      target.hashCode ^
      repetition.hashCode ^
      daysToAchieve.hashCode ^
      daysAchieved.hashCode ^
      category.hashCode ^
      duration.hashCode ^
      currentProgress.hashCode;
}