import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;

  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateOfBirthController = TextEditingController();

  bool _editMode = false;
  String _gender = 'Male';
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  DateTime? _dateOfBirth;

  // Reference to Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(widget.uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        setState(() {
          _nameController.text = userData['name'] ?? '';
          _phoneController.text = userData['phone'] ?? '';

          // Handle date of birth

          if (userData['dateOfBirth'] != null) {
            // Parse the date of birth string to DateTime
            _dateOfBirth = DateTime.parse(userData['dateOfBirth'] as String);

            // Format the date for display in the text controller
            _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(_dateOfBirth!);

            // Calculate age from date of birth
            final currentDate = DateTime.now();
            int age = currentDate.year - _dateOfBirth!.year;

            // Adjust age if the birthday hasn't occurred this year
            if (currentDate.month < _dateOfBirth!.month ||
                (currentDate.month == _dateOfBirth!.month &&
                    currentDate.day < _dateOfBirth!.day)) {
              age--;
            }

            // Update the age text controller
            _ageController.text = age.toString();
          }

          // If we have height, weight, gender in the document
          _heightController.text = userData['height']?.toString() ?? '170';
          _weightController.text = userData['weight']?.toString() ?? '70';
          _gender = userData['gender'] ?? 'Male';
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'User data not found';
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error fetching data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Parse values from controllers
      final double height = double.tryParse(_heightController.text) ?? 170.0;
      final double weight = double.tryParse(_weightController.text) ?? 70.0;

      // Create data map to update
      final Map<String, dynamic> userData = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'height': height,
        'weight': weight,
        'gender': _gender,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update in Firestore
      await _firestore.collection('users').doc(widget.uid).update(userData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error updating data: ${e.toString()}';
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      if (_editMode) {
        _saveUserData();
      }
      _editMode = !_editMode;
    });
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Iconsax.trash, color: Colors.red.shade400, size: 24),
            const SizedBox(width: 10),
            Text(
              'Delete Account',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.red.shade400,
              ),
            ),
          ],
        ),
        content: Text(
          'This action cannot be undone. All your data will be permanently removed.',
          style: GoogleFonts.poppins(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Delete user document
                await _firestore
                    .collection('users')
                    .doc(widget.uid)
                    .delete();

                // Get current Firebase user
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  // Delete Firebase Auth user
                  await user.delete();
                }

                // Navigate back to the first screen (login/signup)
                Navigator.of(context).popUntil((route) => route.isFirst);
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Failed to delete account: ${e.toString()}',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Delete Account',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Calculate BMI
  double _calculateBMI() {
    double height = double.tryParse(_heightController.text) ?? 170.0;
    double weight = double.tryParse(_weightController.text) ?? 70.0;
    double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  // Get BMI status
  String _getBMIStatus(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  // Get BMI status color
  Color _getBMIStatusColor(double bmi) {
    if (bmi < 18.5) return Colors.blue.shade400;
    if (bmi < 25) return Colors.green.shade400;
    if (bmi < 30) return Colors.orange.shade400;
    return Colors.red.shade400;
  }

  // Calculate ideal weight range
  String _getIdealWeightRange() {
    double height = double.tryParse(_heightController.text) ?? 170.0;
    double heightInMeters = height / 100;
    double lowerIdealWeight = 18.5 * heightInMeters * heightInMeters;
    double upperIdealWeight = 24.9 * heightInMeters * heightInMeters;
    return '${lowerIdealWeight.toStringAsFixed(1)}-${upperIdealWeight.toStringAsFixed(1)} kg';
  }

  // Daily calorie needs (basic calculation)
  int _calculateBasalMetabolicRate() {
    double weight = double.tryParse(_weightController.text) ?? 70.0;
    double height = double.tryParse(_heightController.text) ?? 170.0;
    int age = int.tryParse(_ageController.text) ?? 30;

    if (_gender == 'Male') {
      return (10 * weight + 6.25 * height - 5 * age + 5).round();
    } else {
      return (10 * weight + 6.25 * height - 5 * age - 161).round();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive layout
    final screenSize = MediaQuery.of(context).size;
    final double bmi = _calculateBMI();
    final String bmiStatus = _getBMIStatus(bmi);
    final Color bmiStatusColor = _getBMIStatusColor(bmi);

    // Responsive calculation for header height
    final headerHeight =
    screenSize.height < 600
        ? screenSize.height * 0.55
        : screenSize.height < 800
        ? screenSize.height * 0.55
        : screenSize.height * 0.58;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.teal.shade700),
              const SizedBox(height: 20),
              Text(
                'Loading profile data...',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.teal.shade700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_hasError) {
      return Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.warning_2, size: 60, color: Colors.red.shade400),
                const SizedBox(height: 20),
                Text(
                  'Error Loading Profile',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade400,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _fetchUserData,
                  icon: const Icon(Iconsax.refresh),
                  label: Text('Try Again', style: GoogleFonts.poppins()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Iconsax.arrow_left, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _editMode ? Iconsax.tick_circle : Iconsax.edit,
                color: Colors.black,
              ),
              onPressed: _toggleEditMode,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: headerHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.teal.shade400,
                    Colors.teal.shade700,
                    Colors.teal.shade900,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.shade200.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SafeArea(
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Adjust avatar size based on available space
                      final avatarSize =
                      constraints.maxHeight < 300 ? 70.0 : 100.0;
                      final nameFontSize =
                      constraints.maxHeight < 300 ? 20.0 : 26.0;
                      final subTextFontSize =
                      constraints.maxHeight < 300 ? 14.0 : 16.0;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Profile avatar with glowing effect
                          Container(
                            height: avatarSize,
                            width: avatarSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              _gender == 'Male' ? Iconsax.man : Iconsax.woman,
                              size: avatarSize * 0.6,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: constraints.maxHeight * 0.05),
                          // Name field
                          _editMode
                              ? Container(
                            width: min(220, screenSize.width * 0.6),
                            child: TextField(
                              controller: _nameController,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: nameFontSize * 0.9,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: 'Your Name',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          )
                              : Text(
                            _nameController.text,
                            style: GoogleFonts.poppins(
                              fontSize: nameFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: constraints.maxHeight * 0.02),
                          // Gender selector
                          _editMode
                              ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildGenderOption('Male', Iconsax.man),
                              const SizedBox(width: 20),
                              _buildGenderOption('Female', Iconsax.woman),
                            ],
                          )
                              : Text(
                            '${_ageController.text} years • $_gender',
                            style: GoogleFonts.poppins(
                              fontSize: subTextFontSize,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),

                          SizedBox(height: constraints.maxHeight * 0.06),

                          // Health Metrics Section - Responsive layout
                          if (!_editMode) ...[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: min(30, screenSize.width * 0.06),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildHealthMetricCard(
                                    'BMI',
                                    bmi.toStringAsFixed(1),
                                    bmiStatus,
                                    bmiStatusColor,
                                  ),
                                  SizedBox(
                                    width: min(15, screenSize.width * 0.03),
                                  ),
                                  _buildHealthMetricCard(
                                    'Calories',
                                    '${_calculateBasalMetabolicRate()}',
                                    'BMR/day',
                                    Colors.amber,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            // Personal Information Card - Responsive padding
            Container(
              margin: EdgeInsets.only(
                top: 30,
                left: max(
                  16,
                  min(24, MediaQuery.of(context).size.width * 0.06),
                ),
                right: max(
                  16,
                  min(24, MediaQuery.of(context).size.width * 0.06),
                ),
                bottom: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(
                  min(24, MediaQuery.of(context).size.width * 0.05),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Iconsax.user,
                            color: Colors.teal.shade700,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Personal Information',
                            style: GoogleFonts.poppins(
                              fontSize: min(
                                18,
                                MediaQuery.of(context).size.width * 0.04,
                              ),
                              fontWeight: FontWeight.w600,
                              color: Colors.teal.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildInfoItem('Phone', _phoneController, '', Iconsax.call),
                    _buildDivider(),
                    _buildDateOfBirthItem(),
                    _buildDivider(),
                    _buildInfoItem(
                      'Height',
                      _heightController,
                      'cm',
                      Iconsax.ruler,
                    ),
                    _buildDivider(),
                    _buildInfoItem(
                      'Weight',
                      _weightController,
                      'kg',
                      Iconsax.weight,
                    ),
                    if (_dateOfBirth != null) ...[
                      _buildDivider(),
                    ],
                  ],
                ),
              ),
            ),

            // Delete Account Button - Responsive margin
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: max(
                  16,
                  min(24, MediaQuery.of(context).size.width * 0.06),
                ),
                vertical: 16,
              ),
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _showDeleteAccountDialog,
                icon: Icon(Iconsax.trash, color: Colors.red.shade400, size: 20),
                label: Text(
                  'Delete Account',
                  style: GoogleFonts.poppins(
                    color: Colors.red.shade400,
                    fontWeight: FontWeight.w500,
                    fontSize: min(
                      15,
                      MediaQuery.of(context).size.width * 0.035,
                    ),
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            // Bottom spacing
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDateOfBirthItem() {
    // Responsive font sizes and width
    final labelSize = MediaQuery.of(context).size.width < 360 ? 14.0 : 16.0;
    final valueSize = MediaQuery.of(context).size.width < 360 ? 14.0 : 16.0;
    final textFieldWidth =
    MediaQuery.of(context).size.width < 360 ? 120.0 : 150.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Iconsax.calendar, color: Colors.teal.shade700, size: 20),
        ),
        const SizedBox(width: 16),
        Text(
          'Date of Birth',
          style: GoogleFonts.poppins(
            fontSize: labelSize,
            color: Colors.grey.shade800,
          ),
        ),
        const Spacer(),
        _editMode
            ? Container(
          width: textFieldWidth,
          height: 40,
          child: InkWell(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _dateOfBirth ?? DateTime(2000),
                firstDate: DateTime(1920),
                lastDate: DateTime.now(),
                builder: (BuildContext context, Widget? child) {
                  return Theme(
                    data: ThemeData.light().copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Colors.teal.shade700,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black,
                      ),
                      dialogBackgroundColor: Colors.white,
                    ),
                    child: child!,
                  );
                },
              );

              if (picked != null && picked != _dateOfBirth) {
                setState(() {
                  _dateOfBirth = picked;
                  _dateOfBirthController.text = DateFormat(
                    'yyyy-MM-dd',
                  ).format(picked);

                  // Update age
                  final currentDate = DateTime.now();
                  int age = currentDate.year - picked.year;
                  if (currentDate.month < picked.month ||
                      (currentDate.month == picked.month &&
                          currentDate.day < picked.day)) {
                    age--;
                  }
                  _ageController.text = age.toString();
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.teal.shade200),
                borderRadius: BorderRadius.circular(30),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _dateOfBirthController.text.isNotEmpty
                        ? _dateOfBirthController.text
                        : 'Select date',
                    style: GoogleFonts.poppins(
                      fontSize: valueSize,
                      color:
                      _dateOfBirthController.text.isNotEmpty
                          ? Colors.teal.shade700
                          : Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Iconsax.calendar_1,
                    size: 16,
                    color: Colors.teal.shade700,
                  ),
                ],
              ),
            ),
          ),
        )
            : Text(
          _dateOfBirth != null
              ? DateFormat('MMM d, yyyy').format(_dateOfBirth!)
              : 'Not set',
          style: GoogleFonts.poppins(
            fontSize: valueSize,
            fontWeight: FontWeight.w500,
            color:
            _dateOfBirth != null
                ? Colors.teal.shade700
                : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthMetricCard(
      String title,
      String value,
      String subtitle,
      Color accentColor,
      ) {
    // Responsive font sizes
    final titleSize = MediaQuery.of(context).size.width < 360 ? 10.0 : 12.0;
    final valueSize = MediaQuery.of(context).size.width < 360 ? 20.0 : 22.0;
    final subtitleSize = MediaQuery.of(context).size.width < 360 ? 9.0 : 11.0;

    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: min(12, MediaQuery.of(context).size.height * 0.015),
          horizontal: min(12, MediaQuery.of(context).size.width * 0.03),
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: titleSize,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            SizedBox(
              height: min(4, MediaQuery.of(context).size.height * 0.005),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: valueSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                top: min(6, MediaQuery.of(context).size.height * 0.008),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: min(10, MediaQuery.of(context).size.width * 0.025),
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: subtitleSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderOption(String genderValue, IconData icon) {
    // Responsive size adjustments
    final double fontSize =
    MediaQuery.of(context).size.width < 360 ? 13.0 : 14.0;
    final double horizontalPadding =
    MediaQuery.of(context).size.width < 360 ? 15.0 : 20.0;

    final isSelected = _gender == genderValue;
    return GestureDetector(
      onTap: () => setState(() => _gender = genderValue),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? Colors.teal.shade700 : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.teal.shade700 : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              genderValue,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.teal.shade700 : Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
      String label,
      TextEditingController controller,
      String unit,
      IconData icon,
      ) {
    // Responsive font sizes and width
    final labelSize = MediaQuery.of(context).size.width < 360 ? 14.0 : 16.0;
    final valueSize = MediaQuery.of(context).size.width < 360 ? 14.0 : 16.0;
    final textFieldWidth =
    MediaQuery.of(context).size.width < 360 ? 80.0 : 100.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.teal.shade700, size: 20),
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: labelSize,
            color: Colors.grey.shade800,
          ),
        ),
        const Spacer(),
        _editMode
            ? Container(
          width: textFieldWidth,
          height: 40,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: valueSize,
              color: Colors.teal.shade700,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 0,
              ),
              suffix: Text(
                unit,
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: max(11, min(13, valueSize - 3)),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.teal.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: Colors.teal.shade700,
                  width: 2,
                ),
              ),
            ),
          ),
        )
            : Text(
          '${controller.text} $unit',
          style: GoogleFonts.poppins(
            fontSize: valueSize,
            fontWeight: FontWeight.w500,
            color: Colors.teal.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(color: Colors.grey.shade200, thickness: 1.5),
    );
  }
}
