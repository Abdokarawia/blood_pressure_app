import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:iconsax/iconsax.dart';
import '../../GoalReminders/data/HealthGoalModel.dart';
import '../Manger/health_data_analysis_cubit.dart';

class HealthDataAnalysisScreen extends StatefulWidget {
  const HealthDataAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<HealthDataAnalysisScreen> createState() => _HealthDataAnalysisScreenState();
}

class _HealthDataAnalysisScreenState extends State<HealthDataAnalysisScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late HealthDataAnalysisCubit _analysisCubit;
  bool _isLoading = true;

  final List<String> _metrics = [
    'caloriesBurned',
    'activeMinutes',
    'steps',
    'distance',
    'hydration',
    'weight',
    'sleepHours',
    'heartRate',
  ];

  final Map<String, String> _metricNames = {
    'caloriesBurned': 'Calories',
    'activeMinutes': 'Active Time',
    'steps': 'Steps',
    'distance': 'Distance',
    'hydration': 'Hydration',
    'weight': 'Weight',
    'sleepHours': 'Sleep',
    'heartRate': 'Heart Rate',
  };

  // Using Iconsax icons for a more modern look
  final Map<String, IconData> _metricIcons = {
    'caloriesBurned': Iconsax.flash_1,
    'activeMinutes': Iconsax.timer_1,
    'steps': Icons.sports,
    'distance': Icons.route,
    'hydration': Icons.water,
    'weight': Iconsax.weight,
    'sleepHours': Iconsax.moon,
    'heartRate': Iconsax.heart_tick,
  };

  final Map<String, Color> _metricColors = {
    'caloriesBurned': const Color(0xFFFF7E6B),
    'activeMinutes': const Color(0xFF826AED),
    'steps': const Color(0xFF4EADEA),
    'distance': const Color(0xFF2DD4BF),
    'hydration': const Color(0xFF38BDF8),
    'weight': const Color(0xFFFBBF24),
    'sleepHours': const Color(0xFF818CF8),
    'heartRate': const Color(0xFFEF4444),
  };

  final Map<String, String> _metricUnits = {
    'caloriesBurned': 'cal',
    'activeMinutes': 'min',
    'steps': 'steps',
    'distance': 'km',
    'hydration': 'L',
    'weight': 'kg',
    'sleepHours': 'hrs',
    'heartRate': 'bpm',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Only 2 tabs now
    _analysisCubit = context.read<HealthDataAnalysisCubit>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    await _analysisCubit.analyzeHealthData(metrics: _metrics);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Health Analytics',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: _loadData,
            color: Colors.teal,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _buildTabBar(),
        ),
      ),
      body: BlocBuilder<HealthDataAnalysisCubit, HealthDataAnalysisState>(
        builder: (context, state) {
          if (state is HealthDataAnalysisLoading || _isLoading) {
            return _buildLoadingState();
          } else if (state is HealthDataAnalysisEmpty) {
            return _buildEmptyState(state.message);
          } else if (state is HealthDataAnalysisFailure) {
            return _buildErrorState(state.error);
          } else if (state is HealthDataAnalysisSuccess) {
            final analysis = state.analysis;

            return TabBarView(
              controller: _tabController,
              children: [
                // OVERVIEW TAB
                _buildOverviewTab(analysis),

                // TRENDS TAB
                _buildTrendsTab(analysis),
              ],
            );
          }

          return _buildEmptyState("No data available");
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.teal,
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.home_2),
                SizedBox(width: 8),
                Text('Overview'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.chart_2),
                SizedBox(width: 8),
                Text('Trends'),
              ],
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
            height: 80,
            width: 80,
            child: CircularProgressIndicator(
              strokeWidth: 8,
              backgroundColor: Colors.teal.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading your health data...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.chart_fail,
            size: 80,
            color: Colors.teal.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Iconsax.add),
            label: const Text('Add Health Data'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.warning_2,
            size: 80,
            color: Colors.red[400],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Error: $error',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Iconsax.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(Map<String, dynamic> analysis) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHealthSummaryCard(analysis),
          const SizedBox(height: 20),
          _buildRecentActivityCard(analysis),
          const SizedBox(height: 20),
          _buildStatCards(analysis),
        ],
      ),
    );
  }

  Widget _buildHealthSummaryCard(Map<String, dynamic> analysis) {
    final dataPoints = analysis['dataPoints'];
    final periodStart = analysis['period']['start'] as DateTime;
    final periodEnd = analysis['period']['end'] as DateTime;
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      elevation: 2,
      shadowColor: Colors.teal.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        Iconsax.health,
                        color: Colors.teal,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Health Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    Iconsax.calendar,
                    'Period',
                    '${dateFormat.format(periodStart)} - ${dateFormat.format(periodEnd)}',
                  ),
                  _buildSummaryItem(
                    Iconsax.document,
                    'Data Points',
                    dataPoints.toString(),
                  ),
                  _buildSummaryItem(
                    Iconsax.calendar_1,
                    'Days',
                    '${periodEnd.difference(periodStart).inDays + 1}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.teal,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRecentActivityCard(Map<String, dynamic> analysis) {
    final goalProgress = analysis['goalProgress'] as Map<String, dynamic>? ?? {};

    List<MapEntry<String, Map<String, dynamic>>> sortedGoals = [];
    if (goalProgress.isNotEmpty) {
      sortedGoals = goalProgress.entries
          .map((entry) => MapEntry(
        entry.key,
        entry.value as Map<String, dynamic>, // Explicit cast
      ))
          .toList()
        ..sort((a, b) => (b.value['percentage'] as double)
            .compareTo(a.value['percentage'] as double));
      if (sortedGoals.length > 3) {
        sortedGoals = sortedGoals.sublist(0, 3);
      }
    }

    return Card(
      elevation: 2,
      shadowColor: Colors.teal.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4EADEA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Iconsax.activity,
                    color: Color(0xFF4EADEA),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (sortedGoals.isNotEmpty)
              ...sortedGoals.map((entry) => _buildProgressItem(entry.key, entry.value))
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Icon(
                        Iconsax.clock,
                        size: 36,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No recent activity data available',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String metric, Map<String, dynamic> progress) {
    final percentage = progress['percentage'] as double;
    final current = progress['current'];
    final target = progress['target'];
    final color = _metricColors[metric] ?? Colors.teal;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _metricIcons[metric] ?? Iconsax.activity,
                    color: color,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _metricNames[metric] ?? metric,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Text(
                '${percentage.toInt()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearPercentIndicator(
            lineHeight: 10,
            percent: percentage / 100,
            backgroundColor: color.withOpacity(0.2),
            progressColor: color,
            animation: true,
            animationDuration: 1000,
            barRadius: const Radius.circular(5),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${current.toStringAsFixed(1)} ${_metricUnits[metric] ?? ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                'Target: ${target.toStringAsFixed(1)} ${_metricUnits[metric] ?? ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(Map<String, dynamic> analysis) {
    final metrics = analysis['metrics'] as Map<String, dynamic>;
    final trends = analysis['trends'] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Health Metrics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _metrics.length,
          itemBuilder: (context, index) {
            final metric = _metrics[index];
            if (!metrics.containsKey(metric)) {
              return const SizedBox();
            }

            final metricData = metrics[metric];
            final trendDirection = trends[metric];
            final color = _metricColors[metric] ?? Colors.teal;

            return _buildMetricCard(
              metric,
              metricData,
              trendDirection,
              color,
            );
          },
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String metric,
      Map<String, dynamic> data,
      String trendDirection,
      Color color,
      ) {
    final currentValue = data['current'];
    final formattedValue = currentValue is int
        ? currentValue.toString()
        : currentValue.toStringAsFixed(1);

    final changePercentage = data['changePercentage'];

    IconData trendIcon;
    Color trendColor;

    if (trendDirection == 'increasing') {
      trendIcon = Iconsax.trend_up;
      trendColor = metric == 'weight' ? Colors.red : Colors.green;
    } else if (trendDirection == 'decreasing') {
      trendIcon = Iconsax.trend_down;
      trendColor = metric == 'weight' ? Colors.green : Colors.red;
    } else {
      trendIcon = Iconsax.arrow_right_3;
      trendColor = Colors.grey;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.7),
            color,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.2,
              child: Icon(
                _metricIcons[metric] ?? Iconsax.activity,
                size: 100,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _metricIcons[metric] ?? Iconsax.activity,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            trendIcon,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            changePercentage,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  formattedValue,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _metricNames[metric] ?? metric,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _metricUnits[metric] ?? '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(Map<String, dynamic> analysis) {
    final metrics = analysis['metrics'] as Map<String, dynamic>;
    final historicalData = analysis['historicalData'] as Map<String, dynamic>?;

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _metrics.length,
      itemBuilder: (context, index) {
        final metric = _metrics[index];
        if (!metrics.containsKey(metric)) {
          return const SizedBox();
        }

        final metricData = metrics[metric];
        final color = _metricColors[metric] ?? Colors.teal;

        // Handle historical data with proper type safety
        List<Map<String, dynamic>> metricHistory = [];
        if (historicalData != null && historicalData.containsKey(metric)) {
          final historyData = historicalData[metric];
          if (historyData is List) {
            for (var item in historyData) {
              if (item is Map) {
                metricHistory.add(Map<String, dynamic>.from(item));
              }
            }
          }
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 20),
          elevation: 2,
          shadowColor: color.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _metricIcons[metric] ?? Iconsax.activity,
                        color: color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _metricNames[metric] ?? metric,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: 240,
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _buildMetricChart(metric, color, metricHistory),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricChart(String metric, Color color, List<Map<String, dynamic>> metricHistory) {
    // Use real data if available, otherwise use sample data
    List<FlSpot> spots = [];

    if (metricHistory.isNotEmpty) {
      spots = List.generate(metricHistory.length, (index) {
        final value = metricHistory[index]['value'];
        if (value is num) {
          return FlSpot(index.toDouble(), value.toDouble());
        }
        return FlSpot(index.toDouble(), 0.0);
      });
    } else {
      // Fallback to sample data
      spots = [
        const FlSpot(0, 3),
        const FlSpot(1, 1),
        const FlSpot(2, 4),
        const FlSpot(3, 2),
        const FlSpot(4, 5),
        const FlSpot(5, 3),
        const FlSpot(6, 4),
      ];
    }

    return LineChart(
        LineChartData(
        gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
      return FlLine(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
        strokeWidth: 1,
      );
    },
    getDrawingVerticalLine: (value) {
    return FlLine(
    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
      strokeWidth: 1,
    );
    },
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
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (metricHistory.isEmpty || value >= metricHistory.length || value < 0) {
                    return const SizedBox();
                  }

                  final date = metricHistory[value.toInt()]['date'];
                  if (date is DateTime) {
                    return Text(
                      DateFormat('dd/MM').format(date),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    );
                  }

                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  );
                },
                reservedSize: 42,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            ),
          ),
          minX: 0,
          maxX: spots.isEmpty ? 6 : spots.length - 1.0,
          minY: spots.isEmpty ? 0 : spots.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 1,
          maxY: spots.isEmpty ? 6 : spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 1,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.5),
                  color,
                ],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: color,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.3),
                    color.withOpacity(0.0),
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


}
