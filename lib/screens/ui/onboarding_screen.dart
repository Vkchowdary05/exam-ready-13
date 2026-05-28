// lib/screens/ui/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_ready/theme/app_theme.dart';
import 'package:exam_ready/utils/strings.dart';
import 'package:exam_ready/utils/constants.dart';
import 'package:exam_ready/data/dropdown_data.dart';

/// Three-slide onboarding → college/branch/semester picker.
///
/// Shown to new users who haven't completed their profile.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Profile form
  String? _selectedCollege;
  String? _selectedBranch;
  String? _selectedSemester;
  bool _isSaving = false;

  final _slides = const [
    _OnboardingSlide(
      icon: Icons.library_books_rounded,
      title: AppStrings.onboardingSlide1Title,
      subtitle: AppStrings.onboardingSlide1Subtitle,
      accentColor: AppTheme.lavender,
    ),
    _OnboardingSlide(
      icon: Icons.auto_graph_rounded,
      title: AppStrings.onboardingSlide2Title,
      subtitle: AppStrings.onboardingSlide2Subtitle,
      accentColor: AppTheme.teal,
    ),
    _OnboardingSlide(
      icon: Icons.groups_rounded,
      title: AppStrings.onboardingSlide3Title,
      subtitle: AppStrings.onboardingSlide3Subtitle,
      accentColor: AppTheme.amber,
    ),
  ];

  bool get _isLastSlide => _currentPage == _slides.length;
  bool get _isOnForm => _currentPage == _slides.length;
  int get _totalPages => _slides.length + 1; // slides + form

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToForm() {
    _pageController.animateToPage(
      _slides.length,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _saveProfile() async {
    if (_selectedCollege == null ||
        _selectedBranch == null ||
        _selectedSemester == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection(AppConstants.usersCollection)
            .doc(userId)
            .set({
          'college': _selectedCollege,
          'branch': _selectedBranch,
          'semester': _selectedSemester,
          'onboardingCompleted': true,
          'lastActive': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip button ──────────────────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _isOnForm
                    ? const SizedBox.shrink()
                    : TextButton(
                        onPressed: _skipToForm,
                        child: Text(
                          'Skip',
                          style: GoogleFonts.inter(
                            color: AppTheme.textOnDarkMuted,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
              ),
            ),

            // ── Page content ─────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  ..._slides.map((s) => _buildSlide(s)),
                  _buildProfileForm(),
                ],
              ),
            ),

            // ── Bottom nav ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_totalPages, (i) {
                      final isActive = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppTheme.lavender
                              : AppTheme.darkBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Next / Get Started button
                  if (!_isOnForm)
                    SizedBox(
                      width: double.infinity,
                      height: AppConstants.minButtonHeight,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.lavender,
                          foregroundColor: AppTheme.darkBg,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.buttonRadius,
                            ),
                          ),
                        ),
                        child: Text(
                          _currentPage == _slides.length - 1
                              ? 'Set Up Profile'
                              : 'Next',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Slide Builder ─────────────────────────────────────────────

  Widget _buildSlide(_OnboardingSlide slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: slide.accentColor.withAlpha(25),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: slide.accentColor.withAlpha(60),
                width: 1.5,
              ),
            ),
            child: Icon(
              slide.icon,
              size: 56,
              color: slide.accentColor,
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0.7, 0.7),
                end: const Offset(1.0, 1.0),
                duration: 500.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 400.ms),

          const SizedBox(height: 48),

          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppTheme.textOnDark,
              height: 1.3,
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: 16),

          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppTheme.textOnDarkMuted,
              height: 1.6,
            ),
          ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
        ],
      ),
    );
  }

  // ─── Profile Form ──────────────────────────────────────────────

  Widget _buildProfileForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          Text(
            'Set up your profile',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppTheme.textOnDark,
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 8),

          Text(
            'This helps us show you relevant papers and topics for your course.',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppTheme.textOnDarkMuted,
              height: 1.5,
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: 36),

          // College dropdown
          _buildDropdown(
            label: 'College',
            value: _selectedCollege,
            items: DropdownData.colleges,
            onChanged: (v) => setState(() => _selectedCollege = v),
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideX(
                begin: 0.1,
                end: 0,
                duration: 400.ms,
              ),

          const SizedBox(height: 20),

          // Branch dropdown
          _buildDropdown(
            label: 'Branch',
            value: _selectedBranch,
            items: DropdownData.branches,
            onChanged: (v) => setState(() => _selectedBranch = v),
          ).animate(delay: 400.ms).fadeIn(duration: 400.ms).slideX(
                begin: 0.1,
                end: 0,
                duration: 400.ms,
              ),

          const SizedBox(height: 20),

          // Semester dropdown
          _buildDropdown(
            label: 'Semester',
            value: _selectedSemester,
            items: DropdownData.semesters,
            onChanged: (v) => setState(() => _selectedSemester = v),
          ).animate(delay: 500.ms).fadeIn(duration: 400.ms).slideX(
                begin: 0.1,
                end: 0,
                duration: 400.ms,
              ),

          const SizedBox(height: 40),

          // Save button
          SizedBox(
            width: double.infinity,
            height: AppConstants.minButtonHeight,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lavender,
                foregroundColor: AppTheme.darkBg,
                disabledBackgroundColor: AppTheme.lavender.withAlpha(100),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.buttonRadius),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppTheme.darkBg,
                      ),
                    )
                  : Text(
                      AppStrings.getStarted,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ).animate(delay: 600.ms).fadeIn(duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textOnDarkMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: AppTheme.darkCard(),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppTheme.textOnDark,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            dropdownColor: AppTheme.darkSurface,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
              hintText: 'Select $label',
              hintStyle: GoogleFonts.inter(
                fontSize: 15,
                color: AppTheme.textOnDarkMuted,
              ),
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppTheme.lavender,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Slide Data ──────────────────────────────────────────────────

class _OnboardingSlide {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;

  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });
}
