import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../Home/Presentation/Home_View.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileData profileData;

  const EditProfileScreen({
    super.key,
    required this.profileData,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _heartRateController;
  String _selectedGender = '';
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profileData.name);
    _ageController = TextEditingController(text: widget.profileData.age.toString());
    _heightController = TextEditingController(text: widget.profileData.height.toString());
    _weightController = TextEditingController(text: widget.profileData.weight.toString());
    _heartRateController = TextEditingController(text: widget.profileData.heartRate.toString());
    _selectedGender = widget.profileData.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _heartRateController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    final updatedProfile = ProfileData(
      name: _nameController.text,
      age: int.parse(_ageController.text),
      gender: _selectedGender,
      height: double.parse(_heightController.text),
      weight: double.parse(_weightController.text),
      heartRate: int.parse(_heartRateController.text),
      bloodPressureProfile: widget.profileData.bloodPressureProfile,
      medicalConditions: widget.profileData.medicalConditions,
      healthGoals: widget.profileData.healthGoals,
    );

    // Here you would typically save to database or state management
    // For now we'll just navigate back
    if (mounted) {
      Navigator.pop(context, updatedProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Text(
              'SAVE',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.teal
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section
              // Personal Information
              _buildSectionTitle('Personal Information'),
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Iconsax.user,
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),
              _buildGenderSelector(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _ageController,
                label: 'Age',
                icon: Iconsax.calendar,
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty || int.tryParse(value) == null ? 'Please enter a valid age' : null,
              ),

              const SizedBox(height: 30),

              // Health Metrics
              _buildSectionTitle('Health Metrics'),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _heightController,
                      label: 'Height (cm)',
                      icon: Iconsax.ruler,
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                      value!.isEmpty || double.tryParse(value) == null ? 'Enter valid height' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _weightController,
                      label: 'Weight (kg)',
                      icon: Iconsax.weight,
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                      value!.isEmpty || double.tryParse(value) == null ? 'Enter valid weight' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _heartRateController,
                label: 'Resting Heart Rate (bpm)',
                icon: Iconsax.heart,
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty || int.tryParse(value) == null ? 'Enter valid heart rate' : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.teal.shade100,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/profile_placeholder.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.shade600,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: const Icon(Iconsax.camera, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: Colors.teal.shade600),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal.shade600, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      validator: validator,
    );
  }

  Widget _buildGenderSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedGender.isEmpty ? null : _selectedGender,
      decoration: InputDecoration(
        labelText: 'Gender',
        labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
        prefixIcon: Icon(Iconsax.profile_2user, color: Colors.teal.shade600),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal.shade600, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      ),
      dropdownColor: Colors.white,
      style: GoogleFonts.poppins(),
      items: ['Male', 'Female', 'Other', 'Prefer not to say']
          .map((gender) => DropdownMenuItem(
        value: gender,
        child: Text(gender),
      ))
          .toList(),
      onChanged: (value) => setState(() => _selectedGender = value ?? ''),
      validator: (value) => value == null ? 'Please select your gender' : null,
    );
  }
}

