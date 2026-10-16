class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
  });

  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String releaseDate;
  final double voteAverage;

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: (json['id'] ?? json['movie_id']) as int,
      title: (json['title'] ?? json['name'] ?? 'Untitled') as String,
      overview: (json['overview'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: (json['release_date'] ?? json['first_air_date'] ?? '') as String,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toFavoriteJson(String userId) => {
        'user_id': userId,
        'movie_id': id,
        'title': title,
        'overview': overview,
        'poster_path': posterPath,
        'backdrop_path': backdropPath,
        'release_date': releaseDate,
        'vote_average': voteAverage,
      };
}
