/// Minimal domain model used by the UI and player state.
///
/// The API names Surahs, while the test brief says "songs"; in this app each
/// Surah is treated as a playable track.
class Surah {
  const Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.translation,
    required this.ayahs,
    required this.type,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] as int,
      name: json['name'] as String,
      englishName: json['englishName'] as String,
      translation: json['englishNameTranslation'] as String? ?? '',
      ayahs: json['numberOfAyahs'] as int,
      type: json['revelationType'] as String,
    );
  }

  final int number;
  final String name;
  final String englishName;
  final String translation;
  final int ayahs;
  final String type;

  String get audioUrl => 'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/$number.mp3';
}
