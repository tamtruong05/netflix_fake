import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/movie.dart';

class FavoritesService {
  FavoritesService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<Movie>> fetchFavorites() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    final rows = await _client
        .from('favorites')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    return (rows as List<dynamic>)
        .map((row) => Movie.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> add(Movie movie) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Phiên đăng nhập đã hết hạn');
    await _client.from('favorites').upsert(movie.toFavoriteJson(user.id));
  }

  Future<void> remove(int movieId) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client
        .from('favorites')
        .delete()
        .eq('user_id', user.id)
        .eq('movie_id', movieId);
  }
}
