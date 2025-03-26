import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class ProfileData {
  String name;
  int age;
  String gender;
  double height;
  double weight;
  int heartRate;
  double bmi;

  // Blood Pressure Profile
  BloodPressureProfile bloodPressureProfile;

  // Medical Conditions
  List<String> medicalConditions;

  // Health Goals
  HealthGoals healthGoals;

  ProfileData({
    this.name = '',
    this.age = 0,
    this.gender = '',
    this.height = 0.0,
    this.weight = 0.0,
    this.heartRate = 0,
    double? bmi,
    BloodPressureProfile? bloodPressureProfile,
    List<String>? medicalConditions,
    HealthGoals? healthGoals,
  }) :
        bmi = bmi ?? _calculateBMI(height, weight),
        bloodPressureProfile = bloodPressureProfile ?? BloodPressureProfile(),
        medicalConditions = medicalConditions ?? [],
        healthGoals = healthGoals ?? HealthGoals();

  static double _calculateBMI(double height, double weight) {
    return weight / ((height / 100) * (height / 100));
  }
}

class BloodPressureProfile {
  int systolic;
  int diastolic;
  DateTime lastMeasured;
  List<BloodPressureReading> historicalReadings;

  BloodPressureProfile({
    this.systolic = 120,
    this.diastolic = 80,
    DateTime? lastMeasured,
    List<BloodPressureReading>? historicalReadings,
  }) :
        lastMeasured = lastMeasured ?? DateTime.now(),
        historicalReadings = historicalReadings ?? [];
}

class BloodPressureReading {
  DateTime date;
  int systolic;
  int diastolic;

  BloodPressureReading({
    required this.date,
    required this.systolic,
    required this.diastolic,
  });
}

class HealthGoals {
  double weightGoal;
  int dailyStepGoal;
  int sleepHoursGoal;

  HealthGoals({
    this.weightGoal = 0.0,
    this.dailyStepGoal = 10000,
    this.sleepHoursGoal = 8,
  });
}

class ProfileManagementScreen extends StatefulWidget {
  final AnimationController animationController;

  const ProfileManagementScreen({
    super.key,
    required this.animationController
  });

  @override
  _ProfileManagementScreenState createState() => _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends State<ProfileManagementScreen> {
  late ProfileData _profileData;

  @override
  void initState() {
    super.initState();
    _profileData = ProfileData(
      name: 'John Doe',
      age: 35,
      gender: 'Male',
      height: 175.0,
      weight: 70.0,
      heartRate: 72,
      bloodPressureProfile: BloodPressureProfile(
        systolic: 120,
        diastolic: 80,
        historicalReadings: [
          BloodPressureReading(date: DateTime(2024, 1, 1), systolic: 118, diastolic: 78),
          BloodPressureReading(date: DateTime(2024, 2, 1), systolic: 122, diastolic: 82),
          BloodPressureReading(date: DateTime(2024, 3, 1), systolic: 120, diastolic: 80),
        ],
      ),
      medicalConditions: ['Mild Hypertension', 'Seasonal Allergies'],
      healthGoals: HealthGoals(
        weightGoal: 68.0,
        dailyStepGoal: 12000,
        sleepHoursGoal: 8,
      ),
    );
  }

  void _editProfile() {
    final _nameController = TextEditingController(text: _profileData.name);
    final _ageController = TextEditingController(text: _profileData.age.toString());
    final _heightController = TextEditingController(text: _profileData.height.toString());
    final _weightController = TextEditingController(text: _profileData.weight.toString());
    final _heartRateController = TextEditingController(text: _profileData.heartRate.toString());
    final _systolicController = TextEditingController(text: _profileData.bloodPressureProfile.systolic.toString());
    final _diastolicController = TextEditingController(text: _profileData.bloodPressureProfile.diastolic.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            padding: const EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height * 0.9,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Basic Info Section
                  _buildSectionHeader('Basic Information'),
                  _buildTextField(_nameController, 'Name', Iconsax.user, keyboardType: TextInputType.text),
                  _buildTextField(_ageController, 'Age', Iconsax.calendar, keyboardType: TextInputType.number),

                  // Physical Metrics Section
                  _buildSectionHeader('Physical Metrics'),
                  _buildTextField(_heightController, 'Height (cm)', Iconsax.ruler, keyboardType: TextInputType.number),
                  _buildTextField(_weightController, 'Weight (kg)', Iconsax.weight, keyboardType: TextInputType.number),
                  _buildTextField(_heartRateController, 'Heart Rate (bpm)', Iconsax.heart, keyboardType: TextInputType.number),

                  // Blood Pressure Section
                  _buildSectionHeader('Blood Pressure'),
                  _buildTextField(_systolicController, 'Systolic', Iconsax.health, keyboardType: TextInputType.number),
                  _buildTextField(_diastolicController, 'Diastolic', Iconsax.health, keyboardType: TextInputType.number),

                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _profileData.name = _nameController.text;
                          _profileData.age = int.tryParse(_ageController.text) ?? _profileData.age;
                          _profileData.height = double.tryParse(_heightController.text) ?? _profileData.height;
                          _profileData.weight = double.tryParse(_weightController.text) ?? _profileData.weight;
                          _profileData.heartRate = int.tryParse(_heartRateController.text) ?? _profileData.heartRate;

                          _profileData.bloodPressureProfile.systolic = int.tryParse(_systolicController.text) ?? _profileData.bloodPressureProfile.systolic;
                          _profileData.bloodPressureProfile.diastolic = int.tryParse(_diastolicController.text) ?? _profileData.bloodPressureProfile.diastolic;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade700,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Save Changes',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.teal.shade700,
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.teal.shade300),
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.teal.shade700),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.teal.shade100),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.teal.shade100),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.teal.shade400, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Profile Header
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(top: 5),
              child: AnimatedBuilder(
                animation: widget.animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: widget.animationController.value,
                    child: Transform.translate(
                      offset: Offset(0, 30 * (1 - widget.animationController.value)),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.teal.withOpacity(0.2),
                        const Color(0xFFE0F2F1).withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.1),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Iconsax.profile_2user,
                          color: Colors.teal.shade700,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _profileData.name,
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade700,
                              ),
                            ),
                            Text(
                              '${_profileData.age} years old • ${_profileData.gender}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Iconsax.edit,
                          color: Colors.teal,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _editProfile();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Sections
          SliverList(
            delegate: SliverChildListDelegate([
              // Blood Pressure Section
              _buildHealthSection(
                title: 'Blood Pressure Profile',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildBloodPressureIndicator(
                          'Systolic',
                          _profileData.bloodPressureProfile.systolic,
                          Colors.teal.shade400,
                        ),
                        _buildBloodPressureIndicator(
                          'Diastolic',
                          _profileData.bloodPressureProfile.diastolic,
                          Colors.teal.shade200,
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Last Measured: ${_formatDate(_profileData.bloodPressureProfile.lastMeasured)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              // Health Goals Section
              _buildHealthSection(
                title: 'Health Goals',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGoalItem('Weight Goal', '${_profileData.healthGoals.weightGoal} kg', Iconsax.weight),
                    _buildGoalItem('Daily Steps', '${_profileData.healthGoals.dailyStepGoal} steps', Iconsax.activity),
                    _buildGoalItem('Sleep Hours', '${_profileData.healthGoals.sleepHoursGoal} hours', Iconsax.lamp_on),
                  ],
                ),
              ),

              // Medical Conditions Section
              _buildHealthSection(
                title: 'Medical Conditions',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _profileData.medicalConditions.map((condition) =>
                      ListTile(
                        leading: Icon(Iconsax.health, color: Colors.teal.shade300),
                        title: Text(condition, style: GoogleFonts.poppins()),
                      )
                  ).toList(),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthSection({required String title, required Widget content}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
          const SizedBox(height: 15),
          content,
        ],
      ),
    );
  }

  Widget _buildGoalItem(String label, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal.shade300),
      title: Text(label, style: GoogleFonts.poppins()),
      trailing: Text(
        value,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: Colors.teal.shade600,
        ),
      ),
    );
  }

  Widget _buildBloodPressureIndicator(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
            border: Border.all(color: color, width: 3),
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}