import 'dart:math';
import 'dart:ui';

class Vec2 {
  final double x;
  final double y;

  const Vec2(this.x, this.y);
  static const Vec2 zero = Vec2(0, 0);

  Vec2 operator +(Vec2 other) => Vec2(x + other.x, y + other.y);
  Vec2 operator -(Vec2 other) => Vec2(x - other.x, y - other.y);
  Vec2 operator *(double scalar) => Vec2(x * scalar, y * scalar);
  Vec2 operator /(double scalar) => Vec2(x / scalar, y / scalar);
  Vec2 operator -() => Vec2(-x, -y);

  double get length => sqrt(x * x + y * y);
  double get lengthSquared => x * x + y * y;

  Vec2 get normalized {
    final len = length;
    if (len == 0) return Vec2.zero;
    return Vec2(x / len, y / len);
  }

  Vec2 clampLength(double maxLength) {
    final len = length;
    if (len <= maxLength) return this;
    return normalized * maxLength;
  }

  double distanceTo(Vec2 other) => (this - other).length;

  Vec2 lerp(Vec2 target, double t) {
    return Vec2(x + (target.x - x) * t, y + (target.y - y) * t);
  }

  Offset toOffset() => Offset(x, y);

  static Vec2 fromOffset(Offset offset) => Vec2(offset.dx, offset.dy);

  static Vec2 random(Random rng, double range) {
    final angle = rng.nextDouble() * 2 * pi;
    final dist = rng.nextDouble() * range;
    return Vec2(cos(angle) * dist, sin(angle) * dist);
  }

  @override
  String toString() => 'Vec2($x, $y)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vec2 && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);
}
