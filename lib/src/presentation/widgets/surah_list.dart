import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../state/player_cubit.dart';
import '../../state/player_state.dart';
import 'surah_tile.dart';

class SurahList extends StatelessWidget {
  const SurahList({required this.state, super.key});

  final PlayerState state;

  @override
  Widget build(BuildContext context) {
    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: context.read<PlayerCubit>().fetchSurahs, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    final list = state.visibleSurahs;
    if (list.isEmpty) {
      return Center(
        child: Text(state.tab == 1 ? 'No favorites yet. Tap the heart on any Surah.' : 'No Surah found.'),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => SurahTile(surah: list[index]),
    );
  }
}
