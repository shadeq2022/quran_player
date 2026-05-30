import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../models/surah.dart';
import '../../state/player_cubit.dart';

class SurahTile extends StatelessWidget {
  const SurahTile({required this.surah, super.key});

  final Surah surah;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlayerCubit>().state;
    final cubit = context.read<PlayerCubit>();
    final favorite = state.favorites.contains(surah.number);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => cubit.play(surah),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: surah.type == 'Meccan' ? AppColors.gold : AppColors.cyan,
                foregroundColor: Colors.black,
                child: Text('${surah.number}', style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(surah.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                    Text(
                      '${surah.englishName} - ${surah.ayahs} ayahs - ${surah.type}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => cubit.toggleFavorite(surah),
                icon: Icon(favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded),
                color: favorite ? AppColors.cyan : AppColors.textMuted,
              ),
              IconButton(onPressed: () => cubit.play(surah), icon: const Icon(Icons.play_arrow_rounded)),
            ],
          ),
        ),
      ),
    );
  }
}
