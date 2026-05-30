import '../models/ayah.dart';
import '../models/surah.dart';

/// Immutable screen/player state for the whole app.
///
/// Keeping filtering logic here makes it easy to unit test search and favorite
/// behavior without rendering widgets or touching the audio player.
class PlayerState {
  const PlayerState({
    this.surahs = const [],
    this.favorites = const {},
    this.current,
    this.ayahs = const [],
    this.hasBismillahTrack = false,
    this.activeTrackIndex = 0,
    this.loading = true,
    this.error,
    this.tab = 0,
    this.query = '',
    this.speed = 1,
    this.playing = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.loopEnabled = false,
  });

  final List<Surah> surahs;
  final Set<int> favorites;
  final Surah? current;
  final List<Ayah> ayahs;
  final bool hasBismillahTrack;
  final int activeTrackIndex;
  final bool loading;
  final String? error;
  final int tab;
  final String query;
  final double speed;
  final bool playing;
  final Duration position;
  final Duration duration;
  final bool loopEnabled;

  Ayah? get currentAyah {
    // Map current audio index to an ayah model for UI highlighting.
    final index = currentAyahIndex;
    if (index == null) {
      return null;
    }
    return visibleAyahs[index];
  }

  int? get currentAyahIndex {
    // Clamp to safe bounds in case the audio index is out of range.
    final visible = visibleAyahs;
    if (visible.isEmpty) {
      return null;
    }
    final index = activeTrackIndex;
    return index.clamp(0, visible.length - 1);
  }

  List<Ayah> get visibleAyahs {
    return ayahs;
  }

  List<Surah> get visibleSurahs {
    // Apply tab filter (all vs favorites) and query filter together.
    final lowerQuery = query.trim().toLowerCase();
    Iterable<Surah> list = tab == 1 ? surahs.where((surah) => favorites.contains(surah.number)) : surahs;
    if (lowerQuery.isNotEmpty) {
      list = list.where((surah) {
        return surah.number.toString() == lowerQuery ||
            surah.name.contains(lowerQuery) ||
            surah.englishName.toLowerCase().contains(lowerQuery) ||
            surah.translation.toLowerCase().contains(lowerQuery);
      });
    }
    return list.toList();
  }

  PlayerState copyWith({
    List<Surah>? surahs,
    Set<int>? favorites,
    Surah? current,
    List<Ayah>? ayahs,
    bool? hasBismillahTrack,
    int? activeTrackIndex,
    bool? loading,
    String? error,
    bool clearError = false,
    int? tab,
    String? query,
    double? speed,
    bool? playing,
    Duration? position,
    Duration? duration,
    bool? loopEnabled,
  }) {
    return PlayerState(
      surahs: surahs ?? this.surahs,
      favorites: favorites ?? this.favorites,
      current: current ?? this.current,
      ayahs: ayahs ?? this.ayahs,
      hasBismillahTrack: hasBismillahTrack ?? this.hasBismillahTrack,
      activeTrackIndex: activeTrackIndex ?? this.activeTrackIndex,
      loading: loading ?? this.loading,
      error: clearError ? null : error ?? this.error,
      tab: tab ?? this.tab,
      query: query ?? this.query,
      speed: speed ?? this.speed,
      playing: playing ?? this.playing,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      loopEnabled: loopEnabled ?? this.loopEnabled,
    );
  }
}
