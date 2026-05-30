import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart' hide PlayerState;

import '../data/favorites_store.dart';
import '../data/quran_api_service.dart';
import '../models/ayah.dart';
import '../models/surah.dart';
import 'player_state.dart';

/// BLoC state-management layer for metadata, favorites, and audio controls.
///
/// The Cubit is intentionally small for the technical test, but still keeps
/// business logic outside widgets.
class PlayerCubit extends Cubit<PlayerState> {
  PlayerCubit(this._apiService, this._favoritesStore, {AudioPlayer? audioPlayer})
      : player = audioPlayer ?? AudioPlayer(),
        super(const PlayerState());

  final QuranApiService _apiService;
  final FavoritesStore _favoritesStore;
  final AudioPlayer player;
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  Future<void> init() async {
    // Wire up audio player streams to keep UI state in sync.
    _subscriptions
      ..add(player.positionStream.listen((position) => emit(state.copyWith(position: position))))
      ..add(player.durationStream.listen((duration) => emit(state.copyWith(duration: duration ?? Duration.zero))))
      ..add(player.playingStream.listen((playing) => emit(state.copyWith(playing: playing))))
      ..add(player.currentIndexStream.listen((index) {
        if (index != null) {
          emit(state.copyWith(activeTrackIndex: index));
        }
      }));

    await _loadFavorites();
    await fetchSurahs();
  }

  Future<void> _loadFavorites() async {
    emit(state.copyWith(favorites: await _favoritesStore.loadFavorites()));
  }

  Future<void> fetchSurahs() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final surahs = await _apiService.fetchSurahs();
      emit(state.copyWith(surahs: surahs, loading: false, clearError: true));
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'Could not load Surahs. Check your connection and try again.'));
    }
  }

  void setTab(int tab) => emit(state.copyWith(tab: tab));

  void search(String query) => emit(state.copyWith(query: query));

  Future<void> toggleFavorite(Surah surah) async {
    final next = <int>{...state.favorites};
    if (!next.remove(surah.number)) {
      next.add(surah.number);
    }
    await _favoritesStore.saveFavorites(next);
    emit(state.copyWith(favorites: next));
  }

  Future<void> play(Surah surah) async {
    // Reset playback-related state before loading fresh ayahs.
    emit(state.copyWith(
      current: surah,
      ayahs: const [],
      hasBismillahTrack: false,
      activeTrackIndex: 0,
      position: Duration.zero,
      duration: Duration.zero,
    ));

    final ayahs = await _loadAyahs(surah.number);
    emit(state.copyWith(ayahs: ayahs, hasBismillahTrack: false, activeTrackIndex: 0));

    // Prefer per-ayah audio list; fall back to full-surah track when needed.
    if (ayahs.isNotEmpty) {
      await player.setAudioSources(
        ayahs.map((ayah) => AudioSource.uri(Uri.parse(ayah.audioUrl))).toList(),
      );
    } else {
      await player.setAudioSource(AudioSource.uri(Uri.parse(surah.audioUrl)));
    }
    await player.setLoopMode(state.loopEnabled ? LoopMode.one : LoopMode.off);
    await player.setSpeed(state.speed);
    await player.play();
  }

  Future<List<Ayah>> _loadAyahs(int surahNumber) async {
    try {
      return await _apiService.fetchAyahs(surahNumber);
    } catch (_) {
      return const [];
    }
  }


  Future<void> togglePlay() async {
    if (player.playing) {
      await player.pause();
    } else {
      await player.play();
    }
  }

  Future<void> seek(Duration position) => player.seek(position < Duration.zero ? Duration.zero : position);

  Future<void> changeSpeed(double speed) async {
    await player.setSpeed(speed);
    emit(state.copyWith(speed: speed));
  }

  Future<void> skipPrevious() async {
    final current = state.current;
    if (current == null || state.surahs.isEmpty) {
      return;
    }
    final index = state.surahs.indexWhere((surah) => surah.number == current.number);
    if (index > 0) {
      await play(state.surahs[index - 1]);
    }
  }

  Future<void> skipNext() async {
    final current = state.current;
    if (current == null || state.surahs.isEmpty) {
      return;
    }
    final index = state.surahs.indexWhere((surah) => surah.number == current.number);
    if (index >= 0 && index < state.surahs.length - 1) {
      await play(state.surahs[index + 1]);
    }
  }

  Future<void> toggleLoop() async {
    final enabled = !state.loopEnabled;
    await player.setLoopMode(enabled ? LoopMode.one : LoopMode.off);
    emit(state.copyWith(loopEnabled: enabled));
  }

  Future<void> playAyah(int ayahIndex) async {
    if (state.ayahs.isEmpty) {
      return;
    }
    final trackIndex = ayahIndex;
    if (trackIndex < 0 || trackIndex >= state.ayahs.length) {
      return;
    }
    // Jump directly to the requested ayah and resume playback if paused.
    await player.seek(Duration.zero, index: trackIndex);
    if (!player.playing) {
      await player.play();
    }
  }

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _apiService.close();
    await player.dispose();
    return super.close();
  }
}
