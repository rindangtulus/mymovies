import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/movie_provider.dart';
import '../utils/constants.dart';
import 'detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      FocusManager.instance.primaryFocus?.unfocus();
      Provider.of<MovieProvider>(context, listen: false).searchMovies(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 8.0,
                  top: 6.0,
                  bottom: 6.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _performSearch(),
                        decoration: InputDecoration(
                          hintText: 'What are you looking for?',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _performSearch,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFF00A3A0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.search_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: Consumer<MovieProvider>(
                builder: (context, provider, child) {
                  if (provider.isSearching) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00A3A0),
                      ),
                    );
                  }

                  if (provider.searchResults.isEmpty) {
                    return Center(
                      child: Text(
                        'What movies?',
                        style: TextStyle(color: Colors.grey[500], fontSize: 16),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: provider.searchResults.length,
                    itemBuilder: (context, index) {
                      final movie = provider.searchResults[index];
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
                              child: const Icon(
                                Icons.error,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
