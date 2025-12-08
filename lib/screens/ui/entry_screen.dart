// lib/screens/entry_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:exam_ready/screens/auth/login_screen.dart';
import 'package:exam_ready/screens/auth/signup_screen.dart';
import 'package:exam_ready/theme/app_theme.dart';
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isMobile = screenWidth < 600;
            final isTablet = screenWidth >= 600 && screenWidth < 1024;
            final isDesktop = screenWidth >= 1024;

            final horizontalPadding = isMobile ? 24.0 : (isTablet ? 40.0 : 0.0);
            final maxWidth = isDesktop ? 1200.0 : double.infinity;

            return Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 60.0 : horizontalPadding,
                      vertical: isMobile ? 20 : (isTablet ? 32 : 40),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(isMobile, isTablet, isDesktop),
                        SizedBox(height: isMobile ? 32 : (isTablet ? 40 : 48)),
                        _buildAuthButtons(isMobile, isTablet, isDesktop),
                        SizedBox(height: isMobile ? 48 : (isTablet ? 56 : 64)),
                        _buildSectionTitle('Platform Overview', isMobile, isTablet),
                        SizedBox(height: isMobile ? 20 : (isTablet ? 24 : 28)),
                        _buildStatsSection(isMobile, isTablet, isDesktop),
                        SizedBox(height: isMobile ? 48 : (isTablet ? 56 : 64)),
                        _buildPopularSection(
                          'Popular Colleges',
                          popularColleges,
                          isMobile,
                          isTablet,
                          isDesktop,
                        ),
                        SizedBox(height: isMobile ? 48 : (isTablet ? 56 : 64)),
                        _buildPopularSection(
                          'Popular Departments',
                          popularDepartments,
                          isMobile,
                          isTablet,
                          isDesktop,
                        ),
                        SizedBox(height: isMobile ? 32 : (isTablet ? 40 : 48)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile, bool isTablet, bool isDesktop) {
    final fontSize = isMobile ? 26.0 : (isTablet ? 30.0 : 34.0);
    final subtitleSize = isMobile ? 14.0 : (isTablet ? 15.0 : 16.0);
    final iconSize = isMobile ? 32.0 : (isTablet ? 36.0 : 40.0);
    final padding = isMobile ? 28.0 : (isTablet ? 32.0 : 36.0);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(20, 255, 101, 132),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color.fromARGB(10, 255, 101, 132),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 14.0 : (isTablet ? 16.0 : 18.0)),
            decoration: BoxDecoration(
              color: Color.fromARGB(51, 255, 255, 255),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Color.fromARGB(25, 255, 255, 255),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.school_outlined,
              size: iconSize,
              color: Colors.white,
            ),
          ),
          SizedBox(width: isMobile ? 20 : (isTablet ? 24 : 28)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exam Ready',
                  style: AppTheme.headingStyle.copyWith(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.7,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your Ultimate Exam Companion',
                  style: AppTheme.subheadingStyle.copyWith(
                    color: Color.fromARGB(235, 255, 255, 255),
                    fontSize: subtitleSize,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
        .slideY(begin: -0.15, end: 0, duration: 600.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildAuthButtons(bool isMobile, bool isTablet, bool isDesktop) {
    if (isDesktop) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Row(
            children: [
              Expanded(
                child: _buildLoginButton(isMobile, isTablet, isDesktop),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildSignUpButton(isMobile, isTablet, isDesktop),
              ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 600.ms, delay: 200.ms, curve: Curves.easeOut)
          .slideY(begin: 0.1, end: 0, duration: 600.ms, delay: 200.ms, curve: Curves.easeOutCubic);
    }

    return Row(
      children: [
        Expanded(
          child: _buildLoginButton(isMobile, isTablet, isDesktop),
        ),
        SizedBox(width: isMobile ? 16 : 20),
        Expanded(
          child: _buildSignUpButton(isMobile, isTablet, isDesktop),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 200.ms, curve: Curves.easeOut)
        .slideY(begin: 0.1, end: 0, duration: 600.ms, delay: 200.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildLoginButton(bool isMobile, bool isTablet, bool isDesktop) {
    final verticalPadding = isMobile ? 18.0 : (isTablet ? 20.0 : 22.0);
    final fontSize = isMobile ? 16.0 : (isTablet ? 17.0 : 18.0);
    final iconSize = isMobile ? 20.0 : (isTablet ? 22.0 : 24.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(31, 255, 101, 132),
                blurRadius: 16,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: verticalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.login_rounded,
                  color: Colors.white,
                  size: iconSize,
                ),
                const SizedBox(width: 10),
                Text(
                  'Login',
                  style: AppTheme.buttonTextStyle.copyWith(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpButton(bool isMobile, bool isTablet, bool isDesktop) {
    final verticalPadding = isMobile ? 18.0 : (isTablet ? 20.0 : 22.0);
    final fontSize = isMobile ? 16.0 : (isTablet ? 17.0 : 18.0);
    final iconSize = isMobile ? 20.0 : (isTablet ? 22.0 : 24.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SignupScreen()),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Color.fromARGB(153, 230, 233, 242),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(8, 0, 0, 0),
                blurRadius: 12,
                offset: const Offset(0, 3),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_add_outlined,
                color: AppTheme.textPrimary,
                size: iconSize,
              ),
              const SizedBox(width: 10),
              Text(
                'Sign Up',
                style: AppTheme.buttonTextStyle.copyWith(
                  color: AppTheme.textPrimary,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isMobile, bool isTablet) {
    final fontSize = isMobile ? 22.0 : (isTablet ? 24.0 : 26.0);

    return Text(
      title,
      style: AppTheme.headingStyle.copyWith(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, curve: Curves.easeOut)
        .slideX(begin: -0.08, end: 0, duration: 500.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildStatsSection(bool isMobile, bool isTablet, bool isDesktop) {
    final crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 4);
    final crossAxisSpacing = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);
    final mainAxisSpacing = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);
    final childAspectRatio = isMobile ? 1.45 : (isTablet ? 1.4 : 1.35);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
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

  Widget _buildPopularSection(
    String title,
    List<Map<String, dynamic>> items,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    final fontSize = isMobile ? 22.0 : (isTablet ? 24.0 : 26.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.headingStyle.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms, curve: Curves.easeOut)
            .slideX(begin: -0.08, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
        SizedBox(height: isMobile ? 20 : (isTablet ? 24 : 28)),
        isDesktop
            ? _buildPopularGrid(items, isTablet, isDesktop)
            : _buildPopularList(items, isMobile, isTablet),
      ],
    );
  }

  Widget _buildPopularList(List<Map<String, dynamic>> items, bool isMobile, bool isTablet) {
    return ListView.builder(
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
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
                duration: const Duration(milliseconds: 2000),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPopularGrid(List<Map<String, dynamic>> items, bool isTablet, bool isDesktop) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 2.8,
      ),
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
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
                duration: const Duration(milliseconds: 2000),
              ),
            );
          },
        );
      },
    );
  }
}