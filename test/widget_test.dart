import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_player/src/core/theme/app_theme.dart';
import 'package:quran_player/src/data/favorites_store.dart';
import 'package:quran_player/src/data/quran_api_service.dart';
import 'package:quran_player/src/models/surah.dart';
import 'package:quran_player/src/presentation/widgets/surah_tile.dart';
import 'package:quran_player/src/state/player_cubit.dart';

class _FakeApiService extends QuranApiService {
  @override
  Future<List<Surah>> fetchSurahs() async => const [];

  @override
  void close() {}
}

class _FakeFavoritesStore extends FavoritesStore {
  Set<int> saved = {};

  @override
  Future<Set<int>> loadFavorites() async => saved;

  @override
  Future<void> saveFavorites(Set<int> favorites) async {
    saved = favorites;
  }
}

void main() {
  testWidgets('SurahTile toggles favorite icon', (tester) async {
    final cubit = PlayerCubit(_FakeApiService(), _FakeFavoritesStore());
    const surah = Surah(
      number: 1,
      name: 'Al Fatihah Arabic',
      englishName: 'Al-Faatiha',
      translation: 'The Opening',
      ayahs: 7,
      type: 'Meccan',
    );

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(body: SurahTile(surah: surah)),
        ),
      ),
    );

    expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite_border_rounded));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    await cubit.close();
  });
}
