import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import '../Data/medication_model.dart';
import 'Manger/medication_reminders_cubit.dart';
import 'Manger/medication_reminders_state.dart';
import 'package:lottie/lottie.dart';

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
  bool _isSubmitting = false;

  final List<String> _frequencyOptions = ['Daily', 'Weekly', 'Monthly'];

  @override
  void initState() {
    super.initState();
    _listAnimationController =
        widget.animationController ??
              AnimationController(
                duration: const Duration(milliseconds: 500),
                vsync: this,
              )
          ..forward();
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
    _nameController.clear();
    _dosageController.clear();
    _selectedTime = DateTime.now();
    _selectedDays = [0, 1, 2, 3, 4, 5, 6];
    _selectedFrequency = 'Daily';
    _selectedMonthDay = 1;
    _isSubmitting = false;

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder:
          (context) => BlocProvider.value(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Add New Medication',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade800,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.teal.shade800,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildResponsiveTextField(
                            controller: _nameController,
                            labelText: 'Medication Name',
                            prefixIcon: Iconsax.document_text,
                            hintText: 'Enter medication name',
                          ),
                          const SizedBox(height: 15),
                          _buildResponsiveTextField(
                            controller: _dosageController,
                            labelText: 'Dosage',
                            prefixIcon: Iconsax.document_text,
                            hintText: 'Enter dosage (e.g. 1 pill)',
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
                            onPressed:
                                () => _addMedication(context, setModalState),
                            isLoading: _isSubmitting,
                            icon: Iconsax.add_circle,
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

  Widget _buildTimePicker(StateSetter setModalState) {
    return GestureDetector(
      onTap: () async {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_selectedTime),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.teal.shade600,
                  onPrimary: Colors.white,
                  surface: Colors.teal.shade50,
                  onSurface: Colors.teal.shade800,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.teal.shade600,
                  ),
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedTime != null) {
          setModalState(() {
            final now = DateTime.now();
            _selectedTime = DateTime(
              now.year,
              now.month,
              now.day,
              pickedTime.hour,
              pickedTime.minute,
            );
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.shade200.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Iconsax.clock, color: Colors.teal.shade600, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                DateFormat.jm().format(_selectedTime), // e.g., 3:30 PM
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.teal.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.teal.shade600, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    String? hintText,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
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
        filled: true,
        fillColor: Colors.white.withOpacity(0.7),
        labelStyle: GoogleFonts.poppins(color: Colors.teal.shade700),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
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
            child:
                isLoading
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: textColor ?? Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Processing...',
                          style: GoogleFonts.poppins(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
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

  Widget _buildFrequencyDropdown(StateSetter setModalState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.teal.shade100),
        borderRadius: BorderRadius.circular(15),
        color: Colors.white.withOpacity(0.7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Frequency',
              style: GoogleFonts.poppins(
                color: Colors.teal.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          DropdownButton<String>(
            value: _selectedFrequency,
            isExpanded: true,
            underline: Container(),
            dropdownColor: Colors.white,
            style: GoogleFonts.poppins(
              color: Colors.teal.shade700,
              fontWeight: FontWeight.w600,
            ),
            icon: Icon(Iconsax.arrow_down_1, color: Colors.teal.shade700),
            items:
                _frequencyOptions.map((String frequency) {
                  return DropdownMenuItem<String>(
                    value: frequency,
                    child: Row(
                      children: [
                        Icon(
                          frequency == 'Daily'
                              ? Iconsax.calendar_1
                              : frequency == 'Weekly'
                              ? Iconsax.calendar_2
                              : Iconsax.calendar,
                          color: Colors.teal.shade700,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(frequency),
                      ],
                    ),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              setModalState(() {
                _selectedFrequency = newValue!;
              });
            },
          ),
        ],
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
              color: Colors.white.withOpacity(0.7),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.calendar_1,
                        color: Colors.teal.shade700,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Select Days',
                        style: GoogleFonts.poppins(
                          color: Colors.teal.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12.0,
                    left: 8.0,
                    right: 8.0,
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(7, (index) {
                      final isSelected = _selectedDays.contains(index);
                      return ChoiceChip(
                        label: Text(
                          days[index],
                          style: TextStyle(
                            color:
                                isSelected
                                    ? Colors.white
                                    : Colors.teal.shade700,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
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
                        selectedColor: Colors.teal.shade700,
                        backgroundColor: Colors.teal.shade50,
                        elevation: isSelected ? 3 : 0,
                        shadowColor:
                            isSelected
                                ? Colors.teal.shade200
                                : Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        if (_selectedFrequency == 'Monthly')
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.teal.shade100),
              borderRadius: BorderRadius.circular(15),
              color: Colors.white.withOpacity(0.7),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.calendar,
                        color: Colors.teal.shade700,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Select Day of Month',
                        style: GoogleFonts.poppins(
                          color: Colors.teal.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Day $_selectedMonthDay of each month',
                    style: GoogleFonts.poppins(
                      color: Colors.teal.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _addMedication(BuildContext context, StateSetter setModalState) async {
    if (_nameController.text.isEmpty || _dosageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    setModalState(() {
      _isSubmitting = true;
    });

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

    try {
      await context.read<MedicationCubit>().addMedication(
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
    } finally {
      // In case the modal is still open (e.g., due to error)
      setModalState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildEmptyState(Context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Use Lottie animation if available, otherwise use icon
          SizedBox(
            height: 200,
            child: Icon(Iconsax.health, size: 100, color: Colors.teal.shade200),
          ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Tap the + button to add your first medication reminder',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => _showAddMedicationBottomSheet(Context),
            icon: Icon(Iconsax.add_circle, color: Colors.white),
            label: Text(
              'Add Medication',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 100,
            width: 100,
            child: CircularProgressIndicator(
              color: Colors.teal.shade700,
              strokeWidth: 5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading medications...',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.teal.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
          const SizedBox(height: 20),
          Text(
            'Error',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => context.read<MedicationCubit>().loadMedications(),
            icon: Icon(Icons.refresh, color: Colors.white),
            label: Text(
              'Try Again',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
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
    return BlocProvider(
      create: (context) => MedicationCubit(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: SafeArea(
          child: Builder(
            builder:
                (context) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: BlocListener<MedicationCubit, MedicationState>(
                        listener: (context, state) {
                          if (state is MedicationSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message),
                                backgroundColor: Colors.teal.shade700,
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.all(10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                action: SnackBarAction(
                                  label: 'DISMISS',
                                  textColor: Colors.white,
                                  onPressed: () {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).hideCurrentSnackBar();
                                  },
                                ),
                              ),
                            );
                          } else if (state is MedicationError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message),
                                backgroundColor: Colors.red.shade400,
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.all(10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                action: SnackBarAction(
                                  label: 'DISMISS',
                                  textColor: Colors.white,
                                  onPressed: () {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).hideCurrentSnackBar();
                                  },
                                ),
                              ),
                            );
                          }
                        },
                        child: BlocBuilder<MedicationCubit, MedicationState>(
                          builder: (context, state) {
                            if (state is MedicationInitial) {
                              // Trigger loading medications when the UI is first built
                              Future.microtask(
                                () =>
                                    context
                                        .read<MedicationCubit>()
                                        .loadMedications(),
                              );
                              return _buildLoadingState();
                            } else if (state is MedicationLoading) {
                              return _buildLoadingState();
                            } else if (state is MedicationEmpty) {
                              return _buildEmptyState(context);
                            } else if (state is MedicationError) {
                              return _buildErrorState(state.message);
                            } else if (state is MedicationLoaded) {
                              final medications = state.medications;
                              return RefreshIndicator(
                                onRefresh:
                                    () =>
                                        context
                                            .read<MedicationCubit>()
                                            .loadMedications(),
                                color: Colors.teal.shade700,
                                backgroundColor: Colors.white,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
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
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.teal
                                                      .withOpacity(0.1),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: ListTile(
                                              contentPadding:
                                                  const EdgeInsets.all(15),
                                              leading: Container(
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Color(
                                                    int.parse(
                                                      medication.colorHex,
                                                      radix: 16,
                                                    ),
                                                  ),
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Color(
                                                        int.parse(
                                                          medication.colorHex,
                                                          radix: 16,
                                                        ),
                                                      ).withOpacity(0.3),
                                                      blurRadius: 8,
                                                      offset: const Offset(
                                                        0,
                                                        3,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Icon(
                                                  Iconsax.health,
                                                  color: Colors.teal.shade700,
                                                  size: 24,
                                                ),
                                              ),
                                              title: Text(
                                                medication.name,
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.teal.shade800,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    '${medication.dosage} • ${DateFormat('hh:mm a').format(medication.time)}',
                                                    style: GoogleFonts.poppins(
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    _formatMedicationSchedule(
                                                      medication,
                                                    ),
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.grey.shade500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Switch(
                                                    value: medication.isActive,
                                                    onChanged:
                                                        (_) => context
                                                            .read<
                                                              MedicationCubit
                                                            >()
                                                            .toggleMedicationStatus(
                                                              medication,
                                                            ),
                                                    activeColor:
                                                        Colors.teal.shade700,
                                                    activeTrackColor:
                                                        Colors.teal.shade200,
                                                  ),
                                                  IconButton(
                                                    icon: Icon(
                                                      Iconsax.trash,
                                                      color:
                                                          Colors.red.shade400,
                                                    ),
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder:
                                                            (
                                                              ctx,
                                                            ) => AlertDialog(
                                                              title: Text(
                                                                'Delete Medication',
                                                                style: GoogleFonts.poppins(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      Colors
                                                                          .teal
                                                                          .shade800,
                                                                ),
                                                              ),
                                                              content: Text(
                                                                'Are you sure you want to delete ${medication.name}?',
                                                                style: GoogleFonts.poppins(
                                                                  color:
                                                                      Colors
                                                                          .grey
                                                                          .shade700,
                                                                ),
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () => Navigator.pop(
                                                                        context,
                                                                      ),
                                                                  child: Text(
                                                                    'Cancel',
                                                                    style: GoogleFonts.poppins(
                                                                      color:
                                                                          Colors
                                                                              .grey
                                                                              .shade700,
                                                                    ),
                                                                  ),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () {
                                                                    context
                                                                        .read<
                                                                          MedicationCubit
                                                                        >()
                                                                        .deleteMedication(
                                                                          medication
                                                                              .id,
                                                                        );
                                                                    Navigator.pop(
                                                                      context,
                                                                    );
                                                                  },
                                                                  child: Text(
                                                                    'Delete',
                                                                    style: GoogleFonts.poppins(
                                                                      color:
                                                                          Colors
                                                                              .red
                                                                              .shade400,
                                                                      fontWeight:
                                                                          FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      15,
                                                                    ),
                                                              ),
                                                            ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              );
                            }

                            // If none of the above states match, initialize the cubit
                            Future.microtask(
                              () =>
                                  context
                                      .read<MedicationCubit>()
                                      .loadMedications(),
                            );
                            return _buildEmptyState(context);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
          ),
        ),
        floatingActionButton: BlocBuilder<MedicationCubit, MedicationState>(
          builder: (context, state) {
            return FloatingActionButton(
              onPressed: () => _showAddMedicationBottomSheet(context),
              backgroundColor: Colors.teal.shade700,
              child: const Icon(Iconsax.add, color: Colors.white),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            );
          },
        ),
      ),
    );
  }
}
