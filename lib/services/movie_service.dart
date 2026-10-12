import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import '../utils/constants.dart';

class MovieService {
  Future<List<Movie>> getTrendingMovies() async {
    final response = await http.get(
      Uri.parse(
        '${Constants.baseUrl}/trending/movie/day?api_key=${Constants.apiKey}',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> results = data['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat data film terbaru');
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) return [];

    final response = await http.get(
      Uri.parse(
        '${Constants.baseUrl}/search/movie?api_key=${Constants.apiKey}&query=${Uri.encodeComponent(query)}',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> results = data['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mencari film');
    }
  }

  Future<Movie> getMovieDetail(int movieId) async {
    final response = await http.get(
      Uri.parse(
        '${Constants.baseUrl}/movie/$movieId?api_key=${Constants.apiKey}',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Movie.fromJson(data);
    } else {
      throw Exception('Gagal memuat detail film');
    }
  }
}
