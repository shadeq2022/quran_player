import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'data/quran_api_service.dart';
import 'data/favorites_store.dart';
import 'presentation/pages/home_page.dart';
import 'state/player_cubit.dart';

class QuranPlayerApp extends StatelessWidget {
  const QuranPlayerApp({super.key, this.playerCubit});

  /// Optional Cubit injection keeps widget tests fast and independent from
  /// network/audio setup.
  final PlayerCubit? playerCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = playerCubit ?? PlayerCubit(QuranApiService(), FavoritesStore());
        if (playerCubit == null) {
          cubit.init();
        }
        return cubit;
      },
      child: MaterialApp(
        title: 'Quran Player',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const HomePage(),
      ),
    );
  }
}
