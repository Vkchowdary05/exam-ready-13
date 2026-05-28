// lib/utils/sanitizer.dart

/// Centralized input sanitization and PII redaction for Exam Ready.
///
/// All user-supplied text and OCR-extracted text MUST pass through these
/// methods before being stored in Firestore or displayed in the UI.
class InputSanitizer {
  InputSanitizer._();

  // ─── PII Patterns ──────────────────────────────────────────────────

  /// Indian B.Tech roll number patterns:
  /// 20B91A0501, 185W1A0412, 22071A0535, etc.
  static final RegExp _rollPattern = RegExp(r'\b\d{2}[A-Za-z]{1,4}\d{4,5}\b');

  /// Indian mobile numbers: 10 digits starting with 6-9
  static final RegExp _phonePattern = RegExp(r'\b[6-9]\d{9}\b');

  /// Email addresses
  static final RegExp _emailPattern = RegExp(r'\b[\w.\-+]+@[\w.\-]+\.\w{2,}\b');

  /// Aadhaar-like patterns (12-digit numbers with optional spaces)
  static final RegExp _aadhaarPattern =
      RegExp(r'\b\d{4}\s?\d{4}\s?\d{4}\b');

  // ─── Script / XSS Patterns ─────────────────────────────────────────

  /// HTML tags, javascript: URIs, inline event handlers
  static final RegExp _scriptPattern =
      RegExp(r'<[^>]*>|javascript\s*:|on\w+\s*=', caseSensitive: false);

  // ─── PII Redaction ─────────────────────────────────────────────────

  /// Redact personally identifiable information from OCR-extracted text.
  ///
  /// Call this BEFORE storing `extractedText` in Firestore.
  static String redactPII(String text) {
    return text
        .replaceAll(_rollPattern, '[ROLL_NO]')
        .replaceAll(_phonePattern, '[PHONE]')
        .replaceAll(_emailPattern, '[EMAIL]')
        .replaceAll(_aadhaarPattern, '[ID_NO]');
  }

  // ─── User Input Sanitization ───────────────────────────────────────

  /// Sanitize user-supplied free-text input (search queries, doubt text,
  /// group names, etc.).
  ///
  /// - Strips HTML/script content
  /// - Trims whitespace
  /// - Enforces max length (default 500 chars)
  static String sanitizeUserInput(String input, {int maxLength = 500}) {
    String cleaned = input.replaceAll(_scriptPattern, '').trim();
    if (cleaned.length > maxLength) {
      cleaned = cleaned.substring(0, maxLength);
    }
    return cleaned;
  }

  /// Sanitize a metadata field (college, branch, subject, etc.).
  ///
  /// - Max 200 characters
  /// - Strips script content
  /// - Trims whitespace
  static String sanitizeMetadataField(String input) {
    return sanitizeUserInput(input, maxLength: 200);
  }

  // ─── Topic Sanitization ────────────────────────────────────────────

  /// Normalize and sanitize a list of extracted topics.
  ///
  /// - Trims whitespace
  /// - Converts to uppercase (consistent with Groq prompt)
  /// - Removes empty strings
  /// - Caps each topic at 100 characters
  /// - Deduplicates
  /// - Removes garbage entries (single characters, pure numbers)
  static List<String> sanitizeTopics(List<String> raw) {
    return raw
        .map((t) => t.trim().toUpperCase())
        .where((t) =>
            t.isNotEmpty &&
            t.length >= 3 &&
            t.length <= 100 &&
            !RegExp(r'^\d+$').hasMatch(t)) // reject pure numbers
        .toSet() // deduplicate
        .toList();
  }

  // ─── OCR Text Validation ───────────────────────────────────────────

  /// Estimate OCR confidence based on character composition.
  ///
  /// Returns a value between 0.0 and 1.0.
  /// - High ratio of printable alphanumeric → high confidence
  /// - High ratio of special/garbage characters → low confidence
  static double estimateOCRConfidence(String text) {
    if (text.isEmpty) return 0.0;

    final int totalChars = text.length;
    final int alphanumeric =
        RegExp(r'[a-zA-Z0-9\s]').allMatches(text).length;

    final double ratio = alphanumeric / totalChars;

    // Penalize very short extractions
    if (totalChars < 50) return ratio * 0.5;

    return ratio.clamp(0.0, 1.0);
  }

  /// Returns true if OCR confidence is acceptable for storage.
  static bool isOCRAcceptable(String text, {double threshold = 0.3}) {
    return estimateOCRConfidence(text) >= threshold;
  }
}
