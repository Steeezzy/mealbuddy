import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatService {
  static const String _baseUrl = "https://api.groq.com/openai/v1/chat/completions";
  static const String _apiKey = "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";
  static const String _model = "llama3-8b-8192";
  static const String _appGuidePath = 'assets/app_guide.txt';

  String _appGuideText = "";
  bool _isGuideLoaded = false;

  Future<void> loadAppGuide() async {
    try {
      _appGuideText = await rootBundle.loadString(_appGuidePath);
      _isGuideLoaded = true;
    } catch (e) {
      throw Exception('Failed to load app guide: $e');
    }
  }

  String _getRelevantGuideSection(String question) {
    if (!_isGuideLoaded) return "";
    
    final questionLower = question.toLowerCase();
    final relevantSections = _appGuideText
        .split("\n")
        .where((line) => line.toLowerCase().contains(questionLower))
        .toList();
    
    return relevantSections.join("\n");
  }

  Future<String> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) {
      throw ArgumentError('User message cannot be empty');
    }

    try {
      final guideExcerpt = _getRelevantGuideSection(userMessage);
      final response = await _sendApiRequest(userMessage, guideExcerpt);
      return _parseApiResponse(response);
    } catch (error) {
      throw Exception('Error processing message: $error');
    }
  }

  Future<http.Response> _sendApiRequest(String userMessage, String guideExcerpt) async {
    final payload = {
      "messages": [
        {
          "role": "system",
          "content": guideExcerpt.isNotEmpty
              ? "You are a meal planning assistant. Use this context: \n$guideExcerpt"
              : "You are a helpful meal planning assistant.",
        },
        {"role": "user", "content": userMessage},
      ],
      "model": _model,
    };

    try {
      return await http.post(
        Uri.parse(_baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_apiKey",
        },
        body: jsonEncode(payload),
      );
    } catch (e) {
      throw Exception('Failed to send API request: $e');
    }
  }

  String _parseApiResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception('Server returned status code ${response.statusCode}');
    }

    try {
      final responseData = jsonDecode(response.body);
      final content = responseData["choices"]?[0]["message"]["content"];
      
      if (content == null) {
        throw Exception('Invalid response format');
      }
      
      return content;
    } catch (e) {
      throw Exception('Failed to parse API response: $e');
    }
  }
}