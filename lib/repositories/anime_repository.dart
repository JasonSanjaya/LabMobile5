import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anime.dart';

/// Repository untuk handle semua anime data operations
/// Menggunakan Jikan API v4 dengan manual HTTP requests
/// 
/// Base URL: https://api.jikan.moe/v4
/// Rate Limit: 3 requests/second, 60 requests/minute
class AnimeRepository {
  // Base URL untuk Jikan API v4
  static const String _baseUrl = 'https://api.jikan.moe/v4';
  
  // HTTP client untuk reusability
  final http.Client _client = http.Client();

  /// Get top anime dari MyAnimeList
  /// [page] - Page number untuk pagination (default: 1)
  /// Returns list of appropriate anime for educational context
  /// 
  /// Endpoint: GET /top/anime?page={page}
  /// Response: {"data": [...], "pagination": {...}}
  Future<List<Anime>> getTopAnime({int page = 1}) async {
    try {
      // 1. Build URL dengan query parameters
      final url = Uri.parse('$_baseUrl/top/anime').replace(
        queryParameters: {'page': page.toString()},
      );

      // 2. Perform HTTP GET request
      final response = await _client.get(url);

      // 3. Check HTTP status code
      if (response.statusCode == 200) {
        // Success - parse JSON response
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        // 4. Extract 'data' array from response
        final List<dynamic> animeDataList = jsonData['data'] as List;
        
        // 5. Map JSON objects to Anime model
        final animeList = animeDataList.map((animeJson) {
          return Anime.fromJson(animeJson as Map<String, dynamic>);
        }).toList();
        
        // 6. Add delay untuk respect rate limit (3 req/sec)
        await Future.delayed(const Duration(milliseconds: 400));
        
        // 7. Apply content filtering for educational appropriateness
        return animeList.where((anime) => anime.isAppropriateContent).toList();
        
      } else if (response.statusCode == 429) {
        // Rate limit exceeded
        throw Exception('Rate limit exceeded. Please wait a moment and try again.');
      } else if (response.statusCode == 404) {
        // Not found
        throw Exception('Top anime data not found.');
      } else {
        // Other HTTP errors
        throw Exception('Failed to load top anime. Status: ${response.statusCode}');
      }
    } catch (e) {
      // Network errors or parsing errors
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Search anime by query
  /// [query] - Search term
  /// [limit] - Max results to return (default: 20)
  /// Returns filtered list appropriate for educational context
  /// 
  /// Endpoint: GET /anime?q={query}&limit={limit}
  /// Response: {"data": [...], "pagination": {...}}
  Future<List<Anime>> searchAnime(String query, {int limit = 20}) async {
    try {
      // 1. Validate input
      if (query.trim().isEmpty) {
        return [];
      }

      // 2. Build URL dengan query parameters
      final url = Uri.parse('$_baseUrl/anime').replace(
        queryParameters: {
          'q': query.trim(),
          'limit': limit.toString(),
        },
      );

      // 3. Perform HTTP GET request
      final response = await _client.get(url);

      // 4. Check HTTP status code
      if (response.statusCode == 200) {
        // Success - parse JSON response
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        // 5. Extract 'data' array from response
        final List<dynamic> animeDataList = jsonData['data'] as List;
        
        // 6. Map JSON objects to Anime model
        final animeList = animeDataList.map((animeJson) {
          return Anime.fromJson(animeJson as Map<String, dynamic>);
        }).toList();
        
        // 7. Add delay untuk respect rate limit (3 req/sec)
        await Future.delayed(const Duration(milliseconds: 400));
        
        // 8. Apply content filtering for educational appropriateness
        return animeList.where((anime) => anime.isAppropriateContent).toList();
        
      } else if (response.statusCode == 429) {
        // Rate limit exceeded
        throw Exception('Rate limit exceeded. Please wait a moment and try again.');
      } else if (response.statusCode == 404) {
        // No results found
        return [];
      } else {
        // Other HTTP errors
        throw Exception('Failed to search anime. Status: ${response.statusCode}');
      }
    } catch (e) {
      // Network errors or parsing errors
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Get anime details by MAL ID
  /// [malId] - MyAnimeList anime ID
  /// Returns full anime details including status
  /// 
  /// Endpoint: GET /anime/{malId}
  /// Response: {"data": {...}}
  Future<Anime> getAnimeById(int malId) async {
    try {
      // 1. Build URL dengan path parameter
      final url = Uri.parse('$_baseUrl/anime/$malId');

      // 2. Perform HTTP GET request
      final response = await _client.get(url);

      // 3. Check HTTP status code
      if (response.statusCode == 200) {
        // Success - parse JSON response
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        // 4. Extract 'data' object from response
        final Map<String, dynamic> animeData = jsonData['data'] as Map<String, dynamic>;
        
        // 5. Convert JSON to Anime model
        final anime = Anime.fromJson(animeData);
        
        // 6. Add delay untuk respect rate limit (3 req/sec)
        await Future.delayed(const Duration(milliseconds: 400));
        
        return anime;
        
      } else if (response.statusCode == 429) {
        // Rate limit exceeded
        throw Exception('Rate limit exceeded. Please wait a moment and try again.');
      } else if (response.statusCode == 404) {
        // Anime not found
        throw Exception('Anime with ID $malId not found.');
      } else {
        // Other HTTP errors
        throw Exception('Failed to load anime details. Status: ${response.statusCode}');
      }
    } catch (e) {
      // Network errors or parsing errors
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }
  
  /// Dispose HTTP client when repository is no longer needed
  void dispose() {
    _client.close();
  }
}