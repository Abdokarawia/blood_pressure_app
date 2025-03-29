import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medication Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: MedicationTrackerHome(),
    );
  }
}

class MedicationTrackerHome extends StatefulWidget {
  @override
  _MedicationTrackerHomeState createState() => _MedicationTrackerHomeState();
}

class _MedicationTrackerHomeState extends State<MedicationTrackerHome>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: MedicationRemindersScreen(
          animationController: _animationController,
        ),
      ),
    );
  }
}

// Medication Model
class Medication {
  final String id;
  final String name;
  final String dosage;
  final DateTime time;
  final List<int> selectedDays;
  bool isActive;
  final String frequency;
  final Color color;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    this.selectedDays = const [0, 1, 2, 3, 4, 5, 6],
    this.isActive = true,
    this.frequency = 'Daily',
    Color? color,
  }) : color = color ?? _generateRandomPastelColor();

  static Color _generateRandomPastelColor() {
    return Color.fromRGBO(
      200 + (DateTime.now().millisecondsSinceEpoch % 55),
      200 + (DateTime.now().millisecondsSinceEpoch % 55),
      200 + (DateTime.now().millisecondsSinceEpoch % 55),
      0.5,
    );
  }
}

class MedicationRemindersScreen extends StatefulWidget {
  final AnimationController animationController;

  const MedicationRemindersScreen({Key? key, required this.animationController})
    : super(key: key);

  @override
  _MedicationRemindersScreenState createState() =>
      _MedicationRemindersScreenState();
}

class _MedicationRemindersScreenState extends State<MedicationRemindersScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  DateTime _selectedTime = DateTime.now();
  List<int> _selectedDays = [0, 1, 2, 3, 4, 5, 6];
  String _selectedFrequency = 'Daily';
  int _selectedMonthDay = 1;
  late AnimationController _listAnimationController;

  final List<String> _frequencyOptions = ['Daily', 'Weekly', 'Monthly'];

  List<Medication> medications = [
    Medication(
      id: '1',
      name: 'Aspirin',
      dosage: '100mg',
      time: DateTime.now().add(const Duration(hours: 2)),
      selectedDays: [1, 3, 5],
      frequency: 'Weekly',
      color: Colors.blue.withOpacity(0.2),
    ),
    Medication(
      id: '2',
      name: 'Vitamin D',
      dosage: '1000 IU',
      time: DateTime.now().add(const Duration(hours: 4)),
      color: Colors.green.withOpacity(0.2),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  void _showAddMedicationBottomSheet() {
    _selectedTime = DateTime.now();
    _selectedDays = [0, 1, 2, 3, 4, 5, 6];
    _selectedFrequency = 'Daily';
    _selectedMonthDay = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                ),
                child: Padding(
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
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
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
                        _buildTimePicker(setModalState),
                        const SizedBox(height: 15),
                        _buildFrequencyDropdown(setModalState),
                        const SizedBox(height: 15),
                        _buildDaySelector(setModalState),
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
            },
          ),
    );
  }

  Widget _buildResponsiveTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
  }) {
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(color: Colors.blue.shade700),
      ),
    );
  }

  Widget _buildResponsiveButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    bool isLoading = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double buttonHeight = constraints.maxWidth < 600 ? 48 : 56;
        final double fontSize = constraints.maxWidth < 600 ? 14 : 16;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: buttonHeight,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? Colors.blue.shade700,
              foregroundColor: textColor ?? Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              elevation: 3,
            ),
            onPressed: isLoading ? null : onPressed,
            child:
                isLoading
                    ? CircularProgressIndicator(
                      color: textColor ?? Colors.white,
                      strokeWidth: 2,
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(icon, size: fontSize + 4),
                          ),
                        Text(
                          text,
                          style: GoogleFonts.poppins(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
          ),
        );
      },
    );
  }

  Widget _buildTimePicker(StateSetter setModalState) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade100),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Selected Time: ${DateFormat('hh:mm a').format(_selectedTime)}',
              style: GoogleFonts.poppins(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          CupertinoTimerPicker(
            mode: CupertinoTimerPickerMode.hm,
            onTimerDurationChanged: (Duration duration) {
              setModalState(() {
                _selectedTime = DateTime.now().toUtc().add(duration);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyDropdown(StateSetter setModalState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade100),
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButton<String>(
        value: _selectedFrequency,

        isExpanded: true,
        underline: Container(),
        dropdownColor: Colors.white,
        style: GoogleFonts.poppins(
          color: Colors.blue.shade700,
          fontWeight: FontWeight.w600,
        ),
        icon: Icon(Iconsax.calendar, color: Colors.blue.shade700),
        items:
            _frequencyOptions.map((String frequency) {
              return DropdownMenuItem<String>(
                value: frequency,
                child: Text(frequency),
              );
            }).toList(),
        onChanged: (String? newValue) {
          setModalState(() {
            _selectedFrequency = newValue!;
          });
        },
      ),
    );
  }

  Widget _buildDaySelector(StateSetter setModalState) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Column(
      children: [
        if (_selectedFrequency == 'Weekly')
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue.shade100),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Select Days',
                    style: GoogleFonts.poppins(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: List.generate(7, (index) {
                    final isSelected = _selectedDays.contains(index);
                    return ChoiceChip(
                      label: Text(days[index]),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setModalState(() {
                          if (selected) {
                            _selectedDays.add(index);
                          } else {
                            _selectedDays.remove(index);
                          }
                        });
                      },
                      selectedColor: Colors.blue.shade100,
                      backgroundColor: Colors.blue.shade50,
                    );
                  }),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),

        if (_selectedFrequency == 'Monthly')
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue.shade100),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Select Day of Month',
                    style: GoogleFonts.poppins(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Slider(
                  value: _selectedMonthDay.toDouble(),
                  min: 1,
                  max: 31,
                  divisions: 30,
                  label: _selectedMonthDay.toString(),
                  onChanged: (double value) {
                    setModalState(() {
                      _selectedMonthDay = value.toInt();
                    });
                  },
                  activeColor: Colors.blue.shade700,
                  inactiveColor: Colors.blue.shade100,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Selected Day: $_selectedMonthDay',
                    style: GoogleFonts.poppins(color: Colors.blue.shade500),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _addMedication() {
    if (_nameController.text.isNotEmpty && _dosageController.text.isNotEmpty) {
      List<int> finalSelectedDays;

      switch (_selectedFrequency) {
        case 'Daily':
          finalSelectedDays = [0, 1, 2, 3, 4, 5, 6];
          break;
        case 'Weekly':
          finalSelectedDays =
              _selectedDays.isEmpty ? [0, 1, 2, 3, 4, 5, 6] : _selectedDays;
          break;
        case 'Monthly':
          finalSelectedDays = [_selectedMonthDay - 1];
          break;
        default:
          finalSelectedDays = [0, 1, 2, 3, 4, 5, 6];
      }

      final newMedication = Medication(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        dosage: _dosageController.text,
        time: _selectedTime,
        selectedDays: finalSelectedDays,
        frequency: _selectedFrequency,
      );

      setState(() {
        medications.add(newMedication);
        _nameController.clear();
        _dosageController.clear();
      });

      Navigator.pop(context);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.health, size: 100, color: Colors.blue.shade200),
          const SizedBox(height: 20),
          Text(
            'No Medications Added Yet',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tap the + button to add your first medication',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatMedicationSchedule(Medication medication) {
    switch (medication.frequency) {
      case 'Daily':
        return 'Daily at ${DateFormat('hh:mm a').format(medication.time)}';

      case 'Weekly':
        final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        final selectedDayNames = medication.selectedDays
            .map((day) => days[day])
            .toList()
            .join(', ');
        return 'Weekly on $selectedDayNames at ${DateFormat('hh:mm a').format(medication.time)}';

      case 'Monthly':
        final day = medication.selectedDays.first + 1;
        return 'Monthly on the $day${_getDaySuffix(day)} at ${DateFormat('hh:mm a').format(medication.time)}';

      default:
        return 'Unspecified Schedule';
    }
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medication Tracker',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      Text(
                        'Keep track of your health',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade800,
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: TextButton.icon(
                      onPressed: _showAddMedicationBottomSheet,
                      label: Text("Add Medication", style: const TextStyle(color: Colors.white)), // Customizable text color
                      icon: const Icon(
                        Iconsax.add_circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Medication List
            Expanded(
              child:
                  medications.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: medications.length,
                        itemBuilder: (context, index) {
                          final medication = medications[index];
                          return AnimatedBuilder(
                            animation: _listAnimationController,
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: Tween<double>(
                                  begin: 0,
                                  end: 1,
                                ).animate(
                                  CurvedAnimation(
                                    parent: _listAnimationController,
                                    curve: Interval(
                                      index * 0.1,
                                      1.0,
                                      curve: Curves.easeOut,
                                    ),
                                  ),
                                ),
                                child: child,
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: medication.color,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Iconsax.health,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                title: Text(
                                  medication.name,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${medication.dosage} • ${DateFormat('hh:mm a').format(medication.time)}',
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      _formatMedicationSchedule(medication),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Switch(
                                  value: medication.isActive,
                                  onChanged:
                                      (_) =>
                                          _toggleMedicationStatus(medication),
                                  activeColor: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleMedicationStatus(Medication medication) {
    setState(() {
      medication.isActive = !medication.isActive;
    });
  }
}
