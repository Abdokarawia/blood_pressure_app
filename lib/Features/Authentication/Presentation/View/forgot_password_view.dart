import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Manger/authentication_cubit.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthenticationCubit(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFD4FFD2), Color(0xFFA8E7A5)],
            ),
          ),
          child: SafeArea(
            child: BlocConsumer<AuthenticationCubit, AuthenticationState>(
              listener: (context, state) {
                if (state is PasswordResetSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: Colors.white),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Password reset link sent to ${_emailController.text}',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green[700],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                  Future.delayed(const Duration(seconds: 2), () => Navigator.pop(context));
                } else if (state is AuthenticationError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white),
                          const SizedBox(width: 10),
                          Expanded(child: Text(state.message, style: GoogleFonts.poppins(color: Colors.white))),
                        ],
                      ),
                      backgroundColor: Colors.red[700],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              },
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBackButton(context),
                          const SizedBox(height: 24),
                          _buildLogo(),
                          const SizedBox(height: 40),
                          _buildHeader(),
                          const SizedBox(height: 32),
                          _buildResetForm(context, state),
                          const SizedBox(height: 32),
                          _buildSignInPrompt(context),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: Colors.green[800], size: 28),
      onPressed: () => Navigator.pop(context),
      splashRadius: 24,
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Hero(
        tag: 'logo',
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            height: 160,
            width: 160,
            child: ClipOval(
              child: Image.asset(
                "assets/images/logo.png",
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Forgot Password?',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
            shadows: [
              Shadow(
                color: Colors.green.withOpacity(0.2),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your email to reset your password',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildResetForm(BuildContext context, AuthenticationState state) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildAnimatedTextField(
            controller: _emailController,
            icon: Icons.email_outlined,
            label: 'Email',
            hint: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your email';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          _buildResetButton(context, state),
        ],
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 30),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              cursorColor: Colors.green[700],
              style: GoogleFonts.poppins(fontSize: 15),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(icon, color: Colors.green[700], size: 22),
                filled: true,
                fillColor: Colors.white.withOpacity(0.95),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red[700]!, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                errorStyle: GoogleFonts.poppins(color: Colors.red[700], fontSize: 12),
              ),
              validator: validator,
            ),
          ),
        );
      },
    );
  }

  Widget _buildResetButton(BuildContext context, AuthenticationState state) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: state is AuthenticationLoading
                  ? null
                  : () {
                if (_formKey.currentState!.validate()) {
                  context.read<AuthenticationCubit>().resetPassword(
                    email: _emailController.text.trim(),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 6,
                shadowColor: Colors.green.withOpacity(0.4),
              ),
              child: state is AuthenticationLoading
                  ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : Text(
                'Reset Password',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSignInPrompt(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Remembered your password? ',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              'Sign In',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.green[800],
                decoration: TextDecoration.underline,
                decorationThickness: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
