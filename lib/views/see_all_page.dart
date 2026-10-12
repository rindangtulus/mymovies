import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import '../utils/constants.dart';
import 'detail_page.dart';

class SeeAllPage extends StatelessWidget {
  final String title;
  final List<Movie> movies;

  const SeeAllPage({Key? key, required this.title, required this.movies})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1A1A2E),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: movies.isEmpty
          ? Center(
              child: Text(
                'No movies available.',
                style: TextStyle(color: Colors.grey[500], fontSize: 16),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                final imageUrl = movie.posterPath.isNotEmpty
                    ? '${Constants.imageBaseUrl}${movie.posterPath}'
                    : 'https://via.placeholder.com/500x750.png?text=No+Image';

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(movie: movie),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey[300]),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.error, color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
