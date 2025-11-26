// lib/screens/question_paper_submission_page.dart
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
import 'dart:io';
import 'dart:async';
import 'dart:developer' as developer;

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
  static const List<String> allowedExtensions = ['.jpg', '.jpeg', '.png', '.pdf'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
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
      isFormValid = selectedImage != null &&
          selectedCollege != null &&
          selectedBranch != null &&
          selectedSemester != null &&
          selectedSubject != null &&
          selectedExamType != null;
    });
  }

  /// Extract text from image using ML Kit
  Future<String> _extractTextFromImage(File imageFile) async {
    try {
      setState(() => isExtractingText = true);
      _showSnackBar('🔍 Extracting text from image...', isSuccess: true);

      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      String fullText = recognizedText.text;
      
      print('📄 Extracted ${recognizedText.blocks.length} text blocks');
      print('📝 Total text length: ${fullText.length} characters');

      if (fullText.isEmpty) {
        _showSnackBar('⚠️ No text found in image', isError: true);
        return '';
      }

      _showSnackBar(
        '✅ Extracted ${fullText.length} characters',
        isSuccess: true,
      );

      setState(() => isExtractingText = false);
      return fullText;

    } catch (e) {
      setState(() => isExtractingText = false);
      print('❌ Text extraction error: $e');
      _showSnackBar('Text extraction failed: $e', isError: true);
      return '';
    }
  }

  /// Compress image to ensure it's under 5MB
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
      _showSnackBar('🔄 Compressing image...', isSuccess: true);

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

      print('✅ Compressed image size: ${compressedSizeMB.toStringAsFixed(2)}MB');

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
          final double finalSizeMB = compressedImageFile.lengthSync() / (1024 * 1024);
          print('✅ Final compressed size: ${finalSizeMB.toStringAsFixed(2)}MB');
        }
      }

      setState(() => isCompressing = false);

      final double finalSizeMB = compressedImageFile.lengthSync() / (1024 * 1024);
      _showSnackBar(
        '✅ Compressed to ${finalSizeMB.toStringAsFixed(1)}MB',
        isSuccess: true,
      );

      return compressedImageFile;

    } catch (e) {
      setState(() => isCompressing = false);
      print('❌ Compression error: $e');
      _showSnackBar('Compression failed: $e', isError: true);
      return null;
    }
  }

  bool _validateImageFile(File file) {
    final String extension = file.path.toLowerCase().substring(file.path.lastIndexOf('.'));
    
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
          'Image selected! Size: ${finalSizeMB.toStringAsFixed(1)}MB ✓',
          isSuccess: true,
        );
      }
    } on PlatformException catch (e) {
      _showSnackBar('Failed to pick image: ${e.message ?? "Unknown error"}', isError: true);
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', isError: true);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Upload Question Paper',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your upload method',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSourceCard(
                      icon: Icons.photo_library_rounded,
                      title: 'Gallery',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSourceCard(
                      icon: Icons.camera_alt_rounded,
                      title: 'Camera',
                      gradient: const LinearGradient(
                        colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceCard({
    required IconData icon,
    required String title,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
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
        availableSubjects = subjectData[branchKey]?[value]?.cast<String>() ?? [];
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
      // Step 1: Extract text from image
      final String extractedText = await _extractTextFromImage(selectedImage!);
      if (extractedText.isEmpty) {
        throw Exception('No text could be extracted from the image');
      }

      // Step 2: Upload image to Cloudinary
      String? imageUrl;
      try {
        developer.log('Attempting to upload image to Cloudinary...',
            name: 'PaperSubmission');
        imageUrl = await _cloudinaryService.uploadImage(selectedImage!).timeout(
          const Duration(seconds: 60),
          onTimeout: () => throw TimeoutException(
              'Cloudinary upload timed out after 60 seconds'),
        );

        if (imageUrl == null || imageUrl.isEmpty) {
          throw Exception('Cloudinary returned an empty or null URL.');
        }
        developer.log('Cloudinary upload successful. URL: $imageUrl',
            name: 'PaperSubmission');
      } catch (e, s) {
        developer.log('Cloudinary upload failed.',
            name: 'PaperSubmission', error: e, stackTrace: s);
        // Re-throw to be caught by the main try-catch block and show a SnackBar
        rethrow;
      }

      // Step 3: Save to submitted-papers collection
      _showSnackBar('💾 Step 3/6: Saving to submitted-papers...',
          isSuccess: true);
      final String docId = await _firestoreService
          .submitToSubmittedPapers(
            college: selectedCollege!,
            branch: selectedBranch!,
            semester: selectedSemester!,
            subject: selectedSubject!,
            examType: selectedExamType!,
            imageUrl: imageUrl,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException('Database save timed out'),
          );

      developer.log('Submission successful. Firestore Document ID: $docId',
          name: 'PaperSubmission');

      // Step 4: Extract Part B topics using Groq
      _showSnackBar('🤖 Step 4/6: Extracting Part B topics...',
          isSuccess: true);
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
        // This might not be an error, but we can log it.
        developer.log('Warning: No topics were extracted by the Groq service.',
            name: 'PaperSubmission');
      }

      // Step 5: Save to question_papers collection with topics
      _showSnackBar('💾 Step 5/6: Saving topics to question_papers...',
          isSuccess: true);

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

      // Step 6: Update questions collection with topic frequency
      _showSnackBar('📊 Step 6/6: Updating topic frequency...',
          isSuccess: true);

      String documentName =
          '${selectedCollege}_${selectedBranch}_${selectedSemester}_${selectedSubject}_${selectedExamType}'
              .replaceAll(' ', '_')
              .toLowerCase();

      await _firestoreService
          .updateQuestionsCollection(
            documentName: documentName,
            topics: topics,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () =>
                throw TimeoutException('Questions update timed out'),
          );

      if (!mounted) return;

      setState(() => isSubmitting = false);

      _showSnackBar('✅ All steps completed successfully! Doc ID: $docId',
          isSuccess: true);
      _showSuccessDialog(extractedText.length, topics);
      _resetForm();
    } on TimeoutException catch (e, s) {
      if (!mounted) return;
      setState(() {
        isSubmitting = false;
        isExtractingTopics = false;
      });
      developer.log('A timeout occurred during submission.',
          name: 'PaperSubmission', error: e, stackTrace: s);
      _showSnackBar('⏱️ ${e.message}. Please try again.', isError: true);
    } on SocketException catch (e, s) {
      if (!mounted) return;
      setState(() {
        isSubmitting = false;
        isExtractingTopics = false;
      });
      developer.log('A network error occurred.',
          name: 'PaperSubmission', error: e, stackTrace: s);
      _showSnackBar('📡 No internet connection. Please check your network.',
          isError: true);
    } catch (e, s) {
      if (!mounted) return;
      setState(() {
        isSubmitting = false;
        isExtractingTopics = false;
      });
      developer.log('An unexpected error occurred during submission.',
          name: 'PaperSubmission', error: e, stackTrace: s);
      _showSnackBar('❌ An unexpected error occurred: ${e.toString()}',
          isError: true);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF4CAF50),
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Success!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your question paper has been:\n'
                '✓ Image uploaded to Cloudinary\n'
                '✓ Saved to submitted-papers\n'
                '✓ Text extracted ($textLength chars)\n'
                '✓ ${topics.length} Part B topics identified\n'
                '✓ Saved to question_papers\n'
                '✓ Topic frequency updated',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              if (topics.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Extracted Topics:',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...topics.take(5).map((topic) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• $topic',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      )),
                      if (topics.length > 5)
                        Text(
                          '... and ${topics.length - 5} more',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white60,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF667EEA),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
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

  void _showSnackBar(String message, {bool isError = false, bool isSuccess = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : 
              isSuccess ? Icons.check_circle_outline_rounded : 
              Icons.info_outline_rounded,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFE53935)
            : isSuccess
                ? const Color(0xFF43A047)
                : const Color(0xFF667EEA),
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
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImageUploadCard(),
                        const SizedBox(height: 32),
                        const Text(
                          'Paper Details',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildDropdown(
                          label: 'College',
                          value: selectedCollege,
                          items: collegeData.keys.toList(),
                          icon: Icons.school_rounded,
                          color: const Color(0xFF667EEA),
                          onChanged: _handleCollegeChange,
                        ),
                        _buildDropdown(
                          label: 'Branch',
                          value: selectedBranch,
                          items: availableBranches,
                          icon: Icons.account_tree_rounded,
                          color: const Color(0xFF43A047),
                          enabled: selectedCollege != null,
                          onChanged: _handleBranchChange,
                        ),
                        _buildDropdown(
                          label: 'Semester',
                          value: selectedSemester,
                          items: semesters,
                          icon: Icons.calendar_month_rounded,
                          color: const Color(0xFFFF6F00),
                          enabled: selectedBranch != null,
                          onChanged: _handleSemesterChange,
                        ),
                        _buildDropdown(
                          label: 'Subject',
                          value: selectedSubject,
                          items: availableSubjects,
                          icon: Icons.menu_book_rounded,
                          color: const Color(0xFFE91E63),
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
                          icon: Icons.assignment_rounded,
                          color: const Color(0xFF5E35B1),
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
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Submit Paper',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'AI-powered topic extraction',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadCard() {
    return GestureDetector(
      onTap: (isCompressing || isExtractingText || isExtractingTopics) ? null : _showImageSourceDialog,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 240,
        decoration: BoxDecoration(
          gradient: selectedImage == null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF667EEA).withOpacity(0.1),
                    const Color(0xFF764BA2).withOpacity(0.1),
                  ],
                )
              : null,
          color: selectedImage != null ? Colors.white : null,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selectedImage == null
                ? const Color(0xFF667EEA).withOpacity(0.3)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: selectedImage == null
                  ? const Color(0xFF667EEA).withOpacity(0.1)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: (isCompressing || isExtractingText || isExtractingTopics)
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: Color(0xFF667EEA),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isCompressing ? 'Compressing Image...' : 
                    isExtractingText ? 'Extracting Text...' : 
                    'Analyzing Topics...',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isCompressing 
                        ? 'Please wait while we optimize your image'
                        : isExtractingText
                        ? 'Reading text from the question paper'
                        : 'AI is extracting Part B topics',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              )
            : selectedImage == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667EEA).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.cloud_upload_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Upload Question Paper',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to select from gallery or camera',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF667EEA).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'AI Topic Extraction • Auto Compress',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
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
                              color: Colors.red.shade400,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Image Selected (${(selectedImage!.lengthSync() / (1024 * 1024)).toStringAsFixed(1)}MB)',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled && items.isNotEmpty
              ? () => _showDropdownMenu(label, items, value, color, onChanged)
              : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value ?? 'Select $label',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: value != null
                              ? const Color(0xFF1A1A2E)
                              : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: enabled ? color : Colors.grey[300],
                  size: 18,
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
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Select $label',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
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
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected ? color : const Color(0xFF1A1A2E),
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: color,
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 60,
      decoration: BoxDecoration(
        gradient: isFormValid
            ? const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              )
            : LinearGradient(
                colors: [Colors.grey[300]!, Colors.grey[400]!],
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isFormValid
            ? [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isFormValid && !isSubmitting ? _submitPaper : null,
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: isSubmitting
                ? const SizedBox(
                    height: 28,
                    width: 28,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isFormValid ? Icons.cloud_upload_rounded : Icons.lock_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Submit Paper',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
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