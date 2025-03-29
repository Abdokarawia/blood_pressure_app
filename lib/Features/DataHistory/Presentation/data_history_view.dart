import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class DataHistoryScreen extends StatefulWidget {
  final AnimationController animationController;

  const DataHistoryScreen({Key? key, required this.animationController})
    : super(key: key);

  @override
  _DataHistoryScreenState createState() => _DataHistoryScreenState();
}

class _DataHistoryScreenState extends State<DataHistoryScreen>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late TabController _tabController;

  // Sample data types that can be displayed and shared
  final List<String> _dataTypes = [
    'Medications',
    'Health Metrics',
    'Activities',
    'Diet',
    'Sleep',
    'Symptoms',
  ];

  // Selected data type index
  int _selectedDataType = 0;

  // Days of the week for the last 7 days
  final List<DateTime> _lastSevenDays = List.generate(
    7,
    (index) => DateTime.now().subtract(Duration(days: 6 - index)),
  );

  // Mock data for demonstration
  final Map<String, Map<String, List<Map<String, dynamic>>>> _mockData = {
    'Medications': {
      '2025-03-23': [
        {'name': 'Metformin', 'dose': '500mg', 'time': '08:00', 'taken': true},
        {'name': 'Lisinopril', 'dose': '10mg', 'time': '20:00', 'taken': true},
      ],
      '2025-03-24': [
        {'name': 'Metformin', 'dose': '500mg', 'time': '08:00', 'taken': true},
        {'name': 'Lisinopril', 'dose': '10mg', 'time': '20:00', 'taken': false},
      ],
      '2025-03-25': [
        {'name': 'Metformin', 'dose': '500mg', 'time': '08:00', 'taken': true},
        {'name': 'Lisinopril', 'dose': '10mg', 'time': '20:00', 'taken': true},
      ],
      '2025-03-26': [
        {'name': 'Metformin', 'dose': '500mg', 'time': '08:00', 'taken': true},
        {'name': 'Lisinopril', 'dose': '10mg', 'time': '20:00', 'taken': true},
      ],
      '2025-03-27': [
        {'name': 'Metformin', 'dose': '500mg', 'time': '08:00', 'taken': true},
        {'name': 'Lisinopril', 'dose': '10mg', 'time': '20:00', 'taken': true},
      ],
      '2025-03-28': [
        {'name': 'Metformin', 'dose': '500mg', 'time': '08:00', 'taken': false},
        {'name': 'Lisinopril', 'dose': '10mg', 'time': '20:00', 'taken': false},
      ],
      '2025-03-29': [
        {'name': 'Metformin', 'dose': '500mg', 'time': '08:00', 'taken': true},
        {'name': 'Lisinopril', 'dose': '10mg', 'time': '20:00', 'taken': null},
      ],
    },
    'Health Metrics': {
      '2025-03-23': [
        {'name': 'Blood Pressure', 'value': '120/80', 'time': '08:30'},
        {'name': 'Blood Glucose', 'value': '110 mg/dL', 'time': '08:45'},
        {'name': 'Weight', 'value': '75 kg', 'time': '20:15'},
      ],
      '2025-03-24': [
        {'name': 'Blood Pressure', 'value': '118/78', 'time': '08:30'},
        {'name': 'Blood Glucose', 'value': '105 mg/dL', 'time': '08:40'},
      ],
      '2025-03-25': [
        {'name': 'Blood Pressure', 'value': '122/82', 'time': '08:25'},
        {'name': 'Blood Glucose', 'value': '112 mg/dL', 'time': '08:45'},
        {'name': 'Weight', 'value': '74.8 kg', 'time': '20:00'},
      ],
      '2025-03-26': [
        {'name': 'Blood Pressure', 'value': '121/81', 'time': '08:35'},
        {'name': 'Blood Glucose', 'value': '108 mg/dL', 'time': '08:50'},
      ],
      '2025-03-27': [
        {'name': 'Blood Pressure', 'value': '119/79', 'time': '08:30'},
        {'name': 'Blood Glucose', 'value': '103 mg/dL', 'time': '08:45'},
        {'name': 'Weight', 'value': '74.5 kg', 'time': '20:10'},
      ],
      '2025-03-28': [
        {'name': 'Blood Pressure', 'value': '120/80', 'time': '08:30'},
        {'name': 'Blood Glucose', 'value': '107 mg/dL', 'time': '08:45'},
      ],
      '2025-03-29': [
        {'name': 'Blood Pressure', 'value': '118/78', 'time': '08:25'},
        {'name': 'Blood Glucose', 'value': '102 mg/dL', 'time': '08:40'},
        {'name': 'Weight', 'value': '74.2 kg', 'time': '20:05'},
      ],
    },
    'Activities': {},
    'Diet': {},
    'Sleep': {},
    'Symptoms': {},
  };

  @override
  void initState() {
    super.initState();
    _animation = CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.easeInOut,
    );
    _tabController = TabController(length: 7, vsync: this);

    // Set initial tab to today
    _tabController.animateTo(6);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _shareData() {
    final String dateStr = DateFormat(
      'yyyy-MM-dd',
    ).format(_lastSevenDays[_tabController.index]);
    final String dataType = _dataTypes[_selectedDataType];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Share $dataType Data',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[800],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Share data for ${DateFormat('EEEE, MMMM d, yyyy').format(_lastSevenDays[_tabController.index])}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.teal[600],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildShareOption(
                      icon: Iconsax.health,
                      title: 'Healthcare Provider',
                      subtitle: 'Share with your doctor or nurse',
                      color: Colors.blue,
                    ),
                    _buildShareOption(
                      icon: Iconsax.heart,
                      title: 'Family Member',
                      subtitle: 'Share with trusted family members',
                      color: Colors.red,
                    ),
                    _buildShareOption(
                      icon: Iconsax.shield,
                      title: 'Caregiver',
                      subtitle: 'Share with your caregiver',
                      color: Colors.green,
                    ),
                    _buildShareOption(
                      icon: Iconsax.document_1,
                      title: 'Export as PDF',
                      subtitle: 'Save and share as a document',
                      color: Colors.orange,
                    ),
                    _buildShareOption(
                      icon: Iconsax.chart_square,
                      title: 'Export as CSV',
                      subtitle: 'Export data in spreadsheet format',
                      color: Colors.purple,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
        ),
        trailing: Icon(Iconsax.arrow_right_3, color: Colors.grey[400]),
        onTap: () {
          HapticFeedback.mediumImpact();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Sharing $title functionality would be implemented here',
              ),
              backgroundColor: color,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 360;
    final bool isLargeScreen = MediaQuery.of(context).size.width > 600;

    return FadeTransition(
      opacity: _animation,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                isSmallScreen ? 16 : 20,
                isSmallScreen ? 8 : 10,
                isSmallScreen ? 16 : 20,
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Data History',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Iconsax.share,
                            size: isSmallScreen ? 20 : 24,
                            color: Colors.teal,
                          ),
                          onPressed: _shareData,
                          tooltip: 'Share Data',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Iconsax.filter,
                            size: isSmallScreen ? 20 : 24,
                            color: Colors.teal,
                          ),
                          onPressed: () {
                            // Filter functionality would be implemented here
                          },
                          tooltip: 'Filter Data',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 20),
            _buildDataTypeSelector(isSmallScreen),
            SizedBox(height: isSmallScreen ? 12 : 20),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children:
                    _lastSevenDays.map((date) {
                      return _buildDayDataView(date, isSmallScreen);
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTypeSelector(bool isSmallScreen) {
    return SizedBox(
      height: isSmallScreen ? 80 : 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 20),
        itemCount: _dataTypes.length,
        itemBuilder: (context, index) {
          final bool isSelected = _selectedDataType == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDataType = index;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: isSmallScreen ? 8 : 10),
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 4 : 8,
              ),
              decoration: BoxDecoration(
                color: isSelected ? Colors.teal : Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  _dataTypes[index],
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: isSelected ? Colors.white : Colors.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayDataView(DateTime date, bool isSmallScreen) {
    final String dateStr = DateFormat('yyyy-MM-dd').format(date);
    final String dataType = _dataTypes[_selectedDataType];

    // Get data for the selected date and type
    final data = _mockData[dataType]?[dateStr] ?? [];

    if (data.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.clipboard_close,
                size: isSmallScreen ? 50 : 70,
                color: Colors.grey[400],
              ),
              SizedBox(height: isSmallScreen ? 12 : 20),
              Text(
                'No $dataType data for ${DateFormat('MMMM d').format(date)}',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 20),
              ElevatedButton(
                onPressed: () {
                  // Add data functionality would be implemented here
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 20,
                    vertical: isSmallScreen ? 10 : 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Add Data',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 20,
        vertical: 8,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];

        if (dataType == 'Medications') {
          return _buildMedicationItem(item, isSmallScreen);
        } else if (dataType == 'Health Metrics') {
          return _buildHealthMetricItem(item, isSmallScreen);
        } else {
          // Default item rendering
          return Card(
            margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: ListTile(
              contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              title: Text(
                item['name'] ?? 'Unknown',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                item['value'] ?? '',
                style: GoogleFonts.poppins(fontSize: isSmallScreen ? 12 : 14),
              ),
              trailing: Text(
                item['time'] ?? '',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildMedicationItem(
    Map<String, dynamic> medication,
    bool isSmallScreen,
  ) {
    final bool? taken = medication['taken'];

    Color statusColor;
    IconData statusIcon;

    if (taken == null) {
      statusColor = Colors.grey;
      statusIcon = Iconsax.clock;
    } else if (taken) {
      statusColor = Colors.green;
      statusIcon = Iconsax.tick_circle;
    } else {
      statusColor = Colors.red;
      statusIcon = Iconsax.close_circle;
    }

    return Card(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Row(
          children: [
            Container(
              width: isSmallScreen ? 40 : 50,
              height: isSmallScreen ? 40 : 50,
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Iconsax.health,
                size: isSmallScreen ? 20 : 24,
                color: Colors.teal,
              ),
            ),
            SizedBox(width: isSmallScreen ? 10 : 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medication['name'] ?? 'Unknown',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${medication['dose']} · ${medication['time']}',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: isSmallScreen ? 32 : 40,
              height: isSmallScreen ? 32 : 40,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                statusIcon,
                size: isSmallScreen ? 18 : 24,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetricItem(
    Map<String, dynamic> metric,
    bool isSmallScreen,
  ) {
    IconData metricIcon;

    // Determine icon based on metric name
    if (metric['name'] == 'Blood Pressure') {
      metricIcon = Iconsax.heart;
    } else if (metric['name'] == 'Blood Glucose') {
      metricIcon = Iconsax.drop;
    } else if (metric['name'] == 'Weight') {
      metricIcon = Iconsax.weight;
    } else {
      metricIcon = Iconsax.health;
    }

    return Card(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Row(
          children: [
            Container(
              width: isSmallScreen ? 40 : 50,
              height: isSmallScreen ? 40 : 50,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                metricIcon,
                size: isSmallScreen ? 20 : 24,
                color: Colors.blue,
              ),
            ),
            SizedBox(width: isSmallScreen ? 10 : 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metric['name'] ?? 'Unknown',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${metric['value']}',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              metric['time'] ?? '',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 12 : 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
