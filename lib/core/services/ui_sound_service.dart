import 'ui_sound_backend_base.dart';
import 'ui_sound_backend_stub.dart'
    if (dart.library.html) 'ui_sound_backend_web.dart'
    as ui_sound_backend;

enum UiSound {
  tapSoft('tap_soft.wav'),
  toggleSoft('toggle_soft.wav'),
  pickerTick('picker_tick.wav'),
  cardReveal('card_reveal.wav'),
  cardHide('card_hide.wav'),
  successSoft('success_soft.wav'),
  errorSoft('error_soft.wav');

  const UiSound(this.fileName);

  final String fileName;
}

class UiSoundService {
  UiSoundService({UiSoundBackend? backend})
    : _backend = backend ?? ui_sound_backend.createUiSoundBackend();

  final UiSoundBackend _backend;
  bool _enabled = true;

  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  Future<void> play(UiSound sound) async {
    if (!_enabled) {
      return;
    }

    await _backend.playAsset('assets/audio/ui/${sound.fileName}', volume: 0.85);
  }

  Future<void> dispose() => _backend.dispose();
}
