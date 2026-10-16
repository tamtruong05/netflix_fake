import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/movie.dart';

class TmdbService {
  TmdbService({http.Client? client}) : _client = client ?? http.Client();

  static const _apiKey = String.fromEnvironment('TMDB_API_KEY');
  static const _baseUrl = 'https://api.themoviedb.org/3';
  static const imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  final http.Client _client;

  Future<List<Movie>> fetchPopularMovies() async {
    if (_apiKey.isEmpty) {
      throw Exception(
        'Thiếu TMDB API key. Chạy app với --dart-define=TMDB_API_KEY=your_key',
      );
    }
    final uri = Uri.parse(
      '$_baseUrl/trending/movie/week?api_key=$_apiKey&language=vi-VN',
    );
    final response = await _client.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('TMDB trả về lỗi ${response.statusCode}');
    }
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final results = decoded['results'] as List<dynamic>? ?? [];
    return results
        .map((item) => Movie.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
