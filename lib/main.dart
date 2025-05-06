import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'Core/Utils/App Colors.dart';
import 'Features/Authentication/Presentation/View/onboarding_view.dart';
import 'Features/GoalReminders/presentation/Manger/health_goals_cubit.dart';
import 'bloc_observer.dart';
import 'core/Utils/notification_service.dart';
import 'firebase_options.dart';

const supabaseUrl = 'https://vtsoufjuwrjpxribosjg.supabase.co';
const supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ0c291Zmp1d3JqcHhyaWJvc2pnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIwMzY4NDUsImV4cCI6MjA1NzYxMjg0NX0.lM2VArwLzWSU4B-cpQ9H-6YDzWb5hJA2mUiQuI_c8dU";

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  // Initialize local notifications
  await NotificationService().initializeNotifications();


  // Initialize timezone
  tz_data.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('UTC'));

  // Setup notification permissions
  await _setupNotificationPermissions();

  // Initialize BLoC observer
  Bloc.observer = MyBlocObserver();

  // Run the app
  runApp(const MyApp(widget: OnBoardingView()));
}

Future<void> _setupNotificationPermissions() async {
  // Request local notification permissions
  await NotificationService().requestPermissions();
}

class MyApp extends StatelessWidget {
  final Widget widget;
  const MyApp({super.key, required this.widget});


  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HealthGoalsCubit>(
          create: (context) => HealthGoalsCubit(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColorsData.white,
          platform: TargetPlatform.iOS,
          primaryColor: AppColorsData.primaryColor,
          canvasColor: Colors.transparent,
          fontFamily: "Urbanist",
          iconTheme: const IconThemeData(
            color: AppColorsData.primaryColor,
            size: 25,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColorsData.white,
            toolbarHeight: 50,
            elevation: 0,
            surfaceTintColor: AppColorsData.white,
            centerTitle: true,
          ),
        ),
        home: widget,
      ),
    );
  }
}