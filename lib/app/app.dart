import 'package:flutter/material.dart';

import '../core/services/app_controller.dart';
import '../core/services/app_chrome_sync.dart';
import '../core/services/app_scope.dart';
import '../core/services/local_storage_service.dart';
import '../core/services/party_code_codec.dart';
import '../core/services/ui_sound_service.dart';
import '../data/repositories/alias_words_repository.dart';
import '../data/repositories/asset_json_loader.dart';
import '../data/repositories/bunker_repository.dart';
import '../data/repositories/mafia_repository.dart';
import '../data/repositories/spy_words_repository.dart';
import '../data/repositories/whoami_words_repository.dart';
import 'app_palette.dart';
import 'app_router.dart';
import 'app_theme.dart';

class PartyGamesAppBootstrap extends StatefulWidget {
  const PartyGamesAppBootstrap({super.key});

  @override
  State<PartyGamesAppBootstrap> createState() => _PartyGamesAppBootstrapState();
}

class _PartyGamesAppBootstrapState extends State<PartyGamesAppBootstrap> {
  late final AppController _controller;
  late final Future<void> _bootstrapFuture;

  @override
  void initState() {
    super.initState();
    final assetLoader = AssetJsonLoader();
    _controller = AppController(
      codec: const PartyCodeCodec(),
      storage: LocalStorageService(),
      spyRepository: SpyWordsRepository(loader: assetLoader),
      whoAmIRepository: WhoAmIWordsRepository(loader: assetLoader),
      mafiaRepository: MafiaRepository(loader: assetLoader),
      bunkerRepository: BunkerRepository(loader: assetLoader),
      aliasRepository: AliasWordsRepository(loader: assetLoader),
      uiSoundService: UiSoundService(),
    );
    _bootstrapFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        return AppScope(
          controller: _controller,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return MaterialApp(
                title: 'Сборник игр',
                debugShowCheckedModeBanner: false,
                theme: buildAppTheme(Brightness.light),
                darkTheme: buildAppTheme(Brightness.dark),
                themeMode: _controller.themePreference.themeMode,
                themeAnimationCurve: Curves.easeOutCubic,
                themeAnimationDuration: const Duration(milliseconds: 320),
                onGenerateRoute: AppRouter.onGenerateRoute,
                initialRoute: AppRouter.homePath,
                builder: (context, child) {
                  final theme = Theme.of(context);
                  final palette =
                      theme.extension<AppPalette>() ?? AppPalette.light;
                  final isLoading =
                      snapshot.connectionState != ConnectionState.done;
                  return AppChromeSync(
                    brightness: theme.brightness,
                    chromeColor: palette.backgroundTop,
                    child: Stack(
                      children: [
                        if (child != null) child,
                        if (isLoading)
                          ColoredBox(
                            color: palette.backgroundTop.withValues(alpha: 0.6),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
