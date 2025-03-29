import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:math' as math;

class HealthDataAnalysisScreen extends StatefulWidget {
  final AnimationController animationController;

  const HealthDataAnalysisScreen({
    Key? key,
    required this.animationController,
  }) : super(key: key);

  @override
  _HealthDataAnalysisScreenState createState() => _HealthDataAnalysisScreenState();
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

  final Map<String, dynamic> _weightLossPlan = {
    'currentWeight': 82,
    'targetWeight': 75,
    'dailyCalories': 1800,
    'proteinPercentage': 30,
    'carbsPercentage': 40,
    'fatsPercentage': 30,
    'weeklyExercise': 4,
    'estimatedWeeks': 8,
  };

  final Map<String, dynamic> _userStats = {
    'height': 175,
    'weight': 82,
    'age': 35,
    'gender': 'Male',
    'bmr': 1755,
    'bmi': 26.8,
  };

  String _selectedTab = 'sleep';

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: widget.animationController,
          curve: Curves.easeOutQuad,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: widget.animationController,
          curve: Curves.easeOutQuad,
        ));

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Data Analysis',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    Text(
                      'Comprehensive health data analysis and personalized recommendations',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 13 : 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTabSelector(isSmallScreen),
                    const SizedBox(height: 20),
                    Expanded(
                      child: _buildSelectedTabContent(isSmallScreen),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabSelector(bool isSmallScreen) {
    return Container(
      height: isSmallScreen ? 50 : 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabButton('sleep', 'Sleep', Iconsax.moon, isSmallScreen),
          _buildTabButton('weight', 'Weight', Iconsax.weight, isSmallScreen),
          _buildTabButton('bmi', 'BMI', Iconsax.health, isSmallScreen),
          _buildTabButton('chat', 'AI Chat', Iconsax.message, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tabId, String title, IconData icon, bool isSmallScreen) {
    final isSelected = _selectedTab == tabId;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = tabId;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 10 : 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal.shade500 : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: isSmallScreen ? 16 : 20,
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 12 : 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedTabContent(bool isSmallScreen) {
    switch (_selectedTab) {
      case 'sleep':
        return _buildSleepAnalysisTab(isSmallScreen);
      case 'weight':
        return _buildWeightLossPlanTab(isSmallScreen);
      case 'bmi':
        return _buildBMICalculatorTab(isSmallScreen);
      case 'chat':
        return _buildAIChatTab(isSmallScreen);
      default:
        return _buildSleepAnalysisTab(isSmallScreen);
    }
  }

  Widget _buildSleepAnalysisTab(bool isSmallScreen) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalysisCard(
            title: 'Weekly Sleep Report',
            isSmallScreen: isSmallScreen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Weekly Sleep Quality',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Avg: ${_calculateAverageSleep().toStringAsFixed(1)}h',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: isSmallScreen ? 150 : 180,
                  child: _buildSleepChart(isSmallScreen),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.indigo.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expert Analysis',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'You\'re getting an average of ${_calculateAverageSleep().toStringAsFixed(1)} hours of sleep daily. This is slightly below the general recommendation of 7-9 hours for adults. You might want to increase your sleep duration slightly, especially on Wednesdays.',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Sleep Improvement Tips:',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      _buildTipItem('Maintain a consistent sleep schedule daily'),
                      _buildTipItem('Avoid caffeine and screens 2 hours before bed'),
                      _buildTipItem('Keep bedroom dark, quiet and cool'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          _buildAnalysisCard(
            title: 'Daily Sleep Details',
            isSmallScreen: isSmallScreen,
            child: Column(
              children: [
                for (var data in _mockSleepData)
                  _buildDailySleepItem(data, isSmallScreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepChart(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: _mockSleepData.map((data) {
        final double heightFactor = data['hours'] / 10;
        Color barColor;

        switch (data['quality']) {
          case 'Excellent':
            barColor = Colors.green;
            break;
          case 'Good':
            barColor = Colors.blue;
            break;
          case 'Average':
            barColor = Colors.orange;
            break;
          default:
            barColor = Colors.red;
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                Container(
                  width: isSmallScreen ? 8 : 12,
                  height: (isSmallScreen ? 100 : 120) * heightFactor,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade200,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: isSmallScreen ? 8 : 12,
                  height: (isSmallScreen ? 100 : 120) * data['deepSleep'] / 10,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade600,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: isSmallScreen ? 30 : 40,
              height: 4,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data['date'],
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 10 : 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildDailySleepItem(Map<String, dynamic> data, bool isSmallScreen) {
    Color qualityColor;

    switch (data['quality']) {
      case 'Excellent':
        qualityColor = Colors.green;
        break;
      case 'Good':
        qualityColor = Colors.blue;
        break;
      case 'Average':
        qualityColor = Colors.orange;
        break;
      default:
        qualityColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isSmallScreen ? 10 : 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: qualityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  data['quality'],
                  style: GoogleFonts.poppins(
                    color: qualityColor,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    data['date'],
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${data['hours']}h',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                'Deep: ${data['deepSleep']}h | Light: ${data['lightSleep']}h',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightLossPlanTab(bool isSmallScreen) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalysisCard(
            title: 'Weight Loss Plan',
            isSmallScreen: isSmallScreen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isSmallScreen ? 15 : 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade400,
                        Colors.teal.shade400,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recommended Plan',
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              '${_weightLossPlan['estimatedWeeks']} weeks',
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 12 : 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildWeightProgressItem(
                            'Current',
                            '${_weightLossPlan['currentWeight']}kg',
                            Colors.blue.shade300,
                            isSmallScreen,
                          ),
                          Container(
                            width: isSmallScreen ? 40 : 60,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          _buildWeightProgressItem(
                            'Target',
                            '${_weightLossPlan['targetWeight']}kg',
                            Colors.green.shade300,
                            isSmallScreen,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Daily Recommendations',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 15),
                _buildNutritionRecommendations(isSmallScreen),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Success Tips:',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildTipItem('Eat smaller, more frequent meals'),
                      _buildTipItem('Drink plenty of water before meals'),
                      _buildTipItem('Exercise ${_weightLossPlan['weeklyExercise']} times weekly for 30 mins'),
                      _buildTipItem('Avoid eating after 8 PM'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightProgressItem(String label, String value, Color color, bool isSmallScreen) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 10 : 15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 12 : 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 12 : 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionRecommendations(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildNutrientItem(
          'Protein',
          '${_weightLossPlan['proteinPercentage']}%',
          Colors.red.shade400,
          isSmallScreen,
        ),
        _buildNutrientItem(
          'Carbs',
          '${_weightLossPlan['carbsPercentage']}%',
          Colors.amber.shade400,
          isSmallScreen,
        ),
        _buildNutrientItem(
          'Fats',
          '${_weightLossPlan['fatsPercentage']}%',
          Colors.blue.shade400,
          isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildNutrientItem(String name, String percentage, Color color, bool isSmallScreen) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: isSmallScreen ? 60 : 80,
              height: isSmallScreen ? 60 : 80,
              child: CircularProgressIndicator(
                value: double.parse(percentage.replaceAll('%', '')) / 100,
                strokeWidth: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Column(
              children: [
                Text(
                  percentage,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 12 : 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          '${(double.parse(percentage.replaceAll('%', '')) * _weightLossPlan['dailyCalories'] / 100).round()} cal',
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 10 : 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildBMICalculatorTab(bool isSmallScreen) {
    final bmiCategory = _getBMICategory(_userStats['bmi']);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalysisCard(
            title: 'Body Mass Index',
            isSmallScreen: isSmallScreen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isSmallScreen ? 15 : 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.shade300,
                        Colors.deepPurple.shade500,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Current BMI',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        _userStats['bmi'].toString(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 32 : 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          bmiCategory['name'],
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.deepPurple.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About BMI:',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        bmiCategory['description'],
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildBMIChart(isSmallScreen),
                const SizedBox(height: 20),
                Text(
                  'Your Stats',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 15),
                _buildUserStatsGrid(isSmallScreen),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recommended Daily Calories: ${_userStats['bmr']} cal',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'This estimate is based on your Basal Metabolic Rate (BMR) and varies depending on your daily activity level.',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStatsGrid(bool isSmallScreen) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      childAspectRatio: isSmallScreen ? 2 : 2.5,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatItem('Age', '${_userStats['age']} years', Icons.calendar_today, isSmallScreen),
        _buildStatItem('Height', '${_userStats['height']} cm', Iconsax.ruler, isSmallScreen),
        _buildStatItem('Weight', '${_userStats['weight']} kg', Iconsax.weight, isSmallScreen),
        _buildStatItem('Gender', _userStats['gender'], Iconsax.user, isSmallScreen),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: isSmallScreen ? 16 : 18,
              color: Colors.deepPurple.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBMIChart(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BMI Categories',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [
                            Colors.blue,
                            Colors.green,
                            Colors.yellow,
                            Colors.orange,
                            Colors.red,
                          ],
                        ),
                      ),
                    ),
                    if (_userStats['bmi'] >= 15 && _userStats['bmi'] <= 40)
                      Positioned(
                        left: ((_userStats['bmi'] - 15) / 25) * MediaQuery.of(context).size.width * 0.7,
                        child: Container(
                          width: 3,
                          height: 40,
                          color: Colors.black,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '40+',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '30',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '25',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '18.5',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '<18.5',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Obese III',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 8 : 10,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                'Obese II',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 8 : 10,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                'Overweight',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 8 : 10,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                'Normal',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 8 : 10,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                'Underweight',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 8 : 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIChatTab(bool isSmallScreen) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isSmallScreen ? 15 : 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.message_question,
                    size: isSmallScreen ? 30 : 40,
                    color: Colors.teal.shade700,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Health AI Assistant',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Ask any health or lifestyle questions and get personalized answers',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 30),
                _buildSampleQuestion('How can I improve my sleep quality?', isSmallScreen),
                const SizedBox(height: 10),
                _buildSampleQuestion('What are the best exercises for weight loss?', isSmallScreen),
                const SizedBox(height: 10),
                _buildSampleQuestion('What foods are high in protein?', isSmallScreen),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade500,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.send,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type your question here...',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey.shade400,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Iconsax.microphone,
                  size: 18,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSampleQuestion(String question, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 15 : 20,
        vertical: isSmallScreen ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Text(
        question,
        style: GoogleFonts.poppins(
          fontSize: isSmallScreen ? 12 : 14,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildAnalysisCard({required String title, required Widget child, required bool isSmallScreen}) {
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
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.teal.shade500,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return {
        'name': 'Underweight',
        'description': 'Your BMI is below the normal range. You may need to gain some weight to reach a healthy level.',
      };
    } else if (bmi >= 18.5 && bmi < 25) {
      return {
        'name': 'Normal weight',
        'description': 'Your BMI is within the normal range. Keep up your healthy lifestyle.',
      };
    } else if (bmi >= 25 && bmi < 30) {
      return {
        'name': 'Overweight',
        'description': 'Your BMI is slightly above the normal range. You may want to lose some weight to reach a healthy level.',
      };
    } else if (bmi >= 30 && bmi < 35) {
      return {
        'name': 'Obese (Class 1)',
        'description': 'Your BMI indicates Class 1 obesity. Gradual weight loss through healthy diet and exercise is recommended.',
      };
    } else {
      return {
        'name': 'Severe Obesity',
        'description': 'Your BMI is very high. Consider consulting a nutritionist or doctor to develop a weight loss plan.',
      };
    }
  }

  double _calculateAverageSleep() {
    double totalHours = 0;
    for (var data in _mockSleepData) {
      totalHours += data['hours'];
    }
    return totalHours / _mockSleepData.length;
  }
}