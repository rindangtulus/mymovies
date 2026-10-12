import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';

class MovieProvider with ChangeNotifier {
  final MovieService _movieService = MovieService();

  MovieProvider() {
    loadFavorites();
  }

  List<Movie> _trendingMovies = [];
  List<Movie> get trendingMovies => _trendingMovies;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchTrendingMovies() async {
    _isLoading = true;
    notifyListeners();

    try {
      _trendingMovies = await _movieService.getTrendingMovies();
    } catch (e) {
      debugPrint('Error fetch trending: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  List<Movie> _searchResults = [];
  List<Movie> get searchResults => _searchResults;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      _searchResults = await _movieService.searchMovies(query);
    } catch (e) {
      debugPrint('Error search: $e');
    }

    _isSearching = false;
    notifyListeners();
  }

  List<Movie> _favoriteMovies = [];
  List<Movie> get favoriteMovies => _favoriteMovies;

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesString = prefs.getString('saved_favorites');
    if (favoritesString != null) {
      final List<dynamic> decodedData = json.decode(favoritesString);
      _favoriteMovies = decodedData
          .map((item) => Movie.fromJson(item))
          .toList();
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(Movie movie) async {
    final index = _favoriteMovies.indexWhere((m) => m.id == movie.id);
    if (index >= 0) {
      _favoriteMovies.removeAt(index);
    } else {
      _favoriteMovies.add(movie);
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(
      _favoriteMovies.map((m) => m.toJson()).toList(),
    );
    await prefs.setString('saved_favorites', encodedData);
  }

  bool isFavorite(int movieId) {
    return _favoriteMovies.any((m) => m.id == movieId);
  }
}
