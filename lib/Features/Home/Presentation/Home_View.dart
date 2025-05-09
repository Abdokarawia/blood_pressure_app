import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:dio/dio.dart';
import 'package:share_plus/share_plus.dart';

import 'health_chat_view.dart';

class HomeView extends StatefulWidget {
  final AnimationController animationController;
  Map<String, dynamic> userStats;

  HomeView({
    super.key,
    required this.userStats,
    required this.animationController,
  });

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // API related variables
  final Dio _dio = Dio();
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _weightLossPlanApiData;

  // Health Analysis Data
  String _selectedTab = 'sleep';

  double _averageSleepHours = 0.0;

  // List of all sleep tips
  final List<String> _allSleepTips = const [
    'Maintain a consistent sleep schedule daily',
    'Avoid caffeine and screens 2 hours before bed',
    'Keep bedroom dark, quiet and cool',
    'Exercise regularly, but not close to bedtime',
    'Limit daytime naps to 20-30 minutes',
    'Create a relaxing bedtime routine',
    'Use comfortable mattress and pillows',
    'Manage stress with relaxation techniques before bed',
    'Avoid large meals and alcohol before sleeping',
  ];

  Future<void> _loadAverageSleepHours() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });



      // Call the function to get average sleep hours
      final average = await getAverageSleepHours();

      setState(() {
        _averageSleepHours =  average;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load average sleep: ${e.toString()}';
        _isLoading = false;
      });
    }
  }



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

  final List<Map<String, dynamic>> _sleepMealRecommendations = [
    {
      'time': 'Dinner',
      'calories': 500,
      'foods': [
        {'name': 'Grilled Salmon', 'calories': 250, 'icon': Iconsax.cake},
        {'name': 'Quinoa', 'calories': 150, 'icon': Iconsax.cake},
        {'name': 'Steamed Broccoli', 'calories': 100, 'icon': Iconsax.cake},
      ],
      'tips': 'Eat 2-3 hours before bed. Avoid heavy, spicy foods.',
      'color': Colors.indigo.shade400,
    },
    {
      'time': 'Bedtime Snack',
      'calories': 150,
      'foods': [
        {'name': 'Almonds', 'calories': 100, 'icon': Iconsax.cake},
        {'name': 'Chamomile Tea', 'calories': 5, 'icon': Iconsax.cup},
        {'name': 'Banana', 'calories': 45, 'icon': Iconsax.cake},
      ],
      'tips': 'Small snack 30-60 min before bed can promote sleep.',
      'color': Colors.purple.shade300,
    },
    {
      'time': 'Light Dinner',
      'calories': 450,
      'foods': [
        {'name': 'Turkey Breast', 'calories': 200, 'icon': Iconsax.cake},
        {'name': 'Sweet Potato', 'calories': 150, 'icon': Iconsax.cake},
        {'name': 'Spinach Salad', 'calories': 100, 'icon': Iconsax.cake},
      ],
      'tips': 'Turkey contains tryptophan which may help with sleep.',
      'color': Colors.teal.shade400,
    },
    {
      'time': 'Evening Meal',
      'calories': 400,
      'foods': [
        {'name': 'Chicken Soup', 'calories': 200, 'icon': Iconsax.coffee},
        {'name': 'Whole Grain Bread', 'calories': 120, 'icon': Iconsax.cake},
        {'name': 'Sliced Avocado', 'calories': 80, 'icon': Iconsax.cake},
      ],
      'tips': 'Warm soup can be soothing before bed. Eat 3 hours before sleep.',
      'color': Colors.green.shade300,
    },
    {
      'time': 'Pre-Sleep Snack',
      'calories': 180,
      'foods': [
        {'name': 'Greek Yogurt', 'calories': 100, 'icon': Iconsax.cup},
        {'name': 'Cherry Juice', 'calories': 50, 'icon': Iconsax.cup},
        {'name': 'Walnuts', 'calories': 30, 'icon': Iconsax.cake},
      ],
      'tips': 'Cherries contain natural melatonin that may help with sleep quality.',
      'color': Colors.pink.shade300,
    },
    {
      'time': 'Evening Light Meal',
      'calories': 350,
      'foods': [
        {'name': 'Lentil Soup', 'calories': 180, 'icon': Iconsax.coffee},
        {'name': 'Brown Rice', 'calories': 120, 'icon': Iconsax.cake},
        {'name': 'Steamed Carrots', 'calories': 50, 'icon': Iconsax.cake},
      ],
      'tips': 'Complex carbs can boost serotonin to help you sleep better.',
      'color': Colors.amber.shade400,
    },
    {
      'time': 'Night Protein Snack',
      'calories': 190,
      'foods': [
        {'name': 'Cottage Cheese', 'calories': 120, 'icon': Iconsax.cup},
        {'name': 'Kiwi Fruit', 'calories': 50, 'icon': Iconsax.cake},
        {'name': 'Valerian Tea', 'calories': 20, 'icon': Iconsax.cup},
      ],
      'tips': 'Slow-digesting protein like cottage cheese provides amino acids through the night.',
      'color': Colors.blue.shade300,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadAverageSleepHours();

    if (_selectedTab == 'weight') {
      fetchWeightLossPlan();
    }
  }


  // Select 3 random tips from the list
  List<String> _getRandomTips(int count) {
    // Create a copy of the original list to avoid modifying it
    final tipsCopy = List<String>.from(_allSleepTips);

    // Shuffle the list
    tipsCopy.shuffle(Random());

    // Return the first 'count' elements or all if less than 'count'
    return tipsCopy.take(count).toList();
  }

  // Update your existing fetchWeightLossPlan function:
  Future<void> fetchWeightLossPlan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get the API URL from Firebase Firestore
      final DocumentSnapshot docSnapshot =
          await FirebaseFirestore.instance
              .collection('AI_LINK')
              .doc('ee7PKmGZq3xe5PRJEqq2')
              .get();

      if (!docSnapshot.exists) {
        throw Exception('API endpoint document not found in Firestore');
      }

      final data = docSnapshot.data() as Map<String, dynamic>;
      final String apiUrl = data['link'] ?? '';

      if (apiUrl.isEmpty) {
        throw Exception('API URL not found in the document');
      }

      // Now use the retrieved URL for the API call
      final response = await _dio.post(
        "$apiUrl/weight-loss-plan",
        data: {
          "current_weight_kg": widget.userStats['weight'],
          "sleep_hours": 7.5,
          "weight_loss_required": 10,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      setState(() {
        _isLoading = false;
        _weightLossPlanApiData = response.data;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        if (e is DioException) {
          _errorMessage = e.response?.statusMessage ?? 'Network error occurred';
        } else {
          _errorMessage = e.toString();
        }
      });
      print('Error fetching weight loss plan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;
    print(widget.userStats);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Health Analysis Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 20.0 : 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTabSelector(isSmallScreen),
                  const SizedBox(height: 20),
                  _buildSelectedTabContent(isSmallScreen),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Health Analysis Components
  Widget _buildTabSelector(bool isSmallScreen) {
    return Container(
      height: isSmallScreen ? 70 : 65,
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

  Widget _buildTabButton(
    String tabId,
    String title,
    IconData icon,
    bool isSmallScreen,
  ) {
    final isSelected = _selectedTab == tabId;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = tabId;
        });

        // Fetch data when weight tab is selected
        if (tabId == 'weight' && _weightLossPlanApiData == null) {
          fetchWeightLossPlan();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 15 : 20,
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
        return // In Home_View.dart
        SizedBox(
          height:
              MediaQuery.of(context).size.height * 0.6, // or a specific height
          child: HealthAIChatScreen(),
        );
      default:
        return _buildSleepAnalysisTab(isSmallScreen);
    }
  }
  Future<double> getAverageSleepHours({int days = 7}) async {
    try {
      // Get the current user's UID directly from Firebase Auth
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Get all health data for the user without date filtering
      final querySnapshot = await FirebaseFirestore.instance
          .collection('healthData')
          .doc(userId)
          .collection('dailyData')
          .get();

      // Extract sleep hours from the documents
      final sleepHoursList = querySnapshot.docs
          .map((doc) => doc.data()['sleepHours'] ?? 0.0)
          .where((hours) => hours > 0) // Filter out zero values
          .toList();

      // Calculate the average sleep hours
      if (sleepHoursList.isEmpty) {
        return 0.0;
      }

      final totalSleepHours = sleepHoursList.reduce((a, b) => a + b);
      return totalSleepHours / sleepHoursList.length;
    } catch (e) {
      throw Exception('Failed to calculate average sleep hours: $e');
    }
  }

  Widget _buildSleepAnalysisTab(bool isSmallScreen) {
    final randomTips = _getRandomTips(3);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalysisCard(
            title: 'Weekly Sleep Report',
            isSmallScreen: isSmallScreen,
            showShareIcon: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        'You\'re getting an average of ${_averageSleepHours.toStringAsFixed(1)} hours of sleep daily. This is slightly below the general recommendation of 7-9 hours for adults. You might want to increase your sleep duration slightly, especially on Wednesdays.',
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
                      ...randomTips.map((tip) => _buildTipItem(tip)).toList(),

                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          _buildAnalysisCard(
            title: 'Sleep-Friendly Meal Plan',
            isSmallScreen: isSmallScreen,
            showShareIcon: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Optimize your diet for better sleep quality',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 15),
                  _buildMealRecommendationCard(_sleepMealRecommendations[Random().nextInt(_sleepMealRecommendations.length)], isSmallScreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightLossPlanTab(bool isSmallScreen) {
    return _isLoading
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.teal.shade500),
              const SizedBox(height: 20),
              Text(
                'Fetching your personalized weight loss plan...',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        )
        : _errorMessage != null
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.warning_2, size: 50, color: Colors.red.shade400),
              const SizedBox(height: 20),
              Text(
                'Error: $_errorMessage',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.red.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: fetchWeightLossPlan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade500,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Try Again',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        )
        : _weightLossPlanApiData != null
        ? _buildApiWeightLossPlan(isSmallScreen)
        : _buildLocalWeightLossPlan(isSmallScreen);
  }

  Widget _buildApiWeightLossPlan(bool isSmallScreen) {
    final eatPlan = _weightLossPlanApiData!['Eat Plan'];
    final sleepData = _weightLossPlanApiData!['Sleep'];
    final macros = _weightLossPlanApiData!['macronutrients'];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalysisCard(
            title: 'Your Weight Loss Plan',
            isSmallScreen: isSmallScreen,
            showShareIcon: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'API-Generated Personalized Plan',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.teal.shade700,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Macronutrients',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMacroCircle(
                            'Proteins',
                            macros['Protein'],
                            Colors.red.shade400,
                            isSmallScreen,
                          ),
                          _buildMacroCircle(
                            'Carbs',
                            macros['Carbs'],
                            Colors.blue.shade400,
                            isSmallScreen,
                          ),
                          _buildMacroCircle(
                            'Fats',
                            macros['fats'],
                            Colors.amber.shade600,
                            isSmallScreen,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          _buildAnalysisCard(
            title: 'Daily Meal Plan',
            isSmallScreen: isSmallScreen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMealSection(
                  'Breakfast',
                  eatPlan['breakfast'],
                  Colors.amber.shade100,
                  Colors.amber.shade700,
                  isSmallScreen,
                ),
                const SizedBox(height: 15),
                _buildMealSection(
                  'Lunch',
                  eatPlan['lunch'],
                  Colors.teal.shade100,
                  Colors.teal.shade700,
                  isSmallScreen,
                ),
                const SizedBox(height: 15),
                _buildMealSection(
                  'Dinner',
                  eatPlan['dinner'],
                  Colors.purple.shade100,
                  Colors.purple.shade700,
                  isSmallScreen,
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          _buildAnalysisCard(
            title: 'Sleep & Weight Loss',
            isSmallScreen: isSmallScreen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sleep Calorie Burn',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo.shade700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        sleepData['Sleep Calorie burn'],
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  sleepData['Comment'],
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 13 : 15,
                    color: Colors.grey.shade800,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'Sleep Tips:',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.indigo.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                for (var tip in sleepData['Tips']) _buildTipItem(tip),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSection(
    String mealTitle,
    Map<String, dynamic> mealData,
    Color bgColor,
    Color textColor,
    bool isSmallScreen,
  ) {
    final dishes = mealData['dishes'] as Map<String, dynamic>;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeaderText(mealTitle, textColor, isSmallScreen),
              _buildCaloriesBadge(
                mealData['total calories'].toString(),
                textColor,
                isSmallScreen,
              ),
            ],
          ),

          // Always Show Dishes
          if (dishes.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (var dish in dishes.entries)
              _buildDishItem(dish, textColor, isSmallScreen),
          ],

          // Optional Summary Text (if needed)
          if (dishes.isEmpty)
            _buildSummaryText(dishes.length, textColor, isSmallScreen),
        ],
      ),
    );
  }

  // Helper Method: Build Header Text
  Widget _buildHeaderText(String text, Color textColor, bool isSmallScreen) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: isSmallScreen ? 16 : 18,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  // Helper Method: Build Calories Badge
  Widget _buildCaloriesBadge(
    String calories,
    Color textColor,
    bool isSmallScreen,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$calories cal',
        style: GoogleFonts.poppins(
          fontSize: isSmallScreen ? 12 : 14,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildMacroCircle(
    String title,
    String value,
    Color color,
    bool isSmallScreen,
  ) {
    return Column(
      children: [
        // Animated Container for Macro Circle
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _getMacroCircleSize(isSmallScreen),
          height: _getMacroCircleSize(isSmallScreen),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.2),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: _buildMacroValueText(value, color, isSmallScreen),
          ),
        ),
        const SizedBox(height: 8),
        _buildMacroTitleText(title, isSmallScreen),
      ],
    );
  }

  // Helper Method: Get Macro Circle Size
  double _getMacroCircleSize(bool isSmallScreen) {
    return isSmallScreen ? 70 : 80;
  }

  // Helper Method: Build Macro Value Text
  Widget _buildMacroValueText(String value, Color color, bool isSmallScreen) {
    return Text(
      value,
      style: GoogleFonts.poppins(
        fontSize: isSmallScreen ? 16 : 18,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  // Helper Method: Build Macro Title Text
  Widget _buildMacroTitleText(String title, bool isSmallScreen) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: isSmallScreen ? 12 : 14,
        color: Colors.grey.shade800,
      ),
    );
  }

  // Helper Method: Build Dish Item
  Widget _buildDishItem(
    MapEntry<String, dynamic> dish,
    Color textColor,
    bool isSmallScreen,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 6.0 : 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Dish Name with Icon
          Expanded(
            child: Row(
              children: [
                Icon(Iconsax.cake, size: 14, color: textColor.withOpacity(0.8)),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Flexible(
                  child: Text(
                    dish.value['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: textColor.withOpacity(0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),

          // Dish Calories
          Text(
            '${dish.value['calories']} cal',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Method: Build Summary Text
  Widget _buildSummaryText(int itemCount, Color textColor, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        '$itemCount items - Tap to expand',
        style: GoogleFonts.poppins(
          fontSize: isSmallScreen ? 12 : 13,
          color: textColor.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildLocalWeightLossPlan(bool isSmallScreen) {
    // Fallback to local data if API data is not available
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalysisCard(
            title: 'Weight Loss Plan',
            isSmallScreen: isSmallScreen,
            showShareIcon: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Default Weight Loss Plan',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWeightInfoCard(
                      'Current',
                      _weightLossPlan['currentWeight'].toString(),
                      'kg',
                      Colors.blue,
                      isSmallScreen,
                    ),
                    Icon(Iconsax.arrow_right_3, color: Colors.grey.shade400),
                    _buildWeightInfoCard(
                      'Target',
                      _weightLossPlan['targetWeight'].toString(),
                      'kg',
                      Colors.green,
                      isSmallScreen,
                    ),
                    Icon(Iconsax.arrow_right_3, color: Colors.grey.shade400),
                    _buildWeightInfoCard(
                      'Time',
                      _weightLossPlan['estimatedWeeks'].toString(),
                      'weeks',
                      Colors.purple,
                      isSmallScreen,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: fetchWeightLossPlan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    'Get Personalized Plan',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightInfoCard(
    String title,
    String value,
    String unit,
    MaterialColor color,
    bool isSmallScreen,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.shade200, width: 1),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 12 : 14,
              color: color.shade700,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: color.shade700,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: color.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Iconsax.tick_circle, size: 16, color: Colors.teal.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealRecommendationCard(
    Map<String, dynamic> meal,
    bool isSmallScreen,
  ) {
    // State variable for expansion
    bool isExpanded = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: meal['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: meal['color'].withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with time and expand/collapse functionality
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: meal['color'].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Iconsax.clock,
                      color: meal['color'],
                      size: isSmallScreen ? 16 : 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal['time'],
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          '${meal['calories']} calories',
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 12 : 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Expand/collapse button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: meal['color'].withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: isSmallScreen ? 16 : 18,
                        color: meal['color'],
                      ),
                    ),
                  ),
                ],
              ),

              // Show food items only when expanded
              if (isExpanded) ...[
                const SizedBox(height: 12),
                for (var food in meal['foods'])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              food['icon'],
                              size: isSmallScreen ? 16 : 18,
                              color: meal['color'],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              food['name'],
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 13 : 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${food['calories']} cal',
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 12 : 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  meal['tips'],
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 12 : 13,
                    fontStyle: FontStyle.italic,
                    color: meal['color'],
                  ),
                ),
              ],

              // Summary text when collapsed
              if (!isExpanded)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Contains ${meal['foods'].length} items',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 12 : 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _shareContent(String title) async {
    String shareText = 'Check out my $title from Health App\n\n';

    if (title == 'Weekly Sleep Report') {
      shareText += 'Average Sleep: ${_averageSleepHours.toStringAsFixed(1)} hours\n';
    } else if (title == 'Weight Loss Plan') {
      shareText += 'Current Weight: ${_weightLossPlan['currentWeight']}kg\n';
      shareText += 'Target Weight: ${_weightLossPlan['targetWeight']}kg\n';
      shareText += 'Estimated Time: ${_weightLossPlan['estimatedWeeks']} weeks';
    } else if (title == 'Body Mass Index') {
      shareText += 'BMI: ${widget.userStats['bmi']}\n';
      shareText +=
          'Category: ${_getBMICategory(widget.userStats['bmi'])['name']}\n';
      shareText += 'Weight: ${widget.userStats['weight']}kg\n';
      shareText += 'Height: ${widget.userStats['height']}cm';
    } else if (title == 'Sleep-Friendly Meal Plan') {
      shareText += 'Meal Recommendations:\n';
      for (var meal in _sleepMealRecommendations) {
        shareText += '${meal['time']} (${meal['calories']} cal):\n';
        shareText += meal['foods']
            .map((food) => ' - ${food['name']} (${food['calories']} cal)')
            .join('\n');
        shareText += '\nTips: ${meal['tips']}\n\n';
      }
    }

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
                  onTap: () => _shareContent(title),
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

  Widget _buildBMICalculatorTab(bool isSmallScreen) {
    final bmiCategory = _getBMICategory(widget.userStats['bmi']);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalysisCard(
            title: 'Body Mass Index',
            isSmallScreen: isSmallScreen,
            showShareIcon: true,
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
                        widget.userStats['bmi'].toString(),
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
                        'Recommended Daily Calories: ${widget.userStats['bmr']} cal',
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
        _buildStatItem(
          'Age',
          '${widget.userStats['age']} years',
          Icons.calendar_today,
          isSmallScreen,
        ),
        _buildStatItem(
          'Height',
          '${widget.userStats['height']} cm',
          Iconsax.ruler,
          isSmallScreen,
        ),
        _buildStatItem(
          'Weight',
          '${widget.userStats['weight']} kg',
          Iconsax.weight,
          isSmallScreen,
        ),
        _buildStatItem(
          'Gender',
          widget.userStats['gender'],
          Iconsax.user,
          isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200, width: 1),
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
        border: Border.all(color: Colors.grey.shade200, width: 1),
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
                    if (widget.userStats['bmi'] >= 15 &&
                        widget.userStats['bmi'] <= 40)
                      Positioned(
                        left:
                            ((widget.userStats['bmi'] - 15) / 25) *
                            MediaQuery.of(context).size.width *
                            0.7,
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

  Map<String, dynamic> _getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return {
        'name': 'Underweight',
        'description':
            'Your BMI is below the normal range. You may need to gain some weight to reach a healthy level.',
      };
    } else if (bmi >= 18.5 && bmi < 25) {
      return {
        'name': 'Normal weight',
        'description':
            'Your BMI is within the normal range. Keep up your healthy lifestyle.',
      };
    } else if (bmi >= 25 && bmi < 30) {
      return {
        'name': 'Overweight',
        'description':
            'Your BMI is slightly above the normal range. You may want to lose some weight to reach a healthy level.',
      };
    } else if (bmi >= 30 && bmi < 35) {
      return {
        'name': 'Obese (Class 1)',
        'description':
            'Your BMI indicates Class 1 obesity. Gradual weight loss through healthy diet and exercise is recommended.',
      };
    } else {
      return {
        'name': 'Severe Obesity',
        'description':
            'Your BMI is very high. Consider consulting a nutritionist or doctor to develop a weight loss plan.',
      };
    }
  }
}
