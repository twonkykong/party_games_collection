import 'package:audioplayers/audioplayers.dart';

import 'ui_sound_backend_base.dart';

UiSoundBackend createUiSoundBackend() => _PooledAudioPlayersBackend();

class _PooledAudioPlayersBackend implements UiSoundBackend {
  final Map<String, List<AudioPlayer>> _playerPools = {};
  final Map<String, int> _nextPlayerIndex = {};

  @override
  Future<void> playAsset(String assetPath, {double volume = 1}) async {
    final pool = _playerPools.putIfAbsent(assetPath, () {
      return List<AudioPlayer>.generate(6, (_) {
        final player = AudioPlayer();
        player.setPlayerMode(PlayerMode.lowLatency);
        player.setReleaseMode(ReleaseMode.stop);
        return player;
      });
    });

    final nextIndex = (_nextPlayerIndex[assetPath] ?? 0) % pool.length;
    _nextPlayerIndex[assetPath] = nextIndex + 1;
    final player = pool[nextIndex];

    try {
      await player.seek(Duration.zero);
      await player.play(
        AssetSource(assetPath.replaceFirst('assets/', '')),
        volume: volume,
      );
    } catch (_) {
      // UI sounds are best-effort only and must never break app flow.
    }
  }

  @override
  Future<void> dispose() async {
    for (final pool in _playerPools.values) {
      for (final player in pool) {
        await player.dispose();
      }
    }
    _playerPools.clear();
    _nextPlayerIndex.clear();
  }
}
