import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SfxType {
  absorb,
  absorbLarge,
  absorbHuge,
  gameOver,
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});

class AudioService {
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _bgmPlaying = false;

  static const _sfxAssets = {
    SfxType.absorb: 'audio/absorb.mp3',
    SfxType.absorbLarge: 'audio/absorb_large.mp3',
    SfxType.absorbHuge: 'audio/absorb_huge.mp3',
    SfxType.gameOver: 'audio/game_over.mp3',
  };

  Future<void> playBgm() async {
    if (_bgmPlaying) return;
    try {
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(0.5);
      await _bgmPlayer.play(AssetSource('audio/bgm.mp3'));
      _bgmPlaying = true;
    } catch (e) {
      debugPrint('BGM play failed (asset may be missing): $e');
    }
  }

  Future<void> stopBgm() async {
    if (!_bgmPlaying) return;
    try {
      await _bgmPlayer.stop();
    } catch (e) {
      debugPrint('BGM stop failed: $e');
    }
    _bgmPlaying = false;
  }

  Future<void> playSfx(SfxType type) async {
    final asset = _sfxAssets[type];
    if (asset == null) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(asset));
    } catch (e) {
      debugPrint('SFX play failed (asset may be missing): $e');
    }
  }

  static SfxType sfxTypeForMass(double mass) {
    if (mass < 5.0) return SfxType.absorb;
    if (mass < 10.0) return SfxType.absorbLarge;
    return SfxType.absorbHuge;
  }

  void dispose() {
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
