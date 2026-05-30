import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../state/player_cubit.dart';
import '../../state/player_state.dart';
import '../widgets/mini_player.dart';
import '../widgets/surah_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        final cubit = context.read<PlayerCubit>();
        return Scaffold(
          appBar: AppBar(
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Al-Quran Player', style: TextStyle(fontWeight: FontWeight.w800)),
                Text('Listen & Read Along', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
            actions: [
              IconButton(onPressed: cubit.fetchSurahs, icon: const Icon(Icons.refresh_rounded)),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                child: TextField(
                  onChanged: cubit.search,
                  decoration: const InputDecoration(
                    hintText: 'Search Surah by title, translation, or number',
                    prefixIcon: Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, icon: Icon(Icons.list_rounded), label: Text('All')),
                    ButtonSegment(value: 1, icon: Icon(Icons.favorite_rounded), label: Text('Favorites')),
                  ],
                  selected: {state.tab},
                  onSelectionChanged: (value) => cubit.setTab(value.first),
                ),
              ),
              Expanded(child: SurahList(state: state)),
              if (state.current != null) const MiniPlayer(),
            ],
          ),
        );
      },
    );
  }
}
