import 'dart:ui';

import 'package:void_surge/features/game/models/vec2.dart';

class GameCamera {
  final Vec2 center;
  final double zoom;
  final Size viewportSize;

  const GameCamera({
    this.center = Vec2.zero,
    this.zoom = 2.5,
    this.viewportSize = Size.zero,
  });

  Offset worldToScreen(Vec2 worldPos) {
    final dx = (worldPos.x - center.x) * zoom + viewportSize.width / 2;
    final dy = (worldPos.y - center.y) * zoom + viewportSize.height / 2;
    return Offset(dx, dy);
  }

  Vec2 screenToWorld(Offset screenPos) {
    final x = (screenPos.dx - viewportSize.width / 2) / zoom + center.x;
    final y = (screenPos.dy - viewportSize.height / 2) / zoom + center.y;
    return Vec2(x, y);
  }

  Rect get visibleWorldRect {
    final halfW = viewportSize.width / 2 / zoom;
    final halfH = viewportSize.height / 2 / zoom;
    return Rect.fromLTRB(
      center.x - halfW,
      center.y - halfH,
      center.x + halfW,
      center.y + halfH,
    );
  }

  GameCamera copyWith({
    Vec2? center,
    double? zoom,
    Size? viewportSize,
  }) {
    return GameCamera(
      center: center ?? this.center,
      zoom: zoom ?? this.zoom,
      viewportSize: viewportSize ?? this.viewportSize,
    );
  }
}
