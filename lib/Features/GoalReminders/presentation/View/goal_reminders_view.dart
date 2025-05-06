import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../data/HealthGoalModel.dart';
import '../Manger/health_goals_cubit.dart';
import '../Manger/health_goals_state.dart';

// --- Constants ---
const Color kBaseColor = Colors.teal;
const Color kCardBackgroundColor = Colors.white;
const Color kScaffoldBackgroundColor = Color(0xFFF4F6F8);

// --- Goal Reminders Screen ---
class GoalRemindersScreen extends StatefulWidget {
  final String userId;
  const GoalRemindersScreen({super.key, required this.userId});

  @override
  _GoalRemindersScreenState createState() => _GoalRemindersScreenState();
}

class _GoalRemindersScreenState extends State<GoalRemindersScreen> {
  // Controllers
  final TextEditingController _goalTitleController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _repetitionController = TextEditingController();
  final TextEditingController _daysToAchieveController =
      TextEditingController();
  final TextEditingController _currentValueController = TextEditingController();
  final TextEditingController _updateProgressController =
      TextEditingController();

  GoalCategory? _selectedCategory;
  GoalDuration? _selectedDuration = GoalDuration.daily;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthGoalsCubit>().loadGoals(widget.userId);
    });
  }

  @override
  void dispose() {
    [
      _goalTitleController,
      _targetController,
      _repetitionController,
      _daysToAchieveController,
      _currentValueController,
      _updateProgressController,
    ].forEach((controller) => controller.dispose());
    super.dispose();
  }

  // --- Reusable UI Components ---
  Widget _buildTextFieldLabel(String label) => Padding(
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

  InputDecoration _inputDecoration(
    String hintText,
    IconData icon, {
    bool isDropdown = false,
  }) => InputDecoration(
    hintText: hintText,
    hintStyle: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
    prefixIcon: Icon(icon, color: Colors.grey[700], size: 20),
    suffixIcon:
        isDropdown
            ? Icon(Iconsax.arrow_down_1, color: Colors.grey[700], size: 18)
            : null,
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

  // Shows a reusable snackbar
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  // --- Helper Methods ---
  double _getDefaultCurrentValueForCategory(GoalCategory? category) {
    if (category == null) return 0.0;
    switch (category) {
      case GoalCategory.heartRate:
        return 70;
      case GoalCategory.bloodPressure:
        return 120;
      case GoalCategory.sleepHours:
        return 6;
      case GoalCategory.hydration:
        return 0.5;
      default:
        return 0.0;
    }
  }

  String _getTargetHint(GoalCategory? category) =>
      category == null
          ? 'Enter target value'
          : 'Target ${_getTargetUnit(category)}';

  String _getTargetUnit(GoalCategory category) {
    switch (category) {
      case GoalCategory.heartRate:
        return 'BPM';
      case GoalCategory.bloodPressure:
        return 'mmHg';
      case GoalCategory.caloriesBurned:
        return 'kcal';
      case GoalCategory.distanceCovered:
        return 'km';
      case GoalCategory.steps:
        return 'steps';
      case GoalCategory.activeMinutes:
        return 'min';
      case GoalCategory.sleepHours:
        return 'hrs';
      case GoalCategory.hydration:
        return 'liters';
      default:
        return 'value';
    }
  }

  IconData _getIconForCategory(GoalCategory category) {
    switch (category) {
      case GoalCategory.heartRate:
        return Iconsax.heart;
      case GoalCategory.bloodPressure:
        return Iconsax.heart_circle;
      case GoalCategory.caloriesBurned:
        return Iconsax.flash_1;
      case GoalCategory.distanceCovered:
        return Iconsax.location;
      case GoalCategory.steps:
        return Iconsax.activity;
      case GoalCategory.activeMinutes:
        return Iconsax.timer_1;
      case GoalCategory.sleepHours:
        return Iconsax.moon;
      case GoalCategory.hydration:
        return Iconsax.cup;
      default:
        return Iconsax.task_square;
    }
  }

  Color _getColorForCategory(GoalCategory category) {
    switch (category) {
      case GoalCategory.heartRate:
        return Colors.red;
      case GoalCategory.bloodPressure:
        return Colors.pink;
      case GoalCategory.caloriesBurned:
        return Colors.orange;
      case GoalCategory.distanceCovered:
        return Colors.green;
      case GoalCategory.steps:
        return Colors.blue;
      case GoalCategory.activeMinutes:
        return Colors.cyan;
      case GoalCategory.sleepHours:
        return Colors.purple;
      case GoalCategory.hydration:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Color _getDayProgressColor(double percent) =>
      percent >= 0.7
          ? Colors.green.shade400
          : percent >= 0.4
          ? Colors.orange.shade400
          : Colors.red.shade400;

  bool _validateInputs() {
    if (_goalTitleController.text.isEmpty ||
        _targetController.text.isEmpty ||
        _repetitionController.text.isEmpty ||
        _daysToAchieveController.text.isEmpty ||
        _selectedCategory == null ||
        _selectedDuration == null) {
      _showSnackBar(
        'Please fill all fields and select category/duration.',
        isError: true,
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
    } catch (e) {
      _showSnackBar(
        'Please enter valid numbers for all fields.',
        isError: true,
      );
      return false;
    }

    return true;
  }

  // --- Bottom Sheets ---
  void _showAddGoalBottomSheet() {
    // Reset controllers
    [
      _goalTitleController,
      _targetController,
      _repetitionController,
      _daysToAchieveController,
      _currentValueController,
    ].forEach((c) => c.clear());
    _selectedCategory = null;
    _selectedDuration = GoalDuration.daily;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder:
          (modalContext) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(modalContext).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sheet handle
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

                      // Title
                      Text(
                        'Create New Goal',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Form fields
                      _buildTextFieldLabel('Goal Title'),
                      TextField(
                        controller: _goalTitleController,
                        decoration: _inputDecoration(
                          'E.g., Morning Run',
                          Iconsax.edit,
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildTextFieldLabel('Category'),
                      DropdownButtonFormField<GoalCategory>(
                        value: _selectedCategory,
                        decoration: _inputDecoration(
                          'Select category',
                          Iconsax.category,
                          isDropdown: true,
                        ),
                        dropdownColor: Colors.white,
                        items:
                            GoalCategory.values
                                .map(
                                  (category) => DropdownMenuItem<GoalCategory>(
                                    value: category,
                                    child: Text(
                                      category.displayName,
                                      style: GoogleFonts.poppins(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setModalState(() {
                            _selectedCategory = value;
                            _currentValueController.text =
                                _getDefaultCurrentValueForCategory(
                                  value,
                                ).toString();
                          });
                        },
                      ),
                      const SizedBox(height: 20),

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
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: _inputDecoration(
                                    _getTargetHint(_selectedCategory),
                                    Iconsax.chart_2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTextFieldLabel('Current Value'),
                                TextField(
                                  controller: _currentValueController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: _inputDecoration(
                                    _selectedCategory != null
                                        ? _getDefaultCurrentValueForCategory(
                                          _selectedCategory,
                                        ).toString()
                                        : "0.0",
                                    Iconsax.direct_up,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

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
                                  decoration: _inputDecoration(
                                    'Frequency',
                                    Iconsax.clock,
                                    isDropdown: true,
                                  ),
                                  dropdownColor: Colors.white,
                                  items:
                                      GoalDuration.values
                                          .map(
                                            (duration) =>
                                                DropdownMenuItem<GoalDuration>(
                                                  value: duration,
                                                  child: Text(
                                                    duration.displayName,
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.black87,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                          )
                                          .toList(),
                                  onChanged: (value) {
                                    setModalState(
                                      () => _selectedDuration = value,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTextFieldLabel('Repetition'),
                                TextField(
                                  controller: _repetitionController,
                                  keyboardType: TextInputType.number,
                                  decoration: _inputDecoration(
                                    'Times',
                                    Iconsax.repeat,
                                  ),
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
                        decoration: _inputDecoration(
                          'Total Days',
                          Iconsax.calendar_1,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Create button
                      BlocConsumer<HealthGoalsCubit, HealthGoalsState>(
                        listener: (context, state) {
                          if (state is HealthGoalCreated) {
                            Navigator.pop(context);
                            _showSnackBar('Goal created successfully!');
                          } else if (state is HealthGoalCreateError) {
                            _showSnackBar(state.message, isError: true);
                          }
                        },
                        builder: (context, state) {
                          final isLoading = state is HealthGoalCreating;
                          return ElevatedButton(
                            onPressed:
                                isLoading
                                    ? null
                                    : () {
                                      if (_validateInputs()) {
                                        final newGoal = HealthGoal(
                                          title: _goalTitleController.text,
                                          target: double.parse(
                                            _targetController.text,
                                          ),
                                          repetition: int.parse(
                                            _repetitionController.text,
                                          ),
                                          daysToAchieve: int.parse(
                                            _daysToAchieveController.text,
                                          ),
                                          daysAchieved: 0,
                                          icon: _getIconForCategory(
                                            _selectedCategory!,
                                          ),
                                          color: Colors.red,
                                          category: _selectedCategory!,
                                          duration: _selectedDuration!,
                                          currentProgress:
                                              _currentValueController
                                                      .text
                                                      .isNotEmpty
                                                  ? 0
                                                  : _getDefaultCurrentValueForCategory(
                                                    _selectedCategory!,
                                                  ),
                                        );
                                        context
                                            .read<HealthGoalsCubit>()
                                            .createGoal(newGoal, widget.userId);
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
                            child:
                                isLoading
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : Text(
                                      'Create Goal',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),
    );
  }

  void _showUpdateProgressBottomSheet(HealthGoalModel goal) {
    _updateProgressController.text = goal.currentProgress.toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder:
          (modalContext) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(modalContext).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
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

                // Title
                Text(
                  'Update Progress',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  goal.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 24),

                // Progress field
                _buildTextFieldLabel('Current Progress'),
                TextField(
                  controller: _updateProgressController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _inputDecoration(
                    'Enter new progress value',
                    Iconsax.chart_success,
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 8),

                Text(
                  'Target: ${goal.target.toStringAsFixed(goal.target.truncateToDouble() == goal.target ? 0 : 1)} ${_getTargetUnit(goal.category)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),

                // Update button
                BlocConsumer<HealthGoalsCubit, HealthGoalsState>(
                  listener: (context, state) {
                    if (state is HealthGoalProgressUpdated) {
                      Navigator.pop(context);
                      _showSnackBar('Progress updated successfully!');
                    } else if (state is HealthGoalProgressUpdateError) {
                      _showSnackBar(state.message, isError: true);
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state is HealthGoalProgressUpdating;
                    return ElevatedButton(
                      onPressed:
                          isLoading
                              ? null
                              : () {
                                try {
                                  final newProgress = double.parse(
                                    _updateProgressController.text,
                                  );
                                  if (goal.id != null) {
                                    context
                                        .read<HealthGoalsCubit>()
                                        .updateGoalProgress(
                                          goal.id!,
                                          newProgress,
                                        );
                                  }
                                } catch (e) {
                                  _showSnackBar(
                                    'Please enter a valid number',
                                    isError: true,
                                  );
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goal.color,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child:
                          isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text(
                                'Update Progress',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  // --- UI Components ---
  Widget _buildGoalCard(HealthGoalModel goal, int index) {
    // Calculate progress percentages
    final progressPercent = (goal.target > 0
            ? goal.currentProgress / goal.target
            : 0.0)
        .clamp(0.0, 1.0);
    final daysPercent = (goal.daysToAchieve > 0
            ? goal.daysAchieved / goal.daysToAchieve
            : 0.0)
        .clamp(0.0, 1.0);
    final daysIndicatorColor = _getDayProgressColor(daysPercent);

    // Format number as integer if it has no decimal part
    String formatNumber(double value) =>
        value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);

    return FadeInUp(
      delay: Duration(milliseconds: index * 100),
      duration: const Duration(milliseconds: 400),
      child: Dismissible(
        key: Key(goal.id ?? UniqueKey().toString()),
        background: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Iconsax.trash, color: Colors.white),
        ),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text(
                    'Delete Goal',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  content: Text(
                    'Are you sure you want to delete this goal?',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(color: Colors.grey[700]),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'Delete',
                        style: GoogleFonts.poppins(color: Colors.red),
                      ),
                    ),
                  ],
                ),
          );
        },
        onDismissed: (direction) {
          if (goal.id != null) {
            context.read<HealthGoalsCubit>().deleteGoal(goal.id!);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Goal deleted successfully',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                backgroundColor: Colors.grey[700],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(10),
                action: SnackBarAction(
                  label: 'Undo',
                  textColor: Colors.white,
                  onPressed:
                      () => context.read<HealthGoalsCubit>().createGoal(
                        goal.toHealthGoal(),
                        widget.userId,
                      ),
                ),
              ),
            );
          }
        },
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
            onTap: () => _showUpdateProgressBottomSheet(goal),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: goal.color.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                goal.icon,
                                color: goal.color,
                                size: 22,
                              ),
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
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Target: ${formatNumber(goal.target)} ${_getTargetUnit(goal.category)} • ${goal.duration.displayName}',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Progress text
                        Text(
                          'Progress: ${formatNumber(goal.currentProgress)} / ${formatNumber(goal.target)}',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[700],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Timeline progress
                        Row(
                          children: [
                            Icon(
                              Iconsax.calendar_tick,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Timeline:',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${goal.daysAchieved}/${goal.daysToAchieve} days',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: daysPercent,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            daysIndicatorColor,
                          ),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Circular progress indicator
                  CircularPercentIndicator(
                    radius: 40.0,
                    lineWidth: 8.0,
                    percent: progressPercent,
                    center: Text(
                      "${(progressPercent * 100).toStringAsFixed(0)}%",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: goal.color,
                      ),
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
      ),
    );
  }

  Widget _buildEmptyState() => Center(
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
  );

  Widget _buildErrorState(String message) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Iconsax.danger, size: 60, color: Colors.red[300]),
        const SizedBox(height: 16),
        Text(
          'Something went wrong',
          style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[700]),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => context.read<HealthGoalsCubit>().loadGoals(widget.userId),
          style: ElevatedButton.styleFrom(
            backgroundColor: kBaseColor,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Try Again',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Health Goals Tracker',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            onPressed:
                () => context.read<HealthGoalsCubit>().loadGoals(widget.userId),
            icon: const Icon(Iconsax.refresh, color: kBaseColor),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalBottomSheet,
        backgroundColor: kBaseColor,
        elevation: 4,
        child: const Icon(Iconsax.add, color: Colors.white),
      ),
      body: BlocBuilder<HealthGoalsCubit, HealthGoalsState>(
        builder: (context, state) {
          if (state is HealthGoalsLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kBaseColor),
              ),
            );
          } else if (state is HealthGoalsLoaded) {
            final goals = state.goals;
            if (goals.isEmpty) {
              return _buildEmptyState();
            }
            return RefreshIndicator(
              onRefresh:
                  () async =>
                      context.read<HealthGoalsCubit>().loadGoals(widget.userId),
              color: kBaseColor,
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: goals.length,
                itemBuilder:
                    (context, index) => _buildGoalCard(goals[index], index),
              ),
            );
          } else if (state is HealthGoalsError) {
            return _buildErrorState(state.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
