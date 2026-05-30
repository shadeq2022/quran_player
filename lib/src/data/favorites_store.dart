import 'package:shared_preferences/shared_preferences.dart';

/// Persists favorite Surah numbers locally.
///
/// Only the IDs are stored because full metadata is already available from the
/// public Surah endpoint.
class FavoritesStore {
  static const _key = 'favorites';

  Future<Set<int>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? const []).map(int.parse).toSet();
  }

  Future<void> saveFavorites(Set<int> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, favorites.map((id) => '$id').toList());
  }
}
