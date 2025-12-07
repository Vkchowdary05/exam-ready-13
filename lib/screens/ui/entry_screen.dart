// lib/screens/entry_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:exam_ready/screens/auth/login_screen.dart';
import 'package:exam_ready/screens/auth/signup_screen.dart';
import 'package:exam_ready/theme/entry_theme.dart';
import 'package:exam_ready/widgets/stat_card.dart';
import "package:exam_ready/widgets/popular_card.dart";

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  final List<Map<String, dynamic>> stats = [
    {'icon': Icons.school_outlined, 'number': '250+', 'label': 'Colleges'},
    {'icon': Icons.people_outline, 'number': '50K+', 'label': 'Active Users'},
    {'icon': Icons.description_outlined, 'number': '10K+', 'label': 'Exam Papers'},
    {'icon': Icons.category_outlined, 'number': '85+', 'label': 'Departments'},
  ];

  final List<Map<String, dynamic>> popularColleges = [
    {
      'name': 'IIT Hyderabad',
      'description': 'Premier Engineering Institute',
      'icon': Icons.account_balance_outlined,
      'color': const Color(0xFF5A67D8),
    },
    {
      'name': 'JNTU',
      'description': 'Jawaharlal Nehru Technological University',
      'icon': Icons.account_balance_outlined,
      'color': const Color(0xFF7C3AED),
    },
    {
      'name': 'CBIT',
      'description': 'Chaitanya Bharathi Institute of Technology',
      'icon': Icons.account_balance_outlined,
      'color': const Color(0xFF4299E1),
    },
    {
      'name': 'VNR VJIET',
      'description': 'Vallurupalli Nageswara Rao Vignana Jyothi',
      'icon': Icons.account_balance_outlined,
      'color': const Color(0xFF667EEA),
    },
    {
      'name': 'MGIT',
      'description': 'Mahatma Gandhi Institute of Technology',
      'icon': Icons.account_balance_outlined,
      'color': const Color(0xFF6366F1),
    },
  ];

  final List<Map<String, dynamic>> popularDepartments = [
    {
      'name': 'Computer Science',
      'description': 'CSE & IT Programs',
      'icon': Icons.computer_outlined,
      'color': const Color(0xFF5A67D8),
    },
    {
      'name': 'Electronics',
      'description': 'ECE & EEE Programs',
      'icon': Icons.memory_outlined,
      'color': const Color(0xFF7C3AED),
    },
    {
      'name': 'Mechanical',
      'description': 'Mechanical Engineering',
      'icon': Icons.settings_outlined,
      'color': const Color(0xFF4299E1),
    },
    {
      'name': 'Civil Engineering',
      'description': 'Construction & Infrastructure',
      'icon': Icons.domain_outlined,
      'color': const Color(0xFF667EEA),
    },
    {
      'name': 'AI & Data Science',
      'description': 'Artificial Intelligence & ML',
      'icon': Icons.psychology_outlined,
      'color': const Color(0xFF6366F1),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildAuthButtons(),
                const SizedBox(height: 32),
                _buildSectionTitle('Platform Overview'),
                const SizedBox(height: 16),
                _buildStatsSection(),
                const SizedBox(height: 32),
                _buildPopularSection(
                  'Popular Colleges',
                  popularColleges,
                ),
                const SizedBox(height: 32),
                _buildPopularSection(
                  'Popular Departments',
                  popularDepartments,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.school_outlined,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exam Ready',
                  style: AppTheme.headingStyle.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your Ultimate Exam Companion',
                  style: AppTheme.subheadingStyle.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: -0.2, end: 0, duration: 500.ms, curve: Curves.easeOut);
  }

  Widget _buildAuthButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildLoginButton(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSignUpButton(),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 150.ms)
        .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 150.ms);
  }

  Widget _buildLoginButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentColor.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.login_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Login',
                  style: AppTheme.buttonTextStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SignupScreen()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.borderColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_add_outlined,
                color: AppTheme.textPrimary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Sign Up',
                style: AppTheme.buttonTextStyle.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.headingStyle.copyWith(fontSize: 20),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideX(begin: -0.1, end: 0, duration: 400.ms);
  }

  Widget _buildStatsSection() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        return StatCard(
          icon: stats[index]['icon'],
          number: stats[index]['number'],
          label: stats[index]['label'],
          index: index,
        );
      },
    );
  }

  Widget _buildPopularSection(String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.headingStyle.copyWith(fontSize: 20),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideX(begin: -0.1, end: 0, duration: 400.ms),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return PopularCard(
              name: items[index]['name'],
              description: items[index]['description'],
              icon: items[index]['icon'],
              color: items[index]['color'],
              index: index,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening ${items[index]['name']}...'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}