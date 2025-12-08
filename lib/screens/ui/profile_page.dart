import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:exam_ready/screens/ui/submitted_papers.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _collegeController = TextEditingController();
  final _nameController = TextEditingController();
  final _branchController = TextEditingController();
  final _mobileController = TextEditingController();

  bool _isLoading = true;
  bool _isEditMode = false;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;
  String? _uid;
  Map<String, dynamic>? _userData;
  File? _newImageFile;
  String? _newPhotoUrl;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const Color primaryColor = Color(0xFF6366F1);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);

  String get cloudinaryCloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  String get cloudinaryUploadPreset =>
      dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUserProfile();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
        return;
      }

      _uid = user.uid;

      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .get();

      if (!docSnapshot.exists) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      _userData = docSnapshot.data();

      _collegeController.text = _userData?['college'] ?? '';
      _nameController.text = _userData?['name'] ?? '';
      _branchController.text = _userData?['branch'] ?? '';
      _mobileController.text = _userData?['mobile'] ?? '';

      setState(() {
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error loading profile', isError: true);
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      // Go back to root; AuthGate will show EntryScreen because user is now signed out
      Navigator.of(context).popUntil((route) => route.isFirst);

      _showSnackBar('Logged out successfully!');
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error logging out. Please try again.', isError: true);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _newImageFile = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error picking image', isError: true);
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Change Photo',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildImageOption(
                  Icons.photo_library_outlined,
                  'Choose from Gallery',
                  () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                _buildImageOption(
                  Icons.camera_alt_outlined,
                  'Take a Photo',
                  () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                if (_userData?['photoUrl'] != null &&
                    _userData!['photoUrl'].isNotEmpty)
                  _buildImageOption(
                    Icons.delete_outline_rounded,
                    'Remove Photo',
                    () {
                      Navigator.pop(context);
                      _confirmRemovePhoto();
                    },
                    isDestructive: true,
                  ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageOption(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive
                    ? errorColor.withOpacity(0.08)
                    : primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDestructive ? errorColor : primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDestructive ? errorColor : textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemovePhoto() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Remove Photo',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        content: Text(
          'Are you sure you want to remove your profile photo?',
          style: GoogleFonts.inter(fontSize: 14, color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _newPhotoUrl = '';
                _newImageFile = null;
              });
            },
            child: Text(
              'Remove',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _uploadToCloudinary(File imageFile) async {
    try {
      if (cloudinaryCloudName.isEmpty || cloudinaryUploadPreset.isEmpty) {
        throw Exception('Cloudinary credentials not configured in .env file');
      }

      setState(() {
        _isUploadingPhoto = true;
      });

      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = cloudinaryUploadPreset;
      request.fields['folder'] = 'user_profiles';

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseString);
        return jsonResponse['secure_url'] as String;
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Cloudinary upload error: $e');
      if (mounted) {
        _showSnackBar('Photo upload failed', isError: true);
      }
      return null;
    } finally {
      setState(() {
        _isUploadingPhoto = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      String? photoUrlToSave = _userData?['photoUrl'] ?? '';

      if (_newImageFile != null) {
        final uploadedUrl = await _uploadToCloudinary(_newImageFile!);
        if (uploadedUrl != null) {
          photoUrlToSave = uploadedUrl;
        } else {
          throw Exception('Failed to upload photo');
        }
      } else if (_newPhotoUrl != null) {
        photoUrlToSave = _newPhotoUrl!;
      }

      final updateData = {
        'college': _collegeController.text.trim(),
        'name': _nameController.text.trim(),
        'branch': _branchController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'photoUrl': photoUrlToSave,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_userData?['email'] != null) {
        updateData['email'] = _userData!['email'];
      }
      if (_userData?['createdAt'] != null) {
        updateData['createdAt'] = _userData!['createdAt'];
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .update(updateData);

      setState(() {
        _userData = {..._userData ?? {}, ...updateData};
        _isEditMode = false;
        _newImageFile = null;
        _newPhotoUrl = null;
      });

      if (mounted) {
        _showSnackBar('Profile updated successfully!');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error saving profile', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? errorColor : successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _toggleEditMode() {
    setState(() {
      if (_isEditMode) {
        _collegeController.text = _userData?['college'] ?? '';
        _nameController.text = _userData?['name'] ?? '';
        _branchController.text = _userData?['branch'] ?? '';
        _mobileController.text = _userData?['mobile'] ?? '';
        _newImageFile = null;
        _newPhotoUrl = null;
      }
      _isEditMode = !_isEditMode;
    });
  }

  Widget _buildProfilePhoto() {
    String? photoUrl = _userData?['photoUrl'];

    if (_newPhotoUrl == '') {
      photoUrl = null;
    }

    return GestureDetector(
      onTap: _isEditMode ? _showImageSourceDialog : null,
      child: Hero(
        tag: 'profile_photo',
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 64,
                backgroundColor: backgroundColor,
                backgroundImage: _newImageFile != null
                    ? FileImage(_newImageFile!)
                    : (photoUrl != null && photoUrl.isNotEmpty)
                    ? CachedNetworkImageProvider(photoUrl)
                    : null,
                child:
                    (_newImageFile == null &&
                        (photoUrl == null || photoUrl.isEmpty))
                    ? Icon(
                        Icons.person_outline_rounded,
                        size: 64,
                        color: textSecondary,
                      )
                    : null,
              ),
            ),
            if (_isUploadingPhoto)
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black54,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
            if (_isEditMode && !_isUploadingPhoto)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: textSecondary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value.isEmpty ? 'Not set' : value,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField(
    TextEditingController controller,
    String label,
    IconData icon,
    String? Function(String?)? validator, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            color: textSecondary,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: textSecondary, size: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: borderColor, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: borderColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: errorColor, width: 1),
          ),
          filled: true,
          fillColor: backgroundColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_off_outlined,
                size: 80,
                color: textSecondary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Profile Not Found',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: textPrimary,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please complete your profile to continue',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/onboarding'),
              icon: const Icon(Icons.edit_outlined, size: 20),
              label: Text(
                'Complete Profile',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: -0.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _collegeController.dispose();
    _nameController.dispose();
    _branchController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: primaryColor, strokeWidth: 3),
        ),
      );
    }

    if (_userData == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Text(
            'Profile',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          backgroundColor: cardColor,
          elevation: 0,
          centerTitle: true,
        ),
        body: _buildEmptyState(),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (!_isEditMode)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.edit_outlined, size: 22),
                onPressed: _toggleEditMode,
                color: primaryColor,
              ),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        _buildProfilePhoto(),
                        const SizedBox(height: 40),

                        Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: AnimatedCrossFade(
                              duration: const Duration(milliseconds: 300),
                              crossFadeState: _isEditMode
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              firstChild: Column(
                                children: [
                                  _buildInfoRow(
                                    'College',
                                    _userData?['college'] ?? '',
                                    Icons.school_outlined,
                                  ),
                                  Divider(color: borderColor, height: 32),
                                  _buildInfoRow(
                                    'Name',
                                    _userData?['name'] ?? '',
                                    Icons.person_outline_rounded,
                                  ),
                                  Divider(color: borderColor, height: 32),
                                  _buildInfoRow(
                                    'Branch',
                                    _userData?['branch'] ?? '',
                                    Icons.account_tree_outlined,
                                  ),
                                  Divider(color: borderColor, height: 32),
                                  _buildInfoRow(
                                    'Mobile',
                                    _userData?['mobile'] ?? '',
                                    Icons.phone_outlined,
                                  ),
                                  Divider(color: borderColor, height: 32),
                                  _buildInfoRow(
                                    'Email',
                                    _userData?['email'] ?? '',
                                    Icons.email_outlined,
                                  ),
                                ],
                              ),
                              secondChild: Column(
                                children: [
                                  _buildEditField(
                                    _collegeController,
                                    'College Name',
                                    Icons.school_outlined,
                                    (value) => value?.trim().isEmpty ?? true
                                        ? 'College name is required'
                                        : null,
                                  ),
                                  _buildEditField(
                                    _nameController,
                                    'Full Name',
                                    Icons.person_outline_rounded,
                                    (value) => value?.trim().isEmpty ?? true
                                        ? 'Name is required'
                                        : null,
                                  ),
                                  _buildEditField(
                                    _branchController,
                                    'Branch',
                                    Icons.account_tree_outlined,
                                    (value) => value?.trim().isEmpty ?? true
                                        ? 'Branch is required'
                                        : null,
                                  ),
                                  _buildEditField(
                                    _mobileController,
                                    'Mobile Number',
                                    Icons.phone_outlined,
                                    (value) {
                                      if (value?.trim().isEmpty ?? true) {
                                        return 'Mobile number is required';
                                      }
                                      final digitsOnly = value!.replaceAll(
                                        RegExp(r'\D'),
                                        '',
                                      );
                                      if (digitsOnly.length < 7 ||
                                          digitsOnly.length > 15) {
                                        return 'Mobile must be 7-15 digits';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.phone,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Show these only when NOT editing
                        if (!_isEditMode) ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MySubmittedPapersPage(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.description_outlined,
                                size: 20,
                              ),
                              label: Text(
                                'View My Submitted Papers',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _logout,
                              icon: const Icon(Icons.logout_rounded, size: 20),
                              label: Text(
                                'Logout',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  letterSpacing: -0.2,
                                  color: errorColor,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: const BorderSide(
                                  color: errorColor,
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],

                        // Show these only when editing
                        if (_isEditMode) ...[
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _isSaving ? null : _toggleEditMode,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    side: const BorderSide(
                                      color: borderColor,
                                      width: 1,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: textSecondary,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isSaving || _isUploadingPhoto
                                      ? null
                                      : _saveProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : Text(
                                          'Save Changes',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            letterSpacing: -0.2,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
