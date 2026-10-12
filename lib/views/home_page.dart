import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/movie_provider.dart';
import '../utils/constants.dart';
import '../models/movie.dart';
import 'detail_page.dart';
import 'see_all_page.dart';

const _kTeal = Color(0xFF00A3A0);
const _kTealDark = Color(0xFF007A78);
const _kBg = Color(0xFFF2F4F7);
const _kCard = Colors.white;
const _kTextPrimary = Color(0xFF1A1A2E);
const _kTextSecondary = Color(0xFF6B7280);
const _kBadgeNowPlaying = Color(0xFF00A3A0);
const _kBadgeTrending = Color(0xFFE53E3E);
const _kBadgeLegend = Color(0xFFD69E2E);

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedCategory = 0;

  final List<_CategoryTab> _categories = const [
    _CategoryTab(label: 'Trending', badge: _kBadgeTrending),
    _CategoryTab(label: 'Now Playing', badge: _kBadgeNowPlaying),
    _CategoryTab(label: 'Legends', badge: _kBadgeLegend),
    _CategoryTab(label: 'Coming Soon', badge: Color(0xFF6366F1)),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieProvider>(context, listen: false).fetchTrendingMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Consumer<MovieProvider>(
        builder: (context, movieProvider, _) {
          if (movieProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: _kTeal),
            );
          }

          final movies = movieProvider.trendingMovies;

          if (movies.isEmpty) {
            return const Center(child: Text('No movie data available.'));
          }

          final trending = movies.take(8).toList();
          final nowPlaying = movies.reversed.take(8).toList();
          final legends = movies.skip(movies.length ~/ 2).take(8).toList();
          final comingSoon = movies.skip(3).take(8).toList();

          String sectionTitle;
          Color sectionColor;
          List<Movie> sectionMovies;
          String badgeLabel;
          bool isTall = false;

          if (_selectedCategory == 1) {
            sectionTitle = 'Now Playing';
            sectionColor = _kBadgeNowPlaying;
            sectionMovies = nowPlaying;
            badgeLabel = 'NOW PLAYING';
          } else if (_selectedCategory == 2) {
            sectionTitle = 'Legendary Movies';
            sectionColor = _kBadgeLegend;
            sectionMovies = legends;
            badgeLabel = 'LEGEND';
            isTall = true;
          } else if (_selectedCategory == 3) {
            sectionTitle = 'Coming Soon';
            sectionColor = const Color(0xFF6366F1);
            sectionMovies = comingSoon;
            badgeLabel = 'SOON';
          } else {
            sectionTitle = 'Trending Now';
            sectionColor = _kBadgeTrending;
            sectionMovies = trending;
            badgeLabel = 'TRENDING';
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: Colors.white,
                elevation: 0,
                title: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _kTeal,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.movie_filter_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'MyMovies',
                      style: TextStyle(
                        color: _kTextPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: IconButton(
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: _kTextPrimary,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: Container(height: 1, color: const Color(0xFFE5E7EB)),
                ),
              ),

              SliverToBoxAdapter(child: _HeroBanner(movies: trending)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Explore Movies',
                        style: TextStyle(
                          color: _kTextPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                            _categories.length,
                            (i) => _CategoryChip(
                              tab: _categories[i],
                              isSelected: _selectedCategory == i,
                              onTap: () {
                                setState(() {
                                  _selectedCategory = i;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: _MovieSection(
                  title: sectionTitle,
                  accentColor: sectionColor,
                  movies: sectionMovies,
                  badgeLabel: badgeLabel,
                  tallCard: isTall,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }
}

class _HeroBanner extends StatefulWidget {
  final List<Movie> movies;
  const _HeroBanner({required this.movies});

  @override
  State<_HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<_HeroBanner> {
  final PageController _controller = PageController(viewportFraction: 0.92);
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bannerMovies = widget.movies.take(5).toList();

    return Column(
      children: [
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _controller,
            itemCount: bannerMovies.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, index) {
              final movie = bannerMovies[index];
              final String path =
                  (movie.backdropPath != null &&
                      movie.backdropPath.toString().isNotEmpty)
                  ? movie.backdropPath.toString()
                  : movie.posterPath.toString();
              final imageUrl = '${Constants.imageBaseUrl}$path';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(movie: movie),
                    ),
                  );
                },
                child: AnimatedScale(
                  scale: _current == index ? 1.0 : 0.96,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: const Color(0xFFE5E7EB)),
                            errorWidget: (_, __, ___) =>
                                Container(color: const Color(0xFF374151)),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.75),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 14,
                            left: 14,
                            right: 14,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _kTeal,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'NOW PLAYING',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  movie.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black54,
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            bannerMovies.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _current == i ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _current == i ? _kTeal : const Color(0xFFCBD5E0),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MovieSection extends StatelessWidget {
  final String title;
  final Color accentColor;
  final List<Movie> movies;
  final String badgeLabel;
  final bool tallCard;

  const _MovieSection({
    required this.title,
    required this.accentColor,
    required this.movies,
    required this.badgeLabel,
    this.tallCard = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardHeight = tallCard ? 230.0 : 200.0;
    final cardWidth = tallCard ? 140.0 : 130.0;

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: _kTextPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SeeAllPage(title: title, movies: movies),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: Text(
                        'See All',
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: cardHeight + 68,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                final imageUrl = '${Constants.imageBaseUrl}${movie.posterPath}';

                return _MovieCard(
                  movie: movie,
                  imageUrl: imageUrl,
                  badgeLabel: badgeLabel,
                  badgeColor: accentColor,
                  cardWidth: cardWidth,
                  cardHeight: cardHeight,
                  rank: index + 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  final Movie movie;
  final String imageUrl;
  final String badgeLabel;
  final Color badgeColor;
  final double cardWidth;
  final double cardHeight;
  final int rank;

  const _MovieCard({
    required this.movie,
    required this.imageUrl,
    required this.badgeLabel,
    required this.badgeColor,
    required this.cardWidth,
    required this.cardHeight,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailPage(movie: movie)),
        );
      },
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: cardHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: const Color(0xFFE5E7EB)),
                      errorWidget: (_, __, ___) =>
                          Container(color: const Color(0xFF374151)),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#$rank',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFFD700),
                              size: 13,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              movie.voteAverage.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _kTextPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              movie.releaseDate.length >= 4
                  ? movie.releaseDate.substring(0, 4)
                  : '',
              style: const TextStyle(color: _kTextSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTab {
  final String label;
  final Color badge;
  const _CategoryTab({required this.label, required this.badge});
}

class _CategoryChip extends StatelessWidget {
  final _CategoryTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? _kTeal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _kTeal : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _kTeal.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          tab.label,
          style: TextStyle(
            color: isSelected ? Colors.white : _kTextSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
