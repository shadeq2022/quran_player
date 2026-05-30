import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/ayah.dart';
import '../models/surah.dart';

/// Small API client for the public Al-Quran Cloud endpoint.
///
/// It is injectable so tests can provide a fake client/service instead of
/// performing network calls.
class QuranApiService {
  QuranApiService({http.Client? client}) : _client = client ?? http.Client();

  static const _surahUrl = 'https://api.alquran.cloud/v1/surah';

  final http.Client _client;

  Future<List<Surah>> fetchSurahs() async {
    final response = await _client.get(Uri.parse(_surahUrl));
    if (response.statusCode != 200) {
      throw QuranApiException('API returned ${response.statusCode}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data.cast<Map<String, dynamic>>().map(Surah.fromJson).toList();
  }

  Future<List<Ayah>> fetchAyahs(int surahNumber) async {
    // Fetch per-ayah text and audio for a specific surah.
    final response = await _client.get(Uri.parse('https://api.alquran.cloud/v1/surah/$surahNumber/ar.alafasy'));
    if (response.statusCode != 200) {
      throw QuranApiException('API returned ${response.statusCode}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>;
    final ayahs = data['ayahs'] as List<dynamic>;
    return ayahs.cast<Map<String, dynamic>>().map(Ayah.fromJson).toList();
  }

  void close() => _client.close();
}

class QuranApiException implements Exception {
  const QuranApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
