import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/duration_formatter.dart';
import '../../state/player_cubit.dart';
import '../pages/player_page.dart';
import 'geometric_art.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlayerCubit>().state;
    final cubit = context.read<PlayerCubit>();
    final surah = state.current!;
    return Material(
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.cyan.withValues(alpha: 0.22), width: 1.1),
            boxShadow: [
              BoxShadow(
                color: AppColors.cyan.withValues(alpha: 0.15),
                blurRadius: 18,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ListTile(
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PlayerPage())),
            leading: GeometricArt(seed: surah.number, size: 48),
            title: Text(surah.englishName, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('${formatDuration(state.position)} / ${formatDuration(state.duration)}'),
            trailing: IconButton(
              onPressed: cubit.togglePlay,
              icon: Icon(state.playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
            ),
          ),
        ),
      ),
    );
  }
}
