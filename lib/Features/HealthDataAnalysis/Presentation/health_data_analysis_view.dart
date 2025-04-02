import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';

class HealthDataAnalysisScreen extends StatefulWidget {
  final AnimationController animationController;

  const HealthDataAnalysisScreen({Key? key, required this.animationController})
    : super(key: key);

  @override
  _HealthDataAnalysisScreenState createState() =>
      _HealthDataAnalysisScreenState();
}

class _HealthDataAnalysisScreenState extends State<HealthDataAnalysisScreen> {
  final List<Map<String, dynamic>> _mockSleepData = [
    {
      'date': 'Mon',
      'hours': 7.5,
      'quality': 'Good',
      'deepSleep': 3.2,
      'lightSleep': 4.3,
    },
    {
      'date': 'Tue',
      'hours': 8.2,
      'quality': 'Excellent',
      'deepSleep': 3.8,
      'lightSleep': 4.4,
    },
    {
      'date': 'Wed',
      'hours': 6.8,
      'quality': 'Average',
      'deepSleep': 2.5,
      'lightSleep': 4.3,
    },
    {
      'date': 'Thu',
      'hours': 7.2,
      'quality': 'Good',
      'deepSleep': 3.0,
      'lightSleep': 4.2,
    },
    {
      'date': 'Fri',
      'hours': 8.5,
      'quality': 'Excellent',
      'deepSleep': 4.0,
      'lightSleep': 4.5,
    },
    {
      'date': 'Sat',
      'hours': 7.8,
      'quality': 'Good',
      'deepSleep': 3.3,
      'lightSleep': 4.5,
    },
    {
      'date': 'Sun',
      'hours': 7.0,
      'quality': 'Good',
      'deepSleep': 3.0,
      'lightSleep': 4.0,
    },
  ];

  final List<Map<String, dynamic>> _activityData = [
    {'date': 'Mon', 'steps': 7500, 'calories': 390, 'distance': 5.2},
    {'date': 'Tue', 'steps': 9200, 'calories': 450, 'distance': 6.4},
    {'date': 'Wed', 'steps': 6700, 'calories': 320, 'distance': 4.6},
    {'date': 'Thu', 'steps': 8300, 'calories': 410, 'distance': 5.7},
    {'date': 'Fri', 'steps': 10200, 'calories': 510, 'distance': 7.1},
    {'date': 'Sat', 'steps': 12100, 'calories': 580, 'distance': 8.4},
    {'date': 'Sun', 'steps': 8700, 'calories': 430, 'distance': 6.0},
  ];

  final List<Map<String, dynamic>> _nutritionData = [
    {'date': 'Mon', 'calories': 2100, 'protein': 95, 'carbs': 230, 'fats': 65},
    {'date': 'Tue', 'calories': 1950, 'protein': 105, 'carbs': 210, 'fats': 60},
    {'date': 'Wed', 'calories': 2050, 'protein': 90, 'carbs': 240, 'fats': 63},
    {'date': 'Thu', 'calories': 1900, 'protein': 100, 'carbs': 200, 'fats': 62},
    {'date': 'Fri', 'calories': 2200, 'protein': 110, 'carbs': 235, 'fats': 70},
    {'date': 'Sat', 'calories': 2300, 'protein': 115, 'carbs': 250, 'fats': 75},
    {'date': 'Sun', 'calories': 2000, 'protein': 100, 'carbs': 220, 'fats': 65},
  ];

  final List<Map<String, dynamic>> _heartRateData = [
    {'date': 'Mon', 'resting': 65, 'active': 135, 'variability': 45},
    {'date': 'Tue', 'resting': 62, 'active': 140, 'variability': 50},
    {'date': 'Wed', 'resting': 68, 'active': 145, 'variability': 42},
    {'date': 'Thu', 'resting': 64, 'active': 138, 'variability': 47},
    {'date': 'Fri', 'resting': 61, 'active': 152, 'variability': 51},
    {'date': 'Sat', 'resting': 63, 'active': 158, 'variability': 53},
    {'date': 'Sun', 'resting': 66, 'active': 140, 'variability': 46},
  ];

  final Map<String, dynamic> _weeklyAverage = {
    'steps': 8957,
    'calories': 2071,
    'sleep': 7.57,
    'heartRate': 64.1,
    'stressLevel': 'Moderate',
    'hydration': 2.3, // Liters
    'meditation': 15, // Minutes
  };

  Future<void> _shareContent() async {
    String shareText = 'My Weekly Health Report\n\n';
    shareText +=
        'Average Sleep: ${10.4.toStringAsFixed(1)} hours\n';
    shareText += 'Average Steps: ${_weeklyAverage['steps']} steps\n';
    shareText += 'Average Calories: ${_weeklyAverage['calories']} cal\n';
    shareText += 'Average Heart Rate: ${_weeklyAverage['heartRate']} bpm\n';
    shareText += 'Daily Hydration: ${_weeklyAverage['hydration']} liters\n';

    await Share.share(shareText);
  }

  Widget _buildAnalysisCard({
    required String title,
    required Widget child,
    required bool isSmallScreen,
    bool showShareIcon = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 15 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              if (showShareIcon)
                GestureDetector(
                  onTap: () => _shareContent(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.share,
                      size: isSmallScreen ? 16 : 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

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
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Health Analysis',
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 22 : 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _shareContent(),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade500,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Iconsax.share,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      Text(
                        'Last 7 Days',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 20),


                      // Sleep Analysis Card
                      _buildAnalysisCard(
                        title: 'Sleep Analysis',
                        isSmallScreen: isSmallScreen,
                        child: _buildSleepAnalysis(isSmallScreen),
                      ),
                      const SizedBox(height: 15),

                      // Activity Analysis Card
                      _buildAnalysisCard(
                        title: 'Activity & Steps',
                        isSmallScreen: isSmallScreen,
                        child: _buildActivityAnalysis(isSmallScreen),
                      ),
                      const SizedBox(height: 15),

                      // Heart Rate Card
                      _buildAnalysisCard(
                        title: 'Heart Rate',
                        isSmallScreen: isSmallScreen,
                        child: _buildHeartRateAnalysis(isSmallScreen),
                      ),
                      const SizedBox(height: 15),

                      // Nutrition Card
                      _buildAnalysisCard(
                        title: 'Nutrition',
                        isSmallScreen: isSmallScreen,
                        child: _buildNutritionAnalysis(isSmallScreen),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildSummaryItem(
    String title,
    String value,
    Color color,
    IconData icon,
    bool isSmallScreen,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: isSmallScreen ? 24 : 28, color: color),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 12 : 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSleepAnalysis(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sleep Duration & Quality',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Avg: ${7.88.toStringAsFixed(1)}h',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo.shade700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: isSmallScreen ? 180 : 200,
          child: _buildSleepChart(isSmallScreen),
        ),
        const SizedBox(height: 15),
        _buildSleepStats(isSmallScreen),
      ],
    );
  }

  Widget _buildSleepChart(bool isSmallScreen) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 10,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String quality = _mockSleepData[groupIndex]['quality'];
              return BarTooltipItem(
                '${_mockSleepData[groupIndex]['hours']}h\n$quality',
                GoogleFonts.poppins(
                  color: Colors.indigo.shade700,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _mockSleepData[value.toInt()]['date'],
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                      fontSize: isSmallScreen ? 10 : 12,
                    ),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value % 2 == 0) {
                  return Text(
                    '${value.toInt()}h',
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
          },
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        barGroups:
            _mockSleepData.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> data = entry.value;

              Color color;
              switch (data['quality']) {
                case 'Excellent':
                  color = Colors.green;
                  break;
                case 'Good':
                  color = Colors.blue;
                  break;
                case 'Average':
                  color = Colors.orange;
                  break;
                default:
                  color = Colors.red;
              }

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: data['hours'],
                    color: color.withOpacity(0.7),
                    width: isSmallScreen ? 15 : 20,
                    borderRadius: BorderRadius.circular(4),
                    rodStackItems: [
                      BarChartRodStackItem(
                        0,
                        data['deepSleep'],
                        Colors.indigo.shade700,
                      ),
                      BarChartRodStackItem(
                        data['deepSleep'],
                        data['deepSleep'] + data['lightSleep'],
                        Colors.indigo.shade300,
                      ),
                    ],
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: 9, // Target sleep hours
                      color: Colors.grey.shade100,
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSleepStats(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.indigo.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSleepStatItem(
            'Deep Sleep',
            '${4.5.toStringAsFixed(1)}h',
            Colors.indigo.shade700,
            isSmallScreen,
          ),
          _buildSleepStatItem(
            'Light Sleep',
            '${4.toStringAsFixed(1)}h',
            Colors.indigo.shade400,
            isSmallScreen,
          ),
          _buildSleepStatItem(
            'Best Day',
            "MON",
            Colors.green.shade600,
            isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildSleepStatItem(
    String label,
    String value,
    Color color,
    bool isSmallScreen,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 12 : 13,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityAnalysis(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daily Step Count',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Avg: ${_averageSteps()} steps',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: isSmallScreen ? 180 : 200,
          child: _buildStepsChart(isSmallScreen),
        ),
        const SizedBox(height: 15),
        _buildActivityStats(isSmallScreen),
      ],
    );
  }

  Widget _buildStepsChart(bool isSmallScreen) {
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                final data = _activityData[spot.x.toInt()];
                return LineTooltipItem(
                  '${data['steps']} steps\n${data['calories']} cal',
                  GoogleFonts.poppins(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 3000,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < _activityData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _activityData[value.toInt()]['date'],
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontSize: isSmallScreen ? 10 : 12,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 3000,
              getTitlesWidget: (value, meta) {
                return Text(
                  value >= 1000
                      ? '${(value / 1000).toInt()}k'
                      : '${value.toInt()}',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: _activityData.length - 1.0,
        minY: 0,
        maxY: 15000,
        lineBarsData: [
          LineChartBarData(
            spots:
                _activityData.asMap().entries.map((entry) {
                  return FlSpot(
                    entry.key.toDouble(),
                    entry.value['steps'].toDouble(),
                  );
                }).toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [Colors.green.shade300, Colors.green.shade600],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: Colors.green.shade600,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.green.withOpacity(0.3),
                  Colors.green.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStats(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActivityStatItem(
            'Total Steps',
            '${_totalSteps()}',
            Colors.green.shade700,
            isSmallScreen,
          ),
          _buildActivityStatItem(
            'Total Distance',
            '${_totalDistance().toStringAsFixed(1)} km',
            Colors.green.shade600,
            isSmallScreen,
          ),
          _buildActivityStatItem(
            'Calories Burned',
            '${_totalActivityCalories()}',
            Colors.green.shade500,
            isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStatItem(
    String label,
    String value,
    Color color,
    bool isSmallScreen,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 12 : 13,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildHeartRateAnalysis(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Resting Heart Rate',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Avg: ${_averageRestingHeartRate()} bpm',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: isSmallScreen ? 180 : 200,
          child: _buildHeartRateChart(isSmallScreen),
        ),
        const SizedBox(height: 15),
        _buildHeartRateStats(isSmallScreen),
      ],
    );
  }

  Widget _buildHeartRateChart(bool isSmallScreen) {
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                final data = _heartRateData[spot.x.toInt()];
                return LineTooltipItem(
                  '${spot.y.toInt()} bpm\n${data['date']}',
                  GoogleFonts.poppins(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < _heartRateData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _heartRateData[value.toInt()]['date'],
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontSize: isSmallScreen ? 10 : 12,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: _heartRateData.length - 1.0,
        minY: 40,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots:
                _heartRateData.asMap().entries.map((entry) {
                  return FlSpot(
                    entry.key.toDouble(),
                    entry.value['resting'].toDouble(),
                  );
                }).toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [Colors.red.shade300, Colors.red.shade600],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: Colors.red.shade600,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.red.withOpacity(0.3),
                  Colors.red.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartRateStats(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildHeartRateStatItem(
            'Resting',
            '${_averageRestingHeartRate()} bpm',
            Colors.red.shade700,
            isSmallScreen,
          ),
          _buildHeartRateStatItem(
            'Active',
            '${_averageActiveHeartRate()} bpm',
            Colors.red.shade600,
            isSmallScreen,
          ),
          _buildHeartRateStatItem(
            'HRV',
            '${_averageHeartRateVariability()} ms',
            Colors.red.shade500,
            isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildHeartRateStatItem(
    String label,
    String value,
    Color color,
    bool isSmallScreen,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 12 : 13,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionAnalysis(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daily Nutrition',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Avg: ${_averageNutritionCalories()} cal',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: isSmallScreen ? 180 : 200,
          child: _buildNutritionChart(isSmallScreen),
        ),
        const SizedBox(height: 15),
        _buildNutritionStats(isSmallScreen),
      ],
    );
  }

  Widget _buildNutritionChart(bool isSmallScreen) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 2500,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final data = _nutritionData[groupIndex];
              return BarTooltipItem(
                '${data['calories']} cal\nP: ${data['protein']}g | C: ${data['carbs']}g | F: ${data['fats']}g',
                GoogleFonts.poppins(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _nutritionData[value.toInt()]['date'],
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                      fontSize: isSmallScreen ? 10 : 12,
                    ),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 500,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 500,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
          },
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        barGroups:
            _nutritionData.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> data = entry.value;

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: data['calories'].toDouble(),
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade300, Colors.orange.shade600],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    width: isSmallScreen ? 15 : 20,
                    borderRadius: BorderRadius.circular(4),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: 2200, // Target calories
                      color: Colors.grey.shade100,
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildNutritionStats(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNutritionStatItem(
            'Protein',
            '${_averageProtein()}g',
            Colors.orange.shade700,
            isSmallScreen,
          ),
          _buildNutritionStatItem(
            'Carbs',
            '${_averageCarbs()}g',
            Colors.orange.shade600,
            isSmallScreen,
          ),
          _buildNutritionStatItem(
            'Fats',
            '${_averageFats()}g',
            Colors.orange.shade500,
            isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionStatItem(
    String label,
    String value,
    Color color,
    bool isSmallScreen,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 12 : 13,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildInsights(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInsightItem(
          Icons.trending_up,
          'Activity Pattern',
          'Your step count is highest on weekends. Consider maintaining this level throughout the week.',
          Colors.teal,
          isSmallScreen,
        ),
        const SizedBox(height: 12),
        _buildInsightItem(
          Icons.nightlight_outlined,
          'Sleep Quality',
          'Your deep sleep average is lower than recommended. Try going to bed earlier to improve this.',
          Colors.indigo,
          isSmallScreen,
        ),
        const SizedBox(height: 12),
        _buildInsightItem(
          Icons.favorite_outline,
          'Heart Health',
          'Your resting heart rate is within the healthy range. Keep up the good work!',
          Colors.red,
          isSmallScreen,
        ),
        const SizedBox(height: 12),
        _buildInsightItem(
          Icons.restaurant_outlined,
          'Nutrition',
          'Your protein intake is lower than recommended. Consider adding more protein to your diet.',
          Colors.orange,
          isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildInsightItem(
    IconData icon,
    String title,
    String description,
    Color color,
    bool isSmallScreen,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: isSmallScreen ? 18 : 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper methods for calculations
  int _averageSteps() {
    int total = 0;
    for (var data in _activityData) {
      total += (data['steps'] as num).toInt();
    }
    return (total / _activityData.length).round();
  }

  int _totalSteps() {
    int total = 0;
    for (var data in _activityData) {
      total += (data['steps'] as num).toInt();
    }
    return total;
  }

  double _totalDistance() {
    double total = 0;
    for (var data in _activityData) {
      total += (data['distance'] as num).toDouble();
    }
    return total;
  }

  int _totalActivityCalories() {
    int total = 0;
    for (var data in _activityData) {
      total += (data['calories'] as num).toInt();
    }
    return total;
  }

  int _averageRestingHeartRate() {
    int total = 0;
    for (var data in _heartRateData) {
      total += (data['resting'] as num).toInt();
    }
    return (total / _heartRateData.length).round();
  }

  int _averageActiveHeartRate() {
    int total = 0;
    for (var data in _heartRateData) {
      total += (data['active'] as num).toInt();
    }
    return (total / _heartRateData.length).round();
  }

  int _averageHeartRateVariability() {
    int total = 0;
    for (var data in _heartRateData) {
      total += (data['variability'] as num).toInt();
    }
    return (total / _heartRateData.length).round();
  }

  int _averageNutritionCalories() {
    int total = 0;
    for (var data in _nutritionData) {
      total += (data['calories'] as num).toInt();
    }
    return (total / _nutritionData.length).round();
  }

  int _averageProtein() {
    int total = 0;
    for (var data in _nutritionData) {
      total += (data['protein'] as num).toInt();
    }
    return (total / _nutritionData.length).round();
  }

  int _averageCarbs() {
    int total = 0;
    for (var data in _nutritionData) {
      total += (data['carbs'] as num).toInt();
    }
    return (total / _nutritionData.length).round();
  }

  int _averageFats() {
    int total = 0;
    for (var data in _nutritionData) {
      total += (data['fats'] as num).toInt();
    }
    return (total / _nutritionData.length).round();
  }
}
