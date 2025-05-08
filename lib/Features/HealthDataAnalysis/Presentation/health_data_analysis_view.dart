import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../GoalReminders/data/HealthGoalModel.dart';
import '../Manger/health_data_analysis_cubit.dart';
import '../Manger/health_data_analysis_state.dart';

class HealthAnalysisView extends StatefulWidget {
  const HealthAnalysisView({Key? key}) : super(key: key);

  @override
  State<HealthAnalysisView> createState() => _HealthAnalysisViewState();
}

class _HealthAnalysisViewState extends State<HealthAnalysisView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedMetric = 'Steps';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load data when the view is created
    context.read<HealthAnalysisCubit>().loadThisWeekData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Analysis', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Trends'),
            Tab(text: 'Goals'),
          ],
        ),
      ),
      body: BlocBuilder<HealthAnalysisCubit, HealthAnalysisState>(
        builder: (context, state) {
          if (state is HealthAnalysisLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HealthAnalysisError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<HealthAnalysisCubit>().loadThisWeekData(),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else if (state is HealthAnalysisLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(state.analysis),
                _buildTrendsTab(state.analysis),
                _buildGoalsTab(state.analysis),
              ],
            );
          }

          // Initial state or any other state
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No health data available'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<HealthAnalysisCubit>().loadThisWeekData(),
                  child: const Text('Load Data'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(Map<String, dynamic> analysis) {
    final totals = analysis['totals'] as Map<String, double>;
    final averages = analysis['averages'] as Map<String, double>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary card
          _buildSummaryCard(),

          const SizedBox(height: 24),
          const Text('Weekly Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // Weekly stats grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                'Steps',
                totals['steps']?.toInt().toString() ?? '0',
                'Total Steps',
                Icons.directions_walk,
                Colors.blue,
              ),
              _buildStatCard(
                'Calories',
                totals['caloriesBurned']?.toInt().toString() ?? '0',
                'Calories Burned',
                Icons.local_fire_department,
                Colors.orange,
              ),
              _buildStatCard(
                'Activity',
                totals['activeMinutes']?.toInt().toString() ?? '0',
                'Active Minutes',
                Icons.fitness_center,
                Colors.green,
              ),
              _buildStatCard(
                'Distance',
                '${totals['distance']?.toStringAsFixed(2) ?? '0'} km',
                'Total Distance',
                Icons.map,
                Colors.purple,
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Text('Daily Averages',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // Daily averages
          _buildAverageCard('Sleep',
              '${averages['sleepHours']?.toStringAsFixed(1) ?? '0'} hrs',
              Icons.nightlight),
          _buildAverageCard('Hydration',
              '${averages['hydration']?.toStringAsFixed(1) ?? '0'} L',
              Icons.water_drop),
          _buildAverageCard('Heart Rate',
              '${averages['heartRate']?.toInt().toString() ?? '0'} bpm',
              Icons.favorite),

          const SizedBox(height: 24),
          const Text('Recommendations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // Recommendations
          _buildRecommendations(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final cubit = context.read<HealthAnalysisCubit>();
    final summary = cubit.getWeeklySummary();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text('This Week\'s Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(summary),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 6),
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
              ],
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAverageCard(String title, String value, IconData icon) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    final cubit = context.read<HealthAnalysisCubit>();
    final recommendations = cubit.getRecommendations();

    if (recommendations.isEmpty) {
      return const Card(
        elevation: 1,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No recommendations available at this time.'),
        ),
      );
    }

    return Column(
      children: recommendations.map((rec) => _buildRecommendationItem(rec)).toList(),
    );
  }

  Widget _buildRecommendationItem(String recommendation) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lightbulb, color: Colors.amber[700], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(recommendation),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsTab(Map<String, dynamic> analysis) {
    // Get chart data for selected metric
    final chartData = analysis['chartData'][HealthAnalysisCubit.metricToField[_selectedMetric]];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metric selector
          _buildMetricSelector(),

          const SizedBox(height: 24),

          // Chart
          Expanded(
            child: _buildChart(chartData),
          ),

          const SizedBox(height: 24),

          // Stats for the selected metric
          _buildMetricStats(analysis, _selectedMetric),
        ],
      ),
    );
  }

  Widget _buildMetricSelector() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: HealthAnalysisCubit.metricOptions.map((metric) {
          final isSelected = metric == _selectedMetric;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(metric),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedMetric = metric;
                  });
                }
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? Theme.of(context).primaryColor : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChart(List<dynamic>? chartData) {
    if (chartData == null || chartData.isEmpty) {
      return const Center(child: Text('No data available for this metric'));
    }

    final field = HealthAnalysisCubit.metricToField[_selectedMetric]!;
    final unit = HealthAnalysisCubit.metricUnits[_selectedMetric]!;

    // Convert chart data to list of FlSpot with proper type handling
    final spots = List<FlSpot>.generate(
      chartData.length,
          (i) {
        // Handle potential type issues by safely extracting the value
        var dataPoint = chartData[i];
        double value = 0.0;

        if (dataPoint is Map<String, dynamic>) {
          // Safely extract the value with type checking
          var rawValue = dataPoint['value'];
          if (rawValue is num) {
            value = rawValue.toDouble();
          } else if (rawValue is String) {
            value = double.tryParse(rawValue) ?? 0.0;
          }
        }

        return FlSpot(i.toDouble(), value);
      },
    );

    return Column(
      children: [
        Text(
          '$_selectedMetric Trend',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _calculateInterval(spots),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < chartData.length) {
                        // Safely extract the date with type checking
                        final dataPoint = chartData[value.toInt()];
                        String dateStr = '';

                        if (dataPoint is Map<String, dynamic> && dataPoint.containsKey('date')) {
                          dateStr = dataPoint['date'].toString();
                        }

                        if (dateStr.isNotEmpty) {
                          try {
                            final date = DateTime.parse(dateStr);
                            final day = _getWeekdayShort(date.weekday);
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(day, style: const TextStyle(fontSize: 12)),
                            );
                          } catch (e) {
                            // If date parsing fails, show index
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text('Day ${value.toInt() + 1}', style: const TextStyle(fontSize: 12)),
                            );
                          }
                        }
                      }
                      return const SizedBox();
                    },
                    reservedSize: 28,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    },
                    reservedSize: 40,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: const Color(0xff37434d), width: 1),
              ),
              minX: 0,
              maxX: chartData.length - 1.0,
              minY: 0,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Theme.of(context).primaryColor,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((touchedSpot) {
                      final spotIndex = touchedSpot.spotIndex;
                      final value = touchedSpot.y;
                      return LineTooltipItem(
                        '${value.toStringAsFixed(1)} $unit',
                        const TextStyle(color: Colors.white),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _calculateInterval(List<FlSpot> spots) {
    // Find the max Y value
    double maxY = 0;
    for (var spot in spots) {
      if (spot.y > maxY) maxY = spot.y;
    }

    // Calculate a nice interval based on max value
    if (maxY <= 10) return 2;
    if (maxY <= 50) return 10;
    if (maxY <= 100) return 20;
    if (maxY <= 500) return 100;
    if (maxY <= 1000) return 200;
    if (maxY <= 10000) return 2000;

    return 5000;
  }

  String _getWeekdayShort(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  Widget _buildMetricStats(Map<String, dynamic> analysis, String metric) {
    final field = HealthAnalysisCubit.metricToField[metric]!;
    final unit = HealthAnalysisCubit.metricUnits[metric]!;

    final avg = analysis['averages'][field]?.toStringAsFixed(1) ?? '0';
    final total = analysis['totals'][field]?.toStringAsFixed(1) ?? '0';
    final max = analysis['maxValues'][field]?.toStringAsFixed(1) ?? '0';
    final min = analysis['minValues'][field]?.toStringAsFixed(1) ?? '0';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildMetricStatItem('Avg', '$avg $unit', Colors.blue),
        _buildMetricStatItem('Total', '$total $unit', Colors.green),
        _buildMetricStatItem('Max', '$max $unit', Colors.orange),
        _buildMetricStatItem('Min', '$min $unit', Colors.purple),
      ],
    );
  }

  Widget _buildMetricStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsTab(Map<String, dynamic> analysis) {
    return FutureBuilder<Map<String, double>>(
      future: context.read<HealthAnalysisCubit>().calculateGoalProgress(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text('Failed to load goals: ${snapshot.error}',
                    textAlign: TextAlign.center),
              ],
            ),
          );
        }

        final goalProgress = snapshot.data ?? {};

        if (goalProgress.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.track_changes, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('No health goals set'),
                SizedBox(height: 8),
                Text('Create goals to track your progress',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Weekly Goal Progress',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Goal progress indicators
              ...goalProgress.entries.map((entry) =>
                  _buildGoalProgressItem(entry.key, entry.value)
              ).toList(),

              const SizedBox(height: 24),
              Center(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to goal setting page
                    // Navigator.push(context, MaterialPageRoute(
                    //   builder: (context) => const GoalSettingPage()
                    // ));
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Goal'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGoalProgressItem(String fieldName, double progress) {
    // Map field name back to display name
    String displayName = '';
    String unit = '';

    for (final entry in HealthAnalysisCubit.metricToField.entries) {
      if (entry.value == fieldName) {
        displayName = entry.key;
        unit = HealthAnalysisCubit.metricUnits[entry.key] ?? '';
        break;
      }
    }

    if (displayName.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate color based on progress
    Color progressColor;
    if (progress >= 0.8) {
      progressColor = Colors.green;
    } else if (progress >= 0.5) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }
}