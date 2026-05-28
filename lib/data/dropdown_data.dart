// lib/data/dropdown_data.dart
//
// Static dropdown data for onboarding and submission forms.
// Curated for Indian B.Tech students.

class DropdownData {
  DropdownData._();

  // ═══════════════════════════════════════════════════════════════
  // COLLEGES (Top engineering colleges / universities in India)
  // ═══════════════════════════════════════════════════════════════
  static const List<String> colleges = [
    'Amrita Vishwa Vidyapeetham',
    'Anna University',
    'BIT Mesra',
    'BITS Pilani',
    'Chandigarh University',
    'Christ University',
    'DTU (Delhi Technological University)',
    'GITAM University',
    'IIT Bombay',
    'IIT Delhi',
    'IIT Kanpur',
    'IIT Kharagpur',
    'IIT Madras',
    'IIT Roorkee',
    'IIIT Hyderabad',
    'JNTU Hyderabad',
    'Jadavpur University',
    'LPU (Lovely Professional University)',
    'MIT Manipal',
    'NIT Trichy',
    'NIT Warangal',
    'NIT Surathkal',
    'NIT Calicut',
    'NIT Rourkela',
    'Osmania University',
    'PES University',
    'Pune University (SPPU)',
    'RV College of Engineering',
    'SRM University',
    'VIT Vellore',
    'VIT AP',
    'Vignan University',
    'VJIT Hyderabad',
    'Other',
  ];

  // ═══════════════════════════════════════════════════════════════
  // BRANCHES
  // ═══════════════════════════════════════════════════════════════
  static const List<String> branches = [
    'Computer Science (CSE)',
    'Information Technology (IT)',
    'Electronics & Communication (ECE)',
    'Electrical & Electronics (EEE)',
    'Mechanical Engineering',
    'Civil Engineering',
    'Chemical Engineering',
    'Biotechnology',
    'Data Science',
    'Artificial Intelligence & ML',
    'Cyber Security',
    'Aerospace Engineering',
    'Automobile Engineering',
    'Robotics',
    'Other',
  ];

  // ═══════════════════════════════════════════════════════════════
  // SEMESTERS
  // ═══════════════════════════════════════════════════════════════
  static const List<String> semesters = [
    '1st Semester',
    '2nd Semester',
    '3rd Semester',
    '4th Semester',
    '5th Semester',
    '6th Semester',
    '7th Semester',
    '8th Semester',
  ];

  // ═══════════════════════════════════════════════════════════════
  // EXAM TYPES
  // ═══════════════════════════════════════════════════════════════
  static const List<String> examTypes = [
    'Mid 1',
    'Mid 2',
    'Semester End (SEE)',
    'Supplementary',
    'Quiz',
    'Assignment',
    'Internal Assessment',
    'Other',
  ];

  // ═══════════════════════════════════════════════════════════════
  // COMPATIBILITY MAPS (For older UI screens)
  // ═══════════════════════════════════════════════════════════════
  static Map<String, List<String>> get collegeData {
    return {
      for (var college in colleges) college: branches,
    };
  }

  static Map<String, Map<String, List<String>>> get subjectData {
    final defaultSubjects = [
      'Mathematics',
      'Physics',
      'Chemistry',
      'Data Structures',
      'Algorithms',
      'Operating Systems',
      'Database Management Systems',
      'Computer Networks',
      'Software Engineering',
      'Machine Learning',
    ];

    return {
      for (var branch in branches)
        branch: {
          for (var sem in semesters) sem: defaultSubjects,
        }
    };
  }
}
