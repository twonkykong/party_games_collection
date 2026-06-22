abstract class UiSoundBackend {
  Future<void> playAsset(String assetPath, {double volume = 1});

  Future<void> dispose();
}
