import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import '../Data/medication_model.dart';
import 'Manger/medication_reminders_cubit.dart';
import 'Manger/medication_reminders_state.dart';


class MedicationRemindersScreen extends StatefulWidget {
  final AnimationController? animationController;

  const MedicationRemindersScreen({Key? key, this.animationController})
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

  @override
  void initState() {
    super.initState();
    _listAnimationController = widget.animationController ??
        AnimationController(
          duration: const Duration(milliseconds: 500),
          vsync: this,
        )..forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    if (widget.animationController == null) {
      _listAnimationController.dispose();
    }
    super.dispose();
  }

  void _showAddMedicationBottomSheet(BuildContext parentContext) {
    _selectedTime = DateTime.now();
    _selectedDays = [0, 1, 2, 3, 4, 5, 6];
    _selectedFrequency = 'Daily';
    _selectedMonthDay = 1;

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => BlocProvider.value(
        value: parentContext.read<MedicationCubit>(),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.teal.shade50, Colors.teal.shade100],
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
                          color: Colors.teal.shade800,
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
                        onPressed: () => _addMedication(context),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
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
        prefixIcon: Icon(prefixIcon, color: Colors.teal.shade700),
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
          borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(color: Colors.teal.shade700),
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
              backgroundColor: backgroundColor ?? Colors.teal.shade700,
              foregroundColor: textColor ?? Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              elevation: 3,
            ),
            onPressed: isLoading ? null : onPressed,
            child: isLoading
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
        border: Border.all(color: Colors.teal.shade100),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Selected Time: ${DateFormat('hh:mm a').format(_selectedTime)}',
              style: GoogleFonts.poppins(
                color: Colors.teal.shade700,
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
        border: Border.all(color: Colors.teal.shade100),
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButton<String>(
        value: _selectedFrequency,
        isExpanded: true,
        underline: Container(),
        dropdownColor: Colors.white,
        style: GoogleFonts.poppins(
          color: Colors.teal.shade700,
          fontWeight: FontWeight.w600,
        ),
        icon: Icon(Iconsax.calendar, color: Colors.teal.shade700),
        items: _frequencyOptions.map((String frequency) {
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
              border: Border.all(color: Colors.teal.shade100),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Select Days',
                    style: GoogleFonts.poppins(
                      color: Colors.teal.shade700,
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
                      selectedColor: Colors.teal.shade100,
                      backgroundColor: Colors.teal.shade50,
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
              border: Border.all(color: Colors.teal.shade100),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Select Day of Month',
                    style: GoogleFonts.poppins(
                      color: Colors.teal.shade700,
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
                  activeColor: Colors.teal.shade700,
                  inactiveColor: Colors.teal.shade100,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Selected Day: $_selectedMonthDay',
                    style: GoogleFonts.poppins(color: Colors.teal.shade500),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _addMedication(BuildContext context) {
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

      context.read<MedicationCubit>().addMedication(
        name: _nameController.text,
        dosage: _dosageController.text,
        time: _selectedTime,
        selectedDays: finalSelectedDays,
        frequency: _selectedFrequency,
        colorHex: Colors.teal.shade200.value.toRadixString(16).padLeft(8, '0'),
      );

      _nameController.clear();
      _dosageController.clear();
      Navigator.pop(context);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.health, size: 100, color: Colors.teal.shade200),
          const SizedBox(height: 20),
          Text(
            'No Medications Added Yet',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
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
        final selectedDayNames =
        medication.selectedDays.map((day) => days[day]).toList().join(', ');
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
    return BlocProvider(
      create: (context) => MedicationCubit(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: SafeArea(
          child: Builder(
            builder: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                              color: Colors.teal.shade800,
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
                          color: Colors.teal.shade800,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextButton.icon(
                          onPressed: () => _showAddMedicationBottomSheet(context),
                          label: const Text(
                            "Add",
                            style: TextStyle(color: Colors.white),
                          ),
                          icon: const Icon(
                            Iconsax.add_circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: BlocListener<MedicationCubit, MedicationState>(
                    listener: (context, state) {
                      if (state is MedicationSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.teal.shade700,
                          ),
                        );
                      } else if (state is MedicationError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red.shade400,
                          ),
                        );
                      }
                    },
                    child: BlocBuilder<MedicationCubit, MedicationState>(
                      builder: (context, state) {
                        if (state is MedicationLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is MedicationEmpty) {
                          return _buildEmptyState();
                        } else if (state is MedicationError) {
                          return Center(
                            child: Text(
                              state.message,
                              style: GoogleFonts.poppins(color: Colors.red),
                            ),
                          );
                        } else if (state is MedicationLoaded) {
                          final medications = state.medications;
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: medications.length,
                            itemBuilder: (context, index) {
                              final medication = medications[index];
                              return AnimatedBuilder(
                                animation: _listAnimationController,
                                builder: (context, child) {
                                  return FadeTransition(
                                    opacity: Tween<double>(begin: 0, end: 1)
                                        .animate(
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
                                  margin:
                                  const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.teal.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Color(
                                          int.parse(
                                            medication.colorHex,
                                            radix: 16,
                                          ),
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Iconsax.health,
                                        color: Colors.teal.shade700,
                                      ),
                                    ),
                                    title: Text(
                                      medication.name,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.teal.shade800,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
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
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Switch(
                                          value: medication.isActive,
                                          onChanged: (_) => context
                                              .read<MedicationCubit>()
                                              .toggleMedicationStatus(
                                              medication),
                                          activeColor: Colors.teal.shade700,
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Iconsax.trash,
                                            color: Colors.red.shade400,
                                          ),
                                          onPressed: () => context
                                              .read<MedicationCubit>()
                                              .deleteMedication(medication.id),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                        return _buildEmptyState();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}