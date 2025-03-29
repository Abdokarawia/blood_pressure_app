import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class WeeklyDataView extends StatefulWidget {
  final String uid;
  final Function(Map<String, dynamic>) onShareData;

  const WeeklyDataView({
    Key? key,
    required this.uid,
    required this.onShareData,
  }) : super(key: key);

  @override
  _WeeklyDataViewState createState() => _WeeklyDataViewState();
}

class _WeeklyDataViewState extends State<WeeklyDataView> {
  int _selectedDayIndex = 0;
  final List<String> _days = [];
  final Map<String, Map<String, dynamic>> _weeklyData = {};
  bool _isLoading = true;

  // Track which data types are selected for sharing
  final Map<String, bool> _selectedDataTypes = {
    'drivingTime': false,
    'distance': false,
    'fuelConsumption': false,
    'speedViolations': false,
    'hardBraking': false,
  };

  @override
  void initState() {
    super.initState();
    _generateLastSevenDays();
    _fetchWeeklyData();
  }

  void _generateLastSevenDays() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      _days.add(formatter.format(date));
    }
  }

  Future<void> _fetchWeeklyData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // This is a placeholder for your actual data fetching logic
      // Replace this with your Firebase or API call
      await Future.delayed(const Duration(seconds: 1));

      // Sample data structure - replace with your actual data model
      for (String day in _days) {
        _weeklyData[day] = {
          'drivingTime': (40 + _days.indexOf(day) * 5).toDouble(),
          'distance': (15.2 + _days.indexOf(day) * 2.3).toDouble(),
          'fuelConsumption': (3.4 + _days.indexOf(day) * 0.5).toDouble(),
          'speedViolations': _days.indexOf(day) % 3 == 0 ? 1 : 0,
          'hardBraking': _days.indexOf(day) % 4 == 0 ? 2 : 1,
        };
      }
    } catch (e) {
      // Handle errors
      print('Error fetching weekly data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _shareData() {
    // Get selected data types
    final selectedTypes = _selectedDataTypes.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedTypes.isEmpty) {
      // Show a message if no data types are selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one data type to share')),
      );
      return;
    }

    final selectedDay = _days[_selectedDayIndex];
    final dataToShare = <String, dynamic>{};

    // Add selected data types to the sharing payload
    for (String type in selectedTypes) {
      if (_weeklyData[selectedDay]!.containsKey(type)) {
        dataToShare[type] = _weeklyData[selectedDay]![type];
      }
    }

    dataToShare['date'] = selectedDay;

    // Call the sharing callback function
    widget.onShareData(dataToShare);

    // Show confirmation to user
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Data Shared'),
        content: Text('Selected data has been shared successfully.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Last 7 Days Data', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFE67E5E),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE67E5E)))
          : Column(
        children: [
          _buildDaysSelector(),
          Expanded(child: _buildDayDataView()),
          _buildSharingSection(),
        ],
      ),
    );
  }

  Widget _buildDaysSelector() {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (context, index) {
          final day = _days[index];
          final date = DateTime.parse(day);
          final isSelected = index == _selectedDayIndex;
          final dayName = DateFormat('EEE').format(date);
          final dayNumber = DateFormat('d').format(date);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDayIndex = index;
              });
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE67E5E) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? const Color(0xFFE67E5E) : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayNumber,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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

  Widget _buildDayDataView() {
    final selectedDay = _days[_selectedDayIndex];
    final data = _weeklyData[selectedDay];

    if (data == null) {
      return Center(child: Text('No data available for this day'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data for ${DateFormat('EEEE, MMMM d, yyyy').format(DateTime.parse(selectedDay))}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildDataCard(
            'Driving Time',
            '${data['drivingTime']} minutes',
            Icons.timer_outlined,
          ),
          _buildDataCard(
            'Distance',
            '${data['distance']} km',
            Icons.directions_car_outlined,
          ),
          _buildDataCard(
            'Fuel Consumption',
            '${data['fuelConsumption']} L',
            Icons.local_gas_station_outlined,
          ),
          _buildDataCard(
            'Speed Violations',
            '${data['speedViolations']}',
            Icons.speed_outlined,
          ),
          _buildDataCard(
            'Hard Braking',
            '${data['hardBraking']}',
            Icons.do_not_step_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 28, color: const Color(0xFFE67E5E)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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

  Widget _buildSharingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildDataTypeChip('Driving Time', 'drivingTime'),
              _buildDataTypeChip('Distance', 'distance'),
              _buildDataTypeChip('Fuel Consumption', 'fuelConsumption'),
              _buildDataTypeChip('Speed Violations', 'speedViolations'),
              _buildDataTypeChip('Hard Braking', 'hardBraking'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _shareData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE67E5E),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Share Selected Data',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTypeChip(String label, String dataType) {
    return FilterChip(
      label: Text(label),
      selected: _selectedDataTypes[dataType] ?? false,
      onSelected: (selected) {
        setState(() {
          _selectedDataTypes[dataType] = selected;
        });
      },
      selectedColor: const Color(0xFFE67E5E).withOpacity(0.2),
      checkmarkColor: const Color(0xFFE67E5E),
      backgroundColor: Colors.grey.shade200,
      labelStyle: TextStyle(
        color: _selectedDataTypes[dataType] ?? false
            ? const Color(0xFFE67E5E)
            : Colors.black,
      ),
    );
  }
}