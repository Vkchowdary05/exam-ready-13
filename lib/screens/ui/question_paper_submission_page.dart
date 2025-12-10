import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:exam_ready/data/dropdown_data.dart';
import 'package:exam_ready/services/cloudinary_service.dart';
import 'package:exam_ready/services/firestore_service.dart';
import 'package:exam_ready/services/groq_service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart'; // 👈 for kIsWeb & defaultTargetPlatform

class QuestionPaperSubmissionPage extends StatefulWidget {
  const QuestionPaperSubmissionPage({Key? key}) : super(key: key);

  @override
  State<QuestionPaperSubmissionPage> createState() =>
      _QuestionPaperSubmissionPageState();
}

class _QuestionPaperSubmissionPageState
    extends State<QuestionPaperSubmissionPage>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final FirestoreService _firestoreService = FirestoreService();
  final GroqService _chatGPTService = GroqService();
  final TextRecognizer _textRecognizer = TextRecognizer();

  File? selectedImage;
  String? selectedCollege;
  List<String> availableBranches = [];
  String? selectedBranch;
  String? selectedSemester;
  List<String> availableSubjects = [];
  String? selectedSubject;
  String? selectedExamType;
  bool isFormValid = false;
  bool isSubmitting = false;
  bool isCompressing = false;
  bool isExtractingText = false;
  bool isExtractingTopics = false;
  String extractedText = '';
  List<String> extractedTopics = [];

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const int maxFileSizeInBytes = 5 * 1024 * 1024;
  static const List<String> allowedExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.pdf',
  ];

  static const Color primaryColor = Color(0xFF6366F1);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _textRecognizer.close();
    selectedImage = null;
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      isFormValid =
          selectedImage != null &&
          selectedCollege != null &&
          selectedBranch != null &&
          selectedSemester != null &&
          selectedSubject != null &&
          selectedExamType != null;
    });
  }

  bool get _isMobilePlatform =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  /// Web opened on phone/tablet
  bool get _isMobileWeb => kIsWeb && _isMobilePlatform;

  /// Web opened on PC/laptop (Chrome, Edge, etc.)
  bool get _isDesktopWeb => kIsWeb && !_isMobilePlatform;

  Future<String> _extractTextFromImage(File imageFile) async {
    try {
      setState(() => isExtractingText = true);
      _showSnackBar('Extracting text from image...', isInfo: true);

      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      String fullText = recognizedText.text;

      print('📄 Extracted ${recognizedText.blocks.length} text blocks');
      print('📝 Total text length: ${fullText.length} characters');

      if (fullText.isEmpty) {
        _showSnackBar('No text found in image', isError: true);
        return '';
      }

      _showSnackBar('Extracted ${fullText.length} characters', isSuccess: true);

      setState(() => isExtractingText = false);
      return fullText;
    } catch (e) {
      setState(() => isExtractingText = false);
      print('❌ Text extraction error: $e');
      _showSnackBar('Text extraction failed', isError: true);
      return '';
    }
  }

  Future<File?> _compressImage(File imageFile) async {
    try {
      final int fileSize = imageFile.lengthSync();
      final double fileSizeMB = fileSize / (1024 * 1024);

      print('📸 Original image size: ${fileSizeMB.toStringAsFixed(2)}MB');

      if (fileSize <= maxFileSizeInBytes) {
        print('✅ Image already under 5MB, no compression needed');
        return imageFile;
      }

      setState(() => isCompressing = true);
      _showSnackBar('Compressing image...', isInfo: true);

      final Directory tempDir = await getTemporaryDirectory();
      final String targetPath = path.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      int quality = 85;
      if (fileSizeMB > 10) {
        quality = 60;
      } else if (fileSizeMB > 7) {
        quality = 70;
      } else if (fileSizeMB > 5) {
        quality = 80;
      }

      print('🔧 Compressing with quality: $quality%');

      XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: quality,
        minWidth: 1920,
        minHeight: 1920,
        format: CompressFormat.jpeg,
      );

      if (compressedFile == null) {
        throw Exception('Compression failed');
      }

      File compressedImageFile = File(compressedFile.path);
      final int compressedSize = compressedImageFile.lengthSync();
      final double compressedSizeMB = compressedSize / (1024 * 1024);

      print(
        '✅ Compressed image size: ${compressedSizeMB.toStringAsFixed(2)}MB',
      );

      if (compressedSize > maxFileSizeInBytes) {
        print('⚠️ Still too large, compressing more aggressively...');

        final String targetPath2 = path.join(
          tempDir.path,
          'compressed2_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        compressedFile = await FlutterImageCompress.compressAndGetFile(
          compressedImageFile.absolute.path,
          targetPath2,
          quality: 50,
          minWidth: 1600,
          minHeight: 1600,
          format: CompressFormat.jpeg,
        );

        if (compressedFile != null) {
          compressedImageFile = File(compressedFile.path);
          final double finalSizeMB =
              compressedImageFile.lengthSync() / (1024 * 1024);
          print('✅ Final compressed size: ${finalSizeMB.toStringAsFixed(2)}MB');
        }
      }

      setState(() => isCompressing = false);

      final double finalSizeMB =
          compressedImageFile.lengthSync() / (1024 * 1024);
      _showSnackBar(
        'Compressed to ${finalSizeMB.toStringAsFixed(1)}MB',
        isSuccess: true,
      );

      return compressedImageFile;
    } catch (e) {
      setState(() => isCompressing = false);
      print('❌ Compression error: $e');
      _showSnackBar('Compression failed', isError: true);
      return null;
    }
  }

  bool _validateImageFile(File file) {
    final String extension = file.path.toLowerCase().substring(
      file.path.lastIndexOf('.'),
    );

    if (extension == '.pdf') {
      final int fileSize = file.lengthSync();
      if (fileSize > maxFileSizeInBytes) {
        final double fileSizeMB = fileSize / (1024 * 1024);
        _showSnackBar(
          'PDF too large (${fileSizeMB.toStringAsFixed(1)}MB). Max: 5MB',
          isError: true,
        );
        return false;
      }
    }

    if (!allowedExtensions.contains(extension)) {
      _showSnackBar(
        'Invalid file type. Only JPG, PNG, or PDF allowed.',
        isError: true,
      );
      return false;
    }

    return true;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 100,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        if (!_validateImageFile(imageFile)) return;

        final File? compressedImage = await _compressImage(imageFile);

        if (compressedImage == null) {
          _showSnackBar('Failed to process image', isError: true);
          return;
        }

        setState(() {
          selectedImage = compressedImage;
          extractedText = '';
          extractedTopics = [];
          _validateForm();
        });

        final double finalSizeMB = compressedImage.lengthSync() / (1024 * 1024);
        _showSnackBar(
          'Image selected (${finalSizeMB.toStringAsFixed(1)}MB)',
          isSuccess: true,
        );
      }
    } on PlatformException catch (e) {
      _showSnackBar(
        'Failed to pick image: ${e.message ?? "Unknown error"}',
        isError: true,
      );
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', isError: true);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.6,
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
                Text(
                  'Upload Question Paper',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose your upload method',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 14, color: textSecondary),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSourceCard(
                          icon: Icons.photo_library_outlined,
                          title: 'Gallery',
                          color: primaryColor,
                          onTap: () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.gallery);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (!_isDesktopWeb) // 👈 hides camera on PC web
                        Expanded(
                          child: _buildSourceCard(
                            icon: Icons.camera_alt_outlined,
                            title: 'Camera',
                            color: const Color(0xFF8B5CF6),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.camera);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSourceCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.08), color.withOpacity(0.04)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: GoogleFonts.inter(
                color: textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCollegeChange(String? value) {
    setState(() {
      selectedCollege = value;
      availableBranches = collegeData[value]?.cast<String>() ?? [];
      selectedBranch = null;
      selectedSemester = null;
      availableSubjects = [];
      selectedSubject = null;
      _validateForm();
    });
  }

  void _handleBranchChange(String? value) {
    setState(() {
      selectedBranch = value;
      selectedSemester = null;
      availableSubjects = [];
      selectedSubject = null;
      _validateForm();
    });
  }

  void _handleSemesterChange(String? value) {
    setState(() {
      selectedSemester = value;
      if (selectedBranch != null && value != null) {
        String branchKey = selectedBranch!;
        if (!subjectData.containsKey(branchKey)) {
          branchKey = 'CSE';
        }
        availableSubjects =
            subjectData[branchKey]?[value]?.cast<String>() ?? [];
      }
      selectedSubject = null;
      _validateForm();
    });
  }

  Future<void> _submitPaper() async {
    if (!isFormValid) {
      _showSnackBar('Please complete all fields', isError: true);
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final String extractedText = await _extractTextFromImage(selectedImage!);
      if (extractedText.isEmpty) {
        throw Exception('No text could be extracted from the image');
      }

      String? imageUrl;
      try {
        developer.log(
          'Attempting to upload image to Cloudinary...',
          name: 'PaperSubmission',
        );
        imageUrl = await _cloudinaryService
            .uploadImage(selectedImage!)
            .timeout(
              const Duration(seconds: 60),
              onTimeout: () => throw TimeoutException(
                'Cloudinary upload timed out after 60 seconds',
              ),
            );

        if (imageUrl == null || imageUrl.isEmpty) {
          throw Exception('Cloudinary returned an empty or null URL.');
        }
        developer.log(
          'Cloudinary upload successful. URL: $imageUrl',
          name: 'PaperSubmission',
        );
      } catch (e, s) {
        developer.log(
          'Cloudinary upload failed.',
          name: 'PaperSubmission',
          error: e,
          stackTrace: s,
        );
        rethrow;
      }

      _showSnackBar('Saving to database...', isInfo: true);
      final String docId = await _firestoreService
          .submitToSubmittedPapers(
            college: selectedCollege!,
            branch: selectedBranch!,
            semester: selectedSemester!,
            subject: selectedSubject!,
            examType: selectedExamType!,
            imageUrl: imageUrl,
            // no userId needed – service handles it
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException('Database save timed out'),
          );

      developer.log(
        'Submission successful. Firestore Document ID: $docId',
        name: 'PaperSubmission',
      );

      _showSnackBar('Extracting topics...', isInfo: true);
      setState(() => isExtractingTopics = true);

      final List<String> topics = await _chatGPTService
          .extractPartBTopics(extractedText)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () =>
                throw TimeoutException('Topic extraction timed out'),
          );

      setState(() {
        extractedTopics = topics;
        isExtractingTopics = false;
      });

      if (topics.isEmpty) {
        developer.log(
          'Warning: No topics were extracted by the Groq service.',
          name: 'PaperSubmission',
        );
      }

      _showSnackBar('Saving topics...', isInfo: true);

      await _firestoreService
          .submitToQuestionPapers(
            college: selectedCollege!,
            branch: selectedBranch!,
            semester: selectedSemester!,
            subject: selectedSubject!,
            examType: selectedExamType!,
            topics: topics,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException('Database save timed out'),
          );

      _showSnackBar('Updating topic frequency...', isInfo: true);

      String documentName =
          '${selectedCollege}_${selectedBranch}_${selectedSemester}_${selectedSubject}_${selectedExamType}'
              .replaceAll(' ', '_')
              .toLowerCase();

      await _firestoreService
          .updateQuestionsCollection(documentName: documentName, topics: topics)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () =>
                throw TimeoutException('Questions update timed out'),
          );

      if (!mounted) return;

      setState(() => isSubmitting = false);

      _showSnackBar('Paper submitted successfully!', isSuccess: true);
      _showSuccessDialog(extractedText.length, topics);
      _resetForm();
    } on TimeoutException catch (e, s) {
      if (!mounted) return;
      setState(() {
        isSubmitting = false;
        isExtractingTopics = false;
      });
      developer.log(
        'A timeout occurred during submission.',
        name: 'PaperSubmission',
        error: e,
        stackTrace: s,
      );
      _showSnackBar('Request timed out. Please try again.', isError: true);
    } on SocketException catch (e, s) {
      if (!mounted) return;
      setState(() {
        isSubmitting = false;
        isExtractingTopics = false;
      });
      developer.log(
        'A network error occurred.',
        name: 'PaperSubmission',
        error: e,
        stackTrace: s,
      );
      _showSnackBar(
        'No internet connection. Please check your network.',
        isError: true,
      );
    } catch (e, s) {
      if (!mounted) return;
      setState(() {
        isSubmitting = false;
        isExtractingTopics = false;
      });
      developer.log(
        'An unexpected error occurred during submission.',
        name: 'PaperSubmission',
        error: e,
        stackTrace: s,
      );
      _showSnackBar('An unexpected error occurred', isError: true);
    }
  }

  void _resetForm() {
    setState(() {
      selectedImage = null;
      selectedCollege = null;
      availableBranches = [];
      selectedBranch = null;
      selectedSemester = null;
      availableSubjects = [];
      selectedSubject = null;
      selectedExamType = null;
      extractedText = '';
      extractedTopics = [];
      isFormValid = false;
    });
  }

  void _showSuccessDialog(int textLength, List<String> topics) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: successColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: successColor,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Success!',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your question paper has been submitted',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: textSecondary),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Column(
                  children: [
                    _buildSuccessItem(
                      'Text extracted',
                      '$textLength characters',
                    ),
                    const SizedBox(height: 8),
                    _buildSuccessItem(
                      'Topics identified',
                      '${topics.length} topics',
                    ),
                    const SizedBox(height: 8),
                    _buildSuccessItem('Database updated', 'All collections'),
                  ],
                ),
              ),
              if (topics.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Extracted Topics',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: textPrimary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...topics
                          .take(5)
                          .map(
                            (topic) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 6),
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      topic,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      if (topics.length > 5)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '+ ${topics.length - 5} more topics',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Done',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showSnackBar(
    String message, {
    bool isError = false,
    bool isSuccess = false,
    bool isInfo = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : isSuccess
                  ? Icons.check_circle_outline_rounded
                  : Icons.info_outline_rounded,
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
        backgroundColor: isError
            ? errorColor
            : isSuccess
            ? successColor
            : primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final bool isWide = width >= 900;
                final double maxContentWidth = isWide
                    ? 1100
                    : 600; // desktop/tablet vs mobile

                return Column(
                  children: [
                    _buildAppBar(
                      isWide: isWide,
                      maxContentWidth: maxContentWidth,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: maxContentWidth,
                            ),
                            child: isWide
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: _buildImageUploadCard(),
                                      ),
                                      const SizedBox(width: 32),
                                      Expanded(
                                        flex: 1,
                                        child: _buildFormSection(),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildImageUploadCard(),
                                      const SizedBox(height: 40),
                                      _buildFormSection(),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Right-side form section (used in both single column and two-column layouts)
  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paper Details',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 20),
        _buildDropdown(
          label: 'College',
          value: selectedCollege,
          items: collegeData.keys.toList(),
          icon: Icons.school_outlined,
          color: primaryColor,
          onChanged: _handleCollegeChange,
        ),
        _buildDropdown(
          label: 'Branch',
          value: selectedBranch,
          items: availableBranches,
          icon: Icons.account_tree_outlined,
          color: const Color(0xFF10B981),
          enabled: selectedCollege != null,
          onChanged: _handleBranchChange,
        ),
        _buildDropdown(
          label: 'Semester',
          value: selectedSemester,
          items: semesters,
          icon: Icons.calendar_month_outlined,
          color: const Color(0xFFF59E0B),
          enabled: selectedBranch != null,
          onChanged: _handleSemesterChange,
        ),
        _buildDropdown(
          label: 'Subject',
          value: selectedSubject,
          items: availableSubjects,
          icon: Icons.menu_book_outlined,
          color: const Color(0xFFEC4899),
          enabled: selectedSemester != null,
          onChanged: (value) {
            setState(() {
              selectedSubject = value;
              _validateForm();
            });
          },
        ),
        _buildDropdown(
          label: 'Exam Type',
          value: selectedExamType,
          items: examTypes,
          icon: Icons.assignment_outlined,
          color: const Color(0xFF8B5CF6),
          onChanged: (value) {
            setState(() {
              selectedExamType = value;
              _validateForm();
            });
          },
        ),
        const SizedBox(height: 32),
        _buildSubmitButton(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAppBar({required bool isWide, required double maxContentWidth}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: textPrimary,
                    size: 22,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Submit Paper',
                      style: GoogleFonts.inter(
                        color: textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'AI-powered topic extraction',
                      style: GoogleFonts.inter(
                        color: textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
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

  Widget _buildImageUploadCard() {
    return GestureDetector(
      onTap: (isCompressing || isExtractingText || isExtractingTopics)
          ? null
          : () {
              if (_isDesktopWeb) {
                // ✅ PC Web: only allow local file upload (no camera)
                _pickImage(ImageSource.gallery); // opens file picker on web
              } else {
                // ✅ Mobile web or mobile app: show Gallery / Camera bottom sheet
                _showImageSourceDialog();
              }
            },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 240,
        decoration: BoxDecoration(
          gradient: selectedImage == null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor.withOpacity(0.06),
                    primaryColor.withOpacity(0.03),
                  ],
                )
              : null,
          color: selectedImage != null ? cardColor : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selectedImage == null
                ? primaryColor.withOpacity(0.2)
                : borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: (isCompressing || isExtractingText || isExtractingTopics)
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: primaryColor,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isCompressing
                        ? 'Compressing Image'
                        : isExtractingText
                        ? 'Extracting Text'
                        : 'Analyzing Topics',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isCompressing
                        ? 'Optimizing your image'
                        : isExtractingText
                        ? 'Reading text from the paper'
                        : 'AI is extracting topics',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: textSecondary,
                    ),
                  ),
                ],
              )
            : selectedImage == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cloud_upload_outlined,
                      size: 48,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Upload Question Paper',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to select from gallery or camera',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: primaryColor.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'AI Topic Extraction • Auto Compress',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      selectedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedImage = null;
                          extractedText = '';
                          extractedTopics = [];
                          _validateForm();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: errorColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: errorColor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: successColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: successColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Image Selected (${(selectedImage!.lengthSync() / (1024 * 1024)).toStringAsFixed(1)}MB)',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required Color color,
    required ValueChanged<String?> onChanged,
    bool enabled = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled && items.isNotEmpty
              ? () => _showDropdownMenu(label, items, value, color, onChanged)
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.12),
                        color.withOpacity(0.06),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: textSecondary,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value ?? 'Select $label',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: value != null
                              ? textPrimary
                              : textSecondary.withOpacity(0.6),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: enabled ? color : textSecondary.withOpacity(0.3),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDropdownMenu(
    String label,
    List<String> items,
    String? currentValue,
    Color color,
    ValueChanged<String?> onChanged,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Select $label',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = item == currentValue;
                      return InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          onChanged(item);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withOpacity(0.08)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? color.withOpacity(0.2)
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected ? color : textPrimary,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: color,
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 56,
      decoration: BoxDecoration(
        color: isFormValid ? primaryColor : textSecondary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isFormValid
            ? [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isFormValid && !isSubmitting ? _submitPaper : null,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isSubmitting
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isFormValid
                            ? Icons.cloud_upload_outlined
                            : Icons.lock_outline_rounded,
                        color: isFormValid
                            ? Colors.white
                            : textSecondary.withOpacity(0.5),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Submit Paper',
                        style: GoogleFonts.inter(
                          color: isFormValid
                              ? Colors.white
                              : textSecondary.withOpacity(0.5),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
