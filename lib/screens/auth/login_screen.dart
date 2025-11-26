import 'package:exam_ready/screens/auth/on_boarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:exam_ready/theme/app_theme.dart';
import 'package:exam_ready/services/auth_service.dart';
import 'package:exam_ready/widgets/gradient_button.dart';
import 'signup_screen.dart';
import 'package:exam_ready/screens/ui/home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _authService.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );


    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
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

  Future<void> _handleGoogleSignIn() async {
  setState(() => _isGoogleLoading = true);

  try {
    // Call your existing AuthService (it should return UserCredential or null)
    final Map<String, dynamic> result = await _authService.signInWithGoogle();
    setState(() => _isGoogleLoading = false);

    if (!mounted) return;

    if (!result['success']) {
      // Error occurred
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Google sign-in failed'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Login successful → Navigate to Dashboard
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
  } catch (e, st) {
    setState(() => _isGoogleLoading = false);
    debugPrint("Google sign-in error: $e\n$st");

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('An error occurred while signing in'),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your email address'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final result = await _authService.resetPassword(
      email: _emailController.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']),
        backgroundColor: result['success']
            ? AppTheme.secondaryColor
            : AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _navigateToSignUp() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SignupScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    if (_isGoogleLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
      );
    }

    return AnimatedGoogleButton(onPressed: _handleGoogleSignIn);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
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
                    SizedBox(height: screenHeight * 0.06),

                    // Logo/Icon Hero
                    Center(
                      child: Hero(
                        tag: 'auth_logo',
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: const Icon(
                            Icons.lock_outline,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ).animate().scale(
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    // Welcome Text
                    Text('Welcome Back!', style: AppTheme.headingStyle)
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideX(begin: -0.2, end: 0),

                    const SizedBox(height: 8),
                    Text(
                          'Login to continue your journey',
                          style: AppTheme.subHeadingStyle,
                        )
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .slideX(begin: -0.2, end: 0),

                    SizedBox(height: screenHeight * 0.05),

                    // Email Field
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
                        .fadeIn(delay: 400.ms)
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
                        .fadeIn(delay: 500.ms)
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 12),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _handleForgotPassword,
                        child: Text(
                          'Forgot Password?',
                          style: AppTheme.labelTextStyle.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms),

                    SizedBox(height: screenHeight * 0.03),

                    // Login Button
                    GradientButton(
                          text: 'Login',
                          onPressed: _handleLogin,
                          isLoading: _isLoading,
                          icon: Icons.login,
                        )
                        .animate()
                        .fadeIn(delay: 700.ms)
                        .slideY(begin: 0.2, end: 0),

                    SizedBox(height: screenHeight * 0.03),

                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('OR', style: AppTheme.subHeadingStyle),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ).animate().fadeIn(delay: 800.ms),

                    SizedBox(height: screenHeight * 0.03),

                    // Google Sign-In Button
                    _buildGoogleSignInButton()
                        .animate()
                        .fadeIn(delay: 850.ms)
                        .slideY(begin: 0.2, end: 0),

                    SizedBox(height: screenHeight * 0.03),

                    // Sign Up Link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account? ',
                            style: AppTheme.subHeadingStyle,
                          ),
                          GestureDetector(
                            onTap: _navigateToSignUp,
                            child: Text(
                              'Sign Up',
                              style: AppTheme.labelTextStyle.copyWith(
                                color: AppTheme.primaryColor,
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

// IMPORTANT: Move the AnimatedGoogleButton class OUTSIDE of _LoginScreenState
class AnimatedGoogleButton extends StatefulWidget {
  final VoidCallback onPressed;

  const AnimatedGoogleButton({super.key, required this.onPressed});

  @override
  State<AnimatedGoogleButton> createState() => _AnimatedGoogleButtonState();
}

class _AnimatedGoogleButtonState extends State<AnimatedGoogleButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          transform: Matrix4.identity()
            ..scale(_isPressed ? 0.95 : (_isHovered ? 1.02 : 1.0)),
          decoration: BoxDecoration(
            gradient: _isHovered
                ? LinearGradient(
                    colors: [Colors.white, Colors.blue.withAlpha(13)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: _isHovered ? null : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? Colors.black.withAlpha(26)
                    : (_isHovered
                          ? Colors.blue.withAlpha(51)
                          : Colors.black.withAlpha(20)),
                blurRadius: _isPressed ? 8 : (_isHovered ? 20 : 12),
                offset: Offset(0, _isPressed ? 2 : (_isHovered ? 8 : 4)),
                spreadRadius: _isHovered ? 2 : 0,
              ),
            ],
            border: Border.all(
              color: _isHovered
                  ? Colors.blue.withAlpha(77)
                  : Colors.grey.withAlpha(51),
              width: _isHovered ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              // Shimmer effect overlay
              if (_isHovered)
                AnimatedBuilder(
                  animation: _shimmerAnimation,
                  builder: (context, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withAlpha(77),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                            begin: Alignment(_shimmerAnimation.value, -1),
                            end: Alignment(_shimmerAnimation.value + 1, 1),
                          ),
                        ),
                      ),
                    );
                  },
                ),

              // Button content
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google Icon with scale animation
                    AnimatedScale(
                      scale: _isHovered ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.g_mobiledata, // Simple stylized 'G' icon
                        color: Colors.redAccent,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Text with color animation
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _isHovered
                            ? const Color(0xFF1976D2)
                            : Colors.grey[800],
                        letterSpacing: 0.5,
                      ),
                      child: const Text('Continue with Google'),
                    ),

                    // Arrow icon that appears on hover
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      width: _isHovered ? 24 : 0,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: _isHovered ? 1.0 : 0.0,
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 20,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
