// dropdown.dart

// ══════════════════════════════════════════════
// DROPDOWN DATA CONSTANTS
// ══════════════════════════════════════════════

final Map<String, List<String>> collegeData = {
  'IIT Hyderabad': ['CSE', 'ECE', 'EEE', 'Mechanical', 'Civil', 'Chemical', 'AI & ML', 'Data Science', 'Biotechnology'],
  'NIT Warangal': ['CSE', 'ECE', 'EEE', 'Mechanical', 'Civil', 'Chemical', 'Metallurgical', 'Mining', 'Biotechnology'],
  'IIIT Hyderabad': ['CSE', 'ECE', 'CSD', 'ECD'],
  'Chaitanya Bharathi Institute of Technology': ['CSE', 'IT', 'ECE', 'EEE', 'Mechanical', 'Civil', 'AI & ML', 'Data Science', 'Cyber Security'],
  'Gokaraju Rangaraju Institute of Engineering and Technology': ['CSE', 'IT', 'ECE', 'EEE', 'Mechanical', 'Civil', 'AI & ML', 'IoT', 'Cyber Security'],
  'Vasavi College of Engineering': ['CSE', 'IT', 'ECE', 'EEE', 'Mechanical', 'Civil'],
  'CVR College of Engineering': ['CSE', 'IT', 'ECE', 'EEE', 'Mechanical', 'Civil', 'AI & ML'],
  'Mahatma Gandhi Institute of Technology': ['CSE', 'IT', 'ECE', 'EEE', 'Mechanical', 'Civil'],
  'Vidya Jyothi Institute of Technology': ['CSE', 'IT', 'ECE', 'EEE', 'Mechanical', 'Civil', 'AI & ML'],
  'CMR College of Engineering & Technology': ['CSE', 'IT', 'ECE', 'EEE', 'Mechanical', 'Civil'],
  'Sreenidhi Institute of Science and Technology': ['CSE', 'IT', 'ECE', 'EEE', 'Mechanical', 'Civil', 'AI & ML', 'Data Science'],
  'BV Raju Institute of Technology': ['CSE', 'IT', 'ECE', 'EEE', 'Mechanical', 'Civil'],
  'MLR Institute of Technology': ['CSE', 'IT', 'ECE', 'EEE', 'Mechanical', 'Civil'],
  'Kakatiya Institute of Technology & Science Warangal': ['CSE', 'IT', 'ECE', 'EEE', 'Mechanical', 'Civil'],
  'MVSR Engineering College': ['CSE', 'IT', 'ECE', 'EEE', 'Mechanical', 'Civil'],
  'JNTU Hyderabad College of Engineering': ['CSE', 'IT', 'ECE', 'EEE', 'Mechanical', 'Civil', 'Chemical', 'Metallurgical', 'Mining'],
  'OU College of Engineering': ['CSE', 'IT', 'ECE', 'EEE', 'Mechanical', 'Civil', 'Chemical', 'Instrumentation'],
  'Malla Reddy Engineering College': ['CSE', 'IT', 'ECE', 'EEE', 'Mechanical', 'Civil'],
  'JB Institute of Engineering and Technology': ['CSE', 'IT', 'ECE', 'EEE', 'Mechanical', 'Civil'],
  'Sphoorthy Engineering College': ['CSE', 'IT', 'ECE', 'EEE', 'Mechanical', 'Civil'],
  'Vignana Bharathi Institute of Technology': ['CSE', 'IT', 'ECE', 'EEE', 'Mechanical', 'Civil'],
  'Aurora\'s Engineering College': ['CSE', 'IT', 'ECE', 'EEE', 'Mechanical', 'Civil'],
  'Keshav Memorial Institute of Technology': ['CSE', 'IT', 'ECE', 'EEE', 'Mechanical', 'Civil'],
  'G Narayanamma Institute of Technology and Science': ['CSE', 'IT', 'ECE', 'EEE', 'Civil'],
  'St. Peter\'s Engineering College': ['CSE', 'IT', 'ECE', 'EEE', 'Mechanical', 'Civil'],
  'Methodist College of Engineering and Technology': ['CSE', 'IT', 'ECE', 'EEE', 'Mechanical', 'Civil'],
  'Sree Rama Institute of Technology and Science': ['CSE', 'IT', 'ECE', 'EEE', 'Mechanical'],
  'St. Martin\'s Engineering College': ['CSE', 'IT', 'ECE', 'EEE', 'Mechanical', 'Civil'],
  'Sreyas Institute of Engineering and Technology': ['CSE', 'IT', 'ECE', 'EEE', 'Mechanical', 'Civil'],
  'Lords Institute of Engineering and Technology': ['CSE', 'IT', 'ECE', 'EEE', 'Mechanical', 'Civil'],
};

final Map<String, Map<String, List<String>>> subjectData = {
  'CSE': {
    'Sem 1': ['Engineering Mathematics-I', 'Engineering Physics', 'Engineering Chemistry', 'Problem Solving and Programming', 'Engineering Drawing', 'English'],
    'Sem 2': ['Engineering Mathematics-II', 'Data Structures', 'Digital Logic Design', 'Object Oriented Programming', 'Environmental Science', 'Professional Communication'],
    'Sem 3': ['Engineering Mathematics-III', 'Computer Organization', 'Database Management Systems', 'Operating Systems', 'Discrete Mathematics', 'Java Programming'],
    'Sem 4': ['Engineering Mathematics-IV', 'Computer Networks', 'Design and Analysis of Algorithms', 'Software Engineering', 'Web Technologies', 'Theory of Computation'],
    'Sem 5': ['Compiler Design', 'Machine Learning', 'Computer Graphics', 'Information Security', 'Elective-I', 'Open Elective-I'],
    'Sem 6': ['Artificial Intelligence', 'Cloud Computing', 'Mobile Application Development', 'Big Data Analytics', 'Elective-II', 'Open Elective-II'],
    'Sem 7': ['Internet of Things', 'Blockchain Technology', 'Cryptography', 'Elective-III', 'Elective-IV', 'Project Phase-I'],
    'Sem 8': ['Deep Learning', 'Natural Language Processing', 'Elective-V', 'Elective-VI', 'Project Phase-II'],
  },
  'ECE': {
    'Sem 1': ['Engineering Mathematics-I', 'Engineering Physics', 'Engineering Chemistry', 'Basic Electrical Engineering', 'Engineering Drawing', 'English'],
    'Sem 2': ['Engineering Mathematics-II', 'Network Analysis', 'Electronic Devices and Circuits', 'Signals and Systems', 'Environmental Science', 'Professional Communication'],
    'Sem 3': ['Engineering Mathematics-III', 'Analog Electronics', 'Digital Electronics', 'Electromagnetic Fields', 'Electrical Machines', 'Circuit Theory'],
    'Sem 4': ['Engineering Mathematics-IV', 'Microprocessors and Microcontrollers', 'Communication Systems', 'Control Systems', 'Linear IC Applications', 'Probability and Random Processes'],
    'Sem 5': ['Digital Signal Processing', 'Antennas and Wave Propagation', 'VLSI Design', 'Embedded Systems', 'Elective-I', 'Open Elective-I'],
    'Sem 6': ['Digital Communication', 'Microwave Engineering', 'Optical Communication', 'Computer Networks', 'Elective-II', 'Open Elective-II'],
    'Sem 7': ['Wireless Communication', 'Satellite Communication', 'Image Processing', 'Elective-III', 'Elective-IV', 'Project Phase-I'],
    'Sem 8': ['IoT Systems', '5G Networks', 'Elective-V', 'Elective-VI', 'Project Phase-II'],
  },
  'IT': {
    'Sem 1': ['Engineering Mathematics-I', 'Engineering Physics', 'Engineering Chemistry', 'Problem Solving and Programming', 'Engineering Drawing', 'English'],
    'Sem 2': ['Engineering Mathematics-II', 'Data Structures', 'Digital Logic Design', 'Object Oriented Programming', 'Environmental Science', 'Professional Communication'],
    'Sem 3': ['Engineering Mathematics-III', 'Computer Organization', 'Database Management Systems', 'Operating Systems', 'Discrete Mathematics', 'Web Technologies'],
    'Sem 4': ['Engineering Mathematics-IV', 'Computer Networks', 'Design and Analysis of Algorithms', 'Software Engineering', 'Advanced Web Technologies', 'Theory of Computation'],
    'Sem 5': ['Information Security', 'Machine Learning', 'Mobile Computing', 'Software Testing', 'Elective-I', 'Open Elective-I'],
    'Sem 6': ['Artificial Intelligence', 'Cloud Computing', 'Mobile Application Development', 'Data Warehousing and Mining', 'Elective-II', 'Open Elective-II'],
    'Sem 7': ['Internet of Things', 'DevOps', 'Network Security', 'Elective-III', 'Elective-IV', 'Project Phase-I'],
    'Sem 8': ['Ethical Hacking', 'Full Stack Development', 'Elective-V', 'Elective-VI', 'Project Phase-II'],
  },
  'AI & ML': {
    'Sem 1': ['Engineering Mathematics-I', 'Engineering Physics', 'Engineering Chemistry', 'Problem Solving and Programming', 'Engineering Drawing', 'English'],
    'Sem 2': ['Engineering Mathematics-II', 'Data Structures', 'Digital Logic Design', 'Python Programming', 'Environmental Science', 'Professional Communication'],
    'Sem 3': ['Engineering Mathematics-III', 'Linear Algebra', 'Database Management Systems', 'Operating Systems', 'Probability and Statistics', 'Java Programming'],
    'Sem 4': ['Multivariate Calculus', 'Computer Networks', 'Design and Analysis of Algorithms', 'Software Engineering', 'Discrete Mathematics', 'R Programming'],
    'Sem 5': ['Machine Learning', 'Deep Learning', 'Computer Vision', 'Natural Language Processing', 'Elective-I', 'Open Elective-I'],
    'Sem 6': ['Artificial Intelligence', 'Reinforcement Learning', 'Big Data Analytics', 'Neural Networks', 'Elective-II', 'Open Elective-II'],
    'Sem 7': ['Generative AI', 'MLOps', 'Time Series Analysis', 'Elective-III', 'Elective-IV', 'Project Phase-I'],
    'Sem 8': ['Advanced Deep Learning', 'AI Ethics', 'Elective-V', 'Elective-VI', 'Project Phase-II'],
  },
  'Data Science': {
    'Sem 1': ['Engineering Mathematics-I', 'Engineering Physics', 'Engineering Chemistry', 'Problem Solving and Programming', 'Engineering Drawing', 'English'],
    'Sem 2': ['Engineering Mathematics-II', 'Data Structures', 'Digital Logic Design', 'Python Programming', 'Environmental Science', 'Professional Communication'],
    'Sem 3': ['Engineering Mathematics-III', 'Statistics for Data Science', 'Database Management Systems', 'Operating Systems', 'Probability Theory', 'R Programming'],
    'Sem 4': ['Linear Algebra', 'Computer Networks', 'Design and Analysis of Algorithms', 'Data Visualization', 'Business Analytics', 'SQL and NoSQL'],
    'Sem 5': ['Machine Learning', 'Data Mining', 'Big Data Technologies', 'Text Analytics', 'Elective-I', 'Open Elective-I'],
    'Sem 6': ['Deep Learning', 'Time Series Forecasting', 'Cloud Computing for Data Science', 'Data Engineering', 'Elective-II', 'Open Elective-II'],
    'Sem 7': ['Advanced Analytics', 'Recommender Systems', 'Data Ethics and Privacy', 'Elective-III', 'Elective-IV', 'Project Phase-I'],
    'Sem 8': ['Causal Inference', 'AutoML', 'Elective-V', 'Elective-VI', 'Project Phase-II'],
  },
  'EEE': {
    'Sem 1': ['Engineering Mathematics-I', 'Engineering Physics', 'Engineering Chemistry', 'Basic Electrical Engineering', 'Engineering Drawing', 'English'],
    'Sem 2': ['Engineering Mathematics-II', 'Network Analysis', 'Electronic Devices', 'Electrical Machines-I', 'Environmental Science', 'Professional Communication'],
    'Sem 3': ['Engineering Mathematics-III', 'Electrical Measurements', 'Electrical Machines-II', 'Electromagnetic Fields', 'Analog Electronics', 'Control Systems'],
    'Sem 4': ['Engineering Mathematics-IV', 'Power Systems-I', 'Power Electronics', 'Microprocessors', 'Digital Electronics', 'Signals and Systems'],
    'Sem 5': ['Power Systems-II', 'Electric Drives', 'Switchgear and Protection', 'Utilization of Electrical Energy', 'Elective-I', 'Open Elective-I'],
    'Sem 6': ['High Voltage Engineering', 'Control System Design', 'Power System Operation', 'Renewable Energy Sources', 'Elective-II', 'Open Elective-II'],
    'Sem 7': ['Power System Reliability', 'Smart Grid Technology', 'HVDC Transmission', 'Elective-III', 'Elective-IV', 'Project Phase-I'],
    'Sem 8': ['Electric Vehicles', 'Energy Management', 'Elective-V', 'Elective-VI', 'Project Phase-II'],
  },
  'Mechanical': {
    'Sem 1': ['Engineering Mathematics-I', 'Engineering Physics', 'Engineering Chemistry', 'Engineering Mechanics', 'Engineering Drawing', 'English'],
    'Sem 2': ['Engineering Mathematics-II', 'Strength of Materials', 'Thermodynamics', 'Manufacturing Technology', 'Environmental Science', 'Professional Communication'],
    'Sem 3': ['Engineering Mathematics-III', 'Fluid Mechanics', 'Kinematics of Machinery', 'Material Science', 'Thermal Engineering-I', 'Engineering Graphics'],
    'Sem 4': ['Engineering Mathematics-IV', 'Dynamics of Machinery', 'Heat Transfer', 'Thermal Engineering-II', 'Machine Design-I', 'Metrology'],
    'Sem 5': ['Design of Machine Elements', 'Finite Element Methods', 'Mechatronics', 'Operations Research', 'Elective-I', 'Open Elective-I'],
    'Sem 6': ['CAD/CAM', 'Refrigeration and Air Conditioning', 'IC Engines', 'Industrial Engineering', 'Elective-II', 'Open Elective-II'],
    'Sem 7': ['Robotics', 'Automobile Engineering', 'Power Plant Engineering', 'Elective-III', 'Elective-IV', 'Project Phase-I'],
    'Sem 8': ['Renewable Energy Systems', 'Advanced Manufacturing', 'Elective-V', 'Elective-VI', 'Project Phase-II'],
  },
  'Civil': {
    'Sem 1': ['Engineering Mathematics-I', 'Engineering Physics', 'Engineering Chemistry', 'Engineering Mechanics', 'Engineering Drawing', 'English'],
    'Sem 2': ['Engineering Mathematics-II', 'Surveying', 'Building Materials', 'Strength of Materials', 'Environmental Science', 'Professional Communication'],
    'Sem 3': ['Engineering Mathematics-III', 'Structural Analysis-I', 'Fluid Mechanics', 'Geotechnical Engineering-I', 'Concrete Technology', 'Highway Engineering'],
    'Sem 4': ['Engineering Mathematics-IV', 'Structural Analysis-II', 'Geotechnical Engineering-II', 'Hydraulics', 'Design of Steel Structures', 'Transportation Engineering'],
    'Sem 5': ['Design of RC Structures', 'Environmental Engineering-I', 'Irrigation Engineering', 'Estimation and Costing', 'Elective-I', 'Open Elective-I'],
    'Sem 6': ['Advanced Structural Design', 'Environmental Engineering-II', 'Foundation Engineering', 'Water Resources Engineering', 'Elective-II', 'Open Elective-II'],
    'Sem 7': ['Construction Management', 'Earthquake Engineering', 'Remote Sensing and GIS', 'Elective-III', 'Elective-IV', 'Project Phase-I'],
    'Sem 8': ['Smart Cities', 'Sustainable Construction', 'Elective-V', 'Elective-VI', 'Project Phase-II'],
  },
};

final List<String> semesters = [
  'Sem 1', 'Sem 2', 'Sem 3', 'Sem 4',
  'Sem 5', 'Sem 6', 'Sem 7', 'Sem 8'
];

final List<String> examTypes = ['Mid-1', 'Mid-2', 'Sem'];
