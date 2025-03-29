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

class _HealthDataInputScreenState extends State<HealthDataInputScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  // Form field controllers
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _bloodPressureController =
      TextEditingController();
  final TextEditingController _caloriesBurnedController =
      TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _stepsController = TextEditingController();
  final TextEditingController _activeMinutesController =
      TextEditingController();
  final TextEditingController _sleepHoursController = TextEditingController();
  final TextEditingController _hydrationController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Pre-populate with example data (would be removed in production)
    _heartRateController.text = "72";
    _stepsController.text = "8462";
  }

  @override
  void dispose() {
    _heartRateController.dispose();
    _bloodPressureController.dispose();
    _caloriesBurnedController.dispose();
    _distanceController.dispose();
    _stepsController.dispose();
    _activeMinutesController.dispose();
    _sleepHoursController.dispose();
    _hydrationController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _saveData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate network request/data processing
      await Future.delayed(const Duration(milliseconds: 1200));

      // Here you would save the data to your database or state management
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Health data saved successfully'),
            ],
          ),
          backgroundColor: Colors.teal.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(10),
          duration: Duration(seconds: 2),
        ),
      );

      // Optionally clear fields after saving
      // _clearFields();
    }
  }


  void _showTips(BuildContext context, String title) {
    String tipContent = '';
    switch (title) {
      case 'Heart Rate':
        tipContent =
            'Normal resting heart rate for adults ranges from 60-100 bpm. Athletes often have lower resting heart rates.';
        break;
      case 'Blood Pressure':
        tipContent =
            'Enter in format systolic/diastolic (e.g., 120/80). Normal blood pressure is less than 120/80 mmHg.';
        break;
      case 'Hydration':
        tipContent =
            'The recommended daily water intake is about 3.7 liters for men and 2.7 liters for women.';
        break;
      default:
        tipContent = 'Enter your $title data for accurate health tracking.';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tips for $title'),
          content: Text(tipContent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            TextButton(
              child: Text(
                'Got it',
                style: TextStyle(color: Colors.teal.shade700),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;
    final screenWidth = MediaQuery.of(context).size.width;

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tab Bar
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: Colors.teal.shade700,
                        unselectedLabelColor: Colors.grey.shade600,
                        indicatorColor: Colors.teal.shade700,
                        indicatorWeight: 3,
                        labelStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: isSmallScreen ? 13 : 14,
                        ),
                        tabs: const [
                          Tab(text: 'Activity'),
                          Tab(text: 'Vitals'),
                          Tab(text: 'Nutrition'),
                        ],
                      ),
                    ),

                    // Main Content
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Activity Tab
                            ActivityTabView(
                              stepsController: _stepsController,
                              distanceController: _distanceController,
                              caloriesBurnedController:
                                  _caloriesBurnedController,
                              activeMinutesController: _activeMinutesController,
                              isSmallScreen: isSmallScreen,
                              onTipPressed: _showTips,
                            ),

                            // Vitals Tab
                            VitalsTabView(
                              heartRateController: _heartRateController,
                              bloodPressureController: _bloodPressureController,
                              sleepHoursController: _sleepHoursController,
                              weightController: _weightController,
                              isSmallScreen: isSmallScreen,
                              onTipPressed: _showTips,
                            ),

                            // Nutrition Tab
                            NutritionTabView(
                              hydrationController: _hydrationController,
                              notesController: _notesController,
                              isSmallScreen: isSmallScreen,
                              onTipPressed: _showTips,
                            ),
                          ],
                        ),
                      ),
                    ),

                    Container(
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          minimumSize: Size(double.infinity, 56),
                        ),
                        child:
                            _isLoading
                                ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Iconsax.save_2 , color: Colors.white,),
                                    SizedBox(width: 10),
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Activity Tab View
class ActivityTabView extends StatelessWidget {
  final TextEditingController stepsController;
  final TextEditingController distanceController;
  final TextEditingController caloriesBurnedController;
  final TextEditingController activeMinutesController;
  final bool isSmallScreen;
  final Function(BuildContext, String) onTipPressed;

  const ActivityTabView({
    Key? key,
    required this.stepsController,
    required this.distanceController,
    required this.caloriesBurnedController,
    required this.activeMinutesController,
    required this.isSmallScreen,
    required this.onTipPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
      children: [
        _buildStepsCard(context),
        SizedBox(height: 16),
        _buildHealthDataCard(
          context: context,
          title: 'Distance',
          subTitle: 'How far did you go today?',
          icon: Iconsax.map,
          color: Colors.blue.shade700,
          controller: distanceController,
          hint: 'Distance in km',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter distance';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
          suffix: 'km',
        ),
        SizedBox(height: 16),
        _buildHealthDataCard(
          context: context,
          title: 'Calories Burned',
          subTitle: 'Estimated calories from all activities',
          icon: Iconsax.flash_1,
          color: Colors.orange,
          controller: caloriesBurnedController,
          hint: 'Calories burned',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter calories burned';
            }
            if (int.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
          suffix: 'kcal',
        ),
        SizedBox(height: 16),
        _buildHealthDataCard(
          context: context,
          title: 'Active Minutes',
          subTitle: 'Time spent in moderate to intense activity',
          icon: Iconsax.timer_1,
          color: Colors.teal,
          controller: activeMinutesController,
          hint: 'Active minutes',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter active minutes';
            }
            if (int.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
          suffix: 'min',
        ),
      ],
    );
  }

  Widget _buildStepsCard(BuildContext context) {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Iconsax.scan,
                        color: Colors.purple.shade700,
                        size: isSmallScreen ? 22 : 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Steps Count',
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          'Daily goal: 10,000 steps',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 20),
            TextFormField(
              controller: stepsController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
              decoration: InputDecoration(
                hintText: 'Enter today\'s steps',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.normal,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: isSmallScreen ? 12 : 16,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Text(
                    'steps',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                suffixIconConstraints: BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter step count';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              onChanged: (value) {
                // Force refresh to update the progress indicator
                (context as Element).markNeedsBuild();
              },
            ),
          ],
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            color: Colors.grey.shade800,
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
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.normal,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
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
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                suffixIconConstraints: BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
              ),
              validator: validator,
            ),
          ],
        ),
      ),
    );
  }
}

// Vitals Tab View
class VitalsTabView extends StatelessWidget {
  final TextEditingController heartRateController;
  final TextEditingController bloodPressureController;
  final TextEditingController sleepHoursController;
  final TextEditingController weightController;
  final bool isSmallScreen;
  final Function(BuildContext, String) onTipPressed;

  const VitalsTabView({
    Key? key,
    required this.heartRateController,
    required this.bloodPressureController,
    required this.sleepHoursController,
    required this.weightController,
    required this.isSmallScreen,
    required this.onTipPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
      children: [
        _buildHealthDataCard(
          context: context,
          title: 'Heart Rate',
          subTitle: 'Your resting heart rate',
          icon: Iconsax.heart,
          color: Colors.red,
          controller: heartRateController,
          hint: 'Heart rate',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter heart rate';
            }
            if (int.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
          suffix: 'bpm',
        ),
        SizedBox(height: 16),
        _buildHealthDataCard(
          context: context,
          title: 'Blood Pressure',
          subTitle: 'Systolic/Diastolic pressure',
          icon: Iconsax.health,
          color: Colors.blue.shade800,
          controller: bloodPressureController,
          hint: 'e.g. 120/80',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter blood pressure';
            }
            if (!value.contains('/')) {
              return 'Correct format: systolic/diastolic';
            }
            return null;
          },
          suffix: 'mmHg',
        ),
        SizedBox(height: 16),
        _buildHealthDataCard(
          context: context,
          title: 'Sleep',
          subTitle: 'Hours of sleep last night',
          icon: Iconsax.moon,
          color: Colors.indigo,
          controller: sleepHoursController,
          hint: 'Sleep duration',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter sleep hours';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
          suffix: 'hours',
        ),
        SizedBox(height: 16),
        _buildHealthDataCard(
          context: context,
          title: 'Weight',
          subTitle: 'Your current body weight',
          icon: Iconsax.weight,
          color: Colors.teal.shade700,
          controller: weightController,
          hint: 'Body weight',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter weight';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
          suffix: 'kg',
        ),
      ],
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            color: Colors.grey.shade800,
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
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.normal,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
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
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                suffixIconConstraints: BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
              ),
              validator: validator,
            ),
          ],
        ),
      ),
    );
  }
}

// Nutrition Tab View
class NutritionTabView extends StatelessWidget {
  final TextEditingController hydrationController;
  final TextEditingController notesController;
  final bool isSmallScreen;
  final Function(BuildContext, String) onTipPressed;

  const NutritionTabView({
    Key? key,
    required this.hydrationController,
    required this.notesController,
    required this.isSmallScreen,
    required this.onTipPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
      children: [
        _buildHealthDataCard(
          context: context,
          title: 'Hydration',
          subTitle: 'Water intake today',
          icon: Iconsax.drop,
          color: Colors.blue,
          controller: hydrationController,
          hint: 'Water consumed',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter water intake';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
          suffix: 'liters',
        ),
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Iconsax.note_text,
                            color: Colors.amber.shade700,
                            size: isSmallScreen ? 22 : 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notes',
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            Text(
                              'Additional health notes',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: notesController,
                  maxLines: 4,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey.shade800,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter any additional health notes...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            color: Colors.grey.shade800,
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
                IconButton(
                  icon: Icon(
                    Iconsax.info_circle,
                    color: Colors.grey.shade600,
                    size: 22,
                  ),
                  onPressed: () => onTipPressed(context, title),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.normal,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
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
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                suffixIconConstraints: BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
              ),
              validator: validator,
            ),
          ],
        ),
      ),
    );
  }
}

// Step Progress Indicator Widget
class StepProgressIndicator extends StatelessWidget {
  final int currentValue;
  final int maxValue;

  const StepProgressIndicator({
    Key? key,
    required this.currentValue,
    this.maxValue = 10000,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = (currentValue / maxValue).clamp(0.0, 1.0);
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$currentValue steps',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: Colors.purple.shade700,
              ),
            ),
            Text(
              '${(percentage * 100).toStringAsFixed(0)}% of goal',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage,
          minHeight: 10,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade400),
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }
}
