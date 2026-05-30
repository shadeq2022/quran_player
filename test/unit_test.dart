import 'package:flutter_test/flutter_test.dart';
import 'package:quran_player/src/core/utils/duration_formatter.dart';
import 'package:quran_player/src/models/ayah.dart';
import 'package:quran_player/src/models/surah.dart';
import 'package:quran_player/src/state/player_state.dart';

const _fatihah = Surah(
  number: 1,
  name: 'Al Fatihah Arabic',
  englishName: 'Al-Faatiha',
  translation: 'The Opening',
  ayahs: 7,
  type: 'Meccan',
);

const _baqarah = Surah(
  number: 2,
  name: 'Al Baqarah Arabic',
  englishName: 'Al-Baqara',
  translation: 'The Cow',
  ayahs: 286,
  type: 'Medinan',
);

void main() {
  test('formatDuration prints mm:ss and clamps negative values', () {
    expect(formatDuration(Duration.zero), '00:00');
    expect(formatDuration(const Duration(seconds: 9)), '00:09');
    expect(formatDuration(const Duration(minutes: 3, seconds: 5)), '03:05');
    expect(formatDuration(const Duration(seconds: -3)), '00:00');
  });

  test('Surah parses API JSON and builds audio URL', () {
    final surah = Surah.fromJson(const {
      'number': 6,
      'name': 'Al Anaam Arabic',
      'englishName': 'Al-Anaam',
      'englishNameTranslation': 'The Cattle',
      'numberOfAyahs': 165,
      'revelationType': 'Meccan',
    });

    expect(surah.number, 6);
    expect(surah.englishName, 'Al-Anaam');
    expect(surah.audioUrl, endsWith('/6.mp3'));
  });

  test('PlayerState filters by search query', () {
    final state = const PlayerState(
      loading: false,
      surahs: [_fatihah, _baqarah],
      query: 'cow',
    );

    expect(state.visibleSurahs, [_baqarah]);
  });

  test('PlayerState favorites tab only shows favorites', () {
    final state = const PlayerState(
      loading: false,
      surahs: [_fatihah, _baqarah],
      favorites: {1},
      tab: 1,
    );

    expect(state.visibleSurahs, [_fatihah]);
  });

  test('PlayerState estimates current ayah from playback progress', () {
    final state = const PlayerState(
      ayahs: [
        Ayah(numberInSurah: 1, text: 'Ayah one', audioUrl: 'https://example.com/1.mp3'),
        Ayah(numberInSurah: 2, text: 'Ayah two', audioUrl: 'https://example.com/2.mp3'),
        Ayah(numberInSurah: 3, text: 'Ayah three', audioUrl: 'https://example.com/3.mp3'),
      ],
      activeTrackIndex: 2,
    );

    expect(state.currentAyah?.numberInSurah, 2);
  });

  test('PlayerState hides a leading Bismillah track from the active ayah index', () {
    final state = const PlayerState(
      ayahs: [
        Ayah(numberInSurah: 1, text: 'Bismillah', audioUrl: 'https://example.com/bismillah.mp3'),
        Ayah(numberInSurah: 2, text: 'Ayah one', audioUrl: 'https://example.com/1.mp3'),
        Ayah(numberInSurah: 3, text: 'Ayah two', audioUrl: 'https://example.com/2.mp3'),
      ],
      hasBismillahTrack: true,
      activeTrackIndex: 1,
    );

    expect(state.currentAyah?.numberInSurah, 2);
  });
}
