import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../manger/health_records_cubit.dart';
import '../manger/health_records_state.dart';
import '../../GoalReminders/data/HealthGoalModel.dart';

class HealthDataInputScreen extends StatefulWidget {
  final AnimationController animationController;

  const HealthDataInputScreen({Key? key, required this.animationController})
    : super(key: key);

  @override
  _HealthDataInputScreenState createState() => _HealthDataInputScreenState();
}

class _HealthDataInputScreenState extends State<HealthDataInputScreen> {
  final _formKey = GlobalKey<FormState>();

  // Map to convert from GoalCategory to metric title
  final Map<GoalCategory, String> _categoryToTitle = {
    GoalCategory.caloriesBurned: 'Calories Burned',
    GoalCategory.activeMinutes: 'Active Minutes',
    GoalCategory.heartRate: 'Heart Rate',
    GoalCategory.hydration: 'Hydration',
    GoalCategory.weight: 'Weight',
    GoalCategory.goalWeightLoss: 'Goal Weight Loss',
    GoalCategory.sleepHours: 'Sleep Hours',
    GoalCategory.steps: 'Steps',
    GoalCategory.distanceCovered: 'Distance',
  };

  // Reverse mapping from title to GoalCategory
  late Map<String, GoalCategory> _titleToCategory;

  @override
  void initState() {
    super.initState();
    // Initialize reverse mapping
    _titleToCategory = _categoryToTitle.map(
      (key, value) => MapEntry(value, key),
    );

    // Load health data and goals
    context.read<HealthDataCubit>().loadHealthData();
  }

  double _calculateGoalCaloricDeficit() {
    double goalWeightToLose =
        double.tryParse(
          context.read<HealthDataCubit>().goalWeightLossController.text,
        ) ??
        0;
    return 7700 * goalWeightToLose;
  }

  Color _getProgressColor(String title) {
    final controller = _getControllerForTitle(title);
    final currentValue = double.tryParse(controller.text) ?? 0;
    final category = _titleToCategory[title];
    final goalTarget =
        category != null
            ? context.read<HealthDataCubit>().getTargetForCategory(category)
            : null;
    final goalValue = goalTarget ?? _getDefaultGoalValue(title);

    if (goalValue == 0) return Colors.grey;
    final percentage = (currentValue / goalValue * 100).clamp(0, 100);

    if (percentage >= 100) return Colors.green.shade700;
    if (percentage >= 75) return Colors.lightGreen.shade600;
    if (percentage >= 50) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  String _getProgressStatus(String title) {
    final controller = _getControllerForTitle(title);
    final currentValue = double.tryParse(controller.text) ?? 0;
    final category = _titleToCategory[title];
    final goalTarget =
        category != null
            ? context.read<HealthDataCubit>().getTargetForCategory(category)
            : null;
    final goalValue = goalTarget ?? _getDefaultGoalValue(title);

    if (goalValue == 0) return 'No goal set';
    final percentage = (currentValue / goalValue * 100).clamp(0, 100);

    if (percentage >= 100) return 'Goal achieved!';
    if (percentage >= 75) return 'Very close to goal';
    if (percentage >= 50) return 'Close to goal';
    return 'Far from goal';
  }

  double _getDefaultGoalValue(String title) {
    switch (title) {
      case 'Calories Burned':
        return 0;
      case 'Active Minutes':
        return 0;
      case 'Heart Rate':
        return 0;
      case 'Hydration':
        return 0;
      case 'Weight':
        return 0;
      case 'Goal Weight Loss':
        return 0;
      case 'Sleep Hours':
        return 0;
      case 'Steps':
        return 0;
      case 'Distance':
        return 0;
      default:
        return 0;
    }
  }

  TextEditingController _getControllerForTitle(String title) {
    final cubit = context.read<HealthDataCubit>();
    switch (title) {
      case 'Calories Burned':
        return cubit.caloriesBurnedController;
      case 'Active Minutes':
        return cubit.activeMinutesController;
      case 'Heart Rate':
        return cubit.heartRateController;
      case 'Hydration':
        return cubit.hydrationController;
      case 'Weight':
        return cubit.weightController;
      case 'Goal Weight Loss':
        return cubit.goalWeightLossController;
      case 'Sleep Hours':
        return cubit.sleepHoursController;
      case 'Steps':
        return cubit.stepsController;
      case 'Distance':
        return cubit.distanceController;
      default:
        return TextEditingController();
    }
  }

  String? _validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: widget.animationController,
            curve: Curves.easeOutQuad,
          ),
        );

        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: widget.animationController,
            curve: Curves.easeOutQuad,
          ),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: Scaffold(
              backgroundColor: Colors.grey.shade50,
              body: SafeArea(
                child: BlocConsumer<HealthDataCubit, HealthDataState>(
                  listener: (context, state) {
                    if (state is HealthDataError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(state.message)),
                            ],
                          ),
                          backgroundColor: Colors.red.shade700,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.all(10),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    } else if (state is HealthDataSaved) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Text(state.message),
                            ],
                          ),
                          backgroundColor: Colors.teal.shade700,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.all(10),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView(
                              padding: EdgeInsets.all(
                                isSmallScreen ? 16.0 : 24.0,
                              ),
                              children: [
                                _buildSectionTitle('Activity'),
                                _buildHealthDataCard(
                                  context: context,
                                  title: 'Calories Burned',
                                  subTitle: 'Daily calories burned',
                                  icon: Iconsax.flash_1,
                                  color: Colors.orange,
                                  controller:
                                      context
                                          .read<HealthDataCubit>()
                                          .caloriesBurnedController,
                                  hint: 'Calories burned',
                                  keyboardType: TextInputType.number,
                                  validator:
                                      (value) => _validateNumber(
                                        value,
                                        'calories burned',
                                      ),
                                  suffix: 'kcal',
                                ),
                                const SizedBox(height: 16),
                                _buildHealthDataCard(
                                  context: context,
                                  title: 'Active Minutes',
                                  subTitle: 'Exercise duration',
                                  icon: Iconsax.timer_1,
                                  color: Colors.teal,
                                  controller:
                                      context
                                          .read<HealthDataCubit>()
                                          .activeMinutesController,
                                  hint: 'Active minutes',
                                  keyboardType: TextInputType.number,
                                  validator:
                                      (value) => _validateNumber(
                                        value,
                                        'active minutes',
                                      ),
                                  suffix: 'min',
                                ),
                                const SizedBox(height: 16),
                                _buildHealthDataCard(
                                  context: context,
                                  title: 'Steps',
                                  subTitle: 'Daily step count',
                                  icon: Iconsax.health,
                                  color: Colors.purple,
                                  controller:
                                      context
                                          .read<HealthDataCubit>()
                                          .stepsController,
                                  hint: 'Steps taken',
                                  keyboardType: TextInputType.number,
                                  validator:
                                      (value) =>
                                          _validateNumber(value, 'steps'),
                                  suffix: 'steps',
                                ),
                                const SizedBox(height: 16),
                                _buildHealthDataCard(
                                  context: context,
                                  title: 'Distance',
                                  subTitle: 'Distance walked/run',
                                  icon: Iconsax.routing,
                                  color: Colors.blue,
                                  controller:
                                      context
                                          .read<HealthDataCubit>()
                                          .distanceController,
                                  hint: 'Distance covered',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  validator:
                                      (value) =>
                                          _validateNumber(value, 'distance'),
                                  suffix: 'km',
                                ),
                                const SizedBox(height: 24),
                                _buildSectionTitle('Vitals'),
                                _buildHealthDataCard(
                                  context: context,
                                  title: 'Heart Rate',
                                  subTitle: 'Current heart rate',
                                  icon: Iconsax.heart,
                                  color: Colors.red,
                                  controller:
                                      context
                                          .read<HealthDataCubit>()
                                          .heartRateController,
                                  hint: 'Heart rate',
                                  keyboardType: TextInputType.number,
                                  validator:
                                      (value) =>
                                          _validateNumber(value, 'heart rate'),
                                  suffix: 'bpm',
                                ),
                                const SizedBox(height: 16),
                                _buildHealthDataCard(
                                  context: context,
                                  title: 'Weight',
                                  subTitle: 'Current body weight',
                                  icon: Iconsax.weight,
                                  color: Colors.teal.shade700,
                                  controller:
                                      context
                                          .read<HealthDataCubit>()
                                          .weightController,
                                  hint: 'Body weight',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  validator:
                                      (value) =>
                                          _validateNumber(value, 'weight'),
                                  suffix: 'kg',
                                ),
                                const SizedBox(height: 16),
                                _buildHealthDataCard(
                                  context: context,
                                  title: 'Goal Weight Loss',
                                  subTitle:
                                      'Target deficit: ${_calculateGoalCaloricDeficit().toStringAsFixed(0)} kcal',
                                  icon: Iconsax.weight,
                                  color: Colors.deepPurple.shade700,
                                  controller:
                                      context
                                          .read<HealthDataCubit>()
                                          .goalWeightLossController,
                                  hint: 'Target weight to lose',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  validator:
                                      (value) => _validateNumber(
                                        value,
                                        'goal weight loss',
                                      ),
                                  suffix: 'kg',
                                ),
                                const SizedBox(height: 24),
                                _buildSectionTitle('Nutrition & Sleep'),
                                _buildHealthDataCard(
                                  context: context,
                                  title: 'Hydration',
                                  subTitle: 'Water consumed',
                                  icon: Iconsax.drop,
                                  color: Colors.blue,
                                  controller:
                                      context
                                          .read<HealthDataCubit>()
                                          .hydrationController,
                                  hint: 'Water consumed',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  validator:
                                      (value) => _validateNumber(
                                        value,
                                        'water intake',
                                      ),
                                  suffix: 'liters',
                                ),
                                const SizedBox(height: 16),
                                _buildHealthDataCard(
                                  context: context,
                                  title: 'Sleep Hours',
                                  subTitle: 'Last night\'s sleep',
                                  icon: Iconsax.moon,
                                  color: Colors.indigo,
                                  controller:
                                      context
                                          .read<HealthDataCubit>()
                                          .sleepHoursController,
                                  hint: 'Hours slept',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  validator:
                                      (value) =>
                                          _validateNumber(value, 'sleep hours'),
                                  suffix: 'hours',
                                ),
                              ],
                            ),
                          ),
                          _buildSaveButton(isSmallScreen, state),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _buildHealthDataCard({
    required BuildContext context,
    required String title,
    required String subTitle,
    required IconData icon,
    required Color color,
    required TextEditingController controller,
    required String hint,
    required String suffix,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;
    final progressColor = _getProgressColor(title);
    final inputValue = double.tryParse(controller.text) ?? 0;

    // Get goal target from the cubit using category mapping
    final category = _titleToCategory[title];
    final goalTarget =
        category != null
            ? context.read<HealthDataCubit>().getTargetForCategory(category)
            : null;
    final targetValue = goalTarget ?? _getDefaultGoalValue(title);

    final progressStatus = _getProgressStatus(title);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: isSmallScreen ? 22 : 26,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: progressColor,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey.shade400,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: progressColor, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: progressColor, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: isSmallScreen ? 12 : 16,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Text(
                    suffix,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: progressColor,
                    ),
                  ),
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
              ),
              validator: validator,
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Current: ${controller.text.isEmpty ? '0' : controller.text} $suffix',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: progressColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Goal: ${targetValue.toStringAsFixed(title.contains('Hydration') || title.contains('Weight') || title.contains('Sleep') || title.contains('Distance') ? 1 : 0)} $suffix',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: progressColor,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.circle, size: 16, color: progressColor),
                const SizedBox(width: 4),
                Text(
                  progressStatus,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: progressColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            // Add this to show if goal is from Firebase or default
            if (category != null &&
                context.read<HealthDataCubit>().getTargetForCategory(
                      category,
                    ) !=
                    null)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Custom goal',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isSmallScreen, HealthDataState state) {
    final isLoading = state is HealthDataSaving || state is HealthDataLoading;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16.0 : 24.0,
        vertical: 16.0,
      ),
      child: ElevatedButton(
        onPressed:
            isLoading
                ? null
                : () {
                  if (_formKey.currentState!.validate()) {
                    context.read<HealthDataCubit>().saveHealthData();
                  }
                },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size(double.infinity, 56),
        ),
        child:
            isLoading
                ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Iconsax.save_2, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      'Save Health Data',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
