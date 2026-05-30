<p align="center">
  <img src="assets/icon.png" alt="Al-quran Player Logo" width="240"/>
</p>
<p align="center">
  Quran Player
</p>

<p align="center">
  <img src="https://img.shields.io/badge/status-active-brightgreen" />
  <img src="https://img.shields.io/badge/version-1.0.0-blue" />
</p>

<p align="center">
  Quran Player is a focused Flutter audio application designed specifically for Quran memorization (Tahfidz) and repetition (Muraja'ah). It uses the public [Al-Quran Cloud API](https://alquran.cloud) to load Quran Surah metadata, fetch Arabic ayah text, and stream Mishary Rashid Alafasy recitation audio as playable tracks.
</p>
---
<p align="center">
  <img src="docs/docs1.png" style="width:90%;" />
</p>


## Features
- Search: Find Surahs by Arabic name, English name, translation, or number.
- Ayah Playback: Stream and manage audio at the verse level, making it ideal for Quran memorization (Tahfidz) and review (Muraja'ah)..
- Verse Looping: Repeat a specific ayah multiple times to help memorize.
- Text Sync: Auto-highlights and scrolls text in real-time with the audio.
- Full Controls: Previous, play, pause, next, and loop actions at the ayah level.
- Slider: Seek and view precise position with a draggable slider.
- Favorites Tab: Save favorite Surahs locally using `shared_preferences`.

## State Management

This project uses `flutter_bloc` with a single `PlayerCubit`.

`PlayerCubit` owns:

- Loading Surahs from the API.
- Loading ayah text for the selected Surah.
- Search query and tab state.
- Favorite add/remove behavior.
- Current Surah selection.
- Playback state streams: playing, position, and duration.
- Playback commands: play, pause, resume, seek, previous, next, and loop.

Widgets are intentionally kept thin. They render the current `PlayerState` and call Cubit methods for user actions.

## Main Libraries

| Package | Purpose |
| --- | --- |
| `flutter_bloc` | Required BLoC/Cubit state management |
| `http` | Fetch Surah metadata and ayah text |
| `just_audio` | Audio streaming and playback control |
| `shared_preferences` | Local favorites persistence |
| `flutter_test` | Unit and widget tests |

## Setup

Prerequisites:

- Flutter SDK installed.
- Android emulator or physical Android device.
- Internet connection for API metadata and audio streaming.

Run:

```bash
# Clone the repository
git clone https://github.com/shadeq2022/quran_player.git

# Navigate into the project folder
cd quran_player

# Get dependencies
flutter pub get

# Run the app
flutter run
```

## Screenshots
<p align="center">
  <img src="docs/docs2.png" style="width:90%;" />
</p>

## Known Limitations

- **No Offline Caching**: Audio streaming requires an active internet connection as local MP3 caching is not implemented.
- **API Dependency**: App performance and media playback rely entirely on the availability and uptime of the public Al-Quran Cloud API and CDN network.
- **Sequential Buffering**: Transition between verses depends on network speed, which may cause minor buffering gaps on slower connections.
