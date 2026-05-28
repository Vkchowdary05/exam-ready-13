// lib/services/cloudinary_service.dart
//
// SECURITY FIX: Cloudinary uploads now use signed URLs from Cloud Functions.
// The API Secret NO LONGER lives in the Flutter client.
//
// Upload flow:
//   1. Client calls `getUploadSignature` Cloud Function → gets signed params
//   2. Client uploads directly to Cloudinary with signed params
//   3. Cloud Function enforces rate limits (10 uploads/day)

import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:http/http.dart' as http;
import 'package:exam_ready/utils/api_error_handler.dart';
import 'package:exam_ready/utils/constants.dart';

class CloudinaryService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Upload an image file to Cloudinary using signed upload.
  ///
  /// Returns the secure URL of the uploaded image.
  /// Throws on failure with a user-friendly message.
  Future<String> uploadImage(File imageFile) async {
    // ── Validate file ──────────────────────────────────────────────
    final fileSize = imageFile.lengthSync();
    if (fileSize > AppConstants.maxFileSizeBytes) {
      final sizeMB = fileSize / (1024 * 1024);
      throw Exception(
        'File too large (${sizeMB.toStringAsFixed(1)} MB). '
        'Maximum is ${AppConstants.maxFileSizeBytes ~/ (1024 * 1024)} MB.',
      );
    }

    final extension = imageFile.path.toLowerCase().split('.').last;
    if (!['jpg', 'jpeg', 'png'].contains(extension)) {
      throw Exception('Invalid file type. Only JPG and PNG are allowed.');
    }

    try {
      // ── Step 1: Get signed upload params from Cloud Function ────
      developer.log(
        'Requesting upload signature from Cloud Function...',
        name: 'CloudinaryService',
      );

      final callable = _functions.httpsCallable(
        'getUploadSignature',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 15),
        ),
      );

      final signatureResult = await callable.call<Map<String, dynamic>>({});
      final signatureData = signatureResult.data;

      final String signature = signatureData['signature'];
      final int timestamp = signatureData['timestamp'];
      final String cloudName = signatureData['cloudName'];
      final String apiKey = signatureData['apiKey'];
      final String folder = signatureData['folder'];

      // ── Step 2: Upload to Cloudinary with signed params ─────────
      developer.log(
        'Uploading to Cloudinary (signed)...',
        name: 'CloudinaryService',
      );

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['signature'] = signature
        ..fields['timestamp'] = timestamp.toString()
        ..fields['api_key'] = apiKey
        ..fields['folder'] = folder
        ..files.add(
          await http.MultipartFile.fromPath('file', imageFile.path),
        );

      final response = await request.send().timeout(
            AppConstants.cloudinaryTimeout,
          );

      final responseBody = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        developer.log(
          'Cloudinary upload failed: ${response.statusCode} — $responseBody',
          name: 'CloudinaryService',
        );
        throw Exception('Image upload failed. Please try again.');
      }

      final data = jsonDecode(responseBody);
      final secureUrl = data['secure_url'] as String?;

      if (secureUrl == null || secureUrl.isEmpty) {
        throw Exception('Upload succeeded but no URL returned.');
      }

      developer.log(
        'Cloudinary upload successful: $secureUrl',
        name: 'CloudinaryService',
      );

      return secureUrl;
    } on FirebaseFunctionsException catch (e) {
      developer.log(
        'Cloud Function error: ${e.code} — ${e.message}',
        name: 'CloudinaryService',
        error: e,
      );

      final message = switch (e.code) {
        'unauthenticated' => 'Please log in to upload images.',
        'resource-exhausted' =>
          'Daily upload limit reached. Try again tomorrow.',
        _ => 'Image upload failed. Please try again.',
      };

      throw Exception(message);
    } catch (e) {
      developer.log(
        'CloudinaryService.uploadImage error',
        name: 'CloudinaryService',
        error: e,
      );

      if (e is Exception) rethrow;
      throw Exception(ApiErrorHandler.getReadableError(e));
    }
  }
}