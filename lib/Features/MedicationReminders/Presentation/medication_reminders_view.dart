import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

// Model to represent a medication
class Medication {
  final String id;
  final String name;
  final String dosage;
  final DateTime time;
  bool isActive;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    this.isActive = true,
  });
}

class MedicationRemindersScreen extends StatefulWidget {
  final AnimationController animationController;

  const MedicationRemindersScreen({
    super.key,
    required this.animationController,
  });

  @override
  _MedicationRemindersScreenState createState() => _MedicationRemindersScreenState();
}

class _MedicationRemindersScreenState extends State<MedicationRemindersScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  DateTime _selectedTime = DateTime.now();

  // Medication list with unique IDs
  List<Medication> medications = [
    Medication(
      id: '1',
      name: 'Aspirin',
      dosage: '100mg',
      time: DateTime.now().add(const Duration(hours: 2)),
    ),
    Medication(
      id: '2',
      name: 'Vitamin D',
      dosage: '1000 IU',
      time: DateTime.now().add(const Duration(hours: 4)),
    ),
  ];

  // Method to show add medication bottom sheet
  void _showAddMedicationBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add New Medication',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 20),
              _buildResponsiveTextField(
                controller: _nameController,
                labelText: 'Medication Name',
                prefixIcon: Iconsax.document_text,
              ),
              const SizedBox(height: 15),
              _buildResponsiveTextField(
                controller: _dosageController,
                labelText: 'Dosage',
                prefixIcon: Iconsax.document_text,
              ),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.shade100),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hm,
                  onTimerDurationChanged: (Duration duration) {
                    setState(() {
                      _selectedTime = DateTime.now().add(duration);
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              _buildResponsiveButton(
                text: 'Add Medication',
                onPressed: _addMedication,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Responsive TextField
  Widget _buildResponsiveTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            prefixIcon: Icon(prefixIcon, color: Colors.blue.shade700),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.blue.shade100),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.blue.shade100),
            ),
          ),
        );
      },
    );
  }

  // Responsive Button
  Widget _buildResponsiveButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            minimumSize: Size(constraints.maxWidth, 50),
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  // Add medication method
  void _addMedication() {
    if (_nameController.text.isNotEmpty && _dosageController.text.isNotEmpty) {
      final newMedication = Medication(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        dosage: _dosageController.text,
        time: _selectedTime,
      );

      setState(() {
        medications.add(newMedication);
        _nameController.clear();
        _dosageController.clear();
      });

      Navigator.pop(context);
    }
  }

  // Toggle medication active status
  void _toggleMedicationStatus(Medication medication) {
    setState(() {
      medication.isActive = !medication.isActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          margin: EdgeInsets.only(top: constraints.maxHeight * 0.05),
          child: Column(
            children: [
              AnimatedBuilder(
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
                  margin: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth * 0.05,
                    vertical: constraints.maxHeight * 0.02,
                  ),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.withOpacity(0.2),
                        const Color(0xFFE0F2F1).withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.1),
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
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Iconsax.health,
                          color: Colors.blue.shade700,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Medication Reminders',
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 18 : 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            Text(
                              'Track and manage your medications',
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Iconsax.add_circle,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _showAddMedicationBottomSheet();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Medication List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth * 0.05,
                  ),
                  itemCount: medications.length,
                  itemBuilder: (context, index) {
                    final medication = medications[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                        border: Border.all(
                          color: medication.isActive
                              ? Colors.blue.shade100
                              : Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: medication.isActive
                                ? Colors.blue.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Iconsax.health,
                            color: medication.isActive
                                ? Colors.blue.shade700
                                : Colors.grey.shade500,
                          ),
                        ),
                        title: Text(
                          medication.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: medication.isActive
                                ? Colors.blue.shade700
                                : Colors.grey.shade500,
                          ),
                        ),
                        subtitle: Text(
                          '${medication.dosage} • ${DateFormat('HH:mm').format(medication.time)}',
                          style: GoogleFonts.poppins(
                            color: medication.isActive
                                ? Colors.blue.shade300
                                : Colors.grey.shade400,
                          ),
                        ),
                        trailing: Switch(
                          value: medication.isActive,
                          onChanged: (_) => _toggleMedicationStatus(medication),
                          activeColor: Colors.blue.shade700,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }
}