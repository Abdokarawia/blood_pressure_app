import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/services.dart';

class HealthDataInputScreen extends StatefulWidget {
  final AnimationController animationController;

  const HealthDataInputScreen({Key? key, required this.animationController})
      : super(key: key);

  @override
  _HealthDataInputScreenState createState() => _HealthDataInputScreenState();
}

class _HealthDataInputScreenState extends State<HealthDataInputScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form field controllers
  final TextEditingController _caloriesBurnedController = TextEditingController();
  final TextEditingController _activeMinutesController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _hydrationController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _goalWeightLossController = TextEditingController();

  final Map<String, double> _defaults = {
    'Calories Burned': 0,
    'Active Minutes': 0,
    'Heart Rate': 72,
    'Hydration': 0,
    'Weight': 70,
    'Weight Loss': 0,
    'Goal Weight Loss': 0,
  };

  Map<String, double> _goals = {
    'Calories Burned': 2000, // Default daily calorie goal
    'Active Minutes': 30,
    'Heart Rate': 120, // Moderate intensity default
    'Hydration': 2.3, // Average requirement
    'Weight': 70, // Maintain current weight
    'Weight Loss': 0,
    'Goal Weight Loss': 1, // Default goal to lose 1 kg
  };

  @override
  void initState() {
    super.initState();
    _caloriesBurnedController.text = _defaults['Calories Burned']!.toInt().toString();
    _activeMinutesController.text = _defaults['Active Minutes']!.toInt().toString();
    _heartRateController.text = _defaults['Heart Rate']!.toInt().toString();
    _hydrationController.text = _defaults['Hydration']!.toStringAsFixed(1);
    _weightController.text = _defaults['Weight']!.toStringAsFixed(1);
    _goalWeightLossController.text = _goals['Goal Weight Loss']!.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _caloriesBurnedController.dispose();
    _activeMinutesController.dispose();
    _heartRateController.dispose();
    _hydrationController.dispose();
    _weightController.dispose();
    _goalWeightLossController.dispose();
    super.dispose();
  }

  double _calculateGoalCaloricDeficit() {
    double goalWeightToLose = double.tryParse(_goalWeightLossController.text) ?? 0;
    return 7700 * goalWeightToLose;
  }

  void _saveData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 1200));
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Health data saved successfully'),
            ],
          ),
          backgroundColor: Colors.teal.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Color _getProgressColor(String title) {
    final currentValue = double.tryParse(_getControllerForTitle(title).text) ?? 0;
    final goalValue = _goals[title] ?? 1;
    if (goalValue == 0) return Colors.grey;
    final percentage = (currentValue / goalValue * 100).clamp(0, 100);

    if (percentage >= 100) return Colors.green.shade700;
    if (percentage >= 75) return Colors.lightGreen.shade600;
    if (percentage >= 50) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  String _getProgressStatus(String title) {
    final currentValue = double.tryParse(_getControllerForTitle(title).text) ?? 0;
    final goalValue = _goals[title] ?? 1;
    if (goalValue == 0) return 'No goal set';
    final percentage = (currentValue / goalValue * 100).clamp(0, 100);

    if (percentage >= 100) return 'Goal achieved!';
    if (percentage >= 75) return 'Very close to goal';
    if (percentage >= 50) return 'Close to goal';
    return 'Far from goal';
  }

  String _getUnitForTitle(String title) {
    switch (title) {
      case 'Calories Burned': return 'kcal';
      case 'Active Minutes': return 'min';
      case 'Heart Rate': return 'bpm';
      case 'Hydration': return 'L';
      case 'Weight': return 'kg';
      case 'Weight Loss': return 'kg';
      case 'Goal Weight Loss': return 'kg';
      default: return '';
    }
  }

  TextEditingController _getControllerForTitle(String title) {
    switch (title) {
      case 'Calories Burned': return _caloriesBurnedController;
      case 'Active Minutes': return _activeMinutesController;
      case 'Heart Rate': return _heartRateController;
      case 'Hydration': return _hydrationController;
      case 'Weight': return _weightController;
      case 'Goal Weight Loss': return _goalWeightLossController;
      default: return TextEditingController();
    }
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
        ).animate(CurvedAnimation(
          parent: widget.animationController,
          curve: Curves.easeOutQuad,
        ));

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
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
                          children: [
                            _buildSectionTitle('Activity'),
                            _buildHealthDataCard(
                              context: context,
                              title: 'Calories Burned',
                              subTitle: 'Daily calories burned',
                              icon: Iconsax.flash_1,
                              color: Colors.orange,
                              controller: _caloriesBurnedController,
                              hint: 'Calories burned',
                              keyboardType: TextInputType.number,
                              validator: (value) => _validateNumber(value, 'calories burned'),
                              suffix: 'kcal',
                            ),
                            const SizedBox(height: 16),
                            _buildHealthDataCard(
                              context: context,
                              title: 'Active Minutes',
                              subTitle: 'Exercise duration',
                              icon: Iconsax.timer_1,
                              color: Colors.teal,
                              controller: _activeMinutesController,
                              hint: 'Active minutes',
                              keyboardType: TextInputType.number,
                              validator: (value) => _validateNumber(value, 'active minutes'),
                              suffix: 'min',
                            ),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Vitals'),
                            _buildHealthDataCard(
                              context: context,
                              title: 'Heart Rate',
                              subTitle: 'Current heart rate',
                              icon: Iconsax.heart,
                              color: Colors.red,
                              controller: _heartRateController,
                              hint: 'Heart rate',
                              keyboardType: TextInputType.number,
                              validator: (value) => _validateNumber(value, 'heart rate'),
                              suffix: 'bpm',
                            ),
                            const SizedBox(height: 16),
                            _buildHealthDataCard(
                              context: context,
                              title: 'Weight',
                              subTitle: 'Current body weight',
                              icon: Iconsax.weight,
                              color: Colors.teal.shade700,
                              controller: _weightController,
                              hint: 'Body weight',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (value) => _validateNumber(value, 'weight'),
                              suffix: 'kg',
                            ),
                            const SizedBox(height: 16),
                            _buildHealthDataCard(
                              context: context,
                              title: 'Goal Weight Loss',
                              subTitle: 'Target deficit: ${_calculateGoalCaloricDeficit().toStringAsFixed(0)} kcal',
                              icon: Iconsax.weight,
                              color: Colors.deepPurple.shade700,
                              controller: _goalWeightLossController,
                              hint: 'Target weight to lose',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (value) => _validateNumber(value, 'goal weight loss'),
                              suffix: 'kg',
                            ),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Nutrition'),
                            _buildHealthDataCard(
                              context: context,
                              title: 'Hydration',
                              subTitle: 'Water consumed',
                              icon: Iconsax.drop,
                              color: Colors.blue,
                              controller: _hydrationController,
                              hint: 'Water consumed',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (value) => _validateNumber(value, 'water intake'),
                              suffix: 'liters',
                            ),
                          ],
                        ),
                      ),
                      _buildSaveButton(isSmallScreen),
                    ],
                  ),
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
    final targetValue = _goals[title] ?? 0;
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
                  child: Icon(icon, color: color, size: isSmallScreen ? 22 : 26),
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
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: progressColor),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade400),
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
                  child: Text(suffix, style: GoogleFonts.poppins(fontSize: 16, color: progressColor)),
                ),
                suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
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
                    style: GoogleFonts.poppins(fontSize: 12, color: progressColor),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Goal: ${targetValue.toStringAsFixed(title.contains('Hydration') || title.contains('Weight') ? 1 : 0)} $suffix',
                    style: GoogleFonts.poppins(fontSize: 12, color: progressColor),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 16,
                  color: progressColor,
                ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16.0 : 24.0,
        vertical: 16.0,
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveData,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size(double.infinity, 56),
        ),
        child: _isLoading
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
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
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
}