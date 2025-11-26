import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';

// Get Cloudinary credentials from .env file
// Make sure your .env contains:
// CLOUDINARY_CLOUD_NAME=your_cloud_name
// CLOUDINARY_UPLOAD_PRESET=your_upload_preset

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  // Controllers
  final _formKey = GlobalKey<FormState>();
  final _collegeController = TextEditingController();
  final _nameController = TextEditingController();
  final _branchController = TextEditingController();
  final _mobileController = TextEditingController();

  // State variables
  bool _isLoading = true;
  bool _isEditMode = false;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;
  String? _uid;
  Map<String, dynamic>? _userData;
  File? _newImageFile;
  String? _newPhotoUrl;
  
  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Cloudinary credentials from .env
  String get cloudinaryCloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  String get cloudinaryUploadPreset => dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

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
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
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
      
      // Populate controllers
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
        setState(() {
          _isLoading = false;
        });
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            if (_userData?['photoUrl'] != null && _userData!['photoUrl'].isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmRemovePhoto();
                },
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
        title: const Text('Remove Photo'),
        content: const Text('Are you sure you want to remove your profile photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _newPhotoUrl = '';
                _newImageFile = null;
              });
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
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

      // For production: Request signature from your backend
      // POST to your-backend.com/api/cloudinary/signature
      // Include timestamp and any other params you want to sign
      // Backend responds with: { signature, timestamp, api_key }
      // Then include these in the multipart request below along with the file
      
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = cloudinaryUploadPreset;
      request.fields['folder'] = 'user_profiles'; // Optional: organize uploads
      
      // For signed uploads (production), add:
      // request.fields['timestamp'] = timestamp;
      // request.fields['signature'] = signature;
      // request.fields['api_key'] = apiKey;
      
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Photo upload failed: $e')),
        );
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

      // Upload new photo if selected
      if (_newImageFile != null) {
        final uploadedUrl = await _uploadToCloudinary(_newImageFile!);
        if (uploadedUrl != null) {
          photoUrlToSave = uploadedUrl;
        } else {
          throw Exception('Failed to upload photo');
        }
      } else if (_newPhotoUrl != null) {
        // User explicitly removed photo
        photoUrlToSave = _newPhotoUrl!;
      }

      // Update Firestore
      final updateData = {
        'college': _collegeController.text.trim(),
        'name': _nameController.text.trim(),
        'branch': _branchController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'photoUrl': photoUrlToSave,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Keep existing fields
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

      // Update local data
      setState(() {
        _userData = {..._userData ?? {}, ...updateData};
        _isEditMode = false;
        _newImageFile = null;
        _newPhotoUrl = null;
      });

      if (mounted) {
        _showSuccessAnimation();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Profile updated successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Material(
          color: Colors.transparent,
          child: Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 100,
          ),
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _toggleEditMode() {
    setState(() {
      if (_isEditMode) {
        // Cancel editing - reload data
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
      photoUrl = null; // User removed photo
    }

    return GestureDetector(
      onTap: _isEditMode ? _showImageSourceDialog : null,
      child: Hero(
        tag: 'profile_photo',
        child: Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[300],
              backgroundImage: _newImageFile != null
                  ? FileImage(_newImageFile!)
                  : (photoUrl != null && photoUrl.isNotEmpty)
                      ? CachedNetworkImageProvider(photoUrl)
                      : null,
              child: (_newImageFile == null && (photoUrl == null || photoUrl.isEmpty))
                  ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                  : null,
            ),
            if (_isUploadingPhoto)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black54,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),
            if (_isEditMode && !_isUploadingPhoto)
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'Not set' : value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
    String? Function(String?)? validator,
    {TextInputType? keyboardType}
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'Profile Not Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please complete your profile to continue',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/onboarding'),
            icon: const Icon(Icons.edit),
            label: const Text('Complete Profile'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: _buildEmptyState(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEditMode,
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildProfilePhoto(),
                    const SizedBox(height: 32),
                    
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: AnimatedCrossFade(
                          duration: const Duration(milliseconds: 300),
                          crossFadeState: _isEditMode
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: Column(
                            children: [
                              _buildInfoRow('College', _userData?['college'] ?? '', Icons.school),
                              const Divider(),
                              _buildInfoRow('Name', _userData?['name'] ?? '', Icons.person),
                              const Divider(),
                              _buildInfoRow('Branch', _userData?['branch'] ?? '', Icons.class_),
                              const Divider(),
                              _buildInfoRow('Mobile', _userData?['mobile'] ?? '', Icons.phone),
                              const Divider(),
                              _buildInfoRow('Email', _userData?['email'] ?? '', Icons.email),
                            ],
                          ),
                          secondChild: Column(
                            children: [
                              _buildEditField(
                                _collegeController,
                                'College Name',
                                Icons.school,
                                (value) => value?.trim().isEmpty ?? true
                                    ? 'College name is required'
                                    : null,
                              ),
                              _buildEditField(
                                _nameController,
                                'Full Name',
                                Icons.person,
                                (value) => value?.trim().isEmpty ?? true
                                    ? 'Name is required'
                                    : null,
                              ),
                              _buildEditField(
                                _branchController,
                                'Branch',
                                Icons.class_,
                                (value) => value?.trim().isEmpty ?? true
                                    ? 'Branch is required'
                                    : null,
                              ),
                              _buildEditField(
                                _mobileController,
                                'Mobile Number',
                                Icons.phone,
                                (value) {
                                  if (value?.trim().isEmpty ?? true) {
                                    return 'Mobile number is required';
                                  }
                                  final digitsOnly = value!.replaceAll(RegExp(r'\D'), '');
                                  if (digitsOnly.length < 7 || digitsOnly.length > 15) {
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
                    
                    if (_isEditMode) ...[
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isSaving ? null : _toggleEditMode,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSaving || _isUploadingPhoto ? null : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text('Save Changes'),
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
    );
  }
}