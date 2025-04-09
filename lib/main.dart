import 'package:blood_pressure_app/Features/Authentication/Presentation/View/sign_up_view.dart';
import 'package:blood_pressure_app/Features/Tabs/Presenation/tabs_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Core/Utils/App Colors.dart';

import 'Features/Authentication/Presentation/View/forgot_password_view.dart';
import 'Features/Authentication/Presentation/View/onboarding_view.dart';
import 'bloc_observer.dart';
import 'firebase_options.dart';

const supabaseUrl = 'https://vtsoufjuwrjpxribosjg.supabase.co';
const supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ0c291Zmp1d3JqcHhyaWJvc2pnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIwMzY4NDUsImV4cCI6MjA1NzYxMjg0NX0.lM2VArwLzWSU4B-cpQ9H-6YDzWb5hJA2mUiQuI_c8dU";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);


  Bloc.observer = MyBlocObserver();

  Widget widget;

  runApp(MyApp(widget: OnBoardingView()));
}

class MyApp extends StatelessWidget {
  final Widget widget;

  const MyApp({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColorsData.white,
          platform: TargetPlatform.iOS,
          primaryColor: AppColorsData.primaryColor,
          canvasColor: Colors.transparent,
          fontFamily: "Urbanist",
          iconTheme: const IconThemeData(
              color: AppColorsData.primaryColor, size: 25),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColorsData.white,
            toolbarHeight: 50,
            elevation: 0,
            surfaceTintColor: AppColorsData.white,
            centerTitle: true,
          ),
        ),
        home: widget
    );
  }
}
