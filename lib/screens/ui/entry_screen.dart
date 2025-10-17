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
    {'icon': Icons.school, 'number': '250+', 'label': 'Colleges'},
    {'icon': Icons.people, 'number': '50K+', 'label': 'Active Users'},
    {'icon': Icons.description, 'number': '10K+', 'label': 'Exam Papers'},
    {'icon': Icons.category, 'number': '85+', 'label': 'Departments'},
  ];

  final List<Map<String, dynamic>> popularColleges = [
    {
      'name': 'IIT Hyderabad',
      'description': 'Premier Engineering Institute',
      'icon': Icons.account_balance,
      'color': const Color(0xFF6366F1),
    },
    {
      'name': 'JNTU',
      'description': 'Jawaharlal Nehru Technological University',
      'icon': Icons.account_balance,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'name': 'CBIT',
      'description': 'Chaitanya Bharathi Institute of Technology',
      'icon': Icons.account_balance,
      'color': const Color(0xFF06B6D4),
    },
    {
      'name': 'VNR VJIET',
      'description': 'Vallurupalli Nageswara Rao Vignana Jyothi',
      'icon': Icons.account_balance,
      'color': const Color(0xFFEC4899),
    },
    {
      'name': 'MGIT',
      'description': 'Mahatma Gandhi Institute of Technology',
      'icon': Icons.account_balance,
      'color': const Color(0xFF3B82F6),
    },
  ];

  final List<Map<String, dynamic>> popularDepartments = [
    {
      'name': 'Computer Science',
      'description': 'CSE & IT Programs',
      'icon': Icons.computer,
      'color': const Color(0xFF6366F1),
    },
    {
      'name': 'Electronics',
      'description': 'ECE & EEE Programs',
      'icon': Icons.memory,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'name': 'Mechanical',
      'description': 'Mechanical Engineering',
      'icon': Icons.settings,
      'color': const Color(0xFF06B6D4),
    },
    {
      'name': 'Civil Engineering',
      'description': 'Construction & Infrastructure',
      'icon': Icons.domain,
      'color': const Color(0xFFEC4899),
    },
    {
      'name': 'AI & Data Science',
      'description': 'Artificial Intelligence & ML',
      'icon': Icons.psychology,
      'color': const Color(0xFF3B82F6),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.backgroundColor,
              const Color(0xFF1A1A2E),
              AppTheme.backgroundColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildAuthButtons(),
                  const SizedBox(height: 30),
                  _buildStatsSection(),
                  const SizedBox(height: 40),
                  _buildPopularSection(
                    'Popular Colleges',
                    popularColleges,
                  ),
                  const SizedBox(height: 30),
                  _buildPopularSection(
                    'Popular Departments',
                    popularDepartments,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withAlpha(77),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.school,
              size: 32,
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
                  style: AppTheme.headingStyle.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your Ultimate Exam Companion',
                  style: AppTheme.subheadingStyle.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOut);
  }

  Widget _buildAuthButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildLoginButton(),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSignUpButton(),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 200.ms)
        .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 200.ms);
  }

  Widget _buildLoginButton() {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withAlpha(102),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.login,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Login',
              style: AppTheme.cardTitleStyle.copyWith(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SignupScreen()));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF06B6D4).withAlpha(102),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_add,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Sign Up',
              style: AppTheme.cardTitleStyle.copyWith(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
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
          style: AppTheme.headingStyle.copyWith(fontSize: 24),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .slideX(begin: -0.2, end: 0, duration: 600.ms),
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
                    backgroundColor: items[index]['color'],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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