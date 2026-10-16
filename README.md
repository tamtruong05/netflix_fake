# CineScope

Ung dung Flutter cho Lab 7 + 8:

- Dang ky va dang nhap bang Supabase Auth.
- Lay phim trending that tu TMDB bang `http` va `FutureBuilder`.
- Parse JSON qua `Movie.fromJson`.
- Luu/xoa phim yeu thich theo dung tai khoan Supabase.
- Co trang thai loading, loi, retry, empty state va pull-to-refresh.

## Chay ung dung

TMDB khong dung anon key cua Supabase. Tao API key tai TMDB roi chay:

```bash
flutter pub get
flutter run --dart-define=TMDB_API_KEY=8cd98b4e069d8dceb4b4fed1222eb6dd
```

## Tao bang favorites tren Supabase

Mo SQL Editor trong project Supabase va chay:

```sql
create table public.favorites (
  user_id uuid not null references auth.users(id) on delete cascade,
  movie_id integer not null,
  title text not null,
  overview text not null default '',
  poster_path text,
  backdrop_path text,
  release_date text not null default '',
  vote_average double precision not null default 0,
  created_at timestamptz not null default now(),
  primary key (user_id, movie_id)
);

alter table public.favorites enable row level security;

create policy "Users can read their favorites"
  on public.favorites for select
  using (auth.uid() = user_id);

create policy "Users can add their favorites"
  on public.favorites for insert
  with check (auth.uid() = user_id);

create policy "Users can update their favorites"
  on public.favorites for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can delete their favorites"
  on public.favorites for delete
  using (auth.uid() = user_id);
```

Neu bat email confirmation trong Supabase, nguoi dung can bam link xac nhan truoc khi dang nhap.
