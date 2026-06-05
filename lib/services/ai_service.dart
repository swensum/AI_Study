// lib/services/ai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
 
   static String get apiKey {
    final key = dotenv.env['GROQ_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('GROQ_API_KEY not found in .env file');
    }
    return key;
  }
  
  static const String baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  
  static const String model = "llama-3.1-8b-instant"; // Fast & free
  
  static Future<String> sendMessage(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {
              'role': 'system',
              'content': '''You are a helpful study assistant. Follow these formatting rules:
- Use **bold text** for important terms, key concepts, and headings
- Use *italic text* for emphasis, examples, and definitions
- Use clear paragraph breaks between different topics
- Use numbered lists (1. 2. 3.) for steps or sequences
- Use bullet points (- ) for listing items
- Keep explanations clear, well-structured, and educational
- Always format your responses for readability'''
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        // Handle specific errors
        final errorData = jsonDecode(response.body);
        final errorMsg = errorData['error']['message'] ?? 'Unknown error';
        return 'API Error: $errorMsg';
      }
    } catch (e) {
      return 'Connection error: Please check your internet connection.';
    }
  }
  
  static Future<String> summarizeText(String text) async {
    final prompt = '''Please summarize the following text clearly. Format your summary with:
- **Bold** for main topics
- *Italics* for key examples
- Bullet points for important points

Text to summarize:
$text''';
    return await sendMessage(prompt);
  }
  
  // Optional: Test API connection
  static Future<bool> testConnection() async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {'role': 'user', 'content': 'Say "connected" if you can read this.'}
          ],
          'max_tokens': 10,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}