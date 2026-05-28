// lib/services/groq_service.dart
//
// SECURITY FIX: Topic extraction now goes through Cloud Functions.
// The Groq API key NO LONGER lives in the Flutter client.
//
// This service calls the `extractTopics` Cloud Function, which:
//   1. Validates the user is authenticated
//   2. Enforces rate limits (20 calls/day)
//   3. Calls Groq API server-side with the API key
//   4. Sanitizes and returns the topics

import 'dart:developer' as developer;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:exam_ready/utils/api_error_handler.dart';
import 'package:exam_ready/utils/constants.dart';

class GroqService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Extract Part B topics from OCR-extracted text via Cloud Function.
  ///
  /// Returns a list of uppercase topic strings.
  /// Throws a user-friendly exception on failure.
  Future<List<String>> extractPartBTopics(String extractedText) async {
    if (extractedText.trim().length < AppConstants.minimumOCRTextLength) {
      throw Exception(
        'Extracted text is too short (${extractedText.length} chars). '
        'Minimum ${AppConstants.minimumOCRTextLength} characters required.',
      );
    }

    // Truncate to 10,000 chars to stay within Cloud Function limits
    final truncatedText = extractedText.length > 10000
        ? extractedText.substring(0, 10000)
        : extractedText;

    try {
      developer.log(
        'Calling extractTopics Cloud Function...',
        name: 'GroqService',
      );

      final callable = _functions.httpsCallable(
        'extractTopics',
        options: HttpsCallableOptions(
          timeout: AppConstants.groqTimeout,
        ),
      );

      final result = await callable.call<Map<String, dynamic>>({
        'extractedText': truncatedText,
      });

      final data = result.data;
      final topics = (data['topics'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      developer.log(
        'Extracted ${topics.length} topics via Cloud Function',
        name: 'GroqService',
      );

      return topics;
    } on FirebaseFunctionsException catch (e) {
      developer.log(
        'Cloud Function error: ${e.code} — ${e.message}',
        name: 'GroqService',
        error: e,
      );

      // Translate to user-friendly message
      final message = switch (e.code) {
        'unauthenticated' => 'Please log in to extract topics.',
        'resource-exhausted' =>
          'Daily topic extraction limit reached. Try again tomorrow.',
        'invalid-argument' => e.message ?? 'Invalid input text.',
        _ => 'Topic extraction failed. Please try again.',
      };

      throw Exception(message);
    } catch (e) {
      developer.log(
        'Unexpected error in extractPartBTopics',
        name: 'GroqService',
        error: e,
      );
      throw Exception(ApiErrorHandler.getReadableError(e));
    }
  }

  /// Alias for backward compatibility
  Future<List<String>> extractTopicsPartB(String extractedText) =>
      extractPartBTopics(extractedText);
}
