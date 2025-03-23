import 'package:blood_pressure_app/core/Utils/Shared%20Methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../Tabs/Presenation/tabs_view.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _agreeToTerms = false;
  DateTime? _selectedDate;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // Start animations
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Date picker function
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ??
          DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green[700]!,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.green[700]),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateOfBirthController.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFFD4FFD2), const Color(0xFFA8E7A5)],
            stops: const [0.3, 1.0], // Added stops for more dramatic gradient
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(), // Added smoother scrolling
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 0.0,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo with improved visual effect
                      Center(
                        child: Hero(
                          tag: 'logo',
                          child: Container(
                            margin: const EdgeInsets.only(
                              top: 16,
                            ), // Added margin
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              height: 100,
                              width: 180,
                              child: Center(
                                child: ClipOval(
                                  child: Image.asset(
                                    "assets/images/logo.png",
                                    width: 180,
                                    height: 100,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Welcome text with improved typography
                      Text(
                        'Create Account',
                        style: GoogleFonts.poppins(
                          fontSize: 32, // Increased font size
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                          letterSpacing: -0.5, // Added letter spacing
                        ),
                      ),
                      Text(
                        'Sign up to join PulseGuard',
                        style: GoogleFonts.poppins(
                          fontSize: 16, // Increased font size
                          color: Colors.grey[700],
                          letterSpacing: 0.2, // Added letter spacing
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Registration form with improved spacing
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Full Name field
                            _buildAnimatedTextField(
                              controller: _nameController,
                              icon: Icons.person_outline,
                              label: 'Full Name',
                              hint: 'Enter your full name',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20), // Increased spacing
                            // Email field
                            _buildAnimatedTextField(
                              controller: _emailController,
                              icon: Icons.email_outlined,
                              label: 'Email',
                              hint: 'Enter your email',
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20), // Increased spacing
                            // Phone Number field
                            _buildAnimatedTextField(
                              controller: _phoneController,
                              icon: Icons.phone_outlined,
                              label: 'Phone Number',
                              hint: 'Enter your phone number',
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(
                                  value.replaceAll(RegExp(r'[\s\-\(\)]'), ''),
                                )) {
                                  return 'Please enter a valid phone number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20), // Increased spacing
                            // Date of Birth field
                            _buildAnimatedTextField(
                              controller: _dateOfBirthController,
                              icon: Icons.calendar_today_outlined,
                              label: 'Date of Birth',
                              hint: 'MM/DD/YYYY',
                              keyboardType: TextInputType.datetime,
                              readOnly: true,
                              onTap: () => _selectDate(context),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your date of birth';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20), // Increased spacing
                            // Password field
                            _buildAnimatedTextField(
                              controller: _passwordController,
                              icon: Icons.lock_outline,
                              label: 'Password',
                              hint: 'Enter your password',
                              obscureText: !_isPasswordVisible,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20), // Increased spacing
                            // Confirm Password field
                            _buildAnimatedTextField(
                              controller: _confirmPasswordController,
                              icon: Icons.lock_outline,
                              label: 'Confirm Password',
                              hint: 'Confirm your password',
                              obscureText: !_isConfirmPasswordVisible,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),

                            // Terms and Conditions checkbox with improved styling
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20.0,
                              ), // Increased padding
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    height: 24,
                                    width: 24,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        6,
                                      ), // Increased border radius
                                      border: Border.all(
                                        color:
                                            _agreeToTerms
                                                ? Colors.green[700]!
                                                : Colors.grey[400]!,
                                        width: 1.5, // Increased border width
                                      ),
                                      color:
                                          _agreeToTerms
                                              ? Colors.green[700]
                                              : Colors.transparent,
                                    ),
                                    child: Checkbox(
                                      value: _agreeToTerms,
                                      activeColor: Colors.transparent,
                                      checkColor: Colors.white,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      side: BorderSide.none,
                                      onChanged: (value) {
                                        setState(() {
                                          _agreeToTerms = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        text: 'I agree to the ',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Terms of Service',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.green[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' and ',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Privacy Policy',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.green[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Sign Up button with enhanced animation and styling
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 500),
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 60, // Increased height
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate() &&
                                            _agreeToTerms) {
                                          navigateAndFinished(
                                            context,
                                            TabScreen(),
                                          );
                                        } else if (!_agreeToTerms) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.info_outline,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  const Text(
                                                    'Please agree to the Terms and Privacy Policy',
                                                  ),
                                                ],
                                              ),
                                              backgroundColor: Colors.red[700],
                                              duration: const Duration(
                                                seconds: 3,
                                              ),
                                              behavior:
                                                  SnackBarBehavior
                                                      .floating, // Changed to floating
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green[700],
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ), // Increased radius
                                        ),
                                        elevation: 6, // Increased elevation
                                        shadowColor: Colors.green.withOpacity(
                                          0.6,
                                        ),
                                      ),
                                      child: Text(
                                        'Create Account', // Changed text
                                        style: GoogleFonts.poppins(
                                          fontSize: 18, // Increased font size
                                          fontWeight: FontWeight.w600,
                                          letterSpacing:
                                              0.5, // Added letter spacing
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Social login section with improved divider
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 28.0,
                              ), // Increased padding
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 1.5, // Increased thickness
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.grey[300]!.withOpacity(0.1),
                                            Colors.grey[400]!,
                                            Colors.grey[300]!.withOpacity(0.1),
                                          ],
                                          stops: const [0.0, 0.5, 1.0],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      'Or sign up with',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 1.5, // Increased thickness
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.grey[300]!.withOpacity(0.1),
                                            Colors.grey[400]!,
                                            Colors.grey[300]!.withOpacity(0.1),
                                          ],
                                          stops: const [0.0, 0.5, 1.0],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Social buttons with enhanced styling
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSocialIconButton(
                                  FontAwesomeIcons.google,
                                  Colors.red,
                                ),
                              ],
                            ),

                            const SizedBox(height: 28), // Increased spacing
                            // Already have an account text with improved styling
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an account? ",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Sign In',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green[800],
                                      decoration:
                                          TextDecoration
                                              .underline, // Added underline
                                      decorationThickness:
                                          1.5, // Set underline thickness
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28), // Increased spacing
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Enhanced Animated TextField builder method
  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool readOnly = false,
    Widget? suffixIcon,
    VoidCallback? onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              readOnly: readOnly,
              onTap: onTap,
              cursorColor: Colors.green[700],
              style: GoogleFonts.poppins(fontSize: 15), // Added text style
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500, // Added font weight
                ),
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.grey[400], // Lighter hint text
                ),
                prefixIcon: Icon(
                  icon,
                  color: Colors.green[700],
                  size: 22,
                ), // Increased icon size
                suffixIcon: suffixIcon,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    18,
                  ), // Increased border radius
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    18,
                  ), // Increased border radius
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    18,
                  ), // Increased border radius
                  borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    18,
                  ), // Increased border radius
                  borderSide: BorderSide(color: Colors.red[400]!, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    18,
                  ), // Increased border radius
                  borderSide: BorderSide(color: Colors.red[700]!, width: 2),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.95), // Enhanced opacity
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 16,
                ), // Increased padding
                errorStyle: GoogleFonts.poppins(
                  color: Colors.red[700],
                  fontSize: 12, // Smaller error text
                ),
              ),
              validator: validator,
            ),
          ),
        );
      },
    );
  }

  // Enhanced Social Icon Button Builder with animation
  Widget _buildSocialIconButton(IconData icon, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: value,
            child: Container(
              height: 60, // Increased height
              width: 88, // Increased width
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  18,
                ), // Increased border radius
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: FaIcon(
                  icon,
                  color: color,
                  size: 24,
                ), // Increased icon size
                onPressed: () {
                  // Handle social sign up with subtle feedback
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
