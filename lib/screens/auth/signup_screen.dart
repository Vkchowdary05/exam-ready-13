import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_ready/screens/auth/on_boarding.dart';
import 'package:exam_ready/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:exam_ready/theme/app_theme.dart';
import 'package:exam_ready/services/auth_service.dart';
import 'package:exam_ready/widgets/gradient_button.dart';
import 'package:exam_ready/screens/ui/home.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _authService.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      name: _nameController.text.trim(),
    );
    FirebaseService.instance.firestore
        .collection('user')
        .doc('T5ddmSMhEr9C7ef8UZAu')
        .update({'user': FieldValue.increment(1)});

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      // ✅ Success animation
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
          child: Icon(Icons.check_circle, color: Colors.greenAccent, size: 100)
              .animate()
              .scale(duration: 800.ms, curve: Curves.elasticOut)
              .then(delay: 400.ms)
              .fadeOut(duration: 300.ms),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 1200));

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const UserOnboardingPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08,
                vertical: screenHeight * 0.02,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.04),

                    // Back Button
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new),
                      color: AppTheme.textPrimary,
                    ).animate().fadeIn(delay: 100.ms),

                    SizedBox(height: screenHeight * 0.02),

                    // Logo Hero
                    Center(
                      child: Hero(
                        tag: 'auth_logo',
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: AppTheme.accentGradient,
                            shape: BoxShape.circle,
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: const Icon(
                            Icons.person_add_outlined,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ).animate().scale(
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    // Title
                    Text('Create Account', style: AppTheme.headingStyle)
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideX(begin: -0.2, end: 0),

                    const SizedBox(height: 8),
                    Text(
                          'Sign up to get started',
                          style: AppTheme.subHeadingStyle,
                        )
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .slideX(begin: -0.2, end: 0),

                    SizedBox(height: screenHeight * 0.04),

                    // Name Field
                    TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          style: AppTheme.inputTextStyle,
                          decoration: AppTheme.inputDecoration(
                            hint: 'Full Name',
                            icon: Icons.person_outline,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            if (value.length < 3) {
                              return 'Name must be at least 3 characters';
                            }
                            return null;
                          },
                        )
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 20),

                    // Email Field ✅ Fixed Regex
                    TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: AppTheme.inputTextStyle,
                          decoration: AppTheme.inputDecoration(
                            hint: 'Email Address',
                            icon: Icons.email_outlined,
                          ),
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
                        )
                        .animate()
                        .fadeIn(delay: 500.ms)
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 20),

                    // Password Field
                    TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: AppTheme.inputTextStyle,
                          decoration: AppTheme.inputDecoration(
                            hint: 'Password',
                            icon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppTheme.textSecondary,
                              ),
                              onPressed: () {
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                            ),
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
                        )
                        .animate()
                        .fadeIn(delay: 600.ms)
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 20),

                    // Confirm Password Field
                    TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          style: AppTheme.inputTextStyle,
                          decoration: AppTheme.inputDecoration(
                            hint: 'Confirm Password',
                            icon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppTheme.textSecondary,
                              ),
                              onPressed: () {
                                setState(
                                  () => _obscureConfirmPassword =
                                      !_obscureConfirmPassword,
                                );
                              },
                            ),
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
                        )
                        .animate()
                        .fadeIn(delay: 700.ms)
                        .slideY(begin: 0.2, end: 0),

                    SizedBox(height: screenHeight * 0.04),

                    // Sign Up Button
                    GradientButton(
                          text: 'Sign Up',
                          onPressed: _handleSignUp,
                          isLoading: _isLoading,
                          icon: Icons.arrow_forward,
                          gradient: AppTheme.accentGradient,
                        )
                        .animate()
                        .fadeIn(delay: 800.ms)
                        .slideY(begin: 0.2, end: 0),

                    SizedBox(height: screenHeight * 0.03),

                    // Login Link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: AppTheme.subHeadingStyle,
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              'Login',
                              style: AppTheme.labelTextStyle.copyWith(
                                color: AppTheme.accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 900.ms),

                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
