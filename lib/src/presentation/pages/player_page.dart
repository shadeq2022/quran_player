import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/duration_formatter.dart';
import '../../state/player_cubit.dart';
import '../../state/player_state.dart';

class PlayerPage extends StatelessWidget {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlayerCubit>().state;
    final cubit = context.read<PlayerCubit>();
    final surah = state.current;
    if (surah == null) {
      return const Scaffold(body: Center(child: Text('No Surah selected')));
    }
    final maxSeconds = state.duration.inSeconds <= 0 ? 1.0 : state.duration.inSeconds.toDouble();
    final sliderValue = state.position.inSeconds.toDouble().clamp(0.0, maxSeconds);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
              child: Row(
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.keyboard_arrow_down_rounded)),
                  const Spacer(),
                  Column(
                    children: [
                      const Text('Now Playing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      Text(surah.englishName, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => cubit.toggleFavorite(surah),
                    icon: Icon(state.favorites.contains(surah.number) ? Icons.favorite_rounded : Icons.favorite_border_rounded),
                    color: state.favorites.contains(surah.number) ? AppColors.cyan : Colors.white,
                    iconSize: 24,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(width: 40, height: 40),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.purple.withValues(alpha: 0.18),
                        blurRadius: 32,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: _AyahLyricsView(state: state),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 6, 22, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white70, width: 1.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('Surah ${surah.number} - ${surah.type}', style: const TextStyle(fontSize: 15)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(surah.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
                  Text(surah.englishName, style: const TextStyle(fontSize: 16, color: AppColors.textMuted)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text(formatDuration(state.position)), Text(formatDuration(state.duration))],
                  ),
                  Slider(
                    value: sliderValue,
                    max: maxSeconds,
                    onChanged: (seconds) => cubit.seek(Duration(seconds: seconds.round())),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 42,
                        height: 42,
                        child: IconButton(
                          onPressed: cubit.skipPrevious,
                          icon: const Icon(Icons.skip_previous_rounded),
                          iconSize: 22,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: FilledButton(
                          style: FilledButton.styleFrom(shape: const CircleBorder(), backgroundColor: AppColors.purple),
                          onPressed: cubit.togglePlay,
                          child: Icon(state.playing ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 22),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 42,
                        height: 42,
                        child: IconButton(
                          onPressed: cubit.skipNext,
                          icon: const Icon(Icons.skip_next_rounded),
                          iconSize: 22,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 42,
                        height: 42,
                        child: IconButton(
                          onPressed: cubit.toggleLoop,
                          icon: Icon(state.loopEnabled ? Icons.repeat_one_rounded : Icons.repeat_rounded),
                          color: state.loopEnabled ? AppColors.cyan : Colors.white,
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AyahLyricsView extends StatefulWidget {
  const _AyahLyricsView({required this.state});

  final PlayerState state;

  @override
  State<_AyahLyricsView> createState() => _AyahLyricsViewState();
}

class _AyahLyricsViewState extends State<_AyahLyricsView> {
  final ScrollController _controller = ScrollController();
  final Map<int, GlobalKey> _itemKeys = <int, GlobalKey>{};

  @override
  void didUpdateWidget(covariant _AyahLyricsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.currentAyahIndex != widget.state.currentAyahIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActiveAyah());
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActiveAyah());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  GlobalKey _keyForIndex(int index) => _itemKeys.putIfAbsent(index, GlobalKey.new);

  void _scrollToActiveAyah() {
    final activeIndex = widget.state.currentAyahIndex;
    if (activeIndex == null || !_controller.hasClients) {
      return;
    }

    final context = _itemKeys[activeIndex]?.currentContext;
    if (context == null) {
      return;
    }

    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: 0.35,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlayerCubit>();
    final ayahs = widget.state.visibleAyahs;
    final activeIndex = widget.state.currentAyahIndex;
    final surahNumber = widget.state.current?.number ?? 0;
    if (ayahs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Loading ayahs...', style: TextStyle(color: AppColors.textMuted)),
        ),
      );
    }
    return Column(
      children: [
        const SizedBox(height: 8),
        const Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            'بِسْمِ اللَّهِ الرَّحْمٰنِ الرَّحِيمِ',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 18), color: Colors.white12),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            controller: _controller,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            physics: const BouncingScrollPhysics(),
            itemCount: ayahs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final ayah = ayahs[index];
              final isActive = activeIndex == index;
              final displayText = ayah.numberInSurah == 1 && surahNumber != 1
                ? _stripBismillah(ayah.text)
                : ayah.text;
              return AnimatedContainer(
                key: _keyForIndex(index),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => cubit.playAyah(index),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.cyan : Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _toArabicIndicDigits(ayah.numberInSurah),
                            style: TextStyle(
                              color: isActive ? AppColors.background : Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 220),
                          style: TextStyle(
                            color: isActive ? AppColors.cyan : Colors.white.withValues(alpha: 0.75),
                            fontSize: isActive ? 28 : 24,
                            height: 1.65,
                            fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                          ),
                          child: Text(displayText, textAlign: TextAlign.right),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

String _toArabicIndicDigits(int value) {
  const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return value.toString().split('').map((digit) => digits[int.parse(digit)]).join();
}

final RegExp _bismillahRegex = RegExp(
  r'\s*ب[\u064B-\u065F\u0670\u06D6-\u06ED]*\s*س[\u064B-\u065F\u0670\u06D6-\u06ED]*\s*م[\u064B-\u065F\u0670\u06D6-\u06ED]*\s*'
  r'[اٱ][\u064B-\u065F\u0670\u06D6-\u06ED]*\s*ل[\u064B-\u065F\u0670\u06D6-\u06ED]*\s*ل[\u064B-\u065F\u0670\u06D6-\u06ED]*\s*ه[\u064B-\u065F\u0670\u06D6-\u06ED]*\s*'
  r'[اٱ][\u064B-\u065F\u0670\u06D6-\u06ED]*\s*ل[\u064B-\u065F\u0670\u06D6-\u06ED]*\s*ر[\u064B-\u065F\u0670\u06D6-\u06ED]*\s*ح[\u064B-\u065F\u0670\u06D6-\u06ED]*\s*م[\u064B-\u065F\u0670\u06D6-\u06ED]*\s*ن[\u064B-\u065F\u0670\u06D6-\u06ED]*\s*'
  r'[اٱ][\u064B-\u065F\u0670\u06D6-\u06ED]*\s*ل[\u064B-\u065F\u0670\u06D6-\u06ED]*\s*ر[\u064B-\u065F\u0670\u06D6-\u06ED]*\s*ح[\u064B-\u065F\u0670\u06D6-\u06ED]*\s*ي[\u064B-\u065F\u0670\u06D6-\u06ED]*\s*م[\u064B-\u065F\u0670\u06D6-\u06ED]*\s*',
  caseSensitive: false,
);

String _stripBismillah(String text) {
  final cleaned = text.replaceAll(_bismillahRegex, ' ');
  return cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
}
