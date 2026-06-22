import 'dart:js_interop';

import 'package:flutter/services.dart';
import 'package:web/web.dart' as web;

import 'ui_sound_backend_base.dart';

UiSoundBackend createUiSoundBackend() => _WebAudioUiSoundBackend();

class _WebAudioUiSoundBackend implements UiSoundBackend {
  web.AudioContext? _context;
  final Map<String, Future<web.AudioBuffer>> _bufferLoads = {};

  web.AudioContext get _audioContext => _context ??= web.AudioContext();

  @override
  Future<void> playAsset(String assetPath, {double volume = 1}) async {
    try {
      final context = _audioContext;
      if (context.state == 'suspended') {
        await context.resume().toDart;
      }

      final buffer = await _loadBuffer(assetPath);
      final source = context.createBufferSource();
      source.buffer = buffer;

      final gain = context.createGain();
      gain.gain.value = volume;

      source.connect(gain);
      gain.connect(context.destination);
      source.start(0);

      Future<void>.delayed(
        Duration(milliseconds: (buffer.duration * 1000).ceil() + 120),
      ).then((_) {
        source.disconnect();
        gain.disconnect();
      });
    } catch (_) {
      // UI sounds are best-effort only and must never break app flow.
    }
  }

  Future<web.AudioBuffer> _loadBuffer(String assetPath) {
    return _bufferLoads.putIfAbsent(assetPath, () async {
      final data = await rootBundle.load(assetPath);
      final copiedBytes = Uint8List.fromList(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      return _audioContext.decodeAudioData(copiedBytes.buffer.toJS).toDart;
    });
  }

  @override
  Future<void> dispose() async {
    await _context?.close().toDart;
    _context = null;
    _bufferLoads.clear();
  }
}
