// lib/services/groq_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GroqService {
  // Groq API Key is loaded from the .env file
  static final String apiKey = dotenv.env['GROQ_API_KEY'] ?? '';

  static final _ = print('Loaded GROQ_API_KEY from .env: ($apiKey)');

  static const String apiUrl =
      "https://api.groq.com/openai/v1/chat/completions";

  // Primary + fallback models (use supported production IDs)
  final List<String> _models = [
    'llama-3.1-8b-instant', // primary (supported production model)
    'mixtral-8x7b-32768', // fallback
  ];

  Future<List<String>> extractPartBTopics(String extractedText) async {
    final payloadBase = {
      "messages": [
        {"role": "user", "content": _buildPrompt(extractedText)},
      ],
      // keep deterministic output
      "temperature": 0.1,
      "max_tokens": 512,
    };

    for (final model in _models) {
      try {
        final body = {...payloadBase, "model": model};

        print("🤖 Sending text to Groq model '$model' for topic extraction...");
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            "Authorization": "Bearer $apiKey",
            "Content-Type": "application/json",
          },
          body: jsonEncode(body),
        );

        print("📩 Groq Response Code: ${response.statusCode}");

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final text = _extractContent(data);
          print("📝 Raw model ($model) output: $text");
          final cleaned = _cleanJSON(text);
          try {
            final decoded = jsonDecode(cleaned);
            return decoded.cast<String>();
          } catch (e) {
            print(
              "⚠ JSON parse failed for model $model → fallback regex used.",
            );
            return _fallbackExtract(cleaned);
          }
        } else {
          // parse error body
          final err = _tryParse(response.body);
          final code = err?['error']?['code'];
          final message = err?['error']?['message'] ?? response.body;

          // If model was decommissioned, try next model
          if (code == 'model_decommissioned' ||
              (message as String).contains('decommissioned')) {
            print(
              "⚠ Model '$model' decommissioned or unsupported. Trying next model...",
            );
            continue; // try next model in list
          }

          // For other status codes, throw with message
          print("❌ Groq Error: $message");
          throw Exception("Groq API error: ${response.statusCode} - $message");
        }
      } catch (e) {
        // If this is the last model, surface the error; otherwise try fallback
        final isLast = model == _models.last;
        print("❌ Error calling model $model: $e");
        if (isLast) rethrow;
        // else continue to next model
      }
    }

    // if we exit loop with no success
    throw Exception("All models failed or were decommissioned.");
  }

  // Build the strict prompt
  String _buildPrompt(String text) {
    return """
Analyze the following question paper text and extract ONLY the main topics from Part B.

IMPORTANT RULES:
1) RETURN ONLY A JSON ARRAY (no explanation, no extra text).
2) EACH TOPIC MUST BE IN CAPITAL LETTERS.
3) IF A SINGLE QUESTION CONTAINS MULTIPLE TOPICS, SPLIT THEM AND RETURN EACH TOPIC AS A SEPARATE ARRAY ITEM.
4) REMOVE DUPLICATES.
5) NO NUMBERS, NO BULLETS, NO LEADING/TAILING TEXT.
6) Example: [\"MOBILE ETIQUETTE\",\"COMMUNICATION SKILLS\"]

Question paper text:
$text
""";
  }

  // Extract model-generated text from Groq response
  String _extractContent(Map<String, dynamic> data) {
    // Groq returns choices[0].message.content (similar to OpenAI)
    if (data.containsKey('choices')) {
      final c = data['choices'][0];
      if (c is Map && c.containsKey('message')) {
        final content = c['message']['content'];
        if (content is String) return content;
      }
      // older responses might have choices[0].text
      if (c is Map && c.containsKey('text')) {
        return c['text'] as String;
      }
    }
    // fallback: stringify whole response
    return jsonEncode(data);
  }

  Map<String, dynamic>? _tryParse(String s) {
    try {
      return jsonDecode(s) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // Clean fenced code blocks and simple wrappers
  String _cleanJSON(String text) {
    String s = text.trim();
    if (s.startsWith("```json")) s = s.substring(7).trimLeft();
    if (s.startsWith("```")) s = s.substring(3).trimLeft();
    if (s.endsWith("```")) s = s.substring(0, s.length - 3).trimRight();

    // Sometimes model returns text like: Output:\n["A","B"]
    // Try to find first '[' and last ']' and slice
    final firstBracket = s.indexOf('[');
    final lastBracket = s.lastIndexOf(']');
    if (firstBracket != -1 && lastBracket != -1 && lastBracket > firstBracket) {
      s = s.substring(firstBracket, lastBracket + 1);
    }
    return s.trim();
  }

  // Regex fallback extractor (extract quoted strings)
  List<String> _fallbackExtract(String text) {
    final regex = RegExp(r'"([^"]+)"');
    final matches = regex.allMatches(text);
    final topics = matches.map((m) => m.group(1)!.trim()).toList();
    // Uppercase and unique
    final normalized = topics.map((t) => t.toUpperCase()).toSet().toList();
    if (normalized.isEmpty) return ["TOPIC EXTRACTION FAILED"];
    return normalized;
  }

  // ---------------------------
  // Test helper that uses the local uploaded file path (tool will convert path -> url)
  // Replace 'documentText' with actual OCR text in production.
  // ---------------------------
  Future<void> testWithUploadedFile() async {
    final fileUrl = "/mnt/data/43e345f4-89f4-4d86-b47c-a2a07dabb004.png";
    // your system/tooling will convert this local path to a URL when making the actual request
    final testPrompt =
        "Load the image at: $fileUrl and extract Part B topics (NOT executed here).";
    try {
      final topics = await extractPartBTopics(testPrompt);
      print("Test topics: $topics");
    } catch (e) {
      print("Test failed: $e");
    }
  }

  // thin wrapper to keep naming parity with earlier service
  Future<List<String>> extractTopicsPartB(String extractedText) =>
      extractPartBTopics(extractedText);
}
