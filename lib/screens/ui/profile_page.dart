import 'dart:convert';
import 'dart:io';
import 'package:exam_ready/models/user_model.dart';
import 'package:exam_ready/services/user_service.dart';
import 'package:exam_ready/services/firebase_service.dart';
import 'package:exam_ready/widgets/modern_loading_indicator.dart';
import 'package:exam_ready/widgets/animated_scale_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();
  UserModel? _user;
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final user = FirebaseService.instance.currentUser;
    if (user != null) {
      try {
        final userModel = await _userService.getUserProfile(user.uid);
        if (mounted) {
          setState(() {
            _user = userModel;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showErrorSnackBar('Failed to fetch profile: $e');
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('User not logged in');
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      _uploadProfilePicture(File(pickedFile.path));
    }
  }

  Future<void> _uploadProfilePicture(File imageFile) async {
    if (!mounted) return;

    setState(() {
      _isUploading = true;
    });

    // Use environment variables for security
    const cloudName = 'dbtvbnqjt'; // TODO: Move to .env file
    const uploadPreset = 'exam-ready';
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    try {
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = json.decode(responseString);
        final secureUrl = jsonMap['secure_url'] as String;

        await _userService.updateUserProfilePhoto(_user!.uid, secureUrl);

        if (mounted) {
          setState(() {
            _user = _user!.copyWith(photoUrl: secureUrl);
          });
          _showSuccessSnackBar('Profile picture updated!');
        }
      } else {
        if (mounted) {
          _showErrorSnackBar('Failed to upload image');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('An error occurred: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchUserProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: ModernLoadingIndicator(
                message: 'Loading profile...',
                type: LoadingType.spinner,
              ),
            )
          : _user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('User not found'),
                  const SizedBox(height: 16),
                  AnimatedScaleButton(
                    onPressed: _fetchUserProfile,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Hero(
                        tag: 'profile_avatar',
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: _user!.photoUrl != null
                              ? NetworkImage(_user!.photoUrl!)
                              : null,
                          child: _user!.photoUrl == null
                              ? const Icon(Icons.person, size: 60)
                              : null,
                        ),
                      ),
                      if (_isUploading)
                        const Positioned.fill(
                          child: CircularProgressIndicator(),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: AnimatedScaleButton(
                          onPressed: _showImageSourceActionSheet,
                          child: Material(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(20),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _user!.displayName ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _user!.email,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 30),
                  AnimatedScaleButton(
                    onPressed: () async {
                      try {
                        await FirebaseService.instance.auth.signOut();
                        if (mounted) {
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        }
                      } catch (e) {
                        if (mounted) {
                          _showErrorSnackBar('Failed to logout: $e');
                        }
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
