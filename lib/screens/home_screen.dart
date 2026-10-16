import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/movie.dart';
import '../services/favorites_service.dart';
import '../services/tmdb_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _tmdbService = TmdbService();
  final _favoritesService = FavoritesService();
  late Future<List<Movie>> _moviesFuture;
  late Future<List<Movie>> _favoritesFuture;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _moviesFuture = _tmdbService.fetchPopularMovies();
    _favoritesFuture = _favoritesService.fetchFavorites();
  }

  Future<void> _toggleFavorite(Movie movie, bool isFavorite) async {
    try {
      if (isFavorite) {
        await _favoritesService.remove(movie.id);
      } else {
        await _favoritesService.add(movie);
      }
      if (mounted) {
        setState(() {
          _favoritesFuture = _favoritesService.fetchFavorites();
        });
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không thể lưu yêu thích: $error')));
    }
  }

  Future<void> _signOut() => Supabase.instance.client.auth.signOut();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CineScope', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(onPressed: _signOut, tooltip: 'Đăng xuất', icon: const Icon(Icons.logout)),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          _buildMovieTab(),
          _buildFavoritesTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Khám phá'),
          NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Yêu thích'),
        ],
      ),
    );
  }

  Widget _buildMovieTab() {
    return FutureBuilder<List<Movie>>(
      future: _moviesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return _errorState(snapshot.error.toString(), () => setState(_reload));
        final movies = snapshot.data ?? [];
        if (movies.isEmpty) return const Center(child: Text('Chưa có dữ liệu phim.'));
        return _movieList(movies);
      },
    );
  }

  Widget _buildFavoritesTab() {
    return FutureBuilder<List<Movie>>(
      future: _favoritesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) {
          return _errorState(
            'Không thể tải danh sách yêu thích.',
            () {
              setState(() {
                _favoritesFuture = _favoritesService.fetchFavorites();
              });
            },
          );
        }
        final movies = snapshot.data ?? [];
        if (movies.isEmpty) return const Center(child: Text('Bạn chưa lưu phim nào.'));
        return _movieList(movies);
      },
    );
  }

  Widget _movieList(List<Movie> movies) {
    return FutureBuilder<List<Movie>>(
      future: _favoritesFuture,
      builder: (context, favoritesSnapshot) {
        final favoriteIds = (favoritesSnapshot.data ?? []).map((movie) => movie.id).toSet();
        return RefreshIndicator(
          onRefresh: () async => setState(_reload),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return _MovieCard(movie: movie, isFavorite: favoriteIds.contains(movie.id), onFavorite: () => _toggleFavorite(movie, favoriteIds.contains(movie.id)));
            },
          ),
        );
      },
    );
  }

  Widget _errorState(String message, VoidCallback retry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.cloud_off_outlined, size: 48),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton.icon(onPressed: retry, icon: const Icon(Icons.refresh), label: const Text('Thử lại')),
        ]),
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  const _MovieCard({required this.movie, required this.isFavorite, required this.onFavorite});

  final Movie movie;
  final bool isFavorite;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 174,
        child: Row(
          children: [
            SizedBox(
              width: 116,
              height: double.infinity,
              child: movie.posterPath == null
                  ? const ColoredBox(color: Color(0xFF292E3A), child: Icon(Icons.movie_outlined, size: 36))
                  : Image.network('${TmdbService.imageBaseUrl}${movie.posterPath}', fit: BoxFit.cover, errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF292E3A), child: Icon(Icons.broken_image_outlined))),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(movie.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('${movie.releaseDate.isEmpty ? 'N/A' : movie.releaseDate.substring(0, 4)}  •  ★ ${movie.voteAverage.toStringAsFixed(1)}', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 6),
                  Expanded(child: Text(movie.overview.isEmpty ? 'Chưa có mô tả.' : movie.overview, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3))),
                  Align(alignment: Alignment.bottomRight, child: IconButton(onPressed: onFavorite, tooltip: isFavorite ? 'Bỏ yêu thích' : 'Thêm yêu thích', icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? const Color(0xFFE50914) : null))),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
