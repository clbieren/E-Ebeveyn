import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

final class AiRepository {
  AiRepository({required String apiKey}) : _apiKey = apiKey;

  final String _apiKey;
  static const Duration _requestTimeout = Duration(seconds: 60);

  /// [extraContext] bebek profili / aşı özeti gibi kısa bağlam metnidir (isteğe bağlı).
  Future<String> generate(
    String prompt, {
    String? extraContext,
  }) async {
    final apiKey = _apiKey.trim();
    if (apiKey.isEmpty) {
      throw Exception('Google API Hatası: API key boş');
    }

    final fullPrompt = (extraContext != null && extraContext.trim().isNotEmpty)
        ? 'Bağlam (yalnızca referans, tıbbi tanı değildir):\n${extraContext.trim()}\n\n---\n\n$prompt'
        : prompt;

    try {
      final preferredModel = 'gemini-2.5-flash';
      final initialUrl =
          _generateUrl(apiKey, preferredModel, version: 'v1beta');
      var response = await _postGenerate(initialUrl, fullPrompt);

      if (response.statusCode != 200) {
        _printApiError(initialUrl, response);
        final fallbackModel = await _findFallbackModel(apiKey);
        if (fallbackModel != null) {
          final fallbackUrl = _generateUrl(
            apiKey,
            fallbackModel,
            version: fallbackModel.startsWith('models/') ? 'v1' : 'v1beta',
          );
          response = await _postGenerate(fallbackUrl, fullPrompt);
          if (response.statusCode != 200) {
            _printApiError(fallbackUrl, response);
          }
        }

        if (response.statusCode != 200) {
          final errorMessage = _extractErrorMessage(response.body);
          if (response.statusCode == 404) {
            throw Exception(
              'Google API 404: $errorMessage. Lütfen Google Cloud Console üzerinden Generative Language API\'nin etkinleştirildiğini kontrol edin',
            );
          }
          throw Exception(
            'Google API HTTP Hatası: ${response.statusCode} body: $errorMessage',
          );
        }
      }

      return _extractText(response.body);
    } on TimeoutException catch (e) {
      throw Exception("Google API Hatası: $e");
    } on SocketException catch (e) {
      final errorText = (e.osError?.message ?? e.message).toLowerCase();
      if (errorText.contains('connection refused')) {
        throw Exception("İnternet bağlantınızı kontrol edin");
      }
      throw Exception("İnternet bağlantınızı kontrol edin");
    } catch (e) {
      throw Exception("Google API Hatası: $e");
    }
  }

  Uri _generateUrl(String apiKey, String model, {required String version}) {
    final normalizedModel =
        model.startsWith('models/') ? model : 'models/$model';
    return Uri.parse(
      'https://generativelanguage.googleapis.com/$version/$normalizedModel:generateContent?key=${apiKey.trim()}',
    );
  }

  Future<http.Response> _postGenerate(Uri url, String prompt) {
    return http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt},
                ],
              },
            ],
          }),
        )
        .timeout(_requestTimeout);
  }

  String _extractText(String body) {
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final candidates = decoded['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) return '';
    final content = candidates.first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) return '';
    final text = parts.first['text'] as String?;
    return (text ?? '').trim();
  }

  String _extractErrorMessage(String responseBody) {
    try {
      final errorJson = jsonDecode(responseBody) as Map<String, dynamic>;
      return errorJson['error']?['message']?.toString() ?? responseBody;
    } catch (_) {
      return responseBody;
    }
  }

  void _printApiError(Uri url, http.Response response) {
    print('--- GOOGLE API HATASI ---');
    print('Status Code: ${response.statusCode}');
    print('URL: $url');
    print('Body: ${response.body}');
  }

  Future<String?> _findFallbackModel(String apiKey) async {
    final candidates = <String>[
      'gemini-2.5-flash',
      'gemini-2.5-pro',
      'gemini-2.0-flash',
      'gemini-1.5-flash',
      'gemini-1.5-pro',
    ];

    final endpoints = <Uri>[
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models?key=${apiKey.trim()}',
      ),
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1/models?key=${apiKey.trim()}',
      ),
    ];

    for (final endpoint in endpoints) {
      final response = await http.get(endpoint).timeout(_requestTimeout);
      if (response.statusCode != 200) {
        _printApiError(endpoint, response);
        continue;
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final models = decoded['models'] as List<dynamic>? ?? const [];
      final available = <String>{};
      for (final model in models) {
        final item = model as Map<String, dynamic>;
        final name = item['name']?.toString() ?? '';
        final methods =
            (item['supportedGenerationMethods'] as List<dynamic>? ?? const [])
                .map((e) => e.toString())
                .toList();
        if (methods.contains('generateContent')) {
          available.add(name.replaceFirst('models/', ''));
        }
      }
      for (final candidate in candidates) {
        if (available.contains(candidate)) {
          return candidate;
        }
      }
      if (available.isNotEmpty) {
        return available.first;
      }
    }
    return null;
  }
}
